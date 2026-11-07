# Family media on mht-home-pc

This host uses the facade's native Jellyfin and Immich module and the existing
Caddy local-domain configuration. It adds `jellyfin.home.arpa` and
`immich.home.arpa`; it does not format a disk, change NTFS ownership masks, open
firewall ports, configure remote DNS, or add Tailscale Serve/Funnel routes.

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

Review the final host configuration against the running system before switching.
Other staged edits and dependency updates are separate from these routes; a clean
checkout can still contain older dependency versions than the running host.
Do not blindly switch an old worktree or overwrite unrelated user changes.

On first deployment, use the media-only configuration from the original media
PRs to create both local administrator accounts **before** activating these Caddy
routes. An unclaimed setup wizard must not be exposed to other LAN/tailnet users.
Activating the routes changes network access on Caddy's existing listener and
requires an explicit approval even though no new firewall ports are added.

Build without activation:

```sh
nixos-rebuild build --flake .#mht-home-pc
```

Building does not activate services. A later explicit `nixos-rebuild switch`
changes the running host and mounts. No switch is performed by the PR workflow.

## First use

For initial administrator setup, use the backend URLs **on the server itself**:

- Jellyfin: `http://127.0.0.1:8096`
- Immich: `http://127.0.0.1:2283`

After approved Caddy activation, the normal URLs are:

- Jellyfin: **https://jellyfin.home.arpa/**
- Immich: **https://immich.home.arpa/**

Both applications stay at `/`, on separate hostnames. Immich is not placed under
an `/immich` subpath. Caddy handles WebSockets and streaming without a separate
proxy layer. Keep Immich's normal System Settings UI available; after initial
setup, set its External Domain to `https://immich.home.arpa` there if a canonical
URL is needed for generated links. This change does not introduce an
`IMMICH_CONFIG_FILE` or take over existing application settings.
In Jellyfin's Networking settings, keep Base URL empty and add `127.0.0.1` to
Known Proxies if client addresses should be taken from Caddy's forwarded headers.
The Caddy upstream is explicitly port **8096**. If a previous Jellyfin install
uses another HTTP port, either restore 8096 in Jellyfin or update its upstream
in `family-media.nix` before activation; changing only the health-check command
would leave the proxy returning 502.

Create an administrator in each application first, then separate family users.
There are no committed passwords, shared initial accounts, or API keys.

In Jellyfin add libraries using `/srv/family-media/Pictures` and
`/srv/family-media/Videos`. Keep sidecar metadata writes disabled.

In Immich Administration create an External Library, select an owner, add the
same import paths and scan. Share selected albums/libraries with family accounts
in the application. New uploads/mobile backup use `/var/lib/immich`, independently
of those read-only imports. Immich libraries are not created by the Nix mounts.

## DNS, TLS and phone access

The generated `/etc/hosts` entries point both names to `127.0.0.1` **on the
server only**. They are not DNS records for phones, TVs or other computers.
Caddy already has an HTTP/HTTPS listener; this change adds two virtual hosts to
it while leaving app backends on loopback. The media sites reject connections
outside loopback, the current LAN (`192.168.0.0/24`), the host hotspot
(`10.42.0.0/24`) and Tailscale address ranges. This is a network restriction,
not a replacement for application accounts or Tailscale grants.

Choose a client-reachable DNS view for **both** names:

| Client connection | A record target verified on 2026-11-07 |
| --- | --- |
| Same home LAN | `192.168.0.113` |
| This host's Wi-Fi hotspot | `10.42.0.1` |
| Authorized Tailscale client | `100.92.95.37` |

Recheck these addresses before configuring DNS. Reserve the LAN DHCP address if
using it. Do not publish every address in one answer: each client needs a target
it can actually reach. If the LAN subnet changes, update the media-site
`remote_ip` allowlist too.

For LAN/hotspot clients, add records in the private DNS resolver those clients
actually use. The existing hotspot DNS listener does not establish these records
automatically. For Tailscale clients, use a reachable private DNS resolver and a
`home.arpa` split-DNS rule, with records returning `100.92.95.37`. MagicDNS's
`mht-home-pc.tail3cc3ec.ts.net` entry does **not** create the two `home.arpa` names.
No new DNS listener or split-DNS policy is installed by this change.

Each client must trust the existing Caddy internal root certificate. The public
certificate in `assets/caddy-root.crt` was verified against the running Caddy
site on 2026-11-07. Reverify it if the CA has been rotated. Installing a trusted
root changes client security settings and needs approval; never disable TLS
validation to hide a certificate error, and never copy Caddy's private CA key.

Before claiming phone access works:

1. Approve and activate the reviewed routes after local administrator setup.
2. Approve/configure the required private DNS records and client CA trust.
3. Verify the relevant network permits this client to reach Caddy on TCP 443.
   Review firewall and Tailscale grants before changing them; no port opening
   or grant expansion is included here. HTTP/3 on UDP 443 is optional.
4. On an authorized phone, resolve both names to the intended address, open the
   exact HTTPS URLs without a TLS warning, log in, then test one disposable
   upload and video playback. Also test the native Immich phone app and mobile
   backup: browser certificate trust alone does not establish native-app trust.

Do not configure router port-forwarding or Tailscale Funnel. Tailscale Serve is
not needed for this Caddy-based design and could conflict with existing routing.
These instructions are not evidence that remote DNS, CA trust or phone access
has already been configured.

## Verify after activation

```sh
systemctl status jellyfin immich-server immich-machine-learning postgresql
findmnt /srv/family-media/Pictures
findmnt /srv/family-media/Videos
ss -lntup | grep -E ':(8096|2283|3003|7359)\b'
curl --fail http://127.0.0.1:8096/health
curl --fail http://127.0.0.1:2283/api/server/ping
curl --fail --cacert assets/caddy-root.crt \
  --resolve jellyfin.home.arpa:443:127.0.0.1 https://jellyfin.home.arpa/health
curl --fail --cacert assets/caddy-root.crt \
  --resolve immich.home.arpa:443:127.0.0.1 https://immich.home.arpa/api/server/ping
```

Expect read-only bind mounts, application HTTP listeners only on loopback, and
no Jellyfin UDP discovery socket on 7359. Caddy serves HTTPS on its existing
listener. The `--resolve` checks test local routing/TLS, not remote-client DNS. Jellyfin preserves a previously customized HTTP
port; adjust checks in that case. Verify PostgreSQL/Redis are not listening on
external interfaces. Upload one disposable photo, scan a small existing library,
play a video, restart services and verify the uploaded photo survives. Check the
service mount namespaces cannot modify originals. Do not use real family data
as a write/delete test.

Before relying on this as the only family archive, back up the original NTFS
content, all of `/var/lib/immich`, an Immich database dump, and
`/var/lib/jellyfin` to another device/location. Test a restore. Live PostgreSQL
file copies alone are not a consistent database backup.
