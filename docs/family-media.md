# Family media on mht-home-pc

This host uses the facade's native Jellyfin and Immich module. It does not create
an application, format a disk, change the NTFS ownership masks, or add firewall,
Caddy or Tailscale routes.

## Storage

| Purpose | Location | Access |
| --- | --- | --- |
| Existing pictures | `/mnt/main-data/Pictures` → `/srv/family-media/Pictures` | Services read-only |
| Existing videos | `/mnt/main-data/Videos` → `/srv/family-media/Videos` | Services read-only |
| New Immich uploads, thumbnails, encoded videos, database backups | `/var/lib/immich` | Private service-owned Btrfs SSD |
| PostgreSQL data | `/var/lib/postgresql` | Btrfs SSD, never NTFS |
| Jellyfin configuration/catalog | `/var/lib/jellyfin` | Private service-owned Btrfs SSD |

The `/home/cirius/Pictures` and `/home/cirius/Videos` writable user mounts remain
unchanged. Services cannot use the raw `/mnt` or home paths to bypass the
read-only views. Both library mounts require main-data and its directory setup
service. Service startup depends on the library mounts, so a missing disk fails
closed rather than scanning empty fallback directories.

NTFS currently gives every file uid 1000/gid 100 and 022 masks. It cannot provide
private per-service upload ownership. Uploads stay on the encrypted SSD rather
than making the whole NTFS disk writable or running Immich as the desktop user.
Monitor SSD capacity, especially when enabling automatic phone backup. Copying
an uploaded file into an external NTFS library is not an Immich storage migration.

## Review and activation

The facade dependency is pinned to the commit supplying family-media; merge its
PR before this host PR. The original checkout's other staged edits are not part
of this change. Review and reconcile those separately before any system switch.

Build without activation:

```sh
nixos-rebuild build --flake .#mht-home-pc
```

Building does not activate services. A later explicit `nixos-rebuild switch`
changes the running host and mounts. No switch is performed by the PR workflow.

## First use

After an approved switch, open these **on the server itself**:

- Jellyfin: `http://127.0.0.1:8096`
- Immich: `http://127.0.0.1:2283`

Create an administrator in each application first, then separate family users.
There are no committed passwords, shared initial accounts, or API keys.

In Jellyfin add libraries using `/srv/family-media/Pictures` and
`/srv/family-media/Videos`. Keep sidecar metadata writes disabled.

In Immich Administration create an External Library, select an owner, add the
same import paths and scan. Share selected albums/libraries with family accounts
in the application. New uploads/mobile backup use `/var/lib/immich`, independently
of those read-only imports. Immich libraries are not created by the Nix mounts.

These URLs are deliberately local-only. Phone/TV/family access still needs an
explicitly approved Tailscale-only HTTPS route and client DNS/certificate setup;
no router port-forwarding or public exposure is configured here.

## Verify after activation

```sh
systemctl status jellyfin immich-server immich-machine-learning postgresql
findmnt /srv/family-media/Pictures
findmnt /srv/family-media/Videos
ss -lntup | grep -E ':(8096|2283|3003|7359)\b'
curl --fail http://127.0.0.1:8096/health
curl --fail http://127.0.0.1:2283/api/server/ping
```

Expect read-only bind mounts, HTTP listeners only on loopback, and no Jellyfin
UDP discovery socket on 7359. Jellyfin preserves a previously customized HTTP
port; adjust checks in that case. Verify PostgreSQL/Redis are not listening on
external interfaces. Upload one disposable photo, scan a small existing library,
play a video, restart services and verify the uploaded photo survives. Check the
service mount namespaces cannot modify originals. Do not use real family data
as a write/delete test.

Before relying on this as the only family archive, back up the original NTFS
content, all of `/var/lib/immich`, an Immich database dump, and
`/var/lib/jellyfin` to another device/location. Test a restore. Live PostgreSQL
file copies alone are not a consistent database backup.
