{
  config,
  namespace,
  lib,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule
      [ namespace "apps" "nvim" "session" "ignoreFileTypes" ]
      [
        "programs"
        "nixvim"
        "plugins"
        "auto-session"
        "settings"
        "bypass_save_filetypes"
      ]
    )
  ];

  config =
    let
      opts = config.${namespace}.apps.nvim;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        opts = {
          sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions";
        };
        plugins = {
          auto-session = {
            enable = true;
            bypass_save_filetypes = [ "snacks_picker_list" ];
          };
        };
      };
    };
}
