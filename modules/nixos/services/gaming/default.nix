{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.services.gaming = {
    enable = lib.mkEnableOption "Enable gaming mode";
  };
  config =
    let
      opts = config.${namespace}.services.gaming;
    in
    lib.mkIf opts.enable {
      environment.systemPackages = with pkgs; [
        heroic
        lutris
        mumble
        protonup-qt
        retroarch-full
        wine
        mangohud
      ];
      hardware.graphics.enable32Bit = true;
      programs = {
        gamemode.enable = true;
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };
      };
    };
}
