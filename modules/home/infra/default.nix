{
  namespace,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule
      [ namespace "infra" "persistenceDirs" ]
      [ "home" "persistence" "persist" "directories" ]
    )
    (lib.mkAliasOptionModule
      [ namespace "infra" "persistenceFiles" ]
      [ "home" "persistence" "persist" "files" ]
    )
  ];
  options.${namespace}.infra = {
    theme = { };
  };
  config = {
    home = {
      persistence = lib.mkIf osConfig.${namespace}.infra.enablePersistence {
        "/persist" = {
          directories = [ ];
          files = [ ];
        };
      };
      packages = with pkgs; [
        base16-schemes
        tree
      ];
    };
  };
}
