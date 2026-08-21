{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.services.aria2 = {
    enable = lib.mkEnableOption "Enable aria2";
    virtualHost = lib.mkOption {
      type = lib.types.str;
      default = "aria2.${config.networking.hostName}";
      description = "The hostname for the aria2 service.";
    };
    iam = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "aria2";
        description = "The user for the aria2 service.";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "aria2";
        description = "The group for the aria2 service.";
      };
    };
    rpcListenPort = lib.mkOption {
      type = lib.types.int;
      default = 6800;
      description = "The RPC listen port for the aria2 service.";
    };
    rpcSecretFile = lib.mkOption {
      type = lib.types.path;
      description = "The path to the secret file for the aria2 service.";
    };
  };

  config =
    let
      opts = config.${namespace}.services.aria2;
    in
    lib.mkIf opts.enable {
      environment.systemPackages = with pkgs; [
        ariang
      ];
      services = {
        aria2 = {
          enable = true;
          rpcSecretFile = opts.rpcSecretFile;
          settings = {
            inherit (opts) rpcListenPort;
          };
        };
      };

      systemd.services.aria2.serviceConfig = {
        User = opts.iam.user;
        Group = opts.iam.group;
      };

      # setup local host name.
      ${namespace}.infra.networking = {
        hosts = {
          "127.0.0.1" = [ opts.virtualHost ];
        };
        virtualHosts = {
          ${opts.virtualHost} = {
            extraConfig = ''
              tls internal
              reverse_proxy /jsonrpc 127.0.0.1:${toString opts.rpcListenPort} {
                flush_interval -1
                transport http {
                  read_timeout 86400s
                  write_timeout 86400s
                }
              }
              file_server {
                root ${pkgs.ariang}/share/ariang
              }
            '';
          };
        };
      };
    };
}
