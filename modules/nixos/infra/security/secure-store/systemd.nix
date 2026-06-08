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
      deviceMapper = "/dev/mapper/${secureStore.name}";
    in
    lib.mkIf secureStore.enable {
      systemd = {
        services = {
          secure-store-mount = {
            description = "Mount secure-store for sops-nix";

            requiredBy = [ "sops-install-secrets.service" ];
            before = [ "sops-install-secrets.service" ];

            path = with pkgs; [
              cryptsetup
              systemd
              util-linux
              coreutils
            ];

            serviceConfig = {
              Type = "oneshot";
            };

            script = ''
              set -euo pipefail

              if ! cryptsetup status ${secureStore.name} >/dev/null 2>&1; then
                systemd-cryptsetup attach ${secureStore.name} ${secureStore.device}
              fi

              if ! mountpoint -q ${mountPoint}; then
                install -d -m 0700 ${mountPoint}
                mount \
                  -t ${secureStore.fsType} \
                  -o ${lib.concatStringsSep "," secureStore.mountOptions} \
                  ${deviceMapper} \
                  ${mountPoint}
              fi

              test -f ${mountPoint}/${secureStore.hostAgeKey}
            '';
          };

          secure-store-cleanup = {
            description = "Unmount and close secure-store after activation";
            wantedBy = [ "sops-install-secrets.service" ];
            after = [
              "sops-install-secrets.service"
              "nixos-activation.service"
            ];
            path = with pkgs; [
              cryptsetup
              util-linux
              coreutils
            ];
            serviceConfig = {
              Type = "oneshot";
            };
            script = ''
              set -u
              if mountpoint -q ${mountPoint}; then
                umount ${mountPoint} || true
              fi
              if cryptsetup status ${secureStore.name} >/dev/null 2>&1; then
                cryptsetup close ${secureStore.name} || true
              fi
            '';
          };
        };

        user = {
          services.secure-store-reminder = {
            description = "Remind user when secure-store is still open";
            serviceConfig = {
              Type = "oneshot";
            };
            script = ''
              set -euo pipefail

              mounted=0
              opened=0

              if ${pkgs.util-linux}/bin/mountpoint -q ${mountPoint}; then
                mounted=1
              fi

              if [ -e ${deviceMapper} ]; then
                opened=1
              fi

              if [ "$mounted" = 1 ] || [ "$opened" = 1 ]; then
                ${pkgs.libnotify}/bin/notify-send \
                  --app-name="secure-store" \
                  --urgency=normal \
                  --icon=dialog-password \
                  "secure-store is still open" \
                  "Run: secure-store close"
              fi
            '';
          };
          timers.secure-store-reminder = {
            description = "Periodically remind user to close secure-store";
            wantedBy = [
              "timers.target"
              "graphical-session.target"
            ];
            timerConfig = {
              OnBootSec = "5m";
              OnUnitActiveSec = "5m";
              AccuracySec = "30s";
              Unit = "secure-store-reminder.service";
              Persistent = false;
            };
          };
        };
      };
    };
}
