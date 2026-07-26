{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.antares = {
    enable = lib.mkEnableOption "Enable antares";
  };

  config =
    let
      opts = config.${namespace}.apps.antares;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ antares ];
    };
}
