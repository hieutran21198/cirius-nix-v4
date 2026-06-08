{
  namespace,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule [ namespace "infra" "theme" "base16Scheme" ] [ "stylix" "base16Scheme" ])
    (lib.mkAliasOptionModule
      [ namespace "infra" "persistenceDirs" ]
      [ "home" "persistence" "persist" "directories" ]
    )
    (lib.mkAliasOptionModule
      [ namespace "infra" "persistenceFiles" ]
      [ "home" "persistence" "persist" "files" ]
    )
  ];
  options.${namespace}.infra = {
    theme = { };
  };
  config = {
    home = {
      persistence."/persist" = {
        directories = [ ];
        files = [ ];
      };
      packages = with pkgs; [
        base16-schemes
        tree
      ];
    };
    stylix =
      let
        adwaitaBase16Scheme = {
          system = "base16";
          name = "Adwaita Inspired Dark";
          author = "Minh Hieu Tran";
          variant = "dark";
          palette = {
            base00 = "1d1d20";
            base01 = "222226";
            base02 = "2e2e32";
            base03 = "5e5c64";
            base04 = "9a9996";
            base05 = "f6f5f4";
            base06 = "deddda";
            base07 = "ffffff";

            base08 = "ed333b";
            base09 = "ff7800";
            base0A = "f6d32d";
            base0B = "33d17a";
            base0C = "62a0ea";
            base0D = "3584e4";
            base0E = "c061cb";
            base0F = "b5835a";
          };
        };
      in
      {
        enable = true;
        autoEnable = false;
        base16Scheme = lib.mkDefault adwaitaBase16Scheme;
      };
  };
}
