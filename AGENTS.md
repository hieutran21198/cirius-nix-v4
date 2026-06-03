# Repository Guidelines

## Project Structure & Module Organization

This repository is a Snowfall-based Nix flake for personal NixOS and Home Manager configuration. `flake.nix` is the main entry point for inputs, modules, overlays, and host outputs. Host NixOS configurations live in `systems/<system>/<host>/`, for example `systems/x86_64-linux/mht-home-pc/default.nix`. User Home Manager configurations live in `homes/<system>/<user@host>/`.

Reusable modules are grouped by target: `modules/nixos/`, `modules/home/`, and `modules/cross-system/`. Custom helper code belongs in `lib/`; package overrides or generated package sets belong in `overlays/`.

## Build, Test, and Development Commands

- `nix flake check`: evaluate flake outputs and catch broken modules.
- `nix flake show`: inspect available systems, homes, packages, and other generated outputs.
- `sudo nixos-rebuild build --flake .#mht-home-pc`: build the current host without switching to it.
- `sudo nixos-rebuild switch --flake .#mht-home-pc`: apply the host configuration locally.
- `devenv shell`: enter the development environment when `devenv.nix` grows project tooling.

Prefer `build` before `switch` for core NixOS, hardware, boot, or desktop-manager changes.

## Coding Style & Naming Conventions

Use standard Nix style: two-space indentation, multiline attribute sets for nested configuration, and concise `let` bindings for reused values. Name modules by capability and keep paths predictable, such as `modules/home/apps/<app>/default.nix` or `modules/nixos/infra/<feature>/default.nix`.

Expose repository-specific options under the flake namespace (`${namespace}`). Keep host-specific values, hardware details, users, and locale choices in `systems/`; keep reusable behavior in `modules/`.

## Testing Guidelines

There is no separate test suite yet. Treat Nix evaluation and builds as required checks. Run `nix flake check` after module edits and `sudo nixos-rebuild build --flake .#mht-home-pc` before changes affecting boot, display manager, users, shells, or hardware.

## Commit & Pull Request Guidelines

Use Conventional Commits checked by Commitizen. Keep subjects short, imperative, and meaningful, such as `feat: add vscodium home module` or `chore: update desktop settings`. Prefer brief bodies only when they clarify intent or validation. Keep commits focused by host, module, or overlay.

For pull requests, include intent, affected paths, commands run, and manual validation. Mention whether the change was built only or switched locally. Include screenshots only for visible desktop or application changes.

## Security & Configuration Tips

Do not commit secrets, private keys, or unencrypted credentials. Use `sops-nix` for secrets and keep hardware-specific details in the relevant host directory. Review `flake.lock` changes carefully because input updates can affect the whole system.
