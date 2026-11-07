{ config, namespace, ... }:
let
  libraryRoot = "/srv/family-media";
  # Match the existing private home networks. remote_ip checks the connection,
  # not a client-supplied X-Forwarded-For header. Tailnet grants still control
  # which enrolled peers may reach this host.
  privateSiteConfig = ''
    tls internal
    @outsidePrivate not remote_ip 127.0.0.1 ::1 192.168.0.0/24 10.42.0.0/24 100.64.0.0/10 fd7a:115c:a1e0::/48
    respond @outsidePrivate "Private access only" 403
  '';
  libraries = map (name: "${libraryRoot}/${name}") [
    "Pictures"
    "Videos"
  ];
in
{
  cnix-virt.family-media = {
    enable = true;
    jellyfin.libraryPaths = libraries;
    immich.libraryPaths = libraries;
  };

  # Follow the host's existing Caddy/local-domain pattern. This hosts entry
  # resolves on the server only; other clients need their own private DNS and
  # trust in the existing Caddy CA. No DNS listeners or firewall ports are added.
  cnix-net.settings.hosts."127.0.0.1" = [
    {
      localDomain = "jellyfin.home.arpa";
      upstream = "http://127.0.0.1:8096";
      extraConfig = privateSiteConfig;
    }
    {
      localDomain = "immich.home.arpa";
      upstream = "http://127.0.0.1:${toString config.services.immich.port}";
      extraConfig = privateSiteConfig;
    }
  ];

  # NTFS keeps its existing owner/masks. The services only see read-only views;
  # user-facing /home/cirius/{Pictures,Videos} mounts remain unchanged.
  fileSystems = builtins.listToAttrs (
    map
      (name: {
        name = "${libraryRoot}/${name}";
        value = {
          device = "/mnt/main-data/${name}";
          fsType = "none";
          options = [
            "bind"
            "ro"
            "nodev"
            "nosuid"
            "noexec"
            "nofail"
            "x-systemd.requires-mounts-for=/mnt/main-data"
            "x-systemd.requires=main-data-user-dirs.service"
            "x-systemd.after=main-data-user-dirs.service"
          ];
        };
      })
      [
        "Pictures"
        "Videos"
      ]
  );

  # Immich uploads, thumbnails, database backups, and native PostgreSQL data
  # belong on the encrypted Btrfs SSD, never on NTFS. This also preserves them
  # if the host's optional impermanence mode is enabled later.
  ${namespace}.infra.persistenceDirs = [
    "/var/lib/immich"
    "/var/lib/jellyfin"
    "/var/lib/postgresql"
    "/var/lib/redis-immich"
  ];

  assertions = [
    {
      assertion = config.fileSystems."/mnt/main-data".fsType == "ntfs3";
      message = "Review family media mounts if main-data no longer uses NTFS.";
    }
    {
      assertion = config.services.immich.mediaLocation == "/var/lib/immich";
      message = "Keep private Immich uploads on the SSD; NTFS's shared uid/masks are unsuitable for private service-owned uploads.";
    }
  ];
}
