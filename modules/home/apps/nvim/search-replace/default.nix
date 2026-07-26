{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.nvim.search-replace = {
  };

  config =
    let
      inherit (lib.${namespace}.nvim) mkKeymap;

      opts = config.${namespace}.apps.nvim;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        # grug-far drives ripgrep for project-wide search and replace.
        extraPackages = with pkgs; [
          ripgrep
        ];

        keymaps = lib.optionals opts.enableLeaderOrientedKeymaps [
          (mkKeymap "<leader>s" "" " 󰛔 Search / Replace")
          (mkKeymap "<leader>ss" "<cmd>lua require('grug-far').open()<cr>" " 󰛔 Search & replace (project)")
          (mkKeymap "<leader>sw"
            ''<cmd>lua require('grug-far').open({ prefills = { search = vim.fn.expand("<cword>") } })<cr>''
            " 󰛔 Replace word under cursor"
          )
          (mkKeymap "<leader>sf"
            ''<cmd>lua require('grug-far').open({ prefills = { paths = vim.fn.expand("%") } })<cr>''
            " 󰛔 Replace in current file"
          )
          (mkKeymap "<leader>sv" "<cmd>lua require('grug-far').with_visual_selection()<cr>" {
            mode = [ "x" ];
            options = {
              silent = true;
              nowait = true;
              desc = " 󰛔 Replace visual selection";
            };
          })
        ];

        plugins = {
          grug-far = {
            enable = true;

            settings = {
              engine = "ripgrep";

              engines = {
                ripgrep = {
                  path = "rg";
                  showReplaceDiff = true;
                };
              };
            };
          };
        };
      };
    };
}
