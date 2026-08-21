{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ark = {
    enable = lib.mkEnableOption "Enable ark";
  };

  config =
    let
      opts = config.${namespace}.apps.ark;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [
        kdePackages.ark
        unrar
      ];
    };
}
