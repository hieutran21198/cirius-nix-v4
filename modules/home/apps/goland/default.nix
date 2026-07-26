{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.goland = {
    enable = lib.mkEnableOption "Enable goland";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };

  config =
    let
      opts = config.${namespace}.apps.goland;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ jetbrains.goland ];
      ${namespace} = {
        infra.desktop-manager = {
          gnome.setFavoriteApps = [ "goland.desktop" ];
        };
      };
    };
}
