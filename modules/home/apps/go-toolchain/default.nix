{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.go-toolchain = {
    enable = lib.mkEnableOption "Enable go-toolchain";
  };
  config =
    let
      opts = config.${namespace}.apps.go-toolchain;
    in
    lib.mkIf opts.enable {
      programs.go = {
        enable = true;
      };
      ${namespace} = {
        apps.vscodium = {
          userSettings = {

          };
          extensions."golang.go" = {
            package = pkgs.nix-vscode-extensions.vscode-marketplace.golang.go;
          };
        };
        apps.nvim = {
          extraPackagesAfter = with pkgs; [
            go
            gopls
            golangci-lint
            golangci-lint-langserver

            gofumpt
            gci
            gotools
            delve
          ];
          lsp.servers = {
            gopls = {
              enable = true;
              package = pkgs.gopls;
              packageFallback = true;
              config = {
                cmd = [
                  (lib.getExe pkgs.gopls)
                ];

                filetypes = [
                  "go"
                  "gomod"
                  "gowork"
                ];

                root_markers = [
                  "go.work"
                  "go.mod"
                  ".git"
                ];

                settings = {
                  gopls = {
                    gofumpt = true;
                    usePlaceholders = true;
                    completeUnimported = true;
                    semanticTokens = true;

                    # let golangci-lint do the job.
                    staticcheck = false;

                    analyses = {
                      nilness = true;
                      shadow = true;
                      unusedparams = true;
                      unusedwrite = true;
                      useany = true;

                      # noisy, slow with big codebase.
                      fieldalignment = false;
                    };

                    hints = {
                      assignVariableTypes = true;
                      compositeLiteralFields = true;
                      compositeLiteralTypes = true;
                      constantValues = true;
                      functionTypeParameters = true;
                      parameterNames = true;
                      rangeVariableTypes = true;
                    };

                    codelenses = {
                      generate = true;
                      regenerate_cgo = true;
                      run_govulncheck = true;
                      test = true;
                      tidy = true;
                      upgrade_dependency = true;
                      vendor = true;
                    };

                    directoryFilters = [
                      "-.git"
                      "-.direnv"
                      "-node_modules"
                      "-vendor"
                      "-tmp"
                    ];
                  };
                };
              };
            };
            golangci_lint_ls = {
              enable = true;
              package = pkgs.golangci-lint-langserver;
              packageFallback = true;
              config = {
                cmd = [
                  (lib.getExe pkgs.golangci-lint-langserver)
                ];

                filetypes = [
                  "go"
                  "gomod"
                ];

                rootMarkers = [
                  ".golangci.yml"
                  ".golangci.yaml"
                  ".golangci.toml"
                  ".golangci.json"
                  "go.work"
                  "go.mod"
                  ".git"
                ];

                init_options = {
                  command = [
                    # (lib.getExe pkgs.golangci-lint)
                    "golangci-lint" # to use the lib in devenv first, then pkgs.golangci-lint
                    "run"

                    "--show-stats=false"
                    "--output.json.path=stdout"

                    "--issues-exit-code=1"
                  ];
                };

                settings = {
                };
              };
            };
          };
          formatter = {
            byFileType = {
              go = [
                "goimports"
                "gofumpt"
              ];
              gomod = [ "gofumpt" ];
              gowork = [ "gofumpt" ];
              gotmpl = [ "gofumpt" ];
            };
            setFormatters = {
              goimports = {
                command = lib.getExe' pkgs.gotools "goimports";
              };
              gofumpt = {
                command = lib.getExe pkgs.gofumpt;
              };
            };
          };
        };
      };
    };
}
