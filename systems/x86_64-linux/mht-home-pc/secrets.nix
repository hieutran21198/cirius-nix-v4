{
  config,
  namespace,
  ...
}:
let
  inherit (config) sops;
in
{
  ${namespace} = {
    infra.security = {
      # LUKS secure device.
      secureStore = {
        enable = true;
        name = "secure-store";
        device = "/dev/disk/by-uuid/a0b01d1b-4e4a-43b8-af99-888be9694e1d";
        fsType = "btrfs";
        mountOptions = [
          "ro"
          "nodev"
          "nosuid"
          "noexec"
          "compress=zstd"
          "noatime"
        ];
        hostAgeKey = "host/sops-age/key.txt";
      };
      secrets = {
        "personal/sonarqube/env" = {
          key = "sonarqube/env";
          mode = "0400";
        };
        "personal/dockhand/env" = {
          key = "dockhand/env";
          mode = "0400";
        };
        "personal/postgres/sonarqube/env" = {
          key = "postgres/sonarqube/env";
          mode = "0400";
        };
        "personal/postgres/dockhand/env" = {
          key = "postgres/dockhand/env";
          mode = "0400";
        };
        "personal/api-key/deepseek" = {
          key = "ai/deepseek/api-key";
          mode = "0400";
        };
        "personal/nix/extra-options" = {
          key = "nix/extra-options";
          mode = "0400";
        };
        "personal/networking/hotspot-psk" = {
          key = "hotspot-psk";
          sopsFile = ../../../secrets/mht-home-pc/hotspot.yaml;
          mode = "0400";
        };
        "personal/music-server/override-env" = {
          key = "music-server/env";
          mode = "0400";
        };
        "personal/aria2/rpc-secret" = {
          key = "aria2/rpc-secret";
          mode = "0400";
        };
      };
      templates = {
        "personal/hermes/env-file" = {
          content = ''
            DEEPSEEK_API_KEY=${sops.secrets."personal/api-key/deepseek".path}
          '';
        };
        "personal/music-server/env-file" = {
          content = ''
            ${sops.placeholder."personal/music-server/override-env"}
          '';
        };
        "personal/networking/hotspot-env" = {
          content = ''
            HOTSPOT_PSK=${sops.placeholder."personal/networking/hotspot-psk"}
          '';
          restartUnits = [ "NetworkManager-ensure-profiles.service" ];
        };
        "personal/open-design/env-file" = {
          content = "";
        };
      };
    };

    services.open-design.envFile = sops.templates."personal/open-design/env-file".path;
  };
}
