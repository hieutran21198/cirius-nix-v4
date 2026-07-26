{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.services.teamviewer = {
    enable = lib.mkEnableOption "Enable teamviewer";
  };
  config =
    let
      opts = config.${namespace}.services.teamviewer;
    in
    lib.mkIf opts.enable {
      environment.systemPackages = [ pkgs.teamviewer ];
      services.teamviewer.enable = true;
    };
}
