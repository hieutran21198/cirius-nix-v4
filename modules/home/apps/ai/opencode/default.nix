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
    providerAPIKeys = lib.${namespace}.makeAttrsOption {
      ofType = lib.types.str;
      default = { };
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
      home = {
        packages = with pkgs; [
          ast-grep
          bun
        ];
        sessionVariables.OMO_AST_GREP_SG_PATH = "${pkgs.ast-grep}/bin/ast-grep";
      };
      programs.opencode = {
        enable = true;
        package = pkgs.llm-agents.opencode;
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
          provider = providerWithAPIKeys;
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
            "opencode-antigravity-auth@latest"
            "@mohak34/opencode-notifier@latest"
            "@franlol/opencode-md-table-formatter@latest"
            "opencode-claude-auth@latest"
            "opencode-openai-codex-auth"
            #   "oh-my-openagent@latest"
            #   [
            #     "@plannotator/opencode@latest"
            #     {
            #       "workflow" = "plan-agent";
            #       "planningAgents" = [
            #         "plan"
            #         "sisyphus" # depended on on-my-opencode
            #       ];
            #     }
            #   ]
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
