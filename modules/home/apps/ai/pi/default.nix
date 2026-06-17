{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai.pi = {
    enable = lib.mkEnableOption "Enable pi";
  };

  config =
    let
      opts = config.${namespace}.apps.ai.pi;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ llm-agents.pi ];
    };
}
