{
  config,
  namespace,
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
    (lib.mkAliasOptionModule [ namespace "apps" "nvim" "extra-deps" ] [ "programs" "nixvim" "plugins" ])
  ];
  options.${namespace}.apps.nvim = {
    enable = lib.mkEnableOption "Enable nvim";
    leaderKey = lib.${namespace}.makeStrOption { default = " "; };
    enableRecommendedOptions = lib.${namespace}.makeBoolOption { default = true; };
    enableLeaderOrientedKeymaps = lib.${namespace}.makeBoolOption { default = true; };
  };
  config =
    let
      opts = config.${namespace}.apps.nvim;
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
