{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai-utilities.qmd = {
    enable = lib.mkEnableOption "Enable qmd";
  };

  config =
    let
      opts = config.${namespace}.apps.ai-utilities.qmd;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ llm-agents.qmd ];
    };
}
