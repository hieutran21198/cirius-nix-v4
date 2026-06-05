{
  lib,
  config,
  namespace,
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
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware = {
        graphics.enable = lib.mkForce true;
        nvidia = {
          open = true;
          nvidiaPersistenced = true;
          nvidiaSettings = true;
          modesetting.enable = true;
          powerManagement.enable = true;
        };
      };
    };
}
