{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.datagrip = {
    enable = lib.mkEnableOption "Enable datagrip";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };
  config =
    let
      opts = config.${namespace}.apps.datagrip;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ jetbrains.datagrip ];
      ${namespace} = {
        infra.desktop-manager = {
          gnome.setFavoriteApps = [ "datagrip.desktop" ];
        };
      };
    };
}
