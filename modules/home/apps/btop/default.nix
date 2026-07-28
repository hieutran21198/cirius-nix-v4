{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.btop = {
    enable = lib.mkEnableOption "Enable btop";
  };

  config =
    let
      opts = config.${namespace}.apps.btop;
    in
    lib.mkIf opts.enable {
      programs.btop = {
        enable = true;
      };
    };
}
