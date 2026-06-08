{
  lib,
  pkgs,
  secureStore,
  mountPoint,
}:
let
  mountOptions = lib.concatStringsSep "," secureStore.mountOptions;
in
pkgs.writeShellApplication {
  name = "secure-store";

  runtimeInputs = with pkgs; [
    cryptsetup
    util-linux
    coreutils
    zenity
  ];

  text = ''
    set -euo pipefail

    DEVICE="${secureStore.device}"
    NAME="${secureStore.name}"
    MAPPER="/dev/mapper/$NAME"
    MOUNT_POINT="${mountPoint}"
    FS_TYPE="${secureStore.fsType}"
    MOUNT_OPTIONS="${mountOptions}"
    KEY_RELATIVE="${secureStore.hostAgeKey}"
    KEY_PATH="$MOUNT_POINT/$KEY_RELATIVE"
    SUDO="/run/wrappers/bin/sudo"

    as_root() {
      if [ "$(id -u)" -eq 0 ]; then
        "$@"
      else
        "$SUDO" "$@"
      fi
    }

    ensure_sudo() {
      if [ "$(id -u)" -ne 0 ]; then
        "$SUDO" -v
      fi
    }

    is_open() {
      as_root cryptsetup status "$NAME" >/dev/null 2>&1
    }

    is_mounted() {
      mountpoint -q "$MOUNT_POINT"
    }

    open_store() {
      if ! is_open; then
        echo "Opening LUKS device: $DEVICE -> $NAME"
        as_root cryptsetup open "$DEVICE" "$NAME"
      else
        echo "Mapper already open: $NAME"
      fi

      if ! is_mounted; then
        as_root install -d -m 0700 "$MOUNT_POINT"
        echo "Mounting $MAPPER at $MOUNT_POINT"
        as_root mount -t "$FS_TYPE" -o "$MOUNT_OPTIONS" "$MAPPER" "$MOUNT_POINT"
      else
        echo "Already mounted: $MOUNT_POINT"
      fi

      if ! as_root test -f "$KEY_PATH"; then
        echo "ERROR: expected SOPS age key not found: $KEY_PATH" >&2
        exit 1
      fi

      echo "secure-store is ready"
      echo "mount: $MOUNT_POINT"
      echo "key:   $KEY_PATH"
    }

    open_store_gui() {
      if ! is_open; then
        ensure_sudo

        if command -v zenity >/dev/null 2>&1 && [ -n "''${DISPLAY:-}''${WAYLAND_DISPLAY:-}" ]; then
          passphrase="$(
            zenity \
              --password \
              --title="Unlock secure-store"
          )"
          printf '%s' "$passphrase" | as_root cryptsetup open --key-file - "$DEVICE" "$NAME"
          unset passphrase
        else
          echo "Opening LUKS device: $DEVICE -> $NAME"
          as_root cryptsetup open "$DEVICE" "$NAME"
        fi
      else
        echo "Mapper already open: $NAME"
      fi

      if ! is_mounted; then
        as_root install -d -m 0700 "$MOUNT_POINT"
        echo "Mounting $MAPPER at $MOUNT_POINT"
        as_root mount -t "$FS_TYPE" -o "$MOUNT_OPTIONS" "$MAPPER" "$MOUNT_POINT"
      else
        echo "Already mounted: $MOUNT_POINT"
      fi

      if ! as_root test -f "$KEY_PATH"; then
        echo "ERROR: expected SOPS age key not found: $KEY_PATH" >&2
        exit 1
      fi

      echo "secure-store is ready"
      echo "mount: $MOUNT_POINT"
      echo "key:   $KEY_PATH"
    }

    close_store() {
      if is_mounted; then
        echo "Unmounting $MOUNT_POINT"
        as_root umount "$MOUNT_POINT"
      else
        echo "Not mounted: $MOUNT_POINT"
      fi

      if is_open; then
        echo "Closing mapper: $NAME"
        as_root cryptsetup close "$NAME"
      else
        echo "Mapper already closed: $NAME"
      fi
    }

    status_store() {
      echo "device:      $DEVICE"
      echo "mapper name: $NAME"
      echo "mapper path: $MAPPER"
      echo "mount point: $MOUNT_POINT"
      echo "key path:    $KEY_PATH"
      echo

      if is_open; then
        echo "mapper: open"
        as_root cryptsetup status "$NAME" || true
      else
        echo "mapper: closed"
      fi

      echo

      if is_mounted; then
        echo "mount: mounted"
        findmnt --mountpoint "$MOUNT_POINT" || true
      else
        echo "mount: not mounted"
      fi

      echo

      if as_root test -f "$KEY_PATH"; then
        echo "key: exists"
      else
        echo "key: missing"
      fi
    }

    case "''${1:-}" in
      open)
        open_store
        ;;
      open-gui)
        open_store_gui
        ;;
      close|umount|unmount)
        close_store
        ;;
      is-open)
        is_open
        ;;
      is-mounted)
        is_mounted
        ;;
      status)
        status_store
        ;;
      *)
        echo "usage: secure-store {open|open-gui|close|is-open|is-mounted|status}" >&2
        exit 2
        ;;
    esac
  '';
}
