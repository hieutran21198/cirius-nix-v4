{
  config,
  namespace,
  lib,
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
      services.desktopManager.${engine}.enable = true;
      services.displayManager.gdm.enable = true;
    };
}
