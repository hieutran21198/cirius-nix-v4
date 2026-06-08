# Agent Guide

This file is the context-light table of contents for repository work. Keep it short.
The system of record lives under `docs/`; open only the docs relevant to the task.

## Start Here

- Repo map and ownership boundaries: `docs/repository/structure.md`
- Build, evaluation, and local workflow: `docs/repository/development.md`
- Nix style and module option conventions: `docs/repository/nix-style.md`
- Required validation: `docs/repository/testing.md`
- Commit and PR expectations: `docs/repository/changes.md`
- Secrets and secure-store notes: `docs/secure/README.md`
- Secure-store setup procedure: `docs/secure/secure-store.md`

## Quick Context

This is a Snowfall-based Nix flake for personal NixOS and Home Manager
configuration. `flake.nix` wires inputs, modules, overlays, and generated host
outputs.

Use these broad ownership rules:

- Host NixOS configuration: `systems/<system>/<host>/`
- User Home Manager configuration: `homes/<system>/<user@host>/`
- Reusable NixOS modules: `modules/nixos/`
- Reusable Home Manager modules: `modules/home/`
- Cross-system modules: `modules/cross-system/`
- Repository helper library code: `lib/`
- Package overlays and generated package sets: `overlays/`
- Long-lived knowledge and procedures: `docs/`

## Before Editing

- Read the relevant doc from the table above before changing code.
- Keep host-specific values, hardware details, users, and locale choices in
  `systems/`.
- Keep reusable behavior in `modules/`.
- Preserve the existing Snowfall module convention: module directories expose
  `default.nix`.
- Do not commit secrets, private keys, or unencrypted credentials.

## Common Commands

- `nix flake check`
- `nix flake show`
- `sudo nixos-rebuild build --flake .#mht-home-pc`
- `sudo nixos-rebuild switch --flake .#mht-home-pc`
- `devenv shell`

Prefer `build` before `switch` for core NixOS, hardware, boot, display-manager,
desktop-manager, user, shell, or other high-impact system changes.

## Non-Negotiables

- Use standard Nix formatting: two-space indentation and readable multiline
  attribute sets.
- Put repository-specific options under the flake namespace (`${namespace}`).
- Prefer option helpers from `lib/core/default.nix` for primitive, package,
  enum, list, and attrs options.
- Run `nix flake check` after module edits when feasible.
- Review `flake.lock` changes carefully.

## Maintaining This Map

When guidance grows beyond a few lines, move it into `docs/` and link it here.
When docs move, update this file in the same change.
