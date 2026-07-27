{
  namespace,
  config,
  ...
}:
{
  imports = [
    ./secrets-default.nix
  ];
  home = {
    sessionVariables = {
      EDITOR = "nvim";
    };
  };
  ${namespace} = {
    infra = {
      shell = {
        fish.shellAbbrs = {
          rbnix = ''
            sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/Workspaces/personal/dotfiles/cirius-nix-v4#mht-win-home-pc
          '';
          gco = "git checkout";
          gpl = "git pull origin";
          gps = "git push origin";
          gaa = "git add .";
          gcm = "git commit -m";
          nixgens = "sudo nix-env --profile /nix/var/nix/profiles/system --list-generations";
          delgens = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations old";
          cleanstore = "sudo nix-store --gc";
        };
      };
    };

    apps = {
      fabric = {
        enable = true;
      };
      zoxide = {
        enable = true;
      };
      aws-cli.enable = true;
      direnv.enable = true;
      devenv.enable = true;
      fastfetch.enable = true;
      nvim.enable = true;
      markdown-toolchain.enable = true;
      go-toolchain.enable = true;
      nodejs-toolchain.enable = true;
      fzf.enable = true;
      ai = {
        claude.enable = true;
        codex = {
          enable = true;
        };
        opencode.enable = true;
        copilot.enable = true;
      };
      ai-utilities = {
        codegraph.enable = true;
      };
      chamber.enable = true;
      aws-vault.enable = true;
    };
  };
}
