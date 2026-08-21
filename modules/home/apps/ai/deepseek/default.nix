{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai.deepseek = {
    enable = lib.mkEnableOption "Enable deepseek";
  };

  config =
    let
      opts = config.${namespace}.apps.ai.deepseek;
    in
    lib.mkIf opts.enable {
      services.deepseek-harness = {
        enable = true;
        host = "127.0.0.1";
        port = 3080;
        dshHome = config.xdg.dataHome + "/deepseek-harness";
        trustedHosts = [ "localhost" ];
        desktop.enable = true;
        # extraArgs = [ "--patch" "/path/to/overlay.yaml" ];
      };
    };
}
