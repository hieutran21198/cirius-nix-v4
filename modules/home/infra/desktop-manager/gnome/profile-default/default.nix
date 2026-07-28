{
  namespace,
  config,
  osConfig ? { },
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./_keybindings.nix ];
  options.${namespace}.infra.desktop-manager.gnome.profile-default = {
    wallpaper = {
      default = lib.${namespace}.makePathOption {
        nullable = true;
        description = "Default wallpaper for the GNOME desktop manager";
      };
      dark = lib.${namespace}.makePathOption {
        nullable = true;
        description = "Dark wallpaper for the GNOME desktop manager";
      };
    };
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
        { package = pkgs.gnomeExtensions.appindicator; }
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
          settings = {
            "/" = {
              custom-system-monitor-enabled = false;
              displaying-items = "character-and-percentage";
              idle-threshold = 10;
              invert-speed = false;
            };
          };
        }
        {
          package = pkgs.gnomeExtensions.screentospace;
          settings = { };
        }
        {
          package = pkgs.gnomeExtensions.caffeine;
          settings = {
            "/" = {
              cli-toggle = false;
              duration-timer = 2;
              duration-timer-list = [
                900
                1800
                3600
              ];
              enable-fullscreen = true;
              enable-mpris = true;
              indicator-position-max = 2;
              nightlight-control = "never";
              restore-state = false;
              screen-blank = "never";
              show-indicator = "always";
              show-notifications = true;
              show-timer = true;
              show-toggle = true;
              trigger-apps-mode = "on-running";
            };
          };
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
              pipelines = "{'pipeline_default': {'name': <'Default'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000000'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>]>}, 'pipeline_default_rounded': {'name': <'Default rounded'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000001'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>, 'unscaled_radius': <30>}>}>, <{'type': <'corner'>, 'id': <'effect_000000000002'>, 'params': <{'radius': <16>}>}>]>}}";
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
            applications = {
              blacklist = [ ];
              blur = true;
              inherit (blurEffect) brightness sigma;
              enable-all = true;
              opacity = 215;
              static-blur = true;
              pipeline = "pipeline_default_rounded";
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
      home = {
        packages =
          (with pkgs; [
            morewaita-icon-theme
          ])
          ++ (map (x: x.package) extensions);
      };

      programs = {
        nixvim = {
          colorschemes = {
            one.enable = true;
          };
          colorscheme = "one";
          opts.termguicolors = lib.mkForce true;
        };
        ghostty = {
          settings = {
            theme = lib.mkForce "Atom One Dark";
            minimum-contrast = 1;
            background-opacity = lib.mkForce 0.9;
          };
        };
      };

      dconf = {
        settings = {
          "org/gnome/shell" = {
            enabled-extensions = map (x: x.package.extensionUuid) extensions;
          };
          "org/gnome/desktop/background" = {
            picture-uri = lib.mkIf (
              gnome.profile-default.wallpaper.default != null
            ) "file://${lib.toString gnome.profile-default.wallpaper.default}";
            picture-uri-dark = lib.mkIf (
              gnome.profile-default.wallpaper.dark != null
            ) "file://${lib.toString gnome.profile-default.wallpaper.dark}";
          };
        }
        // extensionSettings;
      };
    };
}
