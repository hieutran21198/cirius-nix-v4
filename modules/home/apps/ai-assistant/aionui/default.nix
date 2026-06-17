{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai-assistant.aionui = {
    enable = lib.mkEnableOption "Enable aionui";
  };

  config =
    let
      opts = config.${namespace}.apps.ai-assistant.aionui;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ llm-agents.aionui ];
    };
}
