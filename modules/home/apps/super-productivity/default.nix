{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.super-productivity = {
    enable = lib.mkEnableOption "Enable super-productivity";
  };

  config =
    let
      opts = config.${namespace}.apps.super-productivity;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ super-productivity ];
    };
}
