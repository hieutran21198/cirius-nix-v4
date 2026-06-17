{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.ghostty = {
    enable = lib.mkEnableOption "Enable ghostty";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
    settings = lib.${namespace}.makeAttrsOption {
      default = { };
    };
  };
  config =
    let
      inherit (config.${namespace}) apps;
    in
    lib.mkIf apps.ghostty.enable {
      programs.ghostty = {
        enable = true;
        systemd = {
          enable = true;
        };
        enableFishIntegration = config.${namespace}.infra.shell.fish.enabled;
        settings = {
          adjust-cell-height = "40%";
          copy-on-select = "clipboard";
          window-padding-x = 8;
          window-padding-y = 8;
          window-padding-balance = true;

          keybind = [
            # Pane management
            "ctrl+a>v=new_split:right"
            "ctrl+a>s=new_split:down"
            # Move between panes - vim style
            "ctrl+a>h=goto_split:left"
            "ctrl+a>j=goto_split:down"
            "ctrl+a>k=goto_split:up"
            "ctrl+a>l=goto_split:right"

            # Pane utilities
            "ctrl+a>z=toggle_split_zoom"
            "ctrl+a>equal=equalize_splits"

            # tab management
            "ctrl+a>tab=next_tab"
            "ctrl+a>shift+tab=previous_tab"
            "ctrl+a>t=activate_key_table:tab_mgt"
            "tab_mgt/n=new_tab"
            "tab_mgt/r=prompt_tab_title"
            "tab_mgt/escape=deactivate_key_table"
            "tab_mgt/q=deactivate_key_table"
            "tab_mgt/catch_all=ignore"

            # resize mode
            "ctrl+a>r=activate_key_table:resize"
            "resize/h=resize_split:left,20"
            "resize/j=resize_split:down,20"
            "resize/k=resize_split:up,20"
            "resize/l=resize_split:right,20"
            "resize/e=equalize_splits"
            "resize/escape=deactivate_key_table"
            "resize/q=deactivate_key_table"
            "resize/catch_all=ignore"

            "ctrl+a>slash=start_search"
            "ctrl+a>escape=end_search"
          ];

        }
        // apps.ghostty.settings;
      };

      stylix.targets.ghostty.enable = true;

      ${namespace} = {
        infra.desktop-manager = {
          gnome.setFavoriteApps = [ "com.mitchellh.ghostty.desktop" ];
        };
      };
    };
}
