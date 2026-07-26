{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.qemu = {
    enable = lib.mkEnableOption "Enable qemu";
  };

  config =
    let
      opts = config.${namespace}.apps.qemu;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [
        # qemu_full
        quickemu
      ];
    };
}
