{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.infra.wsl = {
    enable = lib.mkEnableOption "Enable WSL support for this system";
    defaultUser = lib.mkOption {
      type = lib.types.str;
      default = "cirius";
      description = "The default user for WSL.";
    };
    enableDockerDesktop = lib.mkEnableOption "Enable Docker Desktop support for this system";
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "mht-win-home-pc";
      description = "The hostname for WSL.";
    };
    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Additional settings for WSL.";
    };
  };
  config =
    let
      opts = config.${namespace}.infra.wsl;
    in
    lib.mkIf opts.enable {
      wsl = {
        enable = true;
        inherit (opts) defaultUser;
        docker-desktop.enable = opts.enableDockerDesktop;
        startMenuLaunchers = true;
        wslConf = opts.settings;
      };

      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
          zlib
          openssl
          curl
          glib
          libgcc
        ];
      };
    };
}
