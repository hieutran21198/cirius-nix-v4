{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.apps.only-office = {
    enable = lib.mkEnableOption "Enable only office";
  };
  config =
    let
      inherit (config.${namespace}) apps;
    in
    lib.mkIf apps.only-office.enable {
      home.packages = with pkgs; [
        onlyoffice-desktopeditors
      ];
    };
}
