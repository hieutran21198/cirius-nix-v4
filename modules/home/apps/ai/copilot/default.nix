{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai.copilot = {
    enable = lib.mkEnableOption "Enable copilot";
  };

  config =
    let
      opts = config.${namespace}.apps.ai.copilot;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ llm-agents.copilot-cli ];

      ${namespace} = {
        apps.nvim = {
          extra-deps = {
            copilot-lua = {
              enable = true;
              settings = {
                suggestion.enabled = false;
                panel.enabled = false;
              };
            };
            blink-cmp-copilot = {
              enable = true;
            };
          };
          auto-completion = {
            sources = [ "copilot" ];
            providers = {
              copilot = {
                async = true;
                module = "blink-cmp-copilot";
                name = "copilot";
                score_offset = 100;
              };
            };
          };
        };
      };
    };
}
