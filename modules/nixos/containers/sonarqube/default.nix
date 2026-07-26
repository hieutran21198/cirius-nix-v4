{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.containers.sonarqube =
    let
      inherit (lib.${namespace}) makeListOption makeIntOption makeStrOption;
    in
    {
      enable = lib.mkEnableOption "Enable sonarqube";
      port = makeIntOption {
        default = 2001;
        description = "Port to be used by the container";
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
    lib.mkIf opts.enable {
      systemd.tmpfiles.rules = [
        "d ${opts.dataDir} 0750 1000 0 -"
        "d ${opts.logDir} 0750 1000 0 -"
        "d ${opts.extensionsDir} 0750 1000 0 -"
      ];

      virtualisation.oci-containers.containers = {
        sonarqube = {
          image = "sonarqube:${opts.version}";
          ports = [ "127.0.0.1:${toString opts.port}:9000" ];
          volumes = [
            "${opts.extensionsDir}:/opt/sonarqube/extensions"
            "${opts.dataDir}:/opt/sonarqube/data"
            "${opts.logDir}:/opt/sonarqube/logs"
          ];
          inherit (opts) dependsOn environmentFiles;
        };
      };
    };
}
