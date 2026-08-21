{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.eza = {
    enable = lib.mkEnableOption "Enable eza";
  };

  config =
    let
      opts = config.${namespace}.apps.eza;
    in
    lib.mkIf opts.enable {
      programs.eza = {
        enable = true;
        package = pkgs.eza;
        enableFishIntegration = config.${namespace}.infra.shell.fish.enabled;
        colors = "always";
        icons = "always";
      };
    };
}
