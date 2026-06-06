{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.nvim.editor = {
  };

  config =
    let
      opts = config.${namespace}.apps.nvim;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        plugins = {
          snacks = {
            settings = {
            };
          };
          mini = {
            enable = true;
            modules = {
              comment = { };
              pairs = { };
            };
          };
        };
      };
    };
}
