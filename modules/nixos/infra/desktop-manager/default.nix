{
  namespace,
  lib,
  ...
}:
let
  inherit (lib.${namespace}) supportedDesktopManagers;
in
{
  options = {
    ${namespace}.infra.desktop-manager =
      let
        supportedDesktopManagersType = lib.types.enum (with supportedDesktopManagers; [ gnome ]);
      in
      {
        engine = lib.mkOption {
          type = supportedDesktopManagersType;
        };
      };
  };
}
