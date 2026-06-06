{
  config,
  lib,
  namespace,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule
      [
        namespace
        "infra"
        "networking"
        "firewall"
      ]
      [ "networking" "firewall" ]
    )
  ];
  options.${namespace}.infra.networking = {
    enable = lib.mkEnableOption "Enable networking feature";
    hostName = lib.${namespace}.makeStrOption {
      default = "nixos";
    };
  };
  config =
    let
      inherit (config.${namespace}) infra;
    in
    lib.mkIf infra.networking.enable {
      networking = {
        networkmanager = {
          enable = true;
        };
        inherit (infra.networking) hostName;
      };
      services.openssh = {
        enable = true;
      };

      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://proxy.example:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    };
}
