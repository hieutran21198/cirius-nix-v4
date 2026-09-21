{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.merkuro = {
    enable = lib.mkEnableOption "Enable merkuro";
  };

  config =
    let
      opts = config.${namespace}.apps.merkuro;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ kdePackages.merkuro ];
    };
}
