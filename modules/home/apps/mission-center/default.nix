{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.mission-center = {
    enable = lib.mkEnableOption "Enable mission-center
";
  };

  config =
    let
      opts = config.${namespace}.apps.mission-center;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [
        mission-center
      ];
    };
}
