{
  namespace,
  lib,
  config,
  ...
}:
{
  options.${namespace}.infra.desktop-manager.kde.profile-default = {
    enableCustomKeyBindings = lib.${namespace}.makeBoolOption {
      default = true;
    };
  };

  config =
    let
      inherit (config.${namespace}.infra.desktop-manager) kde;
    in
    lib.mkIf (kde.enabled && kde.profile == "default" && kde.profile-default.enableCustomKeyBindings) {
      ${namespace}.infra.desktop-manager.keybindings.bindings = import ../../_keybindings.default.nix;
    };
}
