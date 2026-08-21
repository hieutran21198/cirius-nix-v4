{
  config,
  namespace,
  lib,
  host,
  pkgs,
  inputs,
  ...
}:
{
  options.${namespace}.services.open-design =
    let
      subDomain = "design";
    in
    {
      enable = lib.mkEnableOption "Enable open-design";
      dataDir = lib.${namespace}.makeStrOption { default = "/var/lib/open-design"; };
      virtualHost = lib.${namespace}.makeStrOption {
        default = subDomain + ".${host}";
        description = "The virtual host for the open-design service.";
      };
      port = lib.${namespace}.makeIntOption {
        default = 10000;
        description = "The port for the open-design service.";
      };
      frontEndPort = lib.${namespace}.makeIntOption {
        default = 10001;
        description = "The port for the open-design front-end service.";
      };
      iam = {
        user = lib.${namespace}.makeStrOption {
          default = "open-design";
          description = "The user for the open-design service.";
        };
        group = lib.${namespace}.makeStrOption {
          default = "open-design";
          description = "The group for the open-design service.";
        };
      };
      allowedOrigins = lib.${namespace}.makeListOption {
        default = [
          "https://${subDomain}.${host}"
          "http://${subDomain}.${host}"
        ];
      };
      envFile = lib.${namespace}.makePathOption {
        nullable = true;
        default = null;
      };
    };

  config =
    let
      opts = config.${namespace}.services.open-design;
      allowedOrigins = opts.allowedOrigins ++ [
        "https://localhost:${toString opts.port}"
        "http://localhost:${toString opts.port}"
      ];
      webPackage = inputs.open-design.packages.${pkgs.stdenv.hostPlatform.system}.web;
    in
    lib.mkIf opts.enable {
      services.open-design = {
        enable = true;
        autoStart = true;
        inherit (opts.iam) user group;
        openFirewall = true;
        webFrontend = {
          enable = true;
          package = webPackage;
          host = "127.0.0.1";
          port = opts.frontEndPort;
          inherit allowedOrigins;
        };
        environmentFile = opts.envFile;
        inherit (opts) dataDir port;
      };

      systemd.services.open-design = {
        # FIXME: upstream PATH cause errors in systemd service.
        # the workaround is turn off default path.
        enableDefaultPath = false;
      };

      ${namespace}.infra.networking = {
        hosts = {
          "127.0.0.1" = [ opts.virtualHost ];
        };
        virtualHosts = {
          ${opts.virtualHost}.extraConfig = ''
            tls internal
              handle /api/* {
                reverse_proxy 127.0.0.1:${toString opts.port} {
                  flush_interval -1
                  transport http {
                    read_timeout 86400s
                    write_timeout 86400s
                  }
                }
              }
              handle /artifacts/* {
                reverse_proxy 127.0.0.1:${toString opts.port}
              }
              handle /frames/* {
                reverse_proxy 127.0.0.1:${toString opts.port}
              }
              handle {
                root * ${webPackage}
                try_files {path} {path}/ /index.html
                file_server
                encode gzip
              }
          '';
        };
      };
    };
}
