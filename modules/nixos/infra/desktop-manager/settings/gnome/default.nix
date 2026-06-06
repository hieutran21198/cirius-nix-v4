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
        # Enable touchpad support (enabled default in most desktopManager).
        # services.xserver.libinput.enable = true;
        # Enable the X11 windowing system.
        xserver = {
          enable = true;
          # Configure keymap in X11
          xkb = {
            layout = "us";
            variant = "";
          };
        };
      };
    };
}
