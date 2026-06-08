# Security

Do not commit secrets, private keys, or unencrypted credentials.

Use `sops-nix` for secrets and keep hardware-specific details in the relevant
host directory. Review `flake.lock` changes carefully because input updates can
affect the whole system.

See `secure-store.md` for the secure-store setup procedure.
