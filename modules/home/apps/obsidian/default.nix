{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.obsidian = {
    enable = lib.mkEnableOption "Enable obsidian";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };
  config = lib.mkIf config.${namespace}.apps.obsidian.enable {
    programs.obsidian = {
      enable = true;
      defaultSettings = {
        communityPlugins = [ ];
      };
    };
    ${namespace} = {
      infra.desktop-manager = {
        gnome.setFavoriteApps = [ "obsidian.desktop" ];
      };
    };
  };
}
