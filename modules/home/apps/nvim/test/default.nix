{
  config,
  namespace,
  lib,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule
      [ namespace "apps" "nvim" "test" "adapters" ]
      [ "programs" "nixvim" "plugins" "neotest" "adapters" ]
    )
  ];

  options.${namespace}.apps.nvim.test = {
  };

  config =
    let
      opts = config.${namespace}.apps.nvim;
      inherit (lib.${namespace}.nvim) mkKeymap;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        keymaps = lib.optionals opts.enableLeaderOrientedKeymaps [
          (mkKeymap "<leader>t" "<nop>" "󰙨 Tests")
          (mkKeymap "<leader>tt" "<cmd>lua require('neotest').run.run()<cr>" "󰙨 Run nearest test")
          (mkKeymap "<leader>tf" "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>"
            "󰈙 Run test file"
          )
          (mkKeymap "<leader>ta" "<cmd>lua require('neotest').run.run(vim.uv.cwd())<cr>" "󰙨 Run all tests")
          (mkKeymap "<leader>tl" "<cmd>lua require('neotest').run.run_last()<cr>" "󰑓 Run last test")
          (mkKeymap "<leader>ts" "<cmd>lua require('neotest').summary.toggle()<cr>" "󰮫 Toggle test summary")
          (mkKeymap "<leader>to" "<cmd>lua require('neotest').output.open({ enter = true })<cr>"
            "󰍩 Show test output"
          )
          (mkKeymap "<leader>tp" "<cmd>lua require('neotest').output_panel.toggle()<cr>"
            "󰆍 Toggle test output panel"
          )
          (mkKeymap "<leader>tw" "<cmd>lua require('neotest').watch.toggle(vim.fn.expand('%'))<cr>"
            "󰂚 Watch test file"
          )
          (mkKeymap "<leader>tx" "<cmd>lua require('neotest').run.stop()<cr>" "󰓛 Stop test")
        ];

        plugins.neotest = {
          enable = true;

          settings = {
            floating.border = "rounded";
            output.open_on_run = "short";
            quickfix = {
              enabled = true;
              open = false;
            };
            summary.open = "botright vsplit | vertical resize 50";
          };
        };
      };
    };
}
