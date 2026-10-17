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
  };

  config =
    let
      inherit (config.${namespace}) infra;
      opts = infra.virtualisation;
    in
    lib.mkIf opts.enable {
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
