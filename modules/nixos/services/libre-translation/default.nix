{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.services.libre-translation = {
    enable = lib.mkEnableOption "Enable libre-translation";
    port = lib.${namespace}.makeIntOption {
      default = 5000;
      description = "Port for libre-translation service";
    };
    group = lib.${namespace}.makeStrOption {
      default = "libre-translation";
      description = "Group for libre-translation service";
    };
    user = lib.${namespace}.makeStrOption {
      default = "libre-translation";
      description = "User for libre-translation service";
    };
  };

  config =
    let
      opts = config.${namespace}.services.libre-translation;
    in
    lib.mkIf opts.enable {
      services.libretranslate = {
        enable = true;
        inherit (opts) port group user;
        disableWebUI = false;
        enableApiKeys = true;
        updateModels = true;
        extraArgs = {
          load-only = "en,vi";
        };
      };
    };
}
