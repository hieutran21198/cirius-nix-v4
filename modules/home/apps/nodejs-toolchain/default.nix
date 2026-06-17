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
  };
  config =
    let
      opts = config.${namespace}.apps.nodejs-toolchain;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [
        nodejs
        pnpm
        yarn
        typescript
      ];
      ${namespace} = {
        apps.vscodium = {
          userSettings = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
            "eslint.format.enable" = true;
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
          };
        };
        apps.nvim = {
          extraPackagesAfter = with pkgs; [
            nodejs
            typescript
            typescript-language-server
            # provides vscode-eslint-language-server, plus json/html/css servers.
            vscode-langservers-extracted

            prettierd
            eslint_d
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
                  "package.json"
                  ".git"
                ];
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
        };
      };
    };
}
