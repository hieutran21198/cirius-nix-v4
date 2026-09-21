{
  description = "Cirius Nix V3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    # core
    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # applications
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zjstatus = {
      url = "github:dj95/zjstatus";
    };
    open-spec.url = "github:Fission-AI/OpenSpec";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex-desktop-linux = {
      url = "github:hieutran21198/codex-desktop-linux";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    eden = {
      url = "github:Daaboulex/eden-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deepseek-harness = {
      url = "github:hieutran21198/deepseek-harness-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # desktop

    # input methods
    fcitx5-lotus = {
      url = "github:LotusInputMethod/fcitx5-lotus";
    };

    devenv.url = "github:cachix/devenv";
  };

  outputs =
    inputs:
    let
      namespaceID = "cirius-nix-v4";

      core = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;
        snowfall = {
          meta = {
            name = namespaceID;
            title = "Cirius Nix version 4";
          };
          namespace = namespaceID;
        };
      };

      crossSystemModules = builtins.attrValues (
        core.snowfall.module.create-modules {
          src = ./modules/cross-system;
        }
      );

      coreOutputs = core.mkFlake {
        channels-config = {
          allowUnfree = true;
          cudaCapabilities = [ "8.9" ];
        };

        systems = {
          modules = {
            nixos =
              (with inputs; [
                sops-nix.nixosModules.sops
                stylix.nixosModules.stylix
                fcitx5-lotus.nixosModules.fcitx5-lotus
                impermanence.nixosModules.impermanence
                hermes-agent.nixosModules.default
                nixos-wsl.nixosModules.default
                nix-index-database.nixosModules.default
                eden.nixosModules.default
                nix-flatpak.nixosModules.nix-flatpak
              ])
              ++ crossSystemModules;

            darwin =
              (with inputs; [
                sops-nix.darwinModules.sops
                stylix.darwinModules.stylix
                nix-index-database.darwinModules.default
              ])
              ++ crossSystemModules;
          };
        };

        homes = {
          modules = with inputs; [
            sops-nix.homeModules.sops
            nixvim.homeModules.nixvim
            stylix.homeModules.stylix
            nix-flatpak.homeManagerModules.nix-flatpak
            codex-desktop-linux.homeManagerModules.default
            nix-index-database.homeModules.default
            plasma-manager.homeModules.plasma-manager
            zen-browser.homeModules.default
            deepseek-harness.homeManagerModules.default
          ];
        };

        packages = { };

        outputs-builder = _channels: {
        };
      };
    in
    coreOutputs
    // (
      let
        nixConfig = coreOutputs.nixosConfigurations.mht-home-pc.config;
        homeConfig = coreOutputs.nixosConfigurations.mht-home-pc.config.home-manager.users.cirius;
        plasmaConfig = homeConfig.programs.plasma;
      in
      {
        cirius-nixos = nixConfig;
        cirius-home = homeConfig;
        cirius-plasma = plasmaConfig;
      }
    );
}
