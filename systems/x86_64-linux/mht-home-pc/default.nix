{
  config,
  pkgs,
  namespace,
  lib,
  ...
}:
let
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  stateVersion = "25.11";

  inherit (lib.${namespace}) supportedDesktopManagers;
  inherit (config) sops;
in
{
  imports = [
    ./hardware-configuration.nix
    ./edid/virtual-desktop.nix
    ./secrets.nix
    ./storage.nix
    ./networking.nix
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # namespace config.
  ${namespace} = {
    apps = {
      nh.enable = true;
    };
    containers = {
      dockhand = {
        enable = true;
        port = 2000;
        dependsOn = [ "postgres-dockhand" ];
        environmentFiles = [ sops.secrets."personal/dockhand/env".path ];
      };
      sonarqube = {
        enable = true;
        port = 2001;
        dependsOn = [ "postgres-sonarqube" ];
        environmentFiles = [ sops.secrets."personal/sonarqube/env".path ];
      };
      postgres = {
        enable = true;
        databases = {
          dockhand = {
            port = 5401;
            environmentFiles = [ sops.secrets."personal/postgres/dockhand/env".path ];
          };
          sonarqube = {
            port = 5402;
            environmentFiles = [ sops.secrets."personal/postgres/sonarqube/env".path ];
          };
        };
      };
    };
    services = {
      tailscale.enable = true;
      open-design.enable = true;
      aria2 = {
        enable = true;
        virtualHost = "aria2.mht-home-pc";
        rpcSecretFile = sops.secrets."personal/aria2/rpc-secret".path;
      };
      music-server = {
        enable = true;
        envFile = sops.templates."personal/music-server/env-file".path;
        musicDir = "/mnt/main-data/Music";
      };
      cloudflare-warp.enable = true;
      gaming = {
        enable = true;
        stream = {
          enable = true;
          users = [ "cirius" ];
          displayID = "1";
          applications =
            let
              steamPackage = config.programs.steam.package;
            in
            [
              { name = "Desktop"; }
              {
                name = "steam-sb";
                prep-cmd = [
                  { do = "/home/cirius/Workspaces/SteamGG/_Mods/stellar-blade-mods.sh default"; }
                ];
                cmd = "${lib.getExe steamPackage} -gamepadui";
                wait-all = true;
                auto-detach = true;
              }
              {
                name = "steam-sb-alt";
                prep-cmd = [
                  {
                    do = "/home/cirius/Workspaces/SteamGG/_Mods/stellar-blade-mods.sh alt";
                    undo = "/home/cirius/Workspaces/SteamGG/_Mods/stellar-blade-mods.sh default";
                  }
                ];
                cmd = "${lib.getExe steamPackage} -gamepadui";
                wait-all = true;
                auto-detach = true;
              }
            ];
        };
        gamescope = {
          enable = true;
          enableHDR = false;
        };
        emulator = {
          eden = {
            enable = true;
          };
        };
      };
      hermes = {
        enable = false;
        envFiles = [ sops.templates."personal/hermes/env-file".path ];
      };
      opensnitch.enable = false;
    };

    infra = {
      nix = {
        package = pkgs.lixPackageSets.stable.lix;
        extraOptions = ''
          !include ${sops.secrets."personal/nix/extra-options".path}
        '';
        settings = {
          allowed-users = [ "cirius" ];
          auto-optimise-store = true;
          cores = 8;
          trusted-users = [
            "root"
            "@wheel"
            "cirius"
          ];
          substituters = [
            "https://cache.nixos.org"
            "https://cache.nixos-cuda.org"
            "https://nix-community.cachix.org"
            "https://codex-cli.cachix.org"
            "https://cache.numtide.com"
          ];
          trusted-public-keys = [
            "deepseek-harness-flake.cachix.org-1:X/nyJkoKMvswHStf5hwikOPJRmD9aobzJDqQCLpqqMA="
            "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
            "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
          ];
        };
      };
      ai = {
        llama-cpp.enable = false;
      };
      security = {
        pki = {
          # sudo cp /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt ./assets/caddy-root.crt
          certificateFiles = [ ../../../assets/caddy-root.crt ];
        };
      };
      nvidia.enable = true;
      virtualisation = {
        enable = true;
        distroBox = {
          enable = true;
        };
      };
      input-method = {
        enable = true;
        enableLotus = true;
        users = [ "cirius" ];
      };
      shell = {
        fish = {
          enable = true;
        };
      };
      iam = {
        users =
          let
            inherit (config.${namespace}.infra) shell;
            inherit (shell) fish;
          in
          {
            # Define a user account. Don't forget to set a password with ‘passwd’.
            cirius = {
              enableHomeManager = true;
              userSettings = {
                isNormalUser = true;
                extraGroups =
                  let
                    inherit (config.${namespace}) services;
                    inherit (config.${namespace}) containers;

                    groupEnabledPattern = x: lib.optional x.enable x.iam.group;

                    serviceGroups = with services; [
                      music-server
                      aria2
                      open-design
                    ];

                    containerGroups = with containers; [ sonarqube ];
                  in
                  (lib.concatMap groupEnabledPattern serviceGroups)
                  ++ (lib.concatMap groupEnabledPattern containerGroups)
                  ++ [
                    "networkmanager"
                    "wheel"
                  ]
                  ++ (lib.optional config.${namespace}.infra.virtualisation.enable "libvirtd");
                shell = if fish.enable then fish.package else pkgs.bash;
              };
              homeSettings = {
                home = {
                  inherit stateVersion;
                };
              };
            };
          };
      };
      desktop-manager = {
        enable = true;
        engine = supportedDesktopManagers.kde;
        settings = {
          gnome = { };
          kde = {
            useWalletByLUKS = true;
          };
        };
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "vi_VN";
      LC_IDENTIFICATION = "vi_VN";
      LC_MEASUREMENT = "vi_VN";
      LC_MONETARY = "vi_VN";
      LC_NAME = "vi_VN";
      LC_NUMERIC = "vi_VN";
      LC_PAPER = "vi_VN";
      LC_TELEPHONE = "vi_VN";
      LC_TIME = "vi_VN";
    };
  };

  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    neovim
    git
    github-cli
  ];

  system = {
    inherit stateVersion;
  };
}
