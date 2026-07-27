{ lib, ... }:
let
  supportedDesktopManagers = {
    gnome = "gnome";
    none = "none";
  };
in
{
  inherit supportedDesktopManagers;

  mkDconfTree =
    base: tree:
    lib.mapAttrs' (
      name: value: lib.nameValuePair (if name == "/" then base else "${base}/${name}") value
    ) tree;
}
