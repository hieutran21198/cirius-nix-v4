{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.nvim.ai = {
  };

  config =
    let
      opts = config.${namespace}.apps.nvim;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
      };
    };
}
