{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.clion = {
    enable = lib.mkEnableOption "Enable clion";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };

  config =
    let
      opts = config.${namespace}.apps.clion;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ jetbrains.clion ];
      ${namespace} = {
        infra.desktop-manager = {
          gnome.setFavoriteApps = [ "clion.desktop" ];
        };
      };
    };
}
