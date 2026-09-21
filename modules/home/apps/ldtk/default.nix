{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ldtk = {
    enable = lib.mkEnableOption "Enable ldtk";
  };

  config =
    let
      opts = config.${namespace}.apps.ldtk;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ ldtk ];
    };
}
