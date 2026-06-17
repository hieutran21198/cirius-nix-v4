{
  namespace,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./secrets-default.nix
    ./secrets-buuuk.nix
    ./secrets-shared.nix
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  ${namespace} = {
    infra = {
      virtualisation = {
        enable = true;
      };
      ai = {
        llama-cpp = {
          qwenFIM = {
            enable = true;
            port = 8001;
            model = "fim-qwen-3b-default";
          };
        };
      };
      fonts = {
        monospace = {
          name = "MonaspiceNe Nerd Font Mono";
          package = pkgs.nerd-fonts.monaspace;
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          terminal = 10;
        };
      };
      shell = {
        fish.shellAbbrs = {
          rbnix = ''
            sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/Workspaces/personal/dotfiles/cirius-nix-v4#mht-home-pc
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

    services = {
      opensnitch.enable = true;
    };

    apps = {
      podman = {
        enable = true;
      };
      pods = {
        enable = true;
        markAsFavorite = true;
      };
      zoxide = {
        enable = true;
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
      fastfetch.enable = true;
      nvim.enable = true;
      go-toolchain.enable = true;
      nodejs-toolchain.enable = true;
      ms-teams.enable = true;
      only-office = {
        enable = true;
        markAsFavorite = true;
      };
      fzf.enable = true;
      ai = {
        pi.enable = true;
        claude.enable = true;
        codex.enable = true;
        opencode.enable = true;
        opendesign.enable = true;
        jules.enable = true;
        antigravity.enable = true;
        copilot.enable = true;
        reasonix.enable = true;
      };
      ai-assistant = {
        # TODO: missing aioncore
        aionui.enable = false;
        hermes.enable = true;
      };
      ai-utilities = {
        codegraph.enable = true;
      };
      chamber.enable = true;
      aws-vault.enable = true;
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
