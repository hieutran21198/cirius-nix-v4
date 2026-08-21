{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.gparted = {
    enable = lib.mkEnableOption "Enable gparted";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };
  config =
    let
      opts = config.${namespace}.apps.gparted;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ gparted ];
      ${namespace} = {
        infra.desktop-manager = {
          core.setFavoriteApps = [ "gparted.desktop" ];
        };
      };
    };
}
