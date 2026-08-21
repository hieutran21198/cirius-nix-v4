{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.services.music-server =
    let
      inherit (lib.${namespace})
        makeStrOption
        makeIntOption
        makePathOption
        ;
    in
    {
      enable = lib.mkEnableOption "Enable music server";
      port = makeIntOption {
        default = 4533;
        description = "The port on which the music server will be available.";
      };
      envFile = makePathOption {
        description = "The path to the environment file for the music server.";
      };
      virtualHost = makeStrOption {
        default = "music.${config.networking.hostName}";
      };
      iam = {
        user = makeStrOption {
          default = "music-server";
          description = "The user for the music server.";
        };
        group = makeStrOption {
          default = "music-server";
          description = "The group for the music server.";
        };
      };

      musicDir = makeStrOption {
        description = "The path to the music directory.";
      };
    };
  config =
    let
      opts = config.${namespace}.services.music-server;
    in
    lib.mkMerge [
      # IAM
      (lib.mkIf opts.enable {
        ${namespace}.infra = {
          iam = {
            groups = {
              "${opts.iam.group}" = { };
            };
            users = {
              "${opts.iam.user}" = {
                userSettings = {
                  isSystemUser = true;
                  group = opts.iam.group;
                };
              };
            };
          };
        };
      })

      # Services
      (lib.mkIf opts.enable {
        services.navidrome = {
          enable = true;
          environmentFile = opts.envFile;
          openFirewall = true;
          inherit (opts.iam) user group;
          settings = {
            Port = opts.port;
            Address = "0.0.0.0";
            Plugins = { };
            MusicFolder = opts.musicDir;
            LyricsPriority = ".lrc,embedded";
          };
        };
      })

      # Networking
      (lib.mkIf opts.enable {
        ${namespace}.infra = {
          networking = {
            hosts = {
              "127.0.0.1" = [ opts.virtualHost ];
            };
            virtualHosts = {
              "${opts.virtualHost}".extraConfig = ''
                tls internal
                reverse_proxy 0.0.0.0:${toString opts.port}
              '';
            };
          };
        };
      })
    ];
}
