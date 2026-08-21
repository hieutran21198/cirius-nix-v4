{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.comma = {
    enable = lib.mkEnableOption "Enable comma";
  };

  config =
    let
      opts = config.${namespace}.apps.comma;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ comma ];
    };
}
