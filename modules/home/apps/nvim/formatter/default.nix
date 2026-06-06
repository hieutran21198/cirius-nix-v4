{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule
      [ namespace "apps" "nvim" "formatter" "byFileType" ]
      [ "programs" "nixvim" "plugins" "conform-nvim" "settings" "formatters_by_ft" ]
    )
    (lib.mkAliasOptionModule
      [ namespace "apps" "nvim" "formatter" "setFormatters" ]
      [ "programs" "nixvim" "plugins" "conform-nvim" "settings" "formatters" ]
    )
  ];
  options.${namespace}.apps.nvim.formatter = {
  };

  config =
    let
      opts = config.${namespace}.apps.nvim;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ nixfmt ];
      programs.nixvim = {
        plugins = {
          conform-nvim = {
            enable = true;
            # lets devenv in project path can override.
            autoInstall.enable = false;
            settings = {
              formatters_by_ft = {
                nix = [ "nixfmt" ];
                "_" = [
                  "trim_whitespace"
                  "trim_newlines"
                ];
              };
              formatters = {
                nixfmt.command = lib.getExe pkgs.nixfmt;
              };
              default_format_opts = {
                lsp_format = "never";
                timeout_ms = 1000;
              };
              notify_on_error = true;
              notify_no_formatters = false;
              format_on_save = {
                timeout_ms = 1000;
                # we have formatter so no need lsp format anymore.
                # can set to "falback" "never"
                lsp_format = "never";
              };
            };
          };
        };
      };
    };
}
