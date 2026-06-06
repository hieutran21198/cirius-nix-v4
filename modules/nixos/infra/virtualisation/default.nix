{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.infra.virtualisation = {
    enable = lib.mkEnableOption "Enable virtualisation";
  };
  config =
    let
      inherit (config.${namespace}) infra;
      opts = infra.virtualisation;
    in
    lib.mkIf opts.enable {
      hardware.nvidia-container-toolkit = { inherit (config.${namespace}.infra.nvidia) enable; };
      virtualisation.podman = {
        enable = true;
      };

      ${namespace}.infra = {
        persistenceDirs = [
          "/var/lib/docker"
          "/var/lib/containers"
          "/var/lib/libvirt"
        ];
      };
    };
}
