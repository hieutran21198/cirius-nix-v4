{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.mailspring = {
    enable = lib.mkEnableOption "Enable mailspring";
  };

  config =
    let
      opts = config.${namespace}.apps.mailspring;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ mailspring ];
    };
}
