{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.devenv = {
    enable = lib.mkEnableOption "Enable devenv";
  };
  config =
    let
      opts = config.${namespace}.apps.devenv;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ devenv ];
    };
}
