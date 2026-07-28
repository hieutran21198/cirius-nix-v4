{
  config,
  lib,
  namespace,
  ...
}:
{
  options.${namespace}.services.tailscale = {
    enable = lib.mkEnableOption "Enable Tailscale service";
  };
  config =
    let
      opts = config.${namespace}.services.tailscale;
    in
    lib.mkIf opts.enable {
      services.tailscale.enable = true;
      networking.nftables.enable = true;
      networking.firewall = {
        trustedInterfaces = [ config.services.tailscale.interfaceName ];
        allowedUDPPorts = [ config.services.tailscale.port ];
      };
      systemd.services.tailscaled.serviceConfig.Environment = [
        "TS_DEBUG_FIREWALL_MODE=nftables"
      ];
      systemd.network.wait-online.enable = false;
      boot.initrd.systemd.network.wait-online.enable = false;
      services.tailscale.permitCertUid = "caddy";
    };
}
