{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai-assistant.hermes = {
    enable = lib.mkEnableOption "Enable hermes";
  };

  config =
    let
      opts = config.${namespace}.apps.ai-assistant.hermes;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ llm-agents.hermes-desktop ];
    };
}
