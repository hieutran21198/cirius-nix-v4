{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.services.autossh = {
    enable = lib.mkEnableOption "Enable autossh";

    additionalConfig = lib.${namespace}.makeListOption {
      ofType = with lib.types; either str path;
      default = [ ];
      description = "Extra ssh config files to pull in via Include.";
    };
    # ssh -N profile_name
    portForwardingProfiles = lib.mkOption {
      type =
        with lib.types;
        attrsOf (submodule {
          options = {
            enable = lib.mkEnableOption "this autossh profile";

            monitorPort = lib.mkOption {
              type = lib.types.port;
              default = 0;
              description = ''
                autossh monitoring port.
                0 disables the autossh monitoring connection.
              '';
            };

            passwordFile = lib.mkOption {
              type = with lib.types; nullOr path;
              default = null;
              description = "Optional file containing the SSH password.";
            };

            extraArgs = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
              description = "Additional arguments passed to autossh.";
            };
          };
        });
      default = { };
      description = ''
        SSH Host aliases from ~/.ssh/config that should be kept alive
        by autossh.
      '';
    };
  };

  config =
    let
      opts = config.${namespace}.services.autossh;
    in
    lib.mkMerge [
      # shared configuration
      (lib.mkIf (opts.enable) {
        services.ssh-agent = {
          enable = true;
          defaultMaximumIdentityLifetime = 28800;
        };
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings."*" = {
            AddKeysToAgent = "yes";
          };
          extraConfig = lib.concatMapStringsSep "\n" (x: "Include ${x}") opts.additionalConfig;
        };
        home.packages = with pkgs; [ autossh ];
      })

      # linux configuration
      (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && opts.enable) {
        systemd.user.services = lib.mapAttrs' (
          profileName: profile:
          lib.nameValuePair "autossh-${profileName}" {
            Unit = {
              Description = "AutoSSH tunnel for ${profileName}";

              Wants = [
                "network-online.target"
                "sops-nix.service"
              ];

              After = [
                "network-online.target"
                "sops-nix.service"
              ];
            };

            Service = {
              Environment = [
                "AUTOSSH_GATETIME=0"
              ];
              ExecStart = lib.escapeShellArgs (
                if profile.passwordFile == null then
                  [
                    "${pkgs.autossh}/bin/autossh"
                    "-M"
                    "0"
                    "-N"
                    profileName
                  ]
                else
                  [
                    "${pkgs.sshpass}/bin/sshpass"
                    "-f"
                    (toString profile.passwordFile)
                    "${pkgs.autossh}/bin/autossh"
                    "-M"
                    "0"
                    "-N"
                    profileName
                  ]
              );
              Restart = "always";
              RestartSec = 5;
            };
            Install = {
              WantedBy = [ "default.target" ];
            };

          }
        ) (lib.filterAttrs (_: profile: profile.enable) opts.portForwardingProfiles);
      })

      # darwin configuration
      (lib.mkIf (pkgs.stdenv.isDarwin && opts.enable) {
      })
    ];
}
