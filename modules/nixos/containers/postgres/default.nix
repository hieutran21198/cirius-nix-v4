{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.containers.postgres =
    let
      inherit (lib.${namespace}) makeListOption makeAttrsOption makeIntOption;
    in
    {
      enable = lib.mkEnableOption "Enable postgres";
      databases = makeAttrsOption {
        ofType =
          with lib.types;
          (submodule {
            options = {
              port = makeIntOption {
                default = 5432;
                description = "Port to be used by the container";
              };
              environmentFiles = makeListOption {
                ofType = lib.types.path;
                default = [ ];
                description = "List of environment files to be used by the container";
              };
            };
          });
        default = { };
      };

    };

  config =
    let
      opts = config.${namespace}.containers.postgres;
      containers = lib.mapAttrs' (
        name: db:
        lib.nameValuePair "postgres-${name}" {
          image = "postgres:18-alpine";
          ports = [ "127.0.0.1:${toString db.port}:5432" ];
          volumes = [ "/var/lib/postgres-${name}:/var/lib/postgresql" ];
          inherit (db) environmentFiles;
        }
      ) opts.databases;
    in
    lib.mkIf opts.enable {
      systemd.tmpfiles.rules = lib.mapAttrsToList (
        name: _: "d /var/lib/postgres-${name} 0700 70 70 -"
      ) opts.databases;

      virtualisation.oci-containers = {
        inherit containers;
      };
    };
}
