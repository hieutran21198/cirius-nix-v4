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
    integrateLibrewolf = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Integrate librewolf browser";
    };
  };
  config =
    let
      inherit (config.${namespace}) apps;
    in
    lib.mkIf apps.proton-pass.enable {
      home.packages = with pkgs; [ proton-pass ];

      ${namespace} =
        let
          firefoxExt = pkgs.firefox-extensions.proton-pass;
        in
        {
          apps = {
            # moz-extension://962aca5c-4c9f-4088-ae7c-8d74cc1463d4/manifest.json
            librewolf.extensions.${firefoxExt.addonId} = lib.mkIf apps.proton-pass.integrateLibrewolf {
              package = firefoxExt;
              settings = {
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

                  # optional permissions
                  "privacy"
                  "webRequestAuthProvider"
                  "clipboardRead"
                  "clipboardWrite"
                  "nativeMessaging"

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
