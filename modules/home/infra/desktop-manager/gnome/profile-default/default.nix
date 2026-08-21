{
  namespace,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./_keybindings.nix ];
  options.${namespace}.infra.desktop-manager.gnome.profile-default = {
    extensions = lib.${namespace}.makeListOption {
      ofType = lib.types.submodule {
        options = {
          package = lib.${namespace}.makePackageOption { };
          settings = lib.${namespace}.makeAttrsOption { };
        };
      };
      default = [ ];
    };
    dockPosition = lib.${namespace}.makeEnumOption {
      acceptedList = [
        "LEFT"
        "RIGHT"
        "BOTTOM"
      ];
      default = "LEFT";
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
          settings = {
            "/" = {
              dock-position = gnome.profile-default.dockPosition;
            };
          };
        }
        {
          package = pkgs.gnomeExtensions.gsconnect;
          settings = { };
        }
        {
          package = pkgs.gnomeExtensions.just-perfection;
          settings = {
            "/" = {
              startup-status = 0;
            };
          };
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
      # ++ (lib.optional osConfig.${namespace}.infra.virtualisation.enable {
      #   package = pkgs.gnomeExtensions.containers;
      # })
      ;

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
          "org/gnome/desktop/peripherals/keyboard" = {
            # prevent repeating keys to be too fast
            repeat = true;
            repeat-interval = 30;

            # Key repeat delay when keeping a key pressed (in milliseconds). The default is 500ms.
            delay = 500;
          };
        }
        // extensionSettings;
      };
    };
}
