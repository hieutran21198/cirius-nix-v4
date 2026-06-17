{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule
      [ namespace "apps" "nvim" "auto-completion" "sources" ]
      [
        "programs"
        "nixvim"
        "plugins"
        "blink-cmp"
        "settings"
        "sources"
        "default"
      ]
    )
    (lib.mkAliasOptionModule
      [ namespace "apps" "nvim" "auto-completion" "providers" ]
      [
        "programs"
        "nixvim"
        "plugins"
        "blink-cmp"
        "settings"
        "sources"
        "providers"
      ]
    )
  ];
  options.${namespace}.apps.nvim.auto-completion = { };

  config =
    let
      opts = config.${namespace}.apps.nvim;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        extraConfigLuaPost = ''
          require("luasnip.loaders.from_vscode").lazy_load({
            paths = {
              "${config.${namespace}.apps.snippets.built.nvimSnippetDir}",
            },
          })
        '';
        opts = {
          autocomplete = false;
          completeopt = "popup,nearest";
        };
        dependencies.ripgrep.enable = true;
        extraPackages = with pkgs; [ ];
        plugins = {
          luasnip.enable = true;
          blink-cmp = {
            enable = true;
            settings = {
              appearance = {
                use_nvim_cmp_as_default = true;
                nerd_font_variant = "normal";
              };
              snippets = {
                preset = "luasnip";
              };
              sources = {
                default = [
                  "lsp"
                  "path"
                  "snippets"
                  "buffer"
                ];
              };
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
