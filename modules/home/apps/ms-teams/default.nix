{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.apps.ms-teams = {
    enable = lib.mkEnableOption "Enable microsoft teams for linux (Unofficial)";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };
  config =
    let
      inherit (config.${namespace}) apps;
    in
    lib.mkIf apps.ms-teams.enable {
      home.packages = with pkgs; [
        teams-for-linux
      ];
      ${namespace} = {
        infra.desktop-manager = {
          gnome.setFavoriteApps = [ "teams-for-linux.desktop" ];
        };
      };
    };
}
