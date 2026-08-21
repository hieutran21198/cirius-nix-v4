{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.antimicrox = {
    enable = lib.mkEnableOption "Enable antimicrox";
  };

  config =
    let
      opts = config.${namespace}.apps.antimicrox;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ antimicrox ];
    };
}
