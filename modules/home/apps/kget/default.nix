{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.kget = {
    enable = lib.mkEnableOption "Enable kget";
  };

  config =
    let
      opts = config.${namespace}.apps.kget;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ kdePackages.kget ];
    };
}
