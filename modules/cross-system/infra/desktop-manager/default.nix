{
  lib,
  namespace,
  pkgs,
  ...
}:
{
  options = {
    ${namespace}.infra.desktop-manager = {
      enable = lib.${namespace}.makeBoolOption {
        readOnly = pkgs.stdenv.isDarwin;
        default = pkgs.stdenv.isDarwin;
      };
    };
  };
}
