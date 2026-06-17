{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai.reasonix = {
    enable = lib.mkEnableOption "Enable reasonix";
  };

  config =
    let
      opts = config.${namespace}.apps.ai.reasonix;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ llm-agents.reasonix ];
    };
}
