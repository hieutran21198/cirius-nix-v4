{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.services.music-server =
    let
      inherit (lib.${namespace})
        makeStrOption
        makeIntOption
        makePathOption
        ;
    in
    {
      enable = lib.mkEnableOption "Enable music server";
      port = makeIntOption {
        default = 4533;
        description = "The port on which the music server will be available.";
      };
      envFile = makePathOption {
        description = "The path to the environment file for the music server.";
      };
      group = makeStrOption {
        default = "music-server";
        description = "The group for the music server.";
      };
      musicDir = makeStrOption {
        description = "The path to the music directory.";
      };
    };
  config =
    let
      opts = config.${namespace}.services.music-server;
    in
    lib.mkIf opts.enable {
      ${namespace}.infra.iam.groups = {
        "${opts.group}" = { };
      };
      services.navidrome = {
        enable = true;
        environmentFile = opts.envFile;
        openFirewall = true;
        inherit (opts) group;
        settings = {
          Port = opts.port;
          Address = "0.0.0.0";
          Plugins = { };
          MusicFolder = opts.musicDir;
        };
      };
    };
}
