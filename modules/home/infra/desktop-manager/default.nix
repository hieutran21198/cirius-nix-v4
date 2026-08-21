{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./_keybindings.nix ];

  options.${namespace}.infra.desktop-manager.core = {
    setFavoriteApps = lib.${namespace}.makeListOption {
      ofType = lib.types.str;
      default = [ ];
    };
    wallpaper = {
      default = lib.${namespace}.makePathOption {
        nullable = true;
        description = "Default wallpaper for the kde desktop manager";
      };
      dark = lib.${namespace}.makePathOption {
        nullable = true;
        description = "Dark wallpaper for the kde desktop manager";
      };
    };
    blurEffect = {
      enable = lib.mkEnableOption "Blur effect";
    };
  };

  config =
    let
      inherit (config.${namespace}.infra.desktop-manager) core kde gnome;
    in
    lib.mkMerge [
      (lib.mkIf gnome.enabled {
        ${namespace}.infra.desktop-manager.gnome.profile-default = {
          extensions = (
            lib.optional core.blurEffect.enable {
              package = pkgs.gnomeExtensions.blur-my-shell;
              settings = {
                "/" = {
                  rounded-blur-found = false;
                  settings-version = 2;
                  pipelines = "{'pipeline_default': {'name': <'Default'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000000'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>]>}, 'pipeline_default_rounded': {'name': <'Default rounded'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000001'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>, 'unscaled_radius': <30>}>}>, <{'type': <'corner'>, 'id': <'effect_000000000002'>, 'params': <{'radius': <12>}>}>]>}}";
                };
                dash-to-dock = {
                  blur = true;
                  static-blur = true;
                  style-dash-to-dock = 0;
                  brightness = 0.6;
                  sigma = 30;
                };
                panel = {
                  static-blur = true;
                  pipeline = "pipeline_default_rounded";
                  corner-radius = 0;
                  brightness = 0.6;
                  sigma = 30;
                };
                appfolder = {
                  brightness = 0.6;
                  sigma = 30;
                };
                window-list = {
                  brightness = 0.6;
                  sigma = 30;
                };
                applications = {
                  blacklist = [ ];
                  brightness = 0.6;
                  sigma = 30;
                  blur = true;
                  enable-all = true;
                  opacity = 215;
                  static-blur = true;
                  pipeline = "pipeline_default_rounded";
                };
              };
            }
          );
        };
        dconf =
          let
            primaryColorFile =
              pkgs.runCommand "wallpaper-primary-color"
                {
                  nativeBuildInputs = [ pkgs.imagemagick ];
                }
                ''
                  magick ${core.wallpaper.default} \
                    -resize 128x128 \
                    -colors 8 \
                    -format '%c' histogram:info:- \
                    | sort -nr \
                    | head -n 1 \
                    | grep -oE '#[0-9A-Fa-f]{6}' \
                    | head -n 1 \
                    > "$out"
                '';

            primaryColor = lib.trim (builtins.readFile primaryColorFile);
          in
          {
            enable = true;
            settings = {
              "org/gnome/shell" = {
                favorite-apps = core.setFavoriteApps;
              };
              "org/gnome/desktop/background" = {
                picture-uri = lib.mkIf (
                  core.wallpaper.default != null
                ) "file://${lib.toString core.wallpaper.default}";
                picture-uri-dark = lib.mkIf (
                  gnome.profile-default.wallpaper.dark != null
                ) "file://${lib.toString core.wallpaper.dark}";
                inherit primaryColor;
                secondary-color = "#000000";
              };
            };
          };
      })
      (lib.mkIf kde.enabled {
        programs.plasma = {
          workspace = {
            wallpaper = core.wallpaper.default;
          };
        };
      })
    ];
}
