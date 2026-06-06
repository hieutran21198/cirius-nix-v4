{
  lib,
  namespace,
  pkgs,
  ...
}:
{
  imports = [ (lib.mkAliasOptionModule [ namespace "infra" "fonts" ] [ "stylix" "fonts" ]) ];
  config = {
    home.packages = with pkgs; [ fontconfig ];
    fonts.fontconfig = {
      enable = true;
    };
  };
}
