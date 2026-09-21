{
  config,
  namespace,
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
        update = {
          auto = {
            enable = true;
            onCalendar = "weekly";
          };
        };
      };
    };
}
