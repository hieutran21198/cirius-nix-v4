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
    persistFingerprint = lib.mkEnableOption "Clear cookies and site data everytime closing librewolf";
    containers = lib.mkOption {
      type =
        with lib.types;
        attrsOf (submodule {
          options = {
            id = lib.mkOption {
              type = lib.types.int;
              default = 1;
            };
            color = lib.mkOption { type = lib.types.str; };
            icon = lib.mkOption { type = lib.types.str; };
          };
        });
      default = { };
      description = "Profile's containers";
    };
    extensions = lib.mkOption {
      type =
        with lib.types;
        attrsOf (submodule {
          options = {
            package = lib.mkOption { type = with lib.types; package; };
            settings = lib.mkOption {
              type = with lib.types; attrsOf anything;
              default = { };
            };
          };
        });
      default = { };
      description = "Extensions";
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
          "privacy.clearOnShutdown.offlineApps" = false;
          "privacy.clearOnShutdown_v2.formdata" = true;
          "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.trackingprotection.cryptomining.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
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
    };
}
