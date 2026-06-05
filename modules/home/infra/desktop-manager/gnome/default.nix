{
  config,
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
    setFavoriteApps = lib.${namespace}.makeListOption {
      ofType = lib.types.str;
      default = [ ];
    };
  };

  config =
    let
      inherit (config.${namespace}.infra.desktop-manager) gnome;
    in
    {
      ${namespace}.infra.desktop-manager.gnome = {
        enabled = lib.mkForce (osConfig.${namespace}.infra.desktop-manager.engine == "gnome");
      };
      dconf = {
        enable = true;
        settings = {
          "org/gnome/shell" = {
            favorite-apps = gnome.setFavoriteApps;
          };
        };
      };
      xdg = {
        enable = true;
      };
    };
}
