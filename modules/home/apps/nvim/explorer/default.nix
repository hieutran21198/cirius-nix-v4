{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.nvim.explorer = {
  };

  config =
    let
      inherit (lib.${namespace}.nvim) mkKeymap mkRaw;

      opts = config.${namespace}.apps.nvim;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        extraPackages = with pkgs; [
          fd
          ripgrep
          git
          trash-cli
        ];

        extraConfigLua = ''
          snacks_explorer_focus_or_close = function()
            local pickers = Snacks.picker.get({ source = "explorer" }) or {}

            for _, picker in ipairs(pickers) do
              if picker and not picker.closed then
                local ft = vim.bo.filetype

                if ft:match("^snacks_picker") then
                  picker:close()
                else
                  picker:focus("list", { show = true })
                end

                return
              end
            end

            Snacks.explorer()
          end
        '';

        keymaps = [
          (mkKeymap "<leader>e" "<cmd>lua snacks_explorer_focus_or_close()<cr>" " 󰙅 Explorer")

          (mkKeymap "<leader>f" "" "  Finder")
          (mkKeymap "<leader>ff" "<cmd>lua Snacks.picker.files()<cr>" " Find files")
          (mkKeymap "<leader>fg" "<cmd>lua Snacks.picker.grep()<cr>" "󰱼 Live grep")
          (mkKeymap "<leader>fw" "<cmd>lua Snacks.picker.grep_word()<cr>" "󰱼 Grep word")
          (mkKeymap "<leader>fW"
            ''<cmd>lua Snacks.picker.grep({ search = vim.fn.expand("<cWORD>"), live = false, regex = false })<cr>''
            "󰱼 Grep WORD"
          )
          (mkKeymap "<leader>fb" "<cmd>lua Snacks.picker.buffers()<cr>" "󰈙 Buffers")
          (mkKeymap "<leader>fr" "<cmd>lua Snacks.picker.recent()<cr>" " Recent files")
          (mkKeymap "<leader>fh" "<cmd>lua Snacks.picker.help()<cr>" "󰋖 Help tags")
          (mkKeymap "<leader>fk" "<cmd>lua Snacks.picker.keymaps()<cr>" " Keymaps")
          (mkKeymap "<leader>fc" "<cmd>lua Snacks.picker.commands()<cr>" " Commands")
          (mkKeymap "<leader>fd" "<cmd>lua Snacks.picker.diagnostics_buffer()<cr>" "󰒡 Document diagnostics")
          (mkKeymap "<leader>fD" "<cmd>lua Snacks.picker.diagnostics()<cr>" "󰒡 Workspace diagnostics")

          (mkKeymap "<leader>fs" "<cmd>lua Snacks.picker.lsp_symbols()<cr>" "󰒕 Document symbols")
          (mkKeymap "<leader>fS" "<cmd>lua Snacks.picker.lsp_workspace_symbols()<cr>" "󰒕 Workspace symbols")
          (mkKeymap "<leader>f/" "<cmd>lua Snacks.picker.resume()<cr>" "󰁯 Resume picker")
        ];

        plugins = {
          snacks = {
            enable = true;
            autoLoad = true;
            callSetup = true;
            settings = {
              quickfile = {
                enabled = true;
              };

              explorer = {
                enabled = true;
                replace_netrw = true;
                trash = true;
              };

              picker = {
                enabled = true;
                ui_select = true;

                layout = {
                  cycle = true;
                  preset = "default";
                };

                matcher = {
                  fuzzy = true;
                  smartcase = true;
                  ignorecase = true;
                  filename_bonus = true;
                };

                sources = {
                  files = {
                    hidden = false;
                    ignored = false;
                  };

                  grep = {
                    hidden = false;
                    ignored = false;
                  };

                  explorer = {
                    hidden = false;
                    ignored = false;

                    follow_file = true;
                    focus = "list";
                    auto_close = false;

                    tree = true;
                    watch = true;

                    diagnostics = true;
                    diagnostics_open = false;

                    git_status = true;
                    git_status_open = false;
                    git_untracked = true;

                    layout = {
                      preset = "sidebar";
                      preview = false;
                    };

                    formatters = {
                      file = {
                        filename_only = true;
                      };

                      severity = {
                        pos = "right";
                      };
                    };

                    win = {
                      list = {
                        keys = {
                          "o" = "confirm";
                          "s" = "explorer_open";

                          "l" = "confirm";
                          "h" = "explorer_close";
                          "Z" = "explorer_close_all";

                          "a" = "explorer_add";
                          "d" = "explorer_del";
                          "r" = "explorer_rename";
                          "c" = "explorer_copy";
                          "m" = "explorer_move";
                          "p" = "explorer_paste";
                          "u" = "explorer_update";

                          "y" = mkRaw ''{ "explorer_yank", mode = { "n", "x" } }'';

                          "/" = "picker_grep";
                          "." = "explorer_focus";
                          "I" = "toggle_ignored";
                          "H" = "toggle_hidden";
                          "P" = "toggle_preview";

                          "]g" = "explorer_git_next";
                          "[g" = "explorer_git_prev";
                          "]d" = "explorer_diagnostic_next";
                          "[d" = "explorer_diagnostic_prev";
                          "]w" = "explorer_warn_next";
                          "[w" = "explorer_warn_prev";
                          "]e" = "explorer_error_next";
                          "[e" = "explorer_error_prev";

                          "<Esc>" = "close";
                        };
                      };
                    };
                  };
                };

                win = {
                  input = {
                    keys = {
                      "<Esc>" = mkRaw ''{ "close", mode = { "n", "i" } }'';
                    };
                  };

                  list = {
                    keys = {
                      "<Esc>" = "close";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
}
