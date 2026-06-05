{
  namespace,
  config,
  osConfig ? { },
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.infra.desktop-manager.gnome.profile-default = {
    blurEffect = {
      enable = lib.mkEnableOption "Blur effect";
      dashToDock = lib.${namespace}.makeBoolOption { default = true; };
      brightness = lib.${namespace}.makeFloatOption { default = 0.6; };
      sigma = lib.${namespace}.makeIntOption { default = 30; };
    };
    extensions = lib.${namespace}.makeListOption {
      ofType = lib.types.submodule {
        options = {
          package = lib.${namespace}.makePackageOption { };
          settings = lib.${namespace}.makeAttrsOption { };
        };
      };
      default = [ ];
    };
  };

  config =
    let
      inherit (config.${namespace}.infra.desktop-manager) gnome;
      defaultExtensions = [
        { package = pkgs.gnomeExtensions.user-themes; }
        {
          package = pkgs.gnomeExtensions.dynamic-music-pill;
          settings = { };
        }
        {
          package = pkgs.gnomeExtensions.dash-to-dock;
          settings = { };
        }
        {
          package = pkgs.gnomeExtensions.gsconnect;
          settings = { };
        }
        {
          package = pkgs.gnomeExtensions.just-perfection;
          settings = { };
        }
        {
          package = pkgs.gnomeExtensions.places-status-indicator;
          settings = { };
        }
        {
          package = pkgs.gnomeExtensions.runcat;
          settings = { };
        }
        {
          package = pkgs.gnomeExtensions.caffeine;
          settings = { };
        }
        {
          package = pkgs.gnomeExtensions.kimpanel;
          settings = { };
        }
      ]
      ++ (lib.optional osConfig.${namespace}.infra.virtualisation.enable {
        package = pkgs.gnomeExtensions.containers;
      })
      ++ (lib.optional gnome.profile-default.blurEffect.enable {
        package = pkgs.gnomeExtensions.blur-my-shell;
        settings =
          let
            inherit (gnome.profile-default) blurEffect;
          in
          {
            "/" = {
              rounded-blur-found = false;
              settings-version = 2;
            };
            dash-to-dock = {
              blur = blurEffect.dashToDock;
              static-blur = true;
              style-dash-to-dock = 0;
              inherit (blurEffect) brightness sigma;
            };
            panel = {
              inherit (blurEffect) brightness sigma;
              corner-radius = 0;
            };
            appfolder = {
              inherit (blurEffect) brightness sigma;
            };
            window-list = {
              inherit (blurEffect) brightness sigma;
            };
          };
      });

      finalListExtensions = defaultExtensions ++ gnome.profile-default.extensions;

      extensions = map (
        {
          package,
          ...
        }:
        {
          id = package.extensionUuid;
          inherit package;
        }
      ) finalListExtensions;

      extensionSettings = lib.foldl' lib.recursiveUpdate { } (
        map (
          {
            package,
            settings ? { },
            ...
          }:
          lib.${namespace}.mkDconfTree "org/gnome/shell/extensions/${package.extensionPortalSlug}" settings
        ) finalListExtensions
      );
    in
    lib.mkIf (gnome.enabled && gnome.profile == "default") {
      home.packages = (with pkgs; [ morewaita-icon-theme ]) ++ (map (x: x.package) extensions);

      dconf = {
        settings = {
          "org/gnome/shell" = {
            enabled-extensions = map (x: x.package.extensionUuid) extensions;
          };
        }
        // extensionSettings;
      };
    };
}
