{
  osConfig ? { },
  namespace,
  lib,
  config,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule
      [ namespace "infra" "desktop-manager" "kde" "panels" ]
      [ "programs" "plasma" "panels" ]
    )
  ];
  options.${namespace}.infra.desktop-manager.kde = {
    enabled = lib.${namespace}.makeBoolOption {
      readOnly = true;
    };
    widgets = lib.mkOption {
      type = with lib.types; attrsOf (import ./_widget-type.nix { inherit lib namespace; });
      default = { };
      description = "Widgets to be enabled in the default KDE profile.";
    };
    profile = lib.${namespace}.makeEnumOption {
      acceptedList = [ "default" ];
      default = "default";
    };
  };
  config =
    let
      inherit (config.${namespace}.infra.desktop-manager) kde;
    in
    lib.mkMerge [
      {
        ${namespace}.infra.desktop-manager.kde = {
          enabled = lib.mkForce (osConfig.${namespace}.infra.desktop-manager.engine == "kde");
        };
        xdg = {
          enable = lib.mkDefault true;
        };
      }
      (lib.mkIf kde.enabled {
        ${namespace}.infra.shell.fish.shellAbbrs = {
          ls-widgets = "ls /run/current-system/sw/share/plasma/plasmoids";
          ls-colorschemes = "plasma-apply-colorscheme --list-schemes";
          ls-cursorthemes = "plasma-apply-cursortheme --list-themes";
          ls-lookandfeels = "plasma-apply-lookandfeel --list";
        };
        programs.plasma = {
          enable = true;
          powerdevil = {
            AC = {
              autoSuspend = {
                action = "sleep"; # hibernate | nothing | shutdown | sleep
                idleTimeout = 1800;
              };
              turnOffDisplay = {
                idleTimeout = 600;
                idleTimeoutWhenLocked = "whenLockedAndUnlocked";
              };
            };
          };
          session = {
            general = {
              askForConfirmationOnLogout = true;
            };
            sessionRestore = {
              restoreOpenApplicationsOnLogin = "startWithEmptySession";
            };
          };
        };
      })
    ];
}
