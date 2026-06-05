{
  osConfig ? { },
  config,
  namespace,
  lib,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule
      [ namespace "infra" "shell" "fish" "shellAbbrs" ]
      [ "programs" "fish" "shellAbbrs" ]
    )
  ];
  options.${namespace}.infra.shell.fish = {
    enabled = lib.${namespace}.makeBoolOption {
      readOnly = true;
      default = osConfig.${namespace}.infra.shell.fish.enable;
    };
  };
  config = lib.mkIf config.${namespace}.infra.shell.fish.enabled {
    programs.fish = {
      enable = true;
    };
  };
}
