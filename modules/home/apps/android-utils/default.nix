{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.android-utils = {
    enable = lib.mkEnableOption "Enable android-utils";
  };

  config =
    let
      opts = config.${namespace}.apps.android-utils;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ android-tools ];
    };
}
