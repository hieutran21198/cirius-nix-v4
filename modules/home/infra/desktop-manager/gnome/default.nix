{
  osConfig ? { },
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.infra.desktop-manager.gnome = {
    enabled = lib.${namespace}.makeBoolOption {
      readOnly = true;
    };
    profile = lib.${namespace}.makeEnumOption {
      acceptedList = [ "default" ];
      default = "default";
    };
  };

  config = {
    ${namespace}.infra.desktop-manager.gnome = {
      enabled = lib.mkForce (osConfig.${namespace}.infra.desktop-manager.engine == "gnome");
    };
    xdg = {
      enable = true;
    };
  };
}
