{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.apps.only-office = {
    enable = lib.mkEnableOption "Enable only office";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };
  config =
    let
      opts = config.${namespace}.apps.only-office;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [
        onlyoffice-desktopeditors
      ];
      ${namespace} = {
        infra.desktop-manager = {
          core.setFavoriteApps = lib.mkIf opts.markAsFavorite [
            "onlyoffice-desktopeditors.desktop"
          ];
        };
      };
    };
}
