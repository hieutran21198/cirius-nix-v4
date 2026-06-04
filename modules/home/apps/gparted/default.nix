{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.gparted = {
    enable = lib.mkEnableOption "Enable gparted";
  };
  config =
    let
      opts = config.${namespace}.apps.gparted;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ gparted ];
    };
}
