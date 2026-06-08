# Nix Style

Use standard Nix style:

- Two-space indentation.
- Multiline attribute sets for nested configuration.
- Concise `let` bindings for reused values.
- Capability-based module names.
- `default.nix` as the module entrypoint for Snowfall-discovered module
  directories.

## Namespaced Options

Expose repository-specific options under the flake namespace (`${namespace}`).

Prefer the option helpers from `lib/core/default.nix` when declaring namespaced
module options:

- `lib.${namespace}.makeBoolOption`
- `lib.${namespace}.makeStrOption`
- `lib.${namespace}.makeIntOption`
- `lib.${namespace}.makeFloatOption`
- `lib.${namespace}.makePackageOption`
- `lib.${namespace}.makeEnumOption`
- `lib.${namespace}.makeListOption`
- `lib.${namespace}.makeAttrsOption`

Pass helper inputs such as `default`, `description`, `readOnly`, `nullable`,
`acceptedList`, and `ofType` as needed. Use raw `lib.mkOption` only when the
helper surface does not fit.
