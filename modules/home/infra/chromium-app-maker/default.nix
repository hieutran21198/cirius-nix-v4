{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
{
  options.${namespace}.infra.chromiumAppMaker =
    let
      inherit (lib.${namespace})
        makeAttrsOption
        makeListOption
        makeStrOption
        makePathOption
        ;
    in
    {
      dataDir = makeStrOption {
        default = config.xdg.dataHome + "/chromium-app-maker";
        description = "Directory to be used by the app maker to store data";
      };
      registerApps = makeAttrsOption {
        ofType =
          with lib.types;
          submodule (
            { name, ... }:
            {
              options = {
                class = makeStrOption {
                  default = name;
                  description = "Class of the app to be registered";
                };
                name = makeStrOption {
                  default = name;
                  description = "Name of the app to be registered";
                };
                genericName = makeStrOption {
                  default = name;
                  description = "Generic name of the app to be registered";
                };
                comment = makeStrOption {
                  default = name;
                  description = "Comment of the app to be registered";
                };
                url = makeStrOption {
                  description = "URL of the app to be registered";
                };
                categories = makeListOption {
                  ofType = lib.types.str;
                  default = [ "Network" ];
                  description = "Categories of the app to be registered";
                };
                icon = makePathOption {
                  description = "Icon of the app to be registered";
                };
              };
            }
          );
      };
    };

  config =
    let
      opts = config.${namespace}.infra.chromiumAppMaker;
      chromiumExe = lib.getExe pkgs.chromium;
    in
    {
      home.packages = with pkgs; [ chromium ];
      xdg.desktopEntries = lib.mapAttrs (name: attrs: {
        inherit (attrs)
          name
          genericName
          comment
          categories
          icon
          ;
        exec = lib.concatStringsSep " " [
          chromiumExe
          "--user-data-dir=${opts.dataDir}/${name}"
          "--app=${attrs.url}"
        ];
        terminal = false;
        settings = {
          StartupWMClass = attrs.class;
        };
      }) opts.registerApps;
    };
}
