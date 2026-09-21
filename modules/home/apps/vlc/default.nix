{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.vlc = {
    enable = lib.mkEnableOption "Enable vlc";
  };

  config =
    let
      opts = config.${namespace}.apps.vlc;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ vlc ];
    };
}
