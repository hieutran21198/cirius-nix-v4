{
  osConfig ? { },
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.infra.desktop-manager.gnome = {
    enabled = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      description = "This is the flag that depended on nixos configuration";
    };
    profile = lib.mkOption {
      type = with lib.types; (enum [ "default" ]);
      default = "default";
      description = "Profile to be setted";
    };
  };

  config = {
    ${namespace}.infra.desktop-manager.gnome = {
      enabled = lib.mkForce (osConfig.${namespace}.infra.desktop-manager.engine == "gnome");
    };
  };
}
