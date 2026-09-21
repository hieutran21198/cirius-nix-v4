{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.blender = {
    enable = lib.mkEnableOption "Enable blender";
  };

  config =
    let
      opts = config.${namespace}.apps.blender;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ blender ];
    };
}
