{
  config,
  pkgs,
  namespace,
  lib,
  inputs,
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
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # namespace config.
  ${namespace} = {
    services = {
      gaming.enable = true;
      hermes = {
        enable = true;
        envFiles = [ sops.templates."personal/hermes/env-file".path ];
      };
      opensnitch.enable = true;
    };

    infra = {
      nix = {
        package = pkgs.lixPackageSets.stable.lix;
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
            "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
            "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
          ];
        };
      };
      ai = {
        llama-cpp.enable = true;
      };
      security = {
        secrets = {
          "personal/api-key/deepseek" = {
            key = "ai/deepseek/api-key";
            mode = "0400";
          };
        };
        templates = {
          "personal/hermes/env-file" = {
            content = ''
              DEEPSEEK_API_KEY=${sops.secrets."personal/api-key/deepseek".path}
            '';
          };
        };
        # LUKS secure device.
        secureStore = {
          enable = true;
          name = "secure-store";
          device = "/dev/disk/by-uuid/a0b01d1b-4e4a-43b8-af99-888be9694e1d";
          fsType = "btrfs";
          mountOptions = [
            "ro"
            "nodev"
            "nosuid"
            "noexec"
            "compress=zstd"
            "noatime"
          ];
          hostAgeKey = "host/sops-age/key.txt";
        };
      };
      nvidia.enable = true;
      virtualisation.enable = true;
      networking =
        let
          hostName = "mht-home-pc";
          opencodeHost = "opencode.${hostName}";
          opendesignHost = "opendesign.${hostName}";
        in
        {
          enable = true;
          inherit hostName;
          hosts = {
            "127.0.0.1" = [
              opencodeHost
              opendesignHost
            ];
          };
          # Open ports in the firewall.
          firewall = {
            enable = true;
            # allowedTCPPorts = [ ... ];
            # allowedUDPPorts = [ ... ];
          };
          virtualHosts = {
            ${opencodeHost}.extraConfig = ''
              tls internal
              reverse_proxy 127.0.0.1:10200
            '';
            ${opendesignHost}.extraConfig =
              let
                openDesignWeb = inputs.open-design.packages.${pkgs.system}.web;
              in
              ''
                tls internal
                handle /api/* {
                  reverse_proxy 127.0.0.1:10000 {
                    flush_interval -1
                    transport http {
                      read_timeout 86400s
                      write_timeout 86400s
                    }
                  }
                }
                handle /artifacts/* {
                  reverse_proxy 127.0.0.1:10000
                }
                handle /frames/* {
                  reverse_proxy 127.0.0.1:10000
                }
                handle {
                  root * ${openDesignWeb}
                  try_files {path} {path}/ /index.html
                  file_server
                  encode gzip
                }
              '';
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
        groups = {
          mht-home-pc-admins = { };
        };
        users =
          let
            inherit (config.${namespace}.infra) iam shell;
            inherit (iam) groups;
            inherit (shell) fish;
          in
          {
            # Define a user account. Don't forget to set a password with ‘passwd’.
            cirius = {
              userSettings = {
                isNormalUser = true;
                extraGroups = [
                  groups.mht-home-pc-admins.name
                  "networkmanager"
                  "wheel"
                ];
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
        engine = supportedDesktopManagers.gnome;
        settings = {
          gnome = { };
        };
      };
    };
  };

  environment.etc.crypttab.text = ''
    secure UUID=e211ebab-1197-40df-8f2d-c80fd12fe942 none luks,nofail
  '';

  fileSystems = {
    "/home/cirius/Workspaces" = {
      device = "/dev/mapper/secure";
      fsType = "btrfs";
      options = [
        "subvol=@cirius-workspaces"
        "compress=zstd"
        "noatime"
        "nofail"
        "x-systemd.requires=systemd-cryptsetup@secure.service"
        "x-systemd.after=systemd-cryptsetup@secure.service"
      ];
    };

    "/mnt/main-data" = {
      device = "/dev/disk/by-uuid/16D3A0ED3E0C06F5";
      fsType = "ntfs3";
      options = [
        "rw"
        "nofail"
        "noatime"

        "uid=1000"
        "gid=100"
        "umask=022"
        "dmask=0022"
        "fmask=0022"

        "windows_names"
      ];
    };

    "/home/cirius/Documents" = {
      device = "/mnt/main-data/Documents";
      fsType = "none";
      options = [
        "bind"
        "rw"
        "nofail"
        "x-systemd.requires-mounts-for=/mnt/main-data"
        "x-systemd.requires=main-data-user-dirs.service"
        "x-systemd.after=main-data-user-dirs.service"
      ];
    };

    "/home/cirius/Music" = {
      device = "/mnt/main-data/Music";
      fsType = "none";
      options = [
        "bind"
        "rw"
        "nofail"
        "x-systemd.requires-mounts-for=/mnt/main-data"
        "x-systemd.requires=main-data-user-dirs.service"
        "x-systemd.after=main-data-user-dirs.service"
      ];
    };

    "/home/cirius/Pictures" = {
      device = "/mnt/main-data/Pictures";
      fsType = "none";
      options = [
        "bind"
        "rw"
        "nofail"
        "x-systemd.requires-mounts-for=/mnt/main-data"
        "x-systemd.requires=main-data-user-dirs.service"
        "x-systemd.after=main-data-user-dirs.service"
      ];
    };

    "/home/cirius/Videos" = {
      device = "/mnt/main-data/Videos";
      fsType = "none";
      options = [
        "bind"
        "rw"
        "nofail"
        "x-systemd.requires-mounts-for=/mnt/main-data"
        "x-systemd.requires=main-data-user-dirs.service"
        "x-systemd.after=main-data-user-dirs.service"
      ];
    };
  };

  systemd.services.main-data-user-dirs = {
    description = "Create user directories on main-data";
    requires = [ "mnt-main\\x2ddata.mount" ];
    after = [ "mnt-main\\x2ddata.mount" ];
    before = [
      "home-cirius-Documents.mount"
      "home-cirius-Music.mount"
      "home-cirius-Pictures.mount"
      "home-cirius-Videos.mount"
    ];
    path = [ pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      set -euo pipefail

      for dir in Documents Music Pictures Videos; do
        install -d -m 0755 -o cirius -g users "/home/cirius/$dir"
        mkdir -p "/mnt/main-data/$dir"
      done
    '';
  };

  systemd.tmpfiles.rules = [
    "d /home/cirius/Workspaces 0700 cirius users - -"
  ];

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  security.rtkit.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    neovim
    git
    github-cli
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  system = {
    inherit stateVersion;
  };
}
