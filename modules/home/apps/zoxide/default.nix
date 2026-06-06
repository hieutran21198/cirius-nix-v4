{
  lib,
  config,
  namespace,
  ...
}:
{
  options.${namespace}.apps.zoxide = {
    enable = lib.${namespace}.makeBoolOption { default = false; };
  };
  config = {
    programs.zoxide = {
      enable = true;
      enableFishIntegration = config.${namespace}.infra.shell.fish.enabled;
    };
  };
}
