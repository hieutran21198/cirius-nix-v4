{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.proton-pass = {
    enable = lib.mkEnableOption "Enable proton-pass";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };
  config =
    let
      inherit (config.${namespace}) apps;
      firefoxExt = pkgs.firefox-extensions.proton-pass;
    in
    lib.mkIf apps.proton-pass.enable {
      home.packages = with pkgs; [
        proton-pass
        proton-pass-cli
      ];
      ${namespace} = {
        infra.desktop-manager = {
          gnome.setFavoriteApps = [
            "proton-pass.desktop"
          ];
        };
        apps.librewolf = {
          # moz-extension://962aca5c-4c9f-4088-ae7c-8d74cc1463d4/manifest.json
          extensions.${firefoxExt.addonId} = {
            package = firefoxExt;
            settings = {
              force = true;
              permissions = [
                "activeTab"
                "alarms"
                "scripting"
                "storage"
                "unlimitedStorage"
                "webNavigation"
                "webRequest"
                "webRequestBlocking"
                "https://account.proton.me/*"
                "https://pass.proton.me/*"

                # # optional permissions
                # "privacy"
                # "webRequestAuthProvider"
                # "clipboardRead"
                # "clipboardWrite"
                # "nativeMessaging"

                # host permissions
                "https://*/*"
                "http://*/*"
              ];
            };
          };
        };
      };
    };
}
