{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.spotify = {
    enable = lib.mkEnableOption "Enable spotify";
    markAsFavorite = lib.mkEnableOption "Mark spotify as favorite";
  };

  config =
    let
      opts = config.${namespace}.apps.spotify;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ spotify ];
      ${namespace} = {
        infra.desktop-manager = {
          core.setFavoriteApps = lib.mkIf opts.markAsFavorite [ "datagrip.desktop" ];
        };
      };
    };
}
