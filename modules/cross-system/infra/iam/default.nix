{
  config,
  namespace,
  options,
  lib,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule [ namespace "infra" "iam" "group" ] [ "users" "groups" ])
  ];
  options = {
    ${namespace}.infra.iam = {
      inherit (options.users) groups;
      users = lib.mkOption {
        type =
          with lib.types;
          attrsOf (submodule {
            options = {
              userSettings = lib.mkOption {
                type = with lib.types; attrsOf anything;
                default = { };
                description = "Aliased of user configuration";
              };
              homeSettings = lib.mkOption {
                type = with lib.types; attrsOf anything;
                default = { };
                description = "Aliased of home configuration";
              };
            };
          });
        default = { };
        description = "User with home-manager settings";
      };
    };
  };
  config =
    let
      cfg = config.${namespace}.infra.iam;
      users = lib.mapAttrs (_: userCfg: userCfg.userSettings) cfg.users;
      homeUsers = lib.mapAttrs (_: userCfg: userCfg.homeSettings) cfg.users;
    in
    {
      users = {
        inherit (cfg) groups;
        inherit users;
      };
      home-manager = {
        useGlobalPkgs = true;
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit namespace; };
        users = homeUsers;
      };
    };
}
