{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.datagrip = {
    enable = lib.mkEnableOption "Enable datagrip";
  };
  config =
    let
      opts = config.${namespace}.apps.datagrip;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ jetbrains.datagrip ];
    };
}
