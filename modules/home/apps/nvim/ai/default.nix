{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.nvim.ai = {
    setCompletionCap = lib.${namespace}.makeIntOption { default = 0; };
    defaultOpenAIFIMCompatible = lib.${namespace}.makeAttrsOption {
      default = { };
    };
    fimPresets = lib.${namespace}.makeAttrsOption {
      default = { };
    };
    fimSettings = lib.${namespace}.makeAttrsOption {
    };
  };

  config =
    let
      inherit (config.${namespace}.apps) nvim;
    in
    lib.mkIf nvim.enable {
      programs.nixvim = {
        plugins = {
          blink-cmp.settings = {
            appearance = {
              kind_icons = {
                claude = "󰋦";
                openai = "󱢆";
                codestral = "󱎥";
                gemini = "";
                Groq = "";
                Openrouter = "󱂇";
                Ollama = "󰳆";
                "Llama.cpp" = "󰳆";
                Deepseek = "";
              };
            };
            sources = {
              default = [ "minuet" ];
              providers = {
                minuet = {
                  name = "minuet";
                  module = "minuet.blink";
                  async = true;
                  timeout_ms = 3000;
                  score_offset = 50;
                };
              };
            };
            completion = {
              trigger = {
                prefetch_on_insert = false;
              };
            };
          };
          minuet = {
            enable = true;
            settings = {
              provider = "openai_fim_compatible";
              n_completions = nvim.ai.setCompletionCap;
              context_window = 1024;
              context_ratio = 0.75;
              throttle = 1000;
              debounce = 400;
              request_timeout = 3;
              add_single_line_entry = true;
              notify = "warn";
              presets = { } // nvim.ai.fimPresets;
              provider_options = {
                openai_fim_compatible = nvim.ai.defaultOpenAIFIMCompatible;
              };
              blink = {
                enable_auto_complete = true;
              };
              # turn off virtual text, let's blink completion handle it.
              virtualtext = {
                auto_trigger_ft = [ ];
                keymap = {
                  accept = null;
                  accept_line = null;
                  accept_n_lines = null;
                  next = null;
                  prev = null;
                  dismiss = null;
                };
              };
            };
          };
        };
      };
    };
}
