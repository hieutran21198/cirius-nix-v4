{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.brave = {
    enable = lib.mkEnableOption "Enable brave";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };

  config =
    let
      opts = config.${namespace}.apps.brave;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ brave ];
      ${namespace} = {
        infra.desktop-manager = {
          core.setFavoriteApps = lib.mkIf opts.markAsFavorite [
            "brave-browser.desktop"
          ];
        };
      };
    };
}
