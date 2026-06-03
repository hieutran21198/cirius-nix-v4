{
  namespace,
  osConfig ? { },
  ...
}:
{
  config = {
    programs.git = {
      enable = true;
    };
    programs.lazygit = {
      enable = true;
      enableFishIntegration = osConfig.${namespace}.infra.shell.fish.enable;
    };
  };
}
