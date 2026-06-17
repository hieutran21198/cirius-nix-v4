{
  config,
  namespace,
  pkgs,
  lib,
  host,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule
      [ namespace "apps" "nvim" "lsp" "servers" ]
      [ "programs" "nixvim" "lsp" "servers" ]
    )
  ];

  options.${namespace}.apps.nvim.lsp = {
  };

  config =
    let
      opts = config.${namespace}.apps.nvim;
      inherit (lib.${namespace}.nvim) mkKeymap;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        keymaps = [
          (mkKeymap "K" "<cmd>lua vim.lsp.buf.hover()<cr>" "󰋖 Hover")
        ]
        ++ (lib.optionals opts.enableLeaderOrientedKeymaps [
          (mkKeymap "<leader>l" "<nop>" "󰒓 LSP")

          # LSP navigation via Snacks picker
          (mkKeymap "<leader>ld" "<cmd>lua Snacks.picker.lsp_definitions()<cr>" "󰊕 LSP Definition")
          (mkKeymap "<leader>lD" "<cmd>lua Snacks.picker.lsp_declarations()<cr>" "󰳽 LSP Declaration")
          (mkKeymap "<leader>lr" "<cmd>lua Snacks.picker.lsp_references()<cr>" "󰈇 LSP References")
          (mkKeymap "<leader>li" "<cmd>lua Snacks.picker.lsp_implementations()<cr>" "󰡱 LSP Implementation")
          (mkKeymap "<leader>lt" "<cmd>lua Snacks.picker.lsp_type_definitions()<cr>" "󰜁 LSP Type Definition")

          # Symbols
          (mkKeymap "<leader>ls" "<cmd>lua Snacks.picker.lsp_symbols()<cr>" "󰓹 Document Symbols")
          (mkKeymap "<leader>lS" "<cmd>lua Snacks.picker.lsp_workspace_symbols()<cr>" "󰊄 Workspace Symbols")

          # Calls
          (mkKeymap "<leader>lc" "<nop>" "󰃷 Calls")
          (mkKeymap "<leader>lci" "<cmd>lua Snacks.picker.lsp_incoming_calls()<cr>" "󰃷 Incoming Calls")
          (mkKeymap "<leader>lco" "<cmd>lua Snacks.picker.lsp_outgoing_calls()<cr>" "󰃶 Outgoing Calls")

          # Diagnostics via Snacks
          (mkKeymap "<leader>lx" "<cmd>lua Snacks.picker.diagnostics_buffer()<cr>" "󰅚 Buffer Diagnostics")
          (mkKeymap "<leader>lX" "<cmd>lua Snacks.picker.diagnostics()<cr>" "󰒡 Workspace Diagnostics")

          # Native LSP actions
          (mkKeymap "<leader>la" "<cmd>lua vim.lsp.buf.code_action()<cr>" "󰌵 Code Action")
          (mkKeymap "<leader>ln" "<cmd>lua vim.lsp.buf.rename()<cr>" "󰑕 Rename Symbol")
          (mkKeymap "<leader>lh" "<cmd>lua vim.lsp.buf.signature_help()<cr>" "󰘥 Signature Help")
        ]);
        lsp = {
          servers = {
            nixd = {
              enable = true;
              config =
                let
                  flake = "(builtins.getFlake (builtins.toString ./.))";
                in
                {
                  rootMarkers = [
                    "flake.nix"
                    ".git"
                  ];
                  cmd = [
                    (lib.getExe pkgs.nixd)
                    "--log=error"
                  ];
                  filetypes = [ "nix" ];
                  settings = {
                    nixd = {
                      nixPkgs.expr = "import ${flake}.inputs.pkgs {}";
                      formatting.command = [ (lib.getExe pkgs.nixfmt) ];
                      options =
                        if pkgs.stdenv.isLinux then
                          {
                            nixos.expr = "${flake}.nixosConfigurations.${host}.options";
                            home_manager.expr = "${flake}.nixosConfigurations.${host}.options.home-manager.users.type.getSubOptions [ ]";
                          }
                        else if pkgs.stdenv.isDarwin then
                          {
                            nix-darwin.expr = "${flake}.darwinConfigurations.${host}.options";
                            home_manager.expr = "${flake}.darwinConfigurations.${host}.options.home-manager.users.type.getSubOptions [ ]";
                          }
                        else
                          { };
                    };
                  };
                };
            };
            statix.enable = true;
          };
        };

        plugins = {
          none-ls.enable = true;
          nix-develop.enable = true;
        };

        extraConfigLuaPost = ''
          -- nixd raises noisy "textDocument/documentHighlight failed: cannot
          -- find variable on given node" stderr lines whenever the cursor
          -- sits on a non-variable token. Disable the capability so neovim
          -- stops asking.
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client and client.name == "nixd" then
                client.server_capabilities.documentHighlightProvider = false
              end
            end,
          })
        '';
      };
    };
}
