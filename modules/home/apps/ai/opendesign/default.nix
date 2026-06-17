{
  config,
  namespace,
  lib,
  host,
  ...
}:
{
  options.${namespace}.apps.ai.opendesign = {
    enable = lib.mkEnableOption "Enable opendesign";
    dataDir = lib.${namespace}.makeStrOption { default = "${config.xdg.dataHome}/open-design"; };
    allowedOrigins = lib.${namespace}.makeListOption {
      default = [
        "https://opendesign.${host}"
      ];
    };
    envFile = lib.${namespace}.makePathOption {
      nullable = true;
      default = null;
    };
  };

  config =
    let
      opts = config.${namespace}.apps.ai.opendesign;
    in
    lib.mkIf opts.enable {
      services.open-design = {
        enable = true;
        autoStart = true;
        webFrontend = {
          enable = false;
          inherit (opts) allowedOrigins;
        };
        environmentFile = opts.envFile;
        inherit (opts) dataDir;
        port = 10000;
      };
    };
}
