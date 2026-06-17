{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai.jules = {
    enable = lib.mkEnableOption "Enable jules";
  };

  config =
    let
      opts = config.${namespace}.apps.ai.jules;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ llm-agents.jules ];
    };
}
