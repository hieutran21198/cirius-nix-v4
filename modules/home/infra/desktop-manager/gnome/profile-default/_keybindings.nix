{
  namespace,
  lib,
  config,
  ...
}:
{
  options.${namespace}.infra.desktop-manager.gnome.profile-default = {
    enableCustomKeyBindings = lib.${namespace}.makeBoolOption {
      default = true;
    };
  };

  config =
    let
      inherit (config.${namespace}.infra.desktop-manager) gnome;
    in
    lib.mkIf
      (gnome.enabled && gnome.profile == "default" && gnome.profile-default.enableCustomKeyBindings)
      {
        ${namespace}.infra.desktop-manager.keybindings.bindings = import ../../_keybindings.default.nix;
      };
}
