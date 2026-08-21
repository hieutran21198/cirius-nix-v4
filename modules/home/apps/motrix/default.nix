{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.motrix = {
    enable = lib.mkEnableOption "Enable motrix";
  };

  config =
    let
      opts = config.${namespace}.apps.motrix;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ motrix-next ];
    };
}
