# cirius-nix-v4

Personal [Snowfall](https://snowfall.org/)-based Nix flake for NixOS and Home
Manager. `flake.nix` is the entry point for inputs, modules, overlays, and host
outputs.

## Hosts And Users

- Host: `mht-home-pc` (`x86_64-linux`) - see
  [systems/x86_64-linux/mht-home-pc](systems/x86_64-linux/mht-home-pc).
- User: `cirius@mht-home-pc` - see
  [homes/x86_64-linux/cirius@mht-home-pc](homes/x86_64-linux/cirius@mht-home-pc).

## Layout

- [systems/](systems/) - host NixOS configurations.
- [homes/](homes/) - user Home Manager configurations.
- [modules/nixos/](modules/nixos/) - reusable NixOS modules.
- [modules/home/](modules/home/) - reusable Home Manager modules.
- [modules/cross-system/](modules/cross-system/) - modules shared across system
  targets.
- [lib/](lib/) - repository helper code and option helpers.
- [overlays/](overlays/) - package overrides and generated package sets.
- [secrets/](secrets/) - `sops-nix`-encrypted secrets.
- [docs/](docs/) - long-lived knowledge and procedures.

## Quick Start

Build before switching for high-impact changes (boot, hardware, display
manager, users, shells).

```bash
nix flake check
sudo nixos-rebuild build  --flake .#mht-home-pc
sudo nixos-rebuild switch --flake .#mht-home-pc
```

Enter the development shell for formatting, linting, and secret-scanning
tools:

```bash
devenv shell
ci-check   # format + lint + secret + workflow checks
```

## Conventions

- Two-space Nix indentation, multiline attribute sets, `default.nix` as module
  entrypoint.
- Repository-specific options live under the `cirius-nix-v4` namespace via the
  helpers in [lib/core/default.nix](lib/core/default.nix).
- Conventional Commits enforced by Commitizen.
- No secrets, private keys, or unencrypted credentials in tree. Use
  [sops-nix](https://github.com/Mic92/sops-nix); see
  [docs/secure/](docs/secure/).

## Documentation

[docs/](docs/) is the system of record. Start with the topic you need:

- [Project structure](docs/repository/structure.md)
- [Development workflow](docs/repository/development.md)
- [Nix style](docs/repository/nix-style.md)
- [Testing and validation](docs/repository/testing.md)
- [Commits and PRs](docs/repository/changes.md)
- [Secrets and secure store](docs/secure/README.md)

For agent-assisted work, see [AGENTS.md](AGENTS.md).
