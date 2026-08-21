{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:
{
  options.${namespace}.infra.nvidia = {
    enable = lib.mkEnableOption "Enable nvidia support";
  };
  config =
    let
      inherit (config.${namespace}) infra;
    in
    lib.mkIf infra.nvidia.enable {
      environment.systemPackages = with pkgs; [
        nvtopPackages.nvidia
      ];
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware = {
        graphics.enable = lib.mkForce true;
        nvidia = {
          open = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          nvidiaPersistenced = true;
          nvidiaSettings = true;
          modesetting.enable = true;
          powerManagement.enable = true;
        };
      };
    };
}
