{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.fzf = {
    enable = lib.mkEnableOption "Enable fzf";
  };

  config =
    let
      opts = config.${namespace}.apps.fzf;
    in
    lib.mkIf opts.enable {
      programs.fzf = {
        enable = true;
        package = pkgs.fzf;
        enableFishIntegration = config.${namespace}.infra.shell.fish.enabled;
      };
    };
}
