{
  inputs,
  namespace,
  config,
  pkgs,
  host,
  lib,
  ...
}:
let
  enableAll =
    list:
    lib.listToAttrs (
      map (x: {
        name = x;
        value = {
          enable = true;
        };
      }) list
    );
  inherit (config.snowfallorg) user;

  withFlatpakDesktopEntries =
    list:
    map (
      appID:
      config.home.homeDirectory + "/.local/share/flatpak/exports/share/applications/" + appID + ".desktop"
    ) list;
in
{
  imports = [
    ./secrets-default.nix
    ./secrets-buuuk.nix
    ./secrets-shared.nix
  ];
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      PROTON_PASS_LINUX_KEYRING = "dbus";
      SSH_AUTH_SOCK = "${user.home.directory}/.ssh/proton-pass-ssh-agent.sock";
    };

    packages =
      with pkgs;
      with pkgs.jetbrains;
      with pkgs.kdePackages;
      with pkgs.${namespace};
      [
        freecad
        # IDEs
        clion
        datagrip
        goland
        # Network Tools
        brave
        # Stream Android Screen
        scrcpy
        qtscrcpy
        # chat
        telegram-desktop
        discord
        slack
        # media
        spotify
        vlc
        # touch tools
        rnote
        # utilities
        gparted
        proton-pass
        proton-pass-cli
        filelight
        # Compression Tools
        ark
        unrar
      ];
  };

  cnix-art = {
    useRecommendedPackages = true;
    sprite.enable = true;
  };

  cnix-office = {
    enable = true;
    variant = "research";
  };

  cnix-visual = {
    enable = true;
    useRecommendedFonts = true;
    useRecommendedTheme = true;
    desktop-environment = {
      use = "kde";
      kde = {
        themeSwitcher = {
          enable = true;
          settings = {
            mode = "scheduled";
            sunset = 8;
            sunrise = 16;
          };
        };
        panelOnMonitors = [
          0
          1
        ];
      };
    };
  };

  cnix-sec = {
    ssh.enable = true;
    secret-mgt = {
      enable = true;
      settings = {
        ageKeyFile = "/mnt/secure-store/users/${user.name}/sops-age/key.txt";
        defaultSecretFile = ../../../secrets/${user.name}__${host}/default.yaml;
      };
    };
    ssh-port-mgt.enable = true;
  };

  cnix-dev = {
    useRecommendedPackages = true;
    shell = "fish";
    editor = {
      nvim.enable = true;
      code.enable = true;
    };
    git.enable = true;
    term.useTerms = [ "ghostty" ];
    ai = {
      useRecommendedPackages = true;
      useClients = [
        "claude"
        "opencode"
        "commandcode"
        "codex"
        "multica"
        "copilot"
      ];
    };
    toolchain = enableAll [
      "cpp"
      "go"
      "markdown"
      "nodejs"
      "nix"
      "android"
      "latex"
      "unity"
    ];
  };

  cnix-utils = {
    enable = true;
    settings = {
      dotFileDir = "${config.home.homeDirectory}/Workspaces/personal/dotfiles/cirius-nix-v4";
      enableBootLogCapture = true;
      managedDesktopEnvironment = "kde";
    };
    desktop-environment = {
      shortcuts = {
        enable = true;
        useRecommendedShortcuts = true;
      };
      power-controls.enable = true;
    };
    chrome-webapps = {
      enable = true;
      settings = {
        package = pkgs.brave;
        workspaceDataPath = "${config.xdg.dataHome}/chrome-webapps";
        workspaces = {
          personal.apps = with builtins; fromJSON (readFile ./web-apps/personal.json);
          buuuk.apps = with builtins; fromJSON (readFile ./web-apps/buuuk.json);
        };
      };
    };
    connectivity = {
      enable = true;
      settings = {
        fileSync = {
          enable = true;
          settings = {
            port = 2002;
            devices = with builtins; fromJSON (readFile ./sync-file/devices.json);
            folders = with builtins; fromJSON (readFile ./sync-file/folders.json);
            credentials.username = user.name;
          };
        };
      };
    };
    package-manager.flatpak = {
      enable = true;
      remotePackages = {
        flathub.packages = [
          "org.freedownloadmanager.Manager"
          "eu.betterbird.Betterbird"
          "com.ranfdev.DistroShelf"
        ];
      };
    };
  };
  xdg = {
    enable = true;
    autostart = {
      enable = true;
      entries = [
        "${pkgs.proton-pass}/share/applications/proton-pass.desktop"
      ]
      ++ (withFlatpakDesktopEntries [
        "eu.betterbird.Betterbird"
        "org.freedownloadmanager.Manager"
      ]);
    };
  };
}
