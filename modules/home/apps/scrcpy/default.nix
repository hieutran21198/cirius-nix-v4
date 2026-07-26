{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.scrcpy = {
    enable = lib.mkEnableOption "Enable scrcpy";
  };

  config =
    let
      opts = config.${namespace}.apps.scrcpy;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [
        scrcpy
        qtscrcpy
      ];
    };
}
