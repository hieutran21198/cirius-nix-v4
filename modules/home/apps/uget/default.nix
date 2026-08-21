{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.uget = {
    enable = lib.mkEnableOption "Enable uget";
  };

  config =
    let
      opts = config.${namespace}.apps.uget;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ uget ];
    };
}
