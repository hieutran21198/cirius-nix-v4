{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.services.syncthing =
    let
      inherit (lib.${namespace})
        makeStrOption
        makeIntOption
        makePathOption
        makeAttrsOption
        ;
    in
    {
      enable = lib.mkEnableOption "Enable syncthing";
      port = makeIntOption {
        default = 2002;
        description = "The port on which the syncthing web UI will be available.";
      };
      username = makeStrOption {
        default = "";
        description = "The username for the syncthing web UI.";
      };
      passwordFile = makePathOption {
        description = "The path to the password file for the syncthing web UI.";
      };
      devices = makeAttrsOption {
        ofType = lib.types.json;
        default = { };
        description = "A set of devices to be used by syncthing. Each device should have an id attribute.";
      };
      folders = makeAttrsOption {
        ofType = lib.types.json;
        default = { };
        description = "A set of folders to be synced by syncthing. Each folder should have an id attribute and a devices attribute which is a list of device ids.";
      };
    };

  config =
    let
      opts = config.${namespace}.services.syncthing;
    in
    lib.mkIf opts.enable {
      services.syncthing = {
        enable = true;
        guiAddress = "http://127.0.0.1:${toString opts.port}";
        guiCredentials = {
          inherit (opts) username passwordFile;
        };
        package = pkgs.syncthing;
        settings = {
          gui = {
            theme = lib.mkDefault "black";
          };
          inherit (opts) devices folders;
        };
      };
    };
}
