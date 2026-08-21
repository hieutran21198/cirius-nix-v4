# This module provides an interface to map keybindings for desktop managers like GNOME and KDE.
{
  namespace,
  lib,
  config,
  ...
}:
let
  inherit (lib.${namespace}) makeAttrsOption makeStrOption;

  kdeActionType = lib.types.submodule {
    options = {
      group = makeStrOption {
        description = "Plasma shortcut group or KGlobalAccel component.";
      };
      action = makeStrOption {
        description = "KGlobalAccel action identifier.";
      };
    };
  };
in
{
  options.${namespace}.infra.desktop-manager.keybindings = {
    extendGNOMEActions = makeAttrsOption {
      ofType = lib.types.str;
      default = { };
    };
    extendKDEActions = makeAttrsOption {
      ofType = kdeActionType;
      default = { };
    };
    bindings = makeAttrsOption {
      ofType = with lib.types; listOf (listOf str);
      default = { };
      description = "Canonical desktop-manager actions mapped to key sequences.";
    };
  };

  config =
    let
      inherit (lib.${namespace}) supportedDesktopManagers;
      opts = config.${namespace}.infra.desktop-manager.keybindings;
      mapKeyTokens = {
        "${supportedDesktopManagers.gnome}" = import ./_gnome.modifier.nix;
        "${supportedDesktopManagers.kde}" = (import ./_kde.modifier.nix) // (import ./_kde.key.nix);
      };

      # Input:
      # [
      #   [ "Meta" "Up" ]
      #   [ "Alt" "F10" ]
      # ]
      #
      # Output:
      # Gnome:
      # [
      #   "<Super>Up"
      #   "<Alt>F10"
      # ]
      # KDE:
      # [
      #   "Meta+Up"
      #   "Alt+F10"
      # ]
      combineKeybindings =
        {
          keys ? [ ],
          de ? supportedDesktopManagers.kde,
          ...
        }:
        let
          currentKeyTokens = mapKeyTokens.${de} or { };
          combine =
            keybinding:
            let
              convertedKeys = lib.map (key: currentKeyTokens.${key} or key) keybinding;
            in
            if de == supportedDesktopManagers.kde then
              lib.concatStringsSep "+" convertedKeys
            else
              lib.concatStrings convertedKeys;
        in
        lib.map combine keys;

      mapActions = {
        "${supportedDesktopManagers.gnome}" =
          lib.recursiveUpdate (import ./_gnome.action.nix) opts.extendGNOMEActions;
        "${supportedDesktopManagers.kde}" =
          lib.recursiveUpdate (import ./_kde.action.nix) opts.extendKDEActions;
      };

      configuredActionsFor =
        {
          de ? supportedDesktopManagers.gnome,
          bindings ? { },
          ...
        }:
        let
          actions = mapActions.${de};
        in
        lib.filterAttrs (canonical: _: builtins.hasAttr canonical bindings) actions;

      translateGNOMEKeybindings =
        bindings:
        lib.mapAttrs'
          (canonical: native: {
            name = native;
            value = combineKeybindings {
              keys = bindings.${canonical};
              de = supportedDesktopManagers.gnome;
            };
          })
          (configuredActionsFor {
            de = supportedDesktopManagers.gnome;
            inherit bindings;
          });

      translateKDEKeybindings =
        bindings:
        lib.foldl'
          (
            translated: canonical:
            let
              native = mapActions.${supportedDesktopManagers.kde}.${canonical};
            in
            lib.recursiveUpdate translated {
              ${native.group}.${native.action} = combineKeybindings {
                keys = bindings.${canonical};
                de = supportedDesktopManagers.kde;
              };
            }
          )
          { }
          (
            lib.attrNames (configuredActionsFor {
              de = supportedDesktopManagers.kde;
              inherit bindings;
            })
          );

      inherit (config.${namespace}.infra.desktop-manager) kde gnome;
    in
    lib.mkMerge [
      (lib.mkIf kde.enabled {
        programs.plasma.shortcuts = translateKDEKeybindings opts.bindings;
      })
      (lib.mkIf gnome.enabled {
        dconf = {
          settings =
            let
              translatedBindings = translateGNOMEKeybindings opts.bindings;

              filterAndTrimPrefix =
                prefix: bindings:
                let
                  filteredBindings = lib.filterAttrs (name: _: lib.hasPrefix prefix name) bindings;
                in
                lib.mapAttrs' (name: value: {
                  name = lib.removePrefix prefix name;
                  inherit value;
                }) filteredBindings;
            in
            {
              "org/gnome/shell/keybindings" = filterAndTrimPrefix "shell." translatedBindings;
              "org/gnome/desktop/wm/keybindings" = filterAndTrimPrefix "wm." translatedBindings;
            };
        };
      })
    ];
}
