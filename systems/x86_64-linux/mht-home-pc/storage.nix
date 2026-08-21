{
  pkgs,
  ...
}:
{
  environment = {
    etc.crypttab.text = ''
      secure UUID=e211ebab-1197-40df-8f2d-c80fd12fe942 none luks,nofail
    '';
    systemPackages = with pkgs; [ coreutils ];
  };

  systemd.services.main-data-user-dirs = {
    description = "Create user directories on main-data";
    requires = [ "mnt-main\\x2ddata.mount" ];
    after = [ "mnt-main\\x2ddata.mount" ];
    before = [
      "home-cirius-Documents.mount"
      "home-cirius-Music.mount"
      "home-cirius-Pictures.mount"
      "home-cirius-Videos.mount"
    ];
    path = [ pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      set -euo pipefail

      for dir in Documents Music Pictures Videos; do
        install -d -m 0755 -o cirius -g users "/home/cirius/$dir"
        install -d -m 0755 -o cirius -g users "/mnt/main-data/$dir"
      done
    '';
  };

  systemd.tmpfiles.rules = [
    "d /home/cirius/Workspaces 0700 cirius users - -"
  ];

  fileSystems = {
    "/home/cirius/Workspaces" = {
      device = "/dev/mapper/secure";
      fsType = "btrfs";
      options = [
        "subvol=@cirius-workspaces"
        "compress=zstd"
        "noatime"
        "nofail"
        "x-systemd.requires=systemd-cryptsetup@secure.service"
        "x-systemd.after=systemd-cryptsetup@secure.service"
      ];
    };

    "/mnt/main-data" = {
      device = "/dev/disk/by-uuid/16D3A0ED3E0C06F5";
      fsType = "ntfs3";
      options = [
        "rw"
        "nofail"
        "noatime"

        "uid=1000"
        "gid=100"
        "umask=022"
        "dmask=0022"
        "fmask=0022"

        "windows_names"
      ];
    };

    "/home/cirius/Documents" = {
      device = "/mnt/main-data/Documents";
      fsType = "none";
      options = [
        "bind"
        "rw"
        "nofail"
        "x-systemd.requires-mounts-for=/mnt/main-data"
        "x-systemd.requires=main-data-user-dirs.service"
        "x-systemd.after=main-data-user-dirs.service"
      ];
    };

    "/home/cirius/Music" = {
      device = "/mnt/main-data/Music";
      fsType = "none";
      options = [
        "bind"
        "rw"
        "nofail"
        "x-systemd.requires-mounts-for=/mnt/main-data"
        "x-systemd.requires=main-data-user-dirs.service"
        "x-systemd.after=main-data-user-dirs.service"
      ];
    };

    "/home/cirius/Pictures" = {
      device = "/mnt/main-data/Pictures";
      fsType = "none";
      options = [
        "bind"
        "rw"
        "nofail"
        "x-systemd.requires-mounts-for=/mnt/main-data"
        "x-systemd.requires=main-data-user-dirs.service"
        "x-systemd.after=main-data-user-dirs.service"
      ];
    };

    "/home/cirius/Videos" = {
      device = "/mnt/main-data/Videos";
      fsType = "none";
      options = [
        "bind"
        "rw"
        "nofail"
        "x-systemd.requires-mounts-for=/mnt/main-data"
        "x-systemd.requires=main-data-user-dirs.service"
        "x-systemd.after=main-data-user-dirs.service"
      ];
    };
  };
}
