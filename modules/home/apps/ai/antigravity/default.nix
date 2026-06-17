{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai.antigravity = {
    enable = lib.mkEnableOption "Enable antigravity";
  };

  config =
    let
      opts = config.${namespace}.apps.ai.antigravity;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ antigravity ];
    };
}
