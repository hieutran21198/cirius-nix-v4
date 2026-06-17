{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.aws-vault = {
    enable = lib.mkEnableOption "Enable aws-vault";
  };

  config =
    let
      opts = config.${namespace}.apps.aws-vault;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ aws-vault ];
    };
}
