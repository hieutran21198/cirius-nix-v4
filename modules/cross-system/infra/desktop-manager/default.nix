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
        readOnly = pkgs.stdenv.hostPlatform.isDarwin;
        default = pkgs.stdenv.hostPlatform.isDarwin;
      };
    };
  };
}
