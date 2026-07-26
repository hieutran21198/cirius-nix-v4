{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.fabric = {
    enable = lib.mkEnableOption "Enable fabric";
  };

  config =
    let
      opts = config.${namespace}.apps.fabric;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ fabric-ai ];
    };
}
