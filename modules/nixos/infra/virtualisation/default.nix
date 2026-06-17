{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.infra.virtualisation = {
    enable = lib.mkEnableOption "Enable virtualisation";
    podman = {
      dockerCompat = lib.${namespace}.makeBoolOption {
        default = true;
      };
      dockerSocket = lib.${namespace}.makeBoolOption {
        default = false;
      };
      autoPrune = lib.${namespace}.makeBoolOption {
        default = true;
      };
      defaultNetworkDns = lib.${namespace}.makeBoolOption {
        default = true;
      };
    };
  };

  config =
    let
      inherit (config.${namespace}) infra;
      opts = infra.virtualisation;
    in
    lib.mkIf opts.enable {
      # this currently break.
      # hardware.nvidia-container-toolkit = { inherit (config.${namespace}.infra.nvidia) enable; };
      virtualisation = {
        containers.enable = true;

        oci-containers.backend = "podman";

        podman = {
          enable = true;
          inherit (opts.podman) dockerCompat;

          dockerSocket.enable = opts.podman.dockerSocket;

          autoPrune = {
            enable = opts.podman.autoPrune;
            dates = "weekly";
          };

          defaultNetwork.settings = lib.mkIf opts.podman.defaultNetworkDns {
            dns_enabled = true;
          };
        };
      };

      environment.systemPackages = lib.optionals config.${namespace}.infra.nvidia.enable [
        pkgs.nvidia-container-toolkit
      ];

      ${namespace}.infra = {
        persistenceDirs = [
          "/var/lib/docker"
          "/var/lib/containers"
          "/var/lib/libvirt"
        ];
      };
    };
}
