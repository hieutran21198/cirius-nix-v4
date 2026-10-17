# Project Structure

This repository is a Snowfall-based Nix flake for personal NixOS and Home
Manager configuration. `flake.nix` is the main entry point for inputs, modules,
overlays, and host outputs.

## Main Paths

- `systems/<system>/<host>/`: host NixOS configurations, such as
  `systems/x86_64-linux/mht-home-pc/default.nix`.
- `homes/<system>/<user@host>/`: user Home Manager configurations.
- `modules/nixos/`: reusable NixOS modules.
- `modules/home/`: reusable Home Manager modules.
- `modules/cross-system/`: modules shared across supported system targets.
- `lib/`: custom helper code.
- `overlays/`: package overrides or generated package sets.
- `packages/`: flake-local package definitions for software that nixpkgs
  does not carry, exposed to modules as `pkgs.${namespace}.<name>`.
- `docs/`: repository knowledge base and operating procedures.

## Boundaries

Keep host-specific values, hardware details, users, and locale choices in
`systems/`. Keep reusable behavior in `modules/`.

Name modules by capability and keep paths predictable, such as
`modules/home/apps/<app>/default.nix` or
`modules/nixos/infra/<feature>/default.nix`.

Snowfall module directories should expose `default.nix`.

Package directories under `packages/` expose `default.nix` too. When a
package pins an upstream artifact that has no reproducible, versioned URL,
record how to refresh the pin in a comment next to it, and put any
multi-step refresh procedure in an `update.sh` beside the derivation.
