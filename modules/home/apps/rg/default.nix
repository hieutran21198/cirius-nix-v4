{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.rg = {
    enable = lib.mkEnableOption "Enable rg";
  };

  config =
    let
      opts = config.${namespace}.apps.rg;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ ripgrep ];
    };
}
