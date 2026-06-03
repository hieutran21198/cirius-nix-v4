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
      containers = lib.mapAttrs (name: value: value // { inherit name; }) opts.containers;
      extensionsPackages =
        (with pkgs.firefox-extensions; [ ublock-origin ])
        ++ (lib.mapAttrsToList (_: value: value.package) opts.extensions);
      extensionsSettings = {
        "uBlock0@raymondhill.net" = {
          settings = {
            selectedFilterLists = [
              "ublock-filters"
              "ublock-badware"
              "ublock-privacy"
              "ublock-unbreak"
              "ublock-quick-fixes"
              "easylist"
              "adguard-spyware-url"
              "easyprivacy"
              "urlhaus-1"
              "curben-phishing"
              "plowe-0"
              "LegitimateURLShortener"
            ];
            "whitelist" = [
              "chrome-extension-scheme"
              "moz-extension-scheme"
            ];
            "dynamicFilteringString" = ''
              behind-the-scene * * noop
              behind-the-scene * inline-script noop
              behind-the-scene * 1p-script noop
              behind-the-scene * 3p-script noop
              behind-the-scene * 3p-frame noop
              behind-the-scene * image noop
              behind-the-scene * 3p noop
            '';
            "FilteringString" = "";
            "hostnameSwitchesString" = ''
              no-large-media: behind-the-scene false
              no-csp-reports: * true
            '';
            "userFilters" = "";
          };
        };
      }
      // (lib.mapAttrs (_: value: value.settings) opts.extensions);

      applyBoolForList =
        bool: list:
        lib.listToAttrs (
          map (name: {
            inherit name;
            value = bool;
          }) list
        );
    in
    lib.mkIf opts.enable {
      programs.librewolf = {
        enable = true;
        package = pkgs.librewolf;
        profiles.default = {
          containersForce = true;
          extensions = {
            force = true;
            packages = extensionsPackages;
            settings = extensionsSettings;
          };
          inherit containers;
        };
        settings = {
          "privacy.clearOnShutdown.offlineApps" = false;
          "privacy.clearOnShutdown_v2.formdata" = true;
          "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
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
