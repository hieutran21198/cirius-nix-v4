{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.atuin = {
    enable = lib.mkEnableOption "Enable atuin";
  };

  config =
    let
      opts = config.${namespace}.apps.atuin;
    in
    lib.mkIf opts.enable {
      programs.atuin = {
        enable = true;
        enableFishIntegration = config.${namespace}.infra.shell.fish.enabled;
        daemon = {
          enable = true;
          logLevel = "error";
        };
        flags = [
          "--disable-up-arrow"
        ];
        settings = {
          # index in RAM
          search_mode = "daemon-fuzzy";

          # git
          workspaces = true;
          filter_mode = "workspace";

          # UI
          style = "compact";
          inline_height = 20;
          show_preview = true;
          max_preview_height = 4;
          show_help = true;
          show_tabs = true;

          # persist current text when pressing enter.
          exit_mode = "return-query";

          enter_accept = false;
          keymap_mode = "auto";
          store_failed = true;
          secrets_filter = true;
          update_check = false;

          history_filter = [
            "^export .*(_TOKEN|_KEY|_SECRET|_PASSWORD)="
            "^set (-x|--export) .*(_TOKEN|_KEY|_SECRET|_PASSWORD)"

            ".*(--password|--token|--secret|--api-key)(=| ).*"

            "^atuin login"
          ];

          search = {
            filters = [
              "workspace"
              "directory"
              "session"
              "host"
              "global"
            ];

            recency_score_multiplier = 2;
            frequency_score_multiplier = 1;
            frecency_score_multiplier = 1;
          };
        };
      };
    };
}
