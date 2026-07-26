{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.linear = {
    enable = lib.mkEnableOption "Enable linear";
  };

  config =
    let
      opts = config.${namespace}.apps.linear;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ linear ];
    };
}
