# Testing And Validation

There is no separate test suite yet. Treat Nix evaluation and builds as the
required checks.

## Required Checks

- Run `nix flake check` after module edits when feasible.
- Run `sudo nixos-rebuild build --flake .#mht-home-pc` before changes affecting
  boot, display manager, users, shells, hardware, or other high-impact system
  behavior.

Mention any checks that could not be run and why.
