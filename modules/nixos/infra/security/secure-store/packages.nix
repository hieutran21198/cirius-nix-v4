{
  namespace,
  lib,
  config,
  pkgs,
  ...
}:
{
  config =
    let
      inherit (config.${namespace}.infra.security) secureStore;
      mountPoint = "/run/${secureStore.name}";

      secureStoreCLIPackage = import ./packages/secure-store.nix {
        inherit
          lib
          pkgs
          secureStore
          mountPoint
          ;
      };

      secureNixosSwitchPackage = import ./packages/secure-nixos-switch.nix {
        inherit config pkgs secureStoreCLIPackage;
      };
    in
    lib.mkIf secureStore.enable {
      environment.systemPackages = [
        secureStoreCLIPackage
        secureNixosSwitchPackage
      ];
    };
}
