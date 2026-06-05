{
  namespace,
  config,
  ...
}:
{
  ${namespace} = {
    infra = {
      shell = {
        fish.shellAbbrs = {
          rbnix = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/Workspaces/personal/dotfiles/cirius-nix-v4";
          gco = "git checkout";
          gpl = "git pull origin";
          gps = "git push origin";
          gaa = "git add .";
          gcm = "git commit -m";
          nixgens = "nix-env --list-generations";
          delgens = "nix-env --delete-generations old";
          cleanstore = "nix-store --gc";
        };
      };
      desktop-manager = {
        gnome = {
          profile = "default";
          profile-default = {
            blurEffect = {
              enable = true;
            };
            extensions = [ ];
          };
        };
      };
    };

    apps = {
      pods = {
        enable = true;
        markAsFavorite = true;
      };
      bruno = {
        enable = true;
        markAsFavorite = true;
      };
      obsidian = {
        enable = true;
        markAsFavorite = true;
      };
      ghostty = {
        enable = true;
        markAsFavorite = true;
      };
      aws-cli.enable = true;
      vscodium = {
        enable = true;
        markAsFavorite = true;
      };
      direnv.enable = true;
      devenv.enable = true;
      datagrip = {
        enable = true;
        markAsFavorite = true;
      };
      gparted.enable = true;
      proton-pass = {
        enable = true;
        markAsFavorite = true;
      };
      go-toolchain.enable = true;
      ms-teams.enable = true;
      only-office = {
        enable = true;
        markAsFavorite = true;
      };
      ai = {
        claude.enable = true;
        codex.enable = true;
        opencode.enable = true;
      };
      librewolf = {
        enable = true;
        markAsFavorite = true;
        persistFingerprint = true;
        enableSidebarTabs = true;
        containers = {
          uit = {
            id = 1;
            color = "blue";
            icon = "briefcase";
          };
          buuuk = {
            id = 2;
            color = "red";
            icon = "circle";
          };
        };
      };
    };
  };
}
