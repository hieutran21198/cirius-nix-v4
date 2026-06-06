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
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        lsp = {
          enable = true;
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
