{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule [ namespace "apps" "firefox" ] [ namespace "apps" "librewolf" ])
  ];
  options.${namespace}.apps.librewolf = {
    enable = lib.mkEnableOption "Enable librewolf";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
    persistFingerprint = lib.mkEnableOption "Clear cookies and site data everytime closing librewolf";
    enableSidebarTabs = lib.mkEnableOption "Enable vertical tab";
    containers = lib.${namespace}.makeAttrsOption {
      ofType = lib.types.submodule {
        options = {
          id = lib.${namespace}.makeIntOption {
            nullable = false;
            default = 0;
          };
          color = lib.${namespace}.makeStrOption { };
          icon = lib.${namespace}.makeStrOption { };
        };
      };
      default = { };
    };
    extensions = lib.${namespace}.makeAttrsOption {
      ofType = lib.types.submodule {
        options = {
          package = lib.${namespace}.makePackageOption { nullable = false; };
          settings = lib.${namespace}.makeAttrsOption {
            nullable = false;
            default = { };
          };
        };
      };
      default = { };
    };
  };
  config =
    let
      opts = config.${namespace}.apps.librewolf;

      applyBoolForList =
        bool: list:
        lib.listToAttrs (
          map (name: {
            inherit name;
            value = bool;
          }) list
        );

      containers = lib.mapAttrs (n: v: v // { name = n; }) opts.containers;
      extensionsPackages = lib.mapAttrsToList (_: value: value.package) opts.extensions;
      extensionsSettings = lib.mapAttrs (_: v: v.settings) opts.extensions;
    in
    lib.mkIf opts.enable {
      programs.librewolf = {
        enable = true;
        package = pkgs.librewolf;
        profiles.default = {
          containersForce = true;
          isDefault = true;
          extensions = {
            force = true;
            exactPermissions = true;
            packages = extensionsPackages;
            settings = extensionsSettings;
          };
          inherit containers;
        };
        settings = {
          "browser.profiles.enabled" = true;
          "browser.tabs.groups.enabled" = true;
          "browser.tabs.allowTabDetach" = true;
          "browser.tabs.closeWindowWithLastTab" = false;
          "browser.tabs.groups.smart.enabled" = false;
          "browser.tabs.groups.smart.userEnabled" = false;
          "sidebar.verticalTabs" = opts.enableSidebarTabs;
          "browser.toolbars.bookmarks.visibility" = "never";
          "privacy.clearOnShutdown.offlineApps" = false;
          "privacy.clearOnShutdown_v2.formdata" = true;
          "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.trackingprotection.cryptomining.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.resistFingerprinting.enabled" = false;
          "privacy.firstparty.isolate" = true;
          "privacy.query_stripping.enabled" = true;
          "privacy.query_stripping.strip_list" =
            "utm_source utm_medium utm_campaign utm_term utm_content fbclid gclid dclid twclid";
          "webgl.disabled" = true;
          "geo.enabled" = false;
          "media.navigator.enabled" = false;
        }
        // (applyBoolForList (opts.persistFingerprint == false) [
          "privacy.clearOnShutdown.cache"
          "privacy.clearOnShutdown.cookies"
          "privacy.clearOnShutdown.downloads"
          "privacy.clearOnShutdown.formdata"
          "privacy.clearOnShutdown.history"
          "privacy.clearOnShutdown.openWindows"
          "privacy.clearOnShutdown.sessions"
          "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads"
          "privacy.clearOnShutdown_v2.cache"
          "privacy.clearOnShutdown_v2.cookiesAndStorage"
          "privacy.clearOnShutdown_v2.siteSettings"
        ]);
      };

      ${namespace} = {
        infra.desktop-manager = {
          gnome.setFavoriteApps = [ "librewolf.desktop" ];
        };
      };
    };
}
