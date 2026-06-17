{
  namespace,
  lib,
  config,
  ...
}:
{
  options.${namespace}.infra.desktop-manager.gnome.profile-default = {
    enableCustomKeyBindings = lib.${namespace}.makeBoolOption {
      default = true;
    };
  };
  config =
    let
      inherit (config.${namespace}.infra.desktop-manager) gnome;

      listOpenNewWindowAppBindings = builtins.genList (x: {
        name = "open-new-window-application-${toString (x + 1)}";
        value = [ ];
      }) 9;

      listSwitchToApplicationBindings = builtins.genList (x: {
        name = "switch-to-application-${toString (x + 1)}";
        value = [ ];
      }) 9;

      listMoveWindowToWorkspaceBindings = builtins.genList (x: {
        name = "move-to-workspace-${toString (x + 1)}";
        value = if (x + 1) <= 9 then [ "<super><shift>${toString (x + 1)}" ] else [ ];
      }) 11;

      listSwitchToWorkspaceBindings = builtins.genList (x: {
        name = "switch-to-workspace-${toString (x + 1)}";
        value = if (x + 1) <= 9 then [ "<super>${toString (x + 1)}" ] else [ ];
      }) 11;
    in
    lib.mkIf (gnome.enabled && gnome.profile == "default") {
      dconf = {
        settings = lib.optionalAttrs gnome.profile-default.enableCustomKeyBindings {
          "org/gnome/shell/keybindings" = {
            # disable noise mappings
            toggle-quick-settings = [ ];

            # use overview instead of app views
            toggle-application-view = [ ];
            toggle-overview = [ "<super>d" ];
            # notification
            toggle-message-tray = [ "<super>n" ];

            # screen brightness - keep it as-is
            screen-brightness-cycle = [ "XF86MonBrightnessCycle" ];
            screen-brightness-cycle-monitor = [ "<shift>XF86MonBrightnessCycle" ];
            screen-brightness-down = [ "XF86MonBrightnessDown" ];
            screen-brightness-down-monitor = [ "<shift>XF86MonBrightnessDown" ];
            screen-brightness-up = [ "XF86MonBrightnessDown" ];
            screen-brightness-up-monitor = [ "<shift>XF86MonBrightnessDown" ];

            # screen-shot
            screenshot = [ ];
            show-screenshot-ui = [ "<super><shift>s" ];
            screenshot-window = [ "<super><shift>w" ];
            show-screen-recording-ui = [ ];

            # shift - overview
            shift-overview-up = [ ];
            shift-overview-down = [ ];
          }
          // (lib.listToAttrs listOpenNewWindowAppBindings)
          // (lib.listToAttrs listSwitchToApplicationBindings);
          "org/gnome/desktop/wm/keybindings" = {
            activate-window-menu = [ "<alt><F1>" ];

            # specific mode
            begin-move = [ "<super><alt>m" ];
            begin-resize = [ "<super><alt>r" ];

            # close
            close = [
              "<alt><F4>"
              "<super>q"
            ];

            cycle-group = [ ];
            cycle-group-backward = [ ];
            cycle-panels = [ ];
            cycle-panels-backward = [ ];
            cycle-windows = [ ];
            cycle-windows-backward = [ ];

            lower = [ ];
            always-on-top = [ ];

            maximize = [ "<super>Up" ];
            maximize-horizontally = [ ];
            maximize-vertically = [ ];
            minimize = [ "<super>m" ];

            # moving
            move-to-center = [ ];
            move-to-corner-ne = [ ];
            move-to-corner-nw = [ ];
            move-to-corner-se = [ ];
            move-to-corner-sw = [ ];
            move-to-side-e = [ ];
            move-to-side-s = [ ];
            move-to-side-n = [ ];
            move-to-side-w = [ ];
            move-to-monitor-down = [ "<super><shift><Pg_Down>" ];
            move-to-monitor-up = [ "<super><shift><Pg_Up>" ];
            move-to-monitor-left = [ ];
            move-to-monitor-right = [ ];
            move-to-workspace-down = [ ];
            move-to-workspace-up = [ ];
            move-to-workspace-left = [ "<super><shift>Left" ];
            move-to-workspace-right = [ "<super><shift>Right" ];

            panel-run-dialog = [ ];
            raise = [ ];
            raise-or-lower = [ ];
            set-spew-mark = [ ];
            show-desktop = [ "<super><shift>d" ];
            switch-applications = [ "<alt>Tab" ];
            switch-applications-backward = [ "<alt><shift>Tab" ];
            switch-group = [ ];
            switch-group-backward = [ ];
            switch-input-source = [
              "<super><shift><space>"
              "XF86Keyboard"
            ];
            switch-input-source-backward = [ ];
            switch-panels = [ ];
            switch-panels-backward = [ ];
            switch-to-workspace-down = [ ];
            switch-to-workspace-up = [ ];
            switch-to-workspace-last = [ ];
            switch-to-workspace-right = [ "<super>Tab" ];
            switch-to-workspace-left = [ "<super><shift>Tab" ];
            switch-windows = [ ];
            switch-windows-backward = [ ];
            toggle-above = [ ];
            toggle-fullscreen = [ "<alt><F11>" ];
            toggle-maximize = [ ];
            toggle-on-all-workspaces = [ ];
            unmaximize = [ "<super>Down" ];
          }
          // (lib.listToAttrs listMoveWindowToWorkspaceBindings)
          // (lib.listToAttrs listSwitchToWorkspaceBindings);
        };
      };
    };
}
