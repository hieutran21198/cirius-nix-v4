{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.aws-cli = {
    enable = lib.mkEnableOption "Enable aws-cli";
  };
  config =
    let
      opts = config.${namespace}.apps.aws-cli;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ awscli2 ];
    };
}
