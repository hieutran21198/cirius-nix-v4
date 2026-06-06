{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.infra = {
    persistenceDirs = lib.${namespace}.makeListOption {
      ofType = lib.types.str;
      default = [ ];
    };
    persistenceFiles = lib.${namespace}.makeListOption {
      ofType = lib.types.str;
      default = [ ];
    };
  };
  config = {
    environment = {
      systemPackages = with pkgs; [ parted ];
      persistence."/persist" = {
        hideMounts = true;

        directories = [
          {
            directory = "/etc/NetworkManager/system-connections";
            mode = "0700";
          }

          "/var/lib/bluetooth"
          "/var/lib/nixos"
          "/var/lib/systemd"
          "/var/lib/NetworkManager"

          "/var/log"
        ]
        ++ config.${namespace}.infra.persistenceDirs;

        files = [
          "/etc/machine-id"

          # SSH host identity.
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ]
        ++ config.${namespace}.infra.persistenceFiles;
      };

      # TODO: reset root every boot.
      # hold-on wait network manager ssh host key, machine id working well first.
    };
  };
}
