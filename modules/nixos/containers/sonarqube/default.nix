{
  config,
  namespace,
  lib,
  host,
  ...
}:
{
  options.${namespace}.containers.sonarqube =
    let
      inherit (lib.${namespace}) makeListOption makeIntOption makeStrOption;
      subDomain = "sonarqube";
    in
    {
      enable = lib.mkEnableOption "Enable sonarqube";
      port = makeIntOption {
        default = 2001;
        description = "Port to be used by the container";
      };
      iam = {
        group = makeStrOption {
          default = "sonarqube";
          description = "Group to be used by the container";
        };
      };
      virtualHost = makeStrOption {
        default = "${subDomain}.${host}";
        description = "Virtual host to be used by the container";
      };
      version = makeStrOption {
        default = "community";
        description = "Version of sonarqube to be used by the container";
      };
      dependsOn = makeListOption {
        ofType = lib.types.str;
        default = [ ];
        description = "List of containers that depends on";
      };
      environmentFiles = makeListOption {
        ofType = lib.types.path;
        default = [ ];
        description = "List of environment files to be used by the container";
      };
      dataDir = makeStrOption {
        default = "/var/lib/sonarqube";
        description = "Directory to be used by the container to store state";
      };
      logDir = makeStrOption {
        default = "/var/log/sonarqube";
        description = "Directory to be used by the container to store logs";
      };
      extensionsDir = makeStrOption {
        default = "/var/lib/sonarqube/extensions";
        description = "Directory to be used by the container to store extensions";
      };
    };

  config =
    let
      opts = config.${namespace}.containers.sonarqube;
    in
    lib.mkMerge [
      # IAM configuration for sonarqube container
      (lib.mkIf opts.enable {
        ${namespace}.infra.iam = {
          groups = {
            "${opts.iam.group}" = {
              gid = 991;
            };
          };
        };

        # 2770; bit 2 is setgid directory
        systemd.tmpfiles.rules = [
          "d ${opts.dataDir} 2770 root ${opts.iam.group} -"
          "d ${opts.logDir} 2770 root ${opts.iam.group} -"
          "d ${opts.extensionsDir} 2770 root ${opts.iam.group} -"
        ];
      })

      # configuration for sonarqube container
      (lib.mkIf opts.enable {
        virtualisation.oci-containers.containers = {
          sonarqube = {
            image = "sonarqube:${opts.version}";
            ports = [ "127.0.0.1:${toString opts.port}:9000" ];
            extraOptions = [
              "--group-add=${toString config.users.groups.${opts.iam.group}.gid}"
            ];
            volumes = [
              "${opts.extensionsDir}:/opt/sonarqube/extensions"
              "${opts.dataDir}:/opt/sonarqube/data"
              "${opts.logDir}:/opt/sonarqube/logs"
            ];
            inherit (opts) dependsOn environmentFiles;
          };
        };
      })

      # Networking configuration for sonarqube container
      (lib.mkIf opts.enable {
        ${namespace}.infra.networking = {
          hosts."127.0.0.1" = [ opts.virtualHost ];
          virtualHosts.${opts.virtualHost}.extraConfig = ''
            tls internal
            reverse_proxy 127.0.0.1:${toString opts.port}
          '';
        };
      })
    ];
}
