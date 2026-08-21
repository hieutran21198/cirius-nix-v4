{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.brave = {
    enable = lib.mkEnableOption "Enable brave";
  };

  config =
    let
      opts = config.${namespace}.apps.brave;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ brave ];
    };
}
