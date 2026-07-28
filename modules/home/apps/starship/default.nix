{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.starship = {
    enable = lib.mkEnableOption "Enable starship";
  };

  config =
    let
      opts = config.${namespace}.apps.starship;
    in
    lib.mkIf opts.enable {
      programs.starship = {
        enable = true;
        enableFishIntegration = config.${namespace}.infra.shell.fish.enabled;
        enableTransience = true;
        enableInteractive = true;
      };
    };
}
