{
  description = "Cirius Nix V3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
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

    # applications
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
    open-design.url = "github:nexu-io/open-design";
    open-spec.url = "github:Fission-AI/OpenSpec";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # desktop

    # input methods
    fcitx5-lotus = {
      url = "github:LotusInputMethod/fcitx5-lotus";
    };
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
    in
    core.mkFlake {
      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "librewolf-151.0.2-1"
          "librewolf-unwrapped-151.0.2-1"
        ];
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
            ])
            ++ crossSystemModules;

          darwin =
            (with inputs; [
              sops-nix.darwinModules.sops
              stylix.darwinModules.stylix
            ])
            ++ crossSystemModules;
        };
      };

      homes = {
        modules = with inputs; [
          sops-nix.homeModules.sops
          nixvim.homeModules.nixvim
          stylix.homeModules.stylix
          open-design.homeManagerModules.default
        ];
      };

      packages = { };

      outputs-builder = _channels: {
      };
    };
}
