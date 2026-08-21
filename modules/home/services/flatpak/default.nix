{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.services.flatpak = {
    enable = lib.mkEnableOption "Enable flatpak";
  };

  config =
    let
      opts = config.${namespace}.services.flatpak;
    in
    lib.mkIf opts.enable {
      services.flatpak = {
        enable = true;
        packages = [
          {
            appId = "org.freedownloadmanager.Manager";
            origin = "flathub";
          }
        ];
        remotes = [
          {
            name = "flathub-beta";
            location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
          }
        ];
      };
    };
}
