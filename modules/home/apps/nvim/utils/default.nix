{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.apps.nvim.ai = {
  };

  config =
    let
      opts = config.${namespace}.apps.nvim;
      inherit (lib.${namespace}.nvim) mkKeymap;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        extraConfigLuaPre = ''
          require('vim._core.ui2').enable()
        '';
        keymaps = [
          (mkKeymap "<esc>" "<cmd>nohlsearch<cr>" {
            mode = [ "n" ];
            options = {
              silent = true;
              nowait = true;
              desc = "  Clear highlight";
            };
          })
        ]
        ++ (lib.optionals opts.enableLeaderOrientedKeymaps [
          (mkKeymap "<leader>q" "<cmd>xa<cr>" " 󰩈 Save all and close")

          (mkKeymap "<leader>w" "" " Window Management")
          (mkKeymap "<leader>wh" "<cmd>wincmd h<cr>" "  Switch to left buffer")
          (mkKeymap "<leader>wj" "<cmd>wincmd j<cr>" "  Switch to bottom buffer")
          (mkKeymap "<leader>wk" "<cmd>wincmd k<cr>" "  Switch to top buffer")
          (mkKeymap "<leader>wl" "<cmd>wincmd l<cr>" "  Switch to right buffer")

          (mkKeymap "<leader>b" "" " Buffer Management")
          (mkKeymap "<leader>bd" "<cmd>Snacks.bufdelete.other()<cr>" "  Delete buffer except current one")
        ]);
        plugins = {
          web-devicons.enable = true;
          which-key.enable = true;
          treesitter = {
            enable = true;
            package = pkgs.vimPlugins.nvim-treesitter;
            highlight.enable = true;
            indent.enable = true;
            folding.enable = false;
          };
          lualine = {
            enable = true;
            settings = {
              options = {
                globalstatus = true;
                theme = "auto";
                icons_enabled = true;
              };
            };
          };
          snacks = {
            settings = {
              animate = {
                enabled = true;
              };

              input = {
                enabled = true;
              };

              notifier = {
                enabled = true;
                timeout = 3000;
                style = "compact";
              };

              bigfile = {
                enabled = true;
              };
              scroll = {
                enabled = true;
                animate = {
                  duration = {
                    step = 10;
                    total = 200;
                  };
                  easing = "linear";
                };
                animate_repeat = {
                  delay = 100;
                  duration = {
                    step = 5;
                    total = 50;
                  };
                  easing = "linear";
                };
                filter = {
                  __raw = ''
                    function(buf)
                      return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false and vim.bo[buf].buftype ~= "terminal"
                    end
                  '';
                };
              };

              styles = {
                b = {
                  completion = false;
                };
              };
            };
          };
        };
      };
    };
}
