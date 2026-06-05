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
    ${namespace}.infra.desktop-manager = {
      engine = lib.${namespace}.makeEnumOption {
        acceptedList = with supportedDesktopManagers; [ gnome ];
        default = "gnome";
      };
    };
  };
}
