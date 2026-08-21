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
      fishEnabled = config.${namespace}.infra.shell.fish.enabled;
    in
    lib.mkIf opts.enable {
      programs.fzf = {
        enable = true;
        package = pkgs.fzf;
        enableFishIntegration = fishEnabled;
        historyWidget.fish = lib.mkIf fishEnabled { command = ""; };
      };
    };
}
