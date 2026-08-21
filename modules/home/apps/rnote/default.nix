{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.rnote = {
    enable = lib.mkEnableOption "Enable rnote";
  };

  config =
    let
      opts = config.${namespace}.apps.rnote;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ rnote ];
    };
}
