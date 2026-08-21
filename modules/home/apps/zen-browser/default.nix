{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.zen-browser = {
    enable = lib.mkEnableOption "Enable zen-browser";
  };

  config =
    let
      opts = config.${namespace}.apps.zen-browser;
    in
    lib.mkIf opts.enable {
      programs.zen-browser = {
        enable = true;
      };
    };
}
