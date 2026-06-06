{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.nvim.auto-completion = {
  };

  config =
    let
      opts = config.${namespace}.apps.nvim;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        opts = {
          autocomplete = false;
          completeopt = "popup,nearest";
        };
        plugins = {
          blink-cmp = {
            enable = true;
            settings = {
              sources.default = [
                "lsp"
                "path"
                "snippets"
                "buffer"
              ];
              keymap = {
                preset = "super-tab";
                "<cr>" = [
                  "select_and_accept"
                  "fallback"
                ];
                "<Tab>" = [
                  "snippet_forward"
                  "select_next"
                  "fallback"
                ];
                "<S-Tab>" = [
                  "snippet_backward"
                  "select_prev"
                  "fallback"
                ];
              };
              fuzzy.implementation = "prefer_rust_with_warning";
              appearance.use_nvim_cmp_as_default = true;
              signature.enabled = true;
              completion = {
                trigger.prefetch_on_insert = false;
                list = {
                  selection = {
                    preselect = true;
                    auto_insert = true;
                  };
                };
                keyword.range = "full";
                documentation = {
                  auto_show = true;
                  auto_show_delay_ms = 200;
                };
                ghost_text.enabled = true;
              };
            };
          };
        };
      };
    };
}
