{
  namespace,
  lib,
  config,
  ...
}:
{
  options.${namespace}.infra.security.secureStore = {
    enable = lib.mkEnableOption "Enable secure store support for host SOPS age key";
    built = {
      mountPoint = lib.${namespace}.makeStrOption {
        readOnly = true;
      };
    };
    name = lib.${namespace}.makeStrOption {
      default = "secure-store";
    };
    device = lib.${namespace}.makeStrOption {
      description = "Path to LUKS device, e.g. /dev/disk/by-uuid/...";
    };
    fsType = lib.${namespace}.makeStrOption {
      default = "ext4";
    };
    mountOptions = lib.${namespace}.makeListOption {
      ofType = lib.types.str;
      default = [
        "ro"
        "nodev"
        "nosuid"
        "noexec"
        "noatime"
      ];
    };

    hostAgeKey = lib.${namespace}.makeStrOption {
      default = "host/sops-age/key.txt";
      description = "Key file in runtime directory";
    };
  };
  config =
    let
      inherit (config.${namespace}.infra.security) secureStore;
      mountPoint = "/run/${secureStore.name}";
    in
    lib.mkIf secureStore.enable {
      ${namespace}.infra.security.secureStore.built = { inherit mountPoint; };
      boot.initrd.luks.devices.${secureStore.name} = {
        inherit (secureStore) device;
      };
      fileSystems = {
        ${mountPoint} = {
          device = "/dev/mapper/secure-store";
          inherit (secureStore) fsType;
          options = secureStore.mountOptions;
        };
      };
    };
}
