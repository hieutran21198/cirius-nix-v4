{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.slack = {
    enable = lib.mkEnableOption "Enable slack";
  };

  config =
    let
      opts = config.${namespace}.apps.slack;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ slack ];
    };
}
