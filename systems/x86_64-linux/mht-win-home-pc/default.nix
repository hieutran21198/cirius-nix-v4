{
  config,
  pkgs,
  namespace,
  ...
}:
let
  stateVersion = "26.05";
in
{
  ${namespace} = {
    infra = {
      wsl = {
        enable = true;
        defaultUser = "cirius";
        enableDockerDesktop = true;
        settings = {
          network.hostname = "mht-win-home-pc";
        };
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
            cirius = {
              enableHomeManager = true;
              userSettings = {
                isNormalUser = true;
                uid = 1001;
                extraGroups = [
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
        engine = "none";
      };
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
      security = {
        pki = {
          # sudo cp /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt ./assets/caddy-root.crt
          certificateFiles = [ ../../../assets/caddy-root.crt ];
        };
      };
    };
  };

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

  environment.systemPackages = with pkgs; [
    neovim

    git
    github-cli

    nixfmt
  ];

  system = {
    inherit stateVersion;
  };
}
