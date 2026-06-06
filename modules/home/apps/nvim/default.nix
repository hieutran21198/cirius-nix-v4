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
      [
        namespace
        "apps"
        "nvim"
        "extraPackagesAfter"
      ]
      [
        "programs"
        "nixvim"
        "extraPackagesAfter"
      ]
    )
  ];
  options.${namespace}.apps.nvim = {
    enable = lib.mkEnableOption "Enable nvim";
    leaderKey = lib.${namespace}.makeStrOption { default = " "; };
    enableRecommendedOptions = lib.${namespace}.makeBoolOption { default = true; };
  };
  config =
    let
      opts = config.${namespace}.apps.nvim;
      inherit (lib.${namespace}.nvim) mkKeymap;
    in
    lib.mkIf opts.enable {
      programs.nixvim = {
        enable = true;
        nixpkgs.config = {
          allowUnfree = true;
          allowBroken = false;
        };
        globals = {
          mapleader = opts.leaderKey;
        };
        viAlias = true;
        vimAlias = true;
        plugins = {
          web-devicons.enable = true;
          which-key.enable = true;
          treesitter = {
            enable = true;
            package = pkgs.vimPlugins.nvim-treesitter;
            highlight.enable = true;
            indent.enable = true;
            folding.enable = false;
          };
          lualine = {
            enable = true;
            settings = {
              options = {
                globalstatus = true;
                theme = "auto";
                icons_enabled = true;
              };
            };
          };
        };
        extraConfigLuaPre = ''
          require('vim._core.ui2').enable()
        '';
        keymaps = [
          (mkKeymap "<leader>q" "<cmd>xa<cr>" " 󰩈 Save all and close")
          (mkKeymap "<esc>" "<cmd>nohlsearch<cr>" {
            mode = [ "n" ];
            options = {
              silent = true;
              nowait = true;
              desc = "  Clear highlight";
            };
          })

          (mkKeymap "<leader>w" "" " Window Management")
          (mkKeymap "<leader>wh" "<cmd>wincmd h<cr>" "  Switch to left buffer")
          (mkKeymap "<leader>wj" "<cmd>wincmd j<cr>" "  Switch to bottom buffer")
          (mkKeymap "<leader>wk" "<cmd>wincmd k<cr>" "  Switch to top buffer")
          (mkKeymap "<leader>wl" "<cmd>wincmd l<cr>" "  Switch to right buffer")

          (mkKeymap "<leader>b" "" " Buffer Management")
          (mkKeymap "<leader>bc" "<cmd>%bd|e#<cr>" "  Close buffer")
        ];
        opts = lib.optionalAttrs opts.enableRecommendedOptions {
          clipboard = "unnamedplus";
          timeout = true;
          autowrite = true;
          conceallevel = 3;
          confirm = true;
          cursorline = true;
          expandtab = true;
          formatoptions = "jcroqlnt";
          grepformat = "%f:%l:%c:%m";
          grepprg = "rg --vimgrep";
          ignorecase = true;
          inccommand = "nosplit";
          laststatus = 3;
          list = true;
          mouse = "a";
          number = true;
          pumblend = 10;
          pumheight = 10;
          relativenumber = false;
          scrolloff = 4;
          shiftround = true;
          shiftwidth = 2;
          showmode = false;
          sidescrolloff = 8;
          signcolumn = "yes";
          smartcase = true;
          smartindent = true;
          splitbelow = true;
          splitkeep = "screen";
          splitright = true;
          tabstop = 2;
          termguicolors = true;
          timeoutlen = 500;
          undofile = true;
          undolevels = 10000;
          updatetime = 200;
          virtualedit = "block";
          wildmode = "longest:full,full";
          winminwidth = 5;
          wrap = true;
          winborder = "rounded";
          modeline = false;
        };
      };
    };
}
