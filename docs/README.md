# Repository Knowledge Base

The `docs/` directory is the system of record for repository knowledge. Keep
`AGENTS.md` as a small map that points here instead of duplicating detailed
rules.

## Sections

- `repository/`: project structure, development workflow, Nix style, validation,
  and change process.
- `secure/`: secret handling and secure-store procedures.

## Maintenance

- Prefer small, focused docs with clear ownership over large manuals.
- Update docs in the same change that makes the documented behavior true.
- Link related docs instead of copying the same rule into multiple places.
- Remove or rewrite stale guidance when it stops matching the repository.
