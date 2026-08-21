{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.nvim.http-client = {
  };

  config =
    let
      opts = config.${namespace}.apps.nvim;
      inherit (lib.${namespace}.nvim) mkKeymap;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        keymaps = lib.optionals opts.enableLeaderOrientedKeymaps [
          (mkKeymap "<leader>r" "<nop>" "󰖟 HTTP Client")
        ];

        plugins.kulala = {
          enable = true;

          settings = {
            global_keymaps = true;
            global_keymaps_prefix = "<leader>r";
          };
        };
      };
    };
}
