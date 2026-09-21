{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.services.aria2 = {
    enable = lib.mkEnableOption "Enable aria2";
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
      home.services.aria2 = {
        process.argv = [
          ''
            secret="$(cat ${opts.rpcSecretFile})"

            exec ${pkgs.aria2}/bin/aria2c \
              --conf-path=${config.xdg.configHome}/aria2/aria2.conf \
              --rpc-secret="$secret"
          ''
        ];

        configData."aria2.conf".text = ''
          dir=${config.home.homeDirectory}/Downloads
          continue=true

          enable-rpc=true
          rpc-listen-all=false
          rpc-listen-port=${toString opts.rpcListenPort}
        '';

        systemd.service = {
          Restart = "on-failure";
          After = [
            "network-online.target"
            "sops-nix.service"
          ];

          Wants = [
            "network-online.target"
          ];

          Requires = [
            "sops-nix.service"
          ];
        };
      };
    };
}
