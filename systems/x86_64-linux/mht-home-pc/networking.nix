{
  namespace,
  config,
  ...
}:
let

  inherit (config) sops;

  hostName = "mht-home-pc";
  dockhandHost = "dockhand.${hostName}";
  syncthingHost = "syncthing.${hostName}";
  sunshineHost = "sunshine.${hostName}";
in
{
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=VN
  '';
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ sops.templates."personal/networking/hotspot-env".path ];
    profiles.Hotspot = {
      connection = {
        id = "Hotspot";
        uuid = "cfc99035-9966-4e89-8f48-c3070b1483f3";
        type = "wifi";
        interface-name = "wlp2s0f0u9";
        autoconnect = true;
        autoconnect-priority = 100;
      };
      wifi = {
        band = "a";
        channel = 36;
        channel-width = 80;
        mode = "ap";
        ssid = "mht-home-pc";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$HOTSPOT_PSK";
      };
      ipv4.method = "shared";
      ipv6.method = "disabled";
    };
  };
  ${namespace} = {
    infra.networking = {
      enable = true;
      avahiEnabled = true;
      inherit hostName;
      hosts = {
        "127.0.0.1" = [
          dockhandHost
          syncthingHost
          sunshineHost
        ];
      };
      # Open ports in the firewall.
      firewall = {
        enable = true;
        allowedTCPPorts = [
        ];
        interfaces.wlp2s0f0u9 = {
          allowedUDPPorts = [
            53 # DNS
            67 # DHCP server
          ];

          allowedTCPPorts = [
            53 # DNS TCP fallback
          ];
        };
      };
      virtualHosts = {
        ${dockhandHost}.extraConfig = ''
          tls internal
          reverse_proxy 127.0.0.1:${toString config.${namespace}.containers.dockhand.port}
        '';
        ${syncthingHost}.extraConfig = ''
          tls internal
          reverse_proxy 127.0.0.1:2002
        '';
        "${sunshineHost}".extraConfig = ''
          tls internal
          reverse_proxy 0.0.0.0:47990
        '';
      };
    };
  };
}
