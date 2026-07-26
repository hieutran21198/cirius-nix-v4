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
      users = lib.${namespace}.makeAttrsOption {
        ofType = lib.types.submodule {
          options = {
            enableHomeManager = lib.mkEnableOption "Enable home-manager for this user.";
            userSettings = lib.${namespace}.makeAttrsOption { };
            homeSettings = lib.${namespace}.makeAttrsOption { };
          };
        };
        default = { };
      };
    };
  };
  config =
    let
      cfg = config.${namespace}.infra.iam;
      users = lib.mapAttrs (_: userCfg: userCfg.userSettings) cfg.users;
      # filter who enable home manager only
      homeUsers = lib.mapAttrs (_: userCfg: userCfg.homeSettings) (
        lib.filterAttrs (_: userCfg: userCfg.enableHomeManager) cfg.users
      );
    in
    {
      users = {
        inherit (cfg) groups;
        inherit users;
      };
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit namespace; };
        users = homeUsers;
      };
    };
}
