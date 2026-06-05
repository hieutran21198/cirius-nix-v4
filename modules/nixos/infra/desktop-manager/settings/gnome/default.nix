{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
let
  engine = "gnome";
in
{
  options.${namespace}.infra.desktop-manager.settings.${engine} = {

  };
  config =
    let
      dmOpts = config.${namespace}.infra.desktop-manager;
      gnomeEnabled = dmOpts.enable && dmOpts.engine == engine;
    in
    lib.mkIf gnomeEnabled {
      environment = {
        systemPackages = with pkgs; [
          desktop-file-utils
          dconf-editor
        ];
      };
      services = {
        desktopManager.${engine}.enable = true;
        displayManager.gdm.enable = true;
        udev.packages = with pkgs; [ gnome-settings-daemon ];
        gnome = {
          core-apps.enable = true;
          games.enable = false;
          core-developer-tools.enable = false;
        };
      };
    };
}
