{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.containers.dockhand =
    let
      inherit (lib.${namespace}) makeListOption makeIntOption makeStrOption;
    in
    {
      enable = lib.mkEnableOption "Enable dockhand";
      port = makeIntOption {
        default = 2000;
        description = "Port to be used by the container";
      };
      version = makeStrOption {
        default = "8d7ce9eb-baseline";
        description = "Version of dockhand to be used by the container";
      };
      dependsOn = makeListOption {
        ofType = lib.types.str;
        default = [ ];
        description = "List of containers that dockhand depends on";
      };
      environmentFiles = makeListOption {
        ofType = lib.types.path;
        default = [ ];
        description = "List of environment files to be used by the container";
      };
      dataDir = makeStrOption {
        default = "/var/lib/dockhand";
        description = "Directory to be used by the container to store state";
      };
    };

  config =
    let
      opts = config.${namespace}.containers.dockhand;
    in
    lib.mkIf opts.enable {
      systemd.tmpfiles.rules = [
        "d ${opts.dataDir} 0755 root root -"
      ];

      virtualisation.oci-containers.containers = {
        dockhand = {
          image = "fnsys/dockhand:${opts.version}";
          ports = [ "127.0.0.1:${toString opts.port}:3000" ];
          volumes = [
            "/run/podman/podman.sock:/var/run/docker.sock"
            "${opts.dataDir}:/app/data"
          ];
          inherit (opts) dependsOn environmentFiles;
        };
      };

      systemd.services.podman-dockhand = {
        requires = [ "podman.socket" ];

        after = [
          "podman.socket"
          "network-online.target"
        ];

        wants = [ "network-online.target" ];

        serviceConfig = {
          Restart = lib.mkForce "on-failure";
          RestartSec = "5s";
        };

        unitConfig = {
          StartLimitIntervalSec = "60s";
          StartLimitBurst = 10;
        };
      };
    };
}
