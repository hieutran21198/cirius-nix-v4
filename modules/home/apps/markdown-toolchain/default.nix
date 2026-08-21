{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.apps.markdown-toolchain = {
    enable = lib.mkEnableOption "Enable the markdown toolchain (Marksman, markdownlint, markdown-toc, and render-markdown).";
  };

  config =
    let

      opts = config.${namespace}.apps.markdown-toolchain;
      nvimOpts = config.${namespace}.apps.nvim;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [
        markdownlint-cli
        markdown-toc
      ];

      ${namespace}.apps.nvim = {
        extraPackagesAfter = [
          pkgs.marksman
        ];

        lsp.servers.marksman = {
          enable = true;
          package = pkgs.marksman;
          packageFallback = true;
          config = {
            cmd = [
              (lib.getExe pkgs.marksman)
              "server"
            ];
            filetypes = [
              "markdown"
              "markdown.mdx"
            ];
            root_markers = [
              ".marksman.toml"
              ".git"
            ];
          };
        };
      };

      programs.nixvim = lib.mkIf nvimOpts.enable {
        keymaps =
          let
            inherit (lib.${namespace}.nvim) mkKeymap;
          in
          lib.optionals nvimOpts.enableLeaderOrientedKeymaps [
            (mkKeymap "<leader>m" "" "  Markdown")
            (mkKeymap "<leader>mt" "<cmd>RenderMarkdown toggle<cr>" "  Toggle render")
          ];

        plugins = {
          render-markdown = {
            enable = true;

            settings = {
              # Render in normal/command/terminal modes; show raw source while editing.
              render_modes = [
                "n"
                "c"
                "t"
              ];

              preset = "obsidian";

              file_types = [
                "markdown"
              ];

              heading = {
                position = "inline";
                width = "full";
              };

              code = {
                width = "block";
                position = "right";
                left_pad = 2;
                right_pad = 2;
                border = "thick";
              };

              # Reuse the existing icon provider (web-devicons is already enabled).
              completions = {
                lsp.enabled = true;
              };
            };
          };
        };
      };
    };
}
