{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.jnv = {
    enable = lib.mkEnableOption "Enable jnv";
  };

  config =
    let
      opts = config.${namespace}.apps.jnv;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ jnv ];
    };
}
