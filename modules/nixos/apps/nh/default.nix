{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.nh = {
    enable = lib.mkEnableOption "Enable nh";
  };

  config =
    let
      opts = config.${namespace}.apps.nh;
    in
    lib.mkIf opts.enable {
      environment.systemPackages = with pkgs; [ nh ];
    };
}
