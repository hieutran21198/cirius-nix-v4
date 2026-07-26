{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.services.cloudflare-warp = {
    enable = lib.mkEnableOption "Enable cloudflare-warp";
  };

  config =
    let
      opts = config.${namespace}.services.cloudflare-warp;
    in
    lib.mkIf opts.enable {
      services.cloudflare-warp = {
        enable = true;
        openFirewall = true;
        rootDir = "/var/lib/cloudflare-warp";
        udpPort = 2408;
      };
    };
}
