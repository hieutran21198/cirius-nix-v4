{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.ghostty = {
    enable = lib.mkEnableOption "Enable ghostty";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };
  config = {
    programs.ghostty = {
      enable = true;
      systemd = {
        enable = true;
      };
      enableFishIntegration = config.${namespace}.infra.shell.fish.enabled;
      settings = {

      };
    };

    ${namespace} = {
      infra.desktop-manager = {
        gnome.setFavoriteApps = [ "com.mitchellh.ghostty.desktop" ];
      };
    };
  };
}
