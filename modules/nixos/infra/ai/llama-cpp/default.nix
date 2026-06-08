{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.infra.ai.llama-cpp = {
    enable = lib.mkEnableOption "Enable llama.cpp";
    package = lib.${namespace}.makePrimitiveOption lib.types.package {
      default = pkgs.llama-cpp.override {
        cudaSupport = config.${namespace}.infra.nvidia.enable;
      };
    };
  };

  config =
    let
      inherit (config.${namespace}.infra) ai;
    in
    lib.mkIf ai.llama-cpp.enable {
      environment.systemPackages = [
        ai.llama-cpp.package
      ];
    };
}
