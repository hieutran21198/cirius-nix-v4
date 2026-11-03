{
  namespace,
  config,
  ...
}:
let

  inherit (config) sops;

  hostName = "mht-home-pc";
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
    };
  };
}
