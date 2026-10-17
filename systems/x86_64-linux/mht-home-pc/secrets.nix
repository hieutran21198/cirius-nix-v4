{
  config,
  namespace,
  ...
}:
let
  inherit (config.cnix-sec) secret-mgt;
in
{
  cnix-sec.secret-mgt = {
    secrets = {
      "personal/dockhand/env" = {
        key = "dockhand/env";
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
      "personal/music-server/env-file" = {
        content = ''
          ${secret-mgt.placeholder."personal/music-server/override-env"}
        '';
      };
      "personal/networking/hotspot-env" = {
        content = ''
          HOTSPOT_PSK=${secret-mgt.placeholder."personal/networking/hotspot-psk"}
        '';
        restartUnits = [ "NetworkManager-ensure-profiles.service" ];
      };
    };
  };
}
