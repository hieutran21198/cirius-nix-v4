{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.apps.ms-teams = {
    enable = lib.mkEnableOption "Enable microsoft teams for linux (Unofficial)";
  };
  config =
    let
      inherit (config.${namespace}) apps;
    in
    lib.mkIf apps.ms-teams.enable {
      home.packages = with pkgs; [
        teams-for-linux
      ];
    };
}
