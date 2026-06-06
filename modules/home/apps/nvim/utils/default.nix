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
        plugins = {
          snacks = {
            settings = {
              animate = {
                enabled = true;
              };

              input = {
                enabled = true;
              };

              notifier = {
                enabled = true;
                timeout = 3000;
                style = "compact";
              };

              bigfile = {
                enabled = true;
              };
              scroll = {
                enabled = true;
                animate = {
                  duration = {
                    step = 10;
                    total = 200;
                  };
                  easing = "linear";
                };
                animate_repeat = {
                  delay = 100;
                  duration = {
                    step = 5;
                    total = 50;
                  };
                  easing = "linear";
                };
                filter = {
                  __raw = ''
                    function(buf)
                      return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false and vim.bo[buf].buftype ~= "terminal"
                    end
                  '';
                };
              };

              styles = {
                b = {
                  completion = false;
                };
              };
            };
          };
        };
      };
    };
}
