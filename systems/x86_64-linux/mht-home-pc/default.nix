{
  config,
  pkgs,
  namespace,
  lib,
  host,
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
  inherit (config.cnix-sec) secret-mgt;
in
{
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
    ./storage.nix
    ./networking.nix
  ];

  # core packages need to be installed.
  environment.systemPackages = with pkgs; [
    wget
    neovim
    git
    github-cli
    jq
    ripgrep
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  cnix-vn = {
    enable = true;
    inputMethod.users = [ "cirius" ];
  };

  cnix-visual.desktop-environment.use = "kde";

  cnix-utils.unlockKDEWalletByLUKS = config.cnix-sec.secure-store.enable;

  cnix-gaming = {
    useRecommendedPackages = true;
    usePlatforms = [
      "lutris"
      "steam"
    ];
    emulator.useClients = [
      "eden"
      "retroarch"
    ];
    gamescope = {
      enable = true;
      hdr = true;
    };
    stream = {
      enable = true;
      settings = {
        port = 47990;
        users = [ "cirius" ];
        displayID = "DP-2";
        origins = [ "https://stream.home.arpa" ];
      };
    };
  };

  cnix-virt = {
    useRecommendedPackages = true;

    container = {
      enable = true;
      containers = {
        dockhand = {
          enable = true;
          image = "fnsys/dockhand:8d7ce9eb-baseline";
          address = "127.0.0.1:2000";
          dependsOn = [ "postgres-dockhand" ];
          environmentFiles = [ secret-mgt.secrets."personal/dockhand/env".path ];
        };
        postgres = {
          enable = true;
          instances.dockhand = {
            enable = true;
            image = "postgres:18-alpine";
            address = "127.0.0.1:5401";
            environmentFiles = [ secret-mgt.secrets."personal/postgres/dockhand/env".path ];
          };
        };
      };
    };

    virt-desktop = {
      enable = true;
      settings = {
        dir = ./edid;
        edids."mi15tp60.bin" = {
          name = "DP-2";
          mode = "e";
        };
      };
    };
  };

  # sudo cp /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt ./assets/caddy-root.crt
  cnix-sec = {
    pki.certificateFiles = [ ../../../assets/caddy-root.crt ];
    secret-mgt = {
      enable = true;
      settings = {
        ageKeyFile = "/mnt/secure-store/host/sops-age/key.txt";
        defaultSecretFile = ../../../secrets/${host}/default.yaml;
      };
    };
    secure-store = {
      enable = true;
      settings = {
        name = "secure-store";
        luksDevicePath = "/dev/disk/by-uuid/a0b01d1b-4e4a-43b8-af99-888be9694e1d";
        mountPoint = {
          fsType = "btrfs";
          options = [
            "ro"
            "nodev"
            "nosuid"
            "noexec"
            "compress=zstd"
            "noatime"
          ];
        };
      };
    };
  };

  cnix-net = {
    enable = true;
    settings = {
      hostName = "mht-home-pc";
      hosts = {
        "127.0.0.1" = [
          {
            localDomain = "container.home.arpa";
            extraConfig = "tls internal";
            upstream = config.cnix-virt.container.containers.dockhand.address;
          }
          {
            localDomain = "sync.home.arpa";
            extraConfig = "tls internal";
            upstream = "localhost:2002";
          }
          {
            localDomain = "stream.home.arpa";
            extraConfig = "tls internal";
            proxyExtraConfig = ''
              transport http {
                tls_insecure_skip_verify
              }
            '';
            upstream = "https://localhost:${toString (config.cnix-gaming.stream.settings.port + 1)}";
          }
        ];
      };
      vpn.enable = true;
    };
  };

  # namespace config.
  ${namespace} = {
    services = {
      music-server = {
        enable = true;
        envFile = secret-mgt.templates."personal/music-server/env-file".path;
        musicDir = "/mnt/main-data/Music";
      };
      cloudflare-warp.enable = true;
    };

    infra = {
      nix = {
        # package = pkgs.lixPackageSets.stable.lix;
        extraOptions = ''
          !include ${secret-mgt.secrets."personal/nix/extra-options".path}
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
            "https://cache.numtide.com"
            "https://deepseek-harness-nix.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
            "deepseek-harness-nix.cachix.org-1:5NrkwLN9veNMhiINtU5ZeV4isXFhFsOwn6Ms7J1M+TA="
          ];
        };
      };
      nvidia.enable = true;
      # Deprecated
      virtualisation = {
        enable = true;
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

                    groupEnabledPattern = x: lib.optional x.enable x.iam.group;

                    serviceGroups = with services; [
                      music-server
                    ];
                  in
                  (lib.concatMap groupEnabledPattern serviceGroups)
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
    };
  };

  security.rtkit.enable = true;

  system = {
    inherit stateVersion;
  };
}
