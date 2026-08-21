{
  namespace,
  config,
  lib,
  ...
}:
{
  imports = [ ./_keybindings.nix ];
  options.${namespace}.infra.desktop-manager.kde.profile-default = {
  };

  config =
    let
      inherit (config.${namespace}.infra.desktop-manager) kde;
    in
    lib.mkIf (kde.enabled && kde.profile == "default") {
      home = {
        packages = [ ];
      };

      programs = {
        nixvim = {
          colorschemes = {
            one.enable = true;
          };
          colorscheme = "one";
          opts.termguicolors = lib.mkForce true;
        };
        ghostty = {
          settings = {
            theme = lib.mkForce "Atom One Dark";
            minimum-contrast = 1;
            background-opacity = lib.mkForce 0.9;
          };
        };
        plasma = {
          windows = {
            allowWindowsToRememberPositions = true;
          };
          workspace = {
            clickItemTo = "select"; # open | select
            enableMiddleClickPaste = false;
            colorScheme = "BreezeDark"; # BreezeClassic | BrezzeDark | BreezeLight
            cursor = {
              theme = "breeze_cursors"; # breeze_cursors | Breeze_Light
            };
            iconTheme = "breeze-dark"; # breeze | breeze-dark | breeze-light
            lookAndFeel = "org.kde.breeze.desktop"; # look and feel will override many elements of Plasma styles.
          };
        };
      };
    };
}
