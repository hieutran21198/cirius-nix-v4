# Development Workflow

## Commands

- `nix flake check`: evaluate flake outputs and catch broken modules.
- `nix flake show`: inspect available systems, homes, packages, and generated
  outputs.
- `sudo nixos-rebuild build --flake .#mht-home-pc`: build the current host
  without switching to it.
- `sudo nixos-rebuild switch --flake .#mht-home-pc`: apply the host
  configuration locally.
- `devenv shell`: enter the development environment when `devenv.nix` grows
  project tooling.

Prefer `build` before `switch` for core NixOS, hardware, boot,
desktop-manager, display-manager, user, shell, or hardware changes.

## Flake Notes

Untracked files are not included when Nix evaluates a Git-backed flake source.
If new files are added, add them to Git before relying on repo-root flake
evaluation.
