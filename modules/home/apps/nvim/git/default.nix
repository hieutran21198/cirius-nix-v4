{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.nvim.git = {
  };

  config =
    let
      inherit (lib.${namespace}.nvim) mkKeymap;
      opts = config.${namespace}.apps.nvim;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        keymaps = [ (mkKeymap "<leader>gb" "<cmd>lua Snacks.git.blame_line()<cr>" "󰙨 Summon Bug Creator") ];
        plugins = {
          snacks = {
            settings = {
              styles = {
                blame_line = {
                  enabled = true;
                  width = 0.6;
                  height = 0.6;
                  border = true;
                  title = " Inspect Crime Scene 󰌵 ";
                  title_pos = "center";
                  ft = "git";
                };
              };
            };
          };
        };
      };
    };
}
