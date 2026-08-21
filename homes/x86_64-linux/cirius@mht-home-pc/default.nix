{
  namespace,
  config,
  pkgs,
  host,
  lib,
  ...
}:
{
  imports = [
    ./secrets-default.nix
    ./secrets-buuuk.nix
    ./secrets-shared.nix

    ./kde/default.nix
  ];
  home = {
    sessionVariables = {
      EDITOR = "nvim";
    };
  };
  ${namespace} = {
    infra = {
      virtualisation = {
        enable = true;
      };
      chromiumAppMaker = {
        registerApps = {
          dockhand = {
            class = "dockhand.${host}";
            name = "Dockhand";
            url = "https://dockhand.${host}";
            categories = [ "Development" ];
            # curl -L http://127.0.0.1:2000/favicon.ico -o assets/dockhand.ico
            icon = ../../../assets/dockhand.ico;
          };
          opendesign = {
            class = "design.${host}";
            name = "Open Design";
            url = "https://design.${host}";
            categories = [ "Development" ];
            # curl -L https://opendesign.mht-home-pc/app-icon.svg -o assets/opendesign.ico
            icon = ../../../assets/opendesign.ico;
          };
          sonarqube = {
            class = "sonarqube.${host}";
            name = "SonarQube";
            url = "https://sonarqube.${host}";
            categories = [ "Development" ];
            # curl -L https://sonarqube.mht-home-pc/favicon.ico -o assets/sonarqube.ico
            icon = ../../../assets/sonarqube.ico;
          };
          musicServer = {
            class = "music.${host}";
            name = "Music Server";
            url = "https://music.${host}";
            categories = [ "AudioVideo" ];
            icon = ../../../assets/music.png;
          };
        };
      };
      ai = {
        llama-cpp = {
          qwenFIM = {
            enable = false;
            port = 8001;
            model = "fim-qwen-3b-default";
          };
          integrateNvim = false;
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
        fish.shellAbbrs =
          let
            host = "mht-home-pc";
            dotHome = "${config.home.homeDirectory}/Workspaces/personal/dotfiles/cirius-nix-v4";
            nr = ''
              nix repl --repl-overlays \
                ${dotHome}/repl.${config.home.username}.${host}.nix \
                ${dotHome}
            '';
          in
          {
            rbnix = ''
              nh os switch ${dotHome}#${host}
            '';
            gco = "git checkout";
            gpl = "git pull origin";
            gps = "git push origin";
            gaa = "git add .";
            gcm = "git commit -m";
            nixgens = "sudo nix-env --profile /nix/var/nix/profiles/system --list-generations";
            delgens = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations old";
            cleanstore = "sudo nix-store --gc";
            inherit nr;
            nri = "${nr} --impure";
          };
      };
      desktop-manager = {
        core = {
          wallpaper = {
            default = ../../../assets/halloween-backiee-5K.jpg;
            dark = ../../../assets/halloween-backiee-5K.jpg;
          };
          blurEffect = {
            enable = true;
          };
        };
        gnome = {
          profile = "default";
        };
        kde = {
          profile = "default";
        };
      };
    };

    services = {
      opensnitch.enable = false;
      flatpak.enable = true;
      autossh = {
        enable = true;
        portForwardingProfiles = {
          BuuukDevBas = {
            enable = true;
          };
          FirstLuxuryBas = {
            enable = true;
            passwordFile = config.sops.secrets."buuuk/first-luxury-bas/password".path;
          };
        };
      };
      syncthing = {
        enable = true;
        username = config.snowfallorg.user.name;
        devices = {
          mht-xiaomi15TPro = {
            id = "Y7D3RRJ-C36EN7Z-UMWWFIF-6OVTNCS-7VZ7TLD-RUR7TCQ-YIISMBH-I6ZDEAK";
            name = "Minh Hieu Tran Xiaomi 15T Pro";
            introducer = false;
            skipIntroductionRemovals = false;
            address = "dynamic";
            paused = false;
            autoAcceptFolders = true;
            untrusted = false;
          };
          thl-samsungS25 = {
            id = "CGCXLTY-7EDFHTI-Q7OPCJ2-RK4EDPY-RSQK2LG-BU2RRPC-UZGZN5G-JLZ7PQV";
            name = "Thanh Hien Le Samsung S25";
            introducer = false;
            skipIntroductionRemovals = false;
            address = "dynamic";
            paused = false;
            autoAcceptFolders = true;
            untrusted = false;
          };
        };
        folders =
          let
            devices = config.${namespace}.services.syncthing.devices;
          in
          {
            family-pics = {
              enable = true;
              id = "019f92b8-9b8c-73bb-80d0-fbadc788ad4e";
              label = "Family Pictures";
              type = "sendonly";
              path = config.snowfallorg.user.home.directory + "/Pictures/family-pics";
              copyOwnershipFromParent = true;
              devices = lib.mapAttrsToList (name: _: name) { inherit (devices) mht-xiaomi15TPro thl-samsungS25; };
              versioning = {
                type = "simple";
                params.keep = "2";
              };
            };
            thl-pics = {
              enable = true;
              id = "019f9319-f1e5-7c48-8a35-cb4c6afd36ea";
              label = "THL Pictures";
              type = "receiveonly";
              path = config.snowfallorg.user.home.directory + "/Pictures/thl-samsungS25";
              copyOwnershipFromParent = true;
              devices = lib.mapAttrsToList (name: _: name) { inherit (devices) thl-samsungS25; };
              versioning = {
                type = "simple";
                params.keep = "2";
              };
            };
            thl-videos = {
              enable = true;
              id = "019f931a-933b-7cf6-8741-5f0d704e8e07";
              label = "THL Videos";
              type = "receiveonly";
              path = config.snowfallorg.user.home.directory + "/Videos/thl-samsungS25";
              copyOwnershipFromParent = true;
              devices = lib.mapAttrsToList (name: _: name) { inherit (devices) thl-samsungS25; };
              versioning = {
                type = "simple";
                params.keep = "1";
              };
            };
            thl-docs = {
              enable = true;
              id = "019f931b-3455-7b3a-bb86-d9ec3557aa55";
              label = "THL Documents";
              type = "receiveonly";
              path = config.snowfallorg.user.home.directory + "/Documents/thl-samsungS25";
              copyOwnershipFromParent = true;
              devices = lib.mapAttrsToList (name: _: name) { inherit (devices) thl-samsungS25; };
              versioning = {
                type = "simple";
                params.keep = "5";
              };
            };
            thl-downloads = {
              enable = true;
              id = "019f931b-6140-70ed-904d-14522b6a95a6";
              label = "THL Downloads";
              type = "receiveonly";
              path = config.snowfallorg.user.home.directory + "/Downloads/thl-samsungS25";
              copyOwnershipFromParent = true;
              devices = lib.mapAttrsToList (name: _: name) { inherit (devices) thl-samsungS25; };
              versioning = {
                type = "simple";
                params.keep = "1";
              };
            };
            mht-musics = {
              enable = true;
              id = "019f9304-a8ed-784e-b680-dc4bcb068ac9";
              label = "MHT Musics";
              type = "sendreceive";
              path = config.snowfallorg.user.home.directory + "/Music/mht-xiaomi15TPro";
              copyOwnershipFromParent = true;
              devices = lib.mapAttrsToList (name: _: name) { inherit (devices) mht-xiaomi15TPro; };
              versioning = {
                type = "simple";
                params.keep = "1";
              };
            };
            mht-docs = {
              enable = true;
              id = "019f92ac-fea0-7395-9c26-5ea5e37267b6";
              label = "MHT Documents";
              type = "sendreceive";
              path = config.snowfallorg.user.home.directory + "/Documents/mht-xiaomi15TPro";
              copyOwnershipFromParent = true;
              devices = lib.mapAttrsToList (name: _: name) { inherit (devices) mht-xiaomi15TPro; };
              versioning = {
                type = "simple";
                params.keep = "5";
              };
            };
            mht-pics = {
              enable = true;
              id = "019f92a4-d018-7823-9458-33df01d3a591";
              label = "MHT Pictures";
              type = "sendreceive";
              path = config.snowfallorg.user.home.directory + "/Pictures/mht-xiaomi15TPro";
              copyOwnershipFromParent = true;
              devices = lib.mapAttrsToList (name: _: name) { inherit (devices) mht-xiaomi15TPro; };
              versioning = {
                type = "simple";
                params.keep = "2";
              };
            };
            mht-videos = {
              enable = true;
              id = "019f92ab-2771-76ca-824f-cb92defbdf0f";
              label = "MHT Videos";
              type = "sendreceive";
              path = config.snowfallorg.user.home.directory + "/Videos/mht-xiaomi15TPro";
              copyOwnershipFromParent = true;
              devices = lib.mapAttrsToList (name: _: name) { inherit (devices) mht-xiaomi15TPro; };
              versioning = {
                type = "simple";
                params.keep = "1";
              };
            };
            mht-downloads = {
              enable = true;
              id = "019f92a8-065a-7344-93b9-0f1c6ccc2164";
              label = "MHT Downloads";
              type = "sendreceive";
              path = config.snowfallorg.user.home.directory + "/Downloads/mht-xiaomi15TPro";
              copyOwnershipFromParent = true;
              devices = lib.mapAttrsToList (name: _: name) { inherit (devices) mht-xiaomi15TPro; };
              versioning = {
                type = "simple";
                params.keep = "1";
              };
            };
          };
      };
    };

    apps =
      (lib.mapAttrs (_: config: { enable = true; } // config) {
        ark = { };
        spotify = { };
        uget = { };
        brave = { };
        kget = { };
        motrix = { };
        eza = { };
        rnote = { };
        edge = { };
        mission-center = { };
        antimicrox = { };
        book-converter = { };
        gopeed = { };
        xh = { };
        comma = { };
        nix-index = { };
        nix-tree = { };
        jnv = { };
        atuin = { };
        starship = { };
        btop = { };
        podman = { };
        pods = {
        };
        zoxide = { };
        bruno = {
          markAsFavorite = true;
        };
        obsidian = {
          markAsFavorite = true;
        };
        ghostty = {
        };
        aws-cli = { };
        vscodium = {
        };
        direnv = { };
        devenv = { };
        goland = {
        };
        datagrip = {
          markAsFavorite = true;
        };
        telegram = { };
        scrcpy = { };
        clion = {
        };
        qemu = { };
        gparted = { };
        proton-pass = {
          markAsFavorite = true;
        };
        fastfetch = { };
        nvim = { };
        markdown-toolchain = { };
        cpp-toolchain = { };
        go-toolchain = { };
        nodejs-toolchain = { };
        ms-teams = { };
        only-office = {
          markAsFavorite = true;
        };
        fzf = { };
        super-productivity = { };
        whisper = { };
        discord = { };
        yt-dlp = { };
        slack = { };
        chamber = { };
        aws-vault = { };
        android-utils = { };
      })
      // {
        ai = (
          lib.mapAttrs (_: config: { enable = true; } // config) {
            deepseek = { };
            claude = { };
            codex = { };
            opencode = { };
            copilot = { };
          }
        );
        ai-utilities = {
          codegraph = { };
        };
      };
  };
}
