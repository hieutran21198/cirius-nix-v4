{ lib, ... }:
let
  supportedDesktopManagers = {
    gnome = "gnome";
    kde = "kde";
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
