{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
let
  engine = "kde";
in
{
  options.${namespace}.infra.desktop-manager.settings.${engine} = {
    useWalletByLUKS = lib.mkEnableOption "Using KDE Wallet with LUKS password";
  };
  config =
    let
      dmOpts = config.${namespace}.infra.desktop-manager;
      enabled = dmOpts.enable && dmOpts.engine == engine;
      opts = dmOpts.settings.${engine};
    in
    lib.mkMerge [
      (lib.mkIf enabled {
        environment = {
          plasma6.excludePackages = with pkgs.kdePackages; [
            konsole
            elisa
          ];
          systemPackages = with pkgs; [ wl-clipboard ];
        };

        services = {
          desktopManager.plasma6.enable = true;
          displayManager.plasma-login-manager.enable = true;
        };
        hardware.bluetooth.enable = lib.mkDefault true;
      })
      (lib.mkIf (enabled && opts.useWalletByLUKS) {
        systemd.services.plasmalogin.serviceConfig.KeyringMode = lib.mkForce "inherit";
        security.pam.services.plasmalogin-autologin.rules.auth = {
          systemd_loadkey = {
            order = 0;
            control = "optional";
            modulePath = "${pkgs.systemd}/lib/security/pam_systemd_loadkey.so";
          };
          plasmalogin = {
            order = 1;
            control = "include";
            modulePath = "plasmalogin";
          };
        };
      })
    ];
}
