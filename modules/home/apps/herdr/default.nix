{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.herdr = {
    enable = lib.mkEnableOption "Enable herdr";
  };

  config =
    let
      opts = config.${namespace}.apps.herdr;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ llm-agents.herdr ];
    };
}
