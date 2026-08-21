{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.whisper = {
    enable = lib.mkEnableOption "Enable whisper";
  };

  config =
    let
      opts = config.${namespace}.apps.whisper;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [
        (whisper-cpp.override {
          vulkanSupport = true;
        })
      ];
    };
}
