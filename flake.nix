{
  description = "Cirius Nix V3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # core
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
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    cirius-security = {
      url = "github:cirius-nix/cirius-nix-facade/main?dir=flakes/cirius-security";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    cirius-lib = {
      url = "github:cirius-nix/cirius-nix-facade/main?dir=flakes/cirius-lib";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    cirius-art = {
      url = "github:cirius-nix/cirius-nix-facade/main?dir=flakes/cirius-art";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    cirius-dev = {
      url = "github:cirius-nix/cirius-nix-facade/main?dir=flakes/cirius-dev";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    cirius-gaming = {
      url = "github:cirius-nix/cirius-nix-facade/main?dir=flakes/cirius-gaming";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    cirius-virt = {
      url = "github:cirius-nix/cirius-nix-facade/main?dir=flakes/cirius-virt";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    cirius-vn = {
      url = "github:cirius-nix/cirius-nix-facade/main?dir=flakes/cirius-vn";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    cirius-office = {
      url = "github:cirius-nix/cirius-nix-facade/main?dir=flakes/cirius-office";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    cirius-utils = {
      url = "github:cirius-nix/cirius-nix-facade/main?dir=flakes/cirius-utils";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    cirius-visual = {
      url = "github:cirius-nix/cirius-nix-facade/main?dir=flakes/cirius-visual";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    cirius-networking = {
      url = "github:cirius-nix/cirius-nix-facade/main?dir=flakes/cirius-networking";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
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
                impermanence.nixosModules.impermanence
                nixos-wsl.nixosModules.default
                cirius-gaming.nixosModules.default
                cirius-virt.nixosModules.default
                cirius-vn.nixosModules.default
                cirius-security.nixosModules.default
                cirius-utils.nixosModules.default
                cirius-visual.nixosModules.default
                cirius-networking.nixosModules.default
              ])
              ++ crossSystemModules;

            darwin =
              (with inputs; [
                sops-nix.darwinModules.sops
              ])
              ++ crossSystemModules;
          };
        };

        homes = {
          modules = with inputs; [
            sops-nix.homeModules.sops
            plasma-manager.homeModules.plasma-manager
            cirius-art.homeModules.default
            cirius-dev.homeModules.default
            cirius-office.homeModules.default
            cirius-security.homeModules.default
            cirius-utils.homeModules.default
            cirius-virt.homeModules.default
            cirius-visual.homeModules.default
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
