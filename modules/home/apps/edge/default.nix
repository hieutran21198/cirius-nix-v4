{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.edge = {
    enable = lib.mkEnableOption "Enable edge";
  };

  config =
    let
      opts = config.${namespace}.apps.edge;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ microsoft-edge ];
    };
}
