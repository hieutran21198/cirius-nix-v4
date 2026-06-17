{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.apps.ai.opencode = {
    enable = lib.mkEnableOption "Enable opencode";
    webEnvFile = lib.${namespace}.makePathOption {
      nullable = true;
      default = null;
    };
    providerAPIKeys = lib.${namespace}.makeAttrsOption {
      default = {
      };
    };
  };
  config =
    let
      opts = config.${namespace}.apps.ai.opencode;
      providerWithAPIKeys = lib.mapAttrs (_: value: {
        options.apiKey = "{file:${value}}";
      }) opts.providerAPIKeys;
    in
    lib.mkIf opts.enable {
      programs.opencode = {
        enable = true;
        package = pkgs.llm-agents.opencode;
        tui = { };
        web = {
          enable = true;
          environmentFile = opts.webEnvFile;
          extraArgs = [ ];
        };
        settings = {
          autoupdate = false;
          formatter = true;
          lsp = true;
          server = {
            port = 10200;
            hostname = "127.0.0.1";
          };
          agent = {
          };
          provider = { } // providerWithAPIKeys;
          compaction = {
            auto = true;
            prune = true;
            reserved = 10000;
          };
          watcher = {
            ignore = [
              "node_modules/**"
              "dist/**"
              ".git/**"
              ".devenv/**"
              ".direnv/**"
            ];
          };
          mcp = { };
          plugin = [
            "oh-my-opencode@latest"
            "@mohak34/opencode-notifier@latest"
            "@franlol/opencode-md-table-formatter@latest"
            "opencode-claude-auth@latest"
            [
              "@plannotator/opencode@latest"
              {
                "workflow" = "plan-agent";
                "planningAgents" = [
                  "plan"
                  "sisyphus" # depended on on-my-opencode
                ];
              }
            ]
          ];
          attachment = {
            image = {
              auto_resize = true;
              max_width = 2000;
              max_height = 2000;
              max_base64_bytes = 5242880;
            };
          };
        };
      };
    };
}
