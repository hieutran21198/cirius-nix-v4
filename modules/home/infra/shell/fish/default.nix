{
  osConfig,
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
  config = {
    programs.fish = {
      enable = lib.mkForce osConfig.${namespace}.infra.shell.fish.enable;
    };
  };
}
