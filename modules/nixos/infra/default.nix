{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  imports = [ (lib.mkAliasOptionModule [ namespace "infra" "nix" ] [ "nix" ]) ];
  options.${namespace}.infra = {
    zram = {
      enable = lib.${namespace}.makeBoolOption {
        default = true;
      };
      percent = lib.${namespace}.makeIntOption {
        default = 25;
      };
    };
    persistenceDirs = lib.${namespace}.makeListOption {
      ofType = lib.types.str;
      default = [ ];
    };
    persistenceFiles = lib.${namespace}.makeListOption {
      ofType = lib.types.str;
      default = [ ];
    };
  };
  config =
    let
      inherit (config.${namespace}) infra;
    in
    {
      zramSwap = {
        enable = infra.zram.enable;
        memoryPercent = infra.zram.percent;
      };
      environment = {
        systemPackages = with pkgs; [
          parted
          util-linux
        ];
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
