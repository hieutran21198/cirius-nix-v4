{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai-utilities.codegraph = {
    enable = lib.mkEnableOption "Enable codegraph";
  };

  config =
    let
      opts = config.${namespace}.apps.ai-utilities.codegraph;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ llm-agents.codegraph ];
    };
}
