{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.discord = {
    enable = lib.mkEnableOption "Enable discord";
  };

  config =
    let
      opts = config.${namespace}.apps.discord;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ discord ];
    };
}
