{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.xh = {
    enable = lib.mkEnableOption "Enable xh";
  };

  config =
    let
      opts = config.${namespace}.apps.xh;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ xh ];
    };
}
