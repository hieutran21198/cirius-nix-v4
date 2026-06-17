{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.chamber = {
    enable = lib.mkEnableOption "Enable chamber";
  };

  config =
    let
      opts = config.${namespace}.apps.chamber;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ chamber ];
    };
}
