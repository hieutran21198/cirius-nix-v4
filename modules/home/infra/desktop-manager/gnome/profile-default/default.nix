{
  namespace,
  config,
  lib,
  ...
}:
{
  options.${namespace}.infra.desktop-manager.gnome.profile-default = {

  };

  config =
    let
      inherit (config.${namespace}.infra.desktop-manager) gnome;
    in
    lib.mkIf (gnome.enabled && gnome.profile == "default") { };
}
