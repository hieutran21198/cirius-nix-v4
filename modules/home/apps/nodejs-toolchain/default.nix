{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.nodejs-toolchain = {
    enable = lib.mkEnableOption "Enable nodejs-toolchain";
    package = lib.${namespace}.makePackageOption {
      default = pkgs.nodejs_24;
      description = "Node.js package used by the JavaScript/TypeScript toolchain.";
    };
  };
  config =
    let
      opts = config.${namespace}.apps.nodejs-toolchain;
    in
    lib.mkIf opts.enable {
      home.packages = [
        opts.package
        # Prefer Corepack's shims over the copies bundled with Node.js so Nx
        # workspaces can honor the packageManager version in package.json.
        (lib.hiPrio pkgs.corepack)
        pkgs.typescript
      ];
      ${namespace} = {
        apps.vscodium = {
          userSettings = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
            "eslint.format.enable" = true;
            "eslint.workingDirectories" = [
              {
                mode = "auto";
              }
            ];
            "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
            "[javascriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
            "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
            "[typescriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
            "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
            "[jsonc]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          extensions = {
            "dbaeumer.vscode-eslint" = {
              package = pkgs.nix-vscode-extensions.vscode-marketplace.dbaeumer.vscode-eslint;
            };
            "esbenp.prettier-vscode" = {
              package = pkgs.nix-vscode-extensions.vscode-marketplace.esbenp.prettier-vscode;
            };
            "nrwl.angular-console" = {
              package = pkgs.nix-vscode-extensions.vscode-marketplace.nrwl.angular-console;
            };
          };
        };
        apps.nvim = {
          extraPackagesAfter = [
            opts.package
            pkgs.typescript
            pkgs.typescript-language-server
            # provides vscode-eslint-language-server, plus json/html/css servers.
            pkgs.vscode-langservers-extracted

            pkgs.prettierd
            pkgs.eslint_d
          ];
          lsp.servers = {
            ts_ls = {
              enable = true;
              package = pkgs.typescript-language-server;
              packageFallback = true;
              config = {
                cmd = [
                  (lib.getExe pkgs.typescript-language-server)
                  "--stdio"
                ];

                filetypes = [
                  "javascript"
                  "javascriptreact"
                  "javascript.jsx"
                  "typescript"
                  "typescriptreact"
                  "typescript.tsx"
                ];

                root_markers = [
                  "nx.json"
                  "pnpm-workspace.yaml"
                  "pnpm-lock.yaml"
                  "yarn.lock"
                  "package-lock.json"
                  "bun.lock"
                  "bun.lockb"
                  "tsconfig.base.json"
                  "tsconfig.json"
                  "jsconfig.json"
                  "package.json"
                  ".git"
                ];
              };
            };
            eslint = {
              enable = true;
              package = pkgs.vscode-langservers-extracted;
              packageFallback = true;
              config = {
                cmd = [
                  (lib.getExe' pkgs.vscode-langservers-extracted "vscode-eslint-language-server")
                  "--stdio"
                ];

                filetypes = [
                  "javascript"
                  "javascriptreact"
                  "javascript.jsx"
                  "typescript"
                  "typescriptreact"
                  "typescript.tsx"
                  "vue"
                  "svelte"
                ];

                root_markers = [
                  ".eslintrc"
                  ".eslintrc.js"
                  ".eslintrc.cjs"
                  ".eslintrc.json"
                  ".eslintrc.yaml"
                  ".eslintrc.yml"
                  "eslint.config.js"
                  "eslint.config.mjs"
                  "eslint.config.cjs"
                  "eslint.config.ts"
                  "nx.json"
                  "pnpm-workspace.yaml"
                  "pnpm-lock.yaml"
                  "yarn.lock"
                  "package-lock.json"
                  "bun.lock"
                  "bun.lockb"
                  "package.json"
                  ".git"
                ];

                settings = {
                  workingDirectory = {
                    mode = "auto";
                  };
                };
              };
            };
          };
          formatter = {
            byFileType = {
              javascript = [ "prettierd" ];
              javascriptreact = [ "prettierd" ];
              typescript = [ "prettierd" ];
              typescriptreact = [ "prettierd" ];
              json = [ "prettierd" ];
              jsonc = [ "prettierd" ];
              css = [ "prettierd" ];
              scss = [ "prettierd" ];
              html = [ "prettierd" ];
              yaml = [ "prettierd" ];
              markdown = [ "prettierd" ];
            };
            setFormatters = {
              prettierd = {
                command = lib.getExe pkgs.prettierd;
              };
            };
          };
          test.adapters = {
            jest.enable = true;
            vitest.enable = true;
          };
        };
      };
    };
}
