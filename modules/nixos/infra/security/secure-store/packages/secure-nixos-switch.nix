{
  config,
  pkgs,
  secureStoreCLIPackage,
}:
pkgs.writeShellApplication {
  name = "secure-nixos-switch";

  runtimeInputs = with pkgs; [
    nix
    coreutils
    secureStoreCLIPackage
  ];

  text = ''
    set -euo pipefail

    SUDO="/run/wrappers/bin/sudo"
    SYSTEM_MODE="switch"

    usage() {
      echo "usage: secure-nixos-switch <flake-ref> [nix-build-args...]" >&2
      echo "example: secure-nixos-switch /path/to/flake#${config.networking.hostName}" >&2
    }

    if [ "$#" -lt 1 ]; then
      usage
      exit 2
    fi

    FLAKE_REF="$1"
    shift

    case "$FLAKE_REF" in
      *#*)
        FLAKE_PATH="''${FLAKE_REF%%#*}"
        HOST="''${FLAKE_REF#*#}"
        ;;
      *)
        FLAKE_PATH="$FLAKE_REF"
        HOST="${config.networking.hostName}"
        ;;
    esac

    if [ -z "$FLAKE_PATH" ]; then
      FLAKE_PATH="."
    fi

    BUILD_REF="$FLAKE_PATH#nixosConfigurations.$HOST.config.system.build.toplevel"
    WORK_DIR="$(mktemp -d)"
    WAS_OPEN=0
    OPENED=0

    cleanup() {
      status=$?
      if [ "$OPENED" = 1 ] && [ "$WAS_OPEN" = 0 ]; then
        secure-store close || true
      fi
      rm -rf "$WORK_DIR"
      exit "$status"
    }

    trap cleanup EXIT INT TERM

    echo "Building $BUILD_REF"
    nix build "$BUILD_REF" -o "$WORK_DIR/system" "$@"

    echo "Unlocking secure-store for activation"
    if secure-store is-open; then
      WAS_OPEN=1
    fi

    secure-store open-gui
    OPENED=1

    echo "Activating built system"
    if [ "$(id -u)" -eq 0 ]; then
      "$WORK_DIR/system/bin/switch-to-configuration" "$SYSTEM_MODE"
    else
      "$SUDO" "$WORK_DIR/system/bin/switch-to-configuration" "$SYSTEM_MODE"
    fi
  '';
}
