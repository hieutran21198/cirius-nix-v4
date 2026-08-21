{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.nix-index = {
    enable = lib.mkEnableOption "Enable nix-index";
  };

  config =
    let
      opts = config.${namespace}.apps.nix-index;
    in
    lib.mkIf opts.enable {
      programs.nix-index = {
        enable = true;
        enableFishIntegration = config.${namespace}.infra.shell.fish.enabled;
      };
    };
}
