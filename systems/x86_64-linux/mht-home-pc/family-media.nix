{ config, namespace, ... }:
let
  libraryRoot = "/srv/family-media";
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
