{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai.opencode = {
    enable = lib.mkEnableOption "Enable opencode";
  };
  config =
    let
      opts = config.${namespace}.apps.ai.opencode;
    in
    lib.mkIf opts.enable {
      programs.opencode = {
        enable = true;
      };
    };
}
