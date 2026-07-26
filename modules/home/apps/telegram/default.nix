{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.telegram = {
    enable = lib.mkEnableOption "Enable telegram";
  };

  config =
    let
      opts = config.${namespace}.apps.telegram;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [
        telegram-desktop
        tg
      ];
    };
}
