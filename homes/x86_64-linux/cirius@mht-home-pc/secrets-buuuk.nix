{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.snowfallorg) user;
  sopsFile = ../../../secrets/cirius__mht-home-pc/buuuk.yaml;

  ssh = lib.getExe' pkgs.openssh "ssh";
  sshpass = lib.getExe pkgs.sshpass;

  # Options shared by every tunnel: detect dead peers and exit so systemd can
  # restart, and abort if a requested forward cannot be established.
  keepaliveArgs = [
    "-N"
    "-o"
    "ServerAliveInterval=30"
    "-o"
    "ServerAliveCountMax=3"
    "-o"
    "ExitOnForwardFailure=yes"
  ];

  firstLuxuryPasswordFile = config.sops.secrets."buuuk/first-luxury-bas/password".path;

  mkTunnelService = description: execStart: {
    Unit = {
      Description = description;
      After = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = execStart;
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
in
{
  systemd.user.services = {
    ssh-tunnel-buuuk-dev-bas = mkTunnelService "SSH tunnel to BuuukDevBas" (
      lib.escapeShellArgs (
        [ ssh ]
        ++ keepaliveArgs
        ++ [
          "-o"
          "BatchMode=yes"
          "BuuukDevBas"
        ]
      )
    );
    ssh-tunnel-first-luxury-bas = mkTunnelService "SSH tunnel to FirstLuxuryBas" (
      lib.escapeShellArgs (
        [
          sshpass
          "-f"
          firstLuxuryPasswordFile
          ssh
        ]
        ++ keepaliveArgs
        ++ [
          "-o"
          "PubkeyAuthentication=no"
          "-o"
          "PreferredAuthentications=password"
          "-o"
          "NumberOfPasswordPrompts=1"
          "FirstLuxuryBas"
        ]
      )
    );
  };

  ${namespace} = {
    infra.security = {
      secrets = {
        "buuuk/git/prv_key" = {
          inherit sopsFile;
          key = "ssh/git/prv_key";
          path = "${user.home.directory}/.ssh/buuuk_git";
          mode = "0400";
        };
        "buuuk/git/pub_key" = {
          inherit sopsFile;
          key = "ssh/git/pub_key";
          path = "${user.home.directory}/.ssh/buuuk_git.pub";
          mode = "0400";
        };
        "buuuk/bas/prv_key" = {
          inherit sopsFile;
          key = "ssh/bas/prv_key";
          path = "${user.home.directory}/.ssh/buuuk_bas";
          mode = "0400";
        };
        "buuuk/bas/pub_key" = {
          inherit sopsFile;
          key = "ssh/bas/pub_key";
          path = "${user.home.directory}/.ssh/buuuk_bas.pub";
          mode = "0400";
        };
        "buuuk/git/config" = {
          inherit sopsFile;
          key = "git/config";
          path = "${user.home.directory}/Workspaces/buuuk/.gitconfig";
          mode = "0400";
        };
        "buuuk/ssh/config" = {
          inherit sopsFile;
          key = "ssh/config";
          mode = "0400";
        };
        "buuuk/aws/config" = {
          inherit sopsFile;
          key = "aws/config";
          mode = "0400";
        };
        "buuuk/first-luxury-bas/password" = {
          inherit sopsFile;
          key = "ssh/first_luxury_bas/password";
          mode = "0400";
        };
      };
    };
    apps = {
      git = {
        includes = [
          {
            condition = "gitdir:${user.home.directory}/Workspaces/buuuk/";
            path = "${user.home.directory}/Workspaces/buuuk/.gitconfig";
          }
        ];
      };
    };
  };
}
