{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.localsend = {
    enable = lib.mkEnableOption "Enable localsend";
  };

  config =
    let
      opts = config.${namespace}.apps.localsend;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ localsend ];
    };
}
