{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.bruno = {
    enable = lib.mkEnableOption "Enable bruno";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };

  config =
    let
      opts = config.${namespace}.apps.bruno;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ bruno ];
      ${namespace} = {
        infra.desktop-manager = {
          gnome.setFavoriteApps = [ "bruno.desktop" ];
        };
      };
    };
}
