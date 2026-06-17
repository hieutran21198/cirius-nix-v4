{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.services.opensnitch = {
    enable = lib.mkEnableOption "Enable opensnitch";
  };

  config =
    let
      opts = config.${namespace}.services.opensnitch;
    in
    lib.mkIf opts.enable {
      services.opensnitch = {
        enable = true;
      };
    };
}
