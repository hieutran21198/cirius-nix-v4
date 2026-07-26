{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.apps.direnv = {
    enable = lib.mkEnableOption "Enable direnv";
  };
  config =
    let
      opts = config.${namespace}.apps.direnv;
    in
    lib.mkIf opts.enable {
      programs.direnv = {
        enable = true;
        package = pkgs.direnv;
        config = {
          global = {
            hide_env_diff = true;
          };
        };
      };
    };
}
