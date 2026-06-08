{
  namespace,
  lib,
  config,
  ...
}:
{
  config =
    let
      inherit (config.${namespace}.infra.security) secureStore;
      mountPoint = "/run/${secureStore.name}";
    in
    lib.mkIf secureStore.enable {
      ${namespace}.infra.security.secureStore.built = {
        inherit mountPoint;
      };

      sops = {
        useSystemdActivation = lib.mkForce true;
        age.keyFile = lib.mkForce "${mountPoint}/${secureStore.hostAgeKey}";
      };

      boot.initrd.luks.devices.${secureStore.name} = {
        inherit (secureStore) device;
      };
    };
}
