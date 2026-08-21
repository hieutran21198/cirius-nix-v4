{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.gopeed = {
    enable = lib.mkEnableOption "Enable gopeed";
  };

  config =
    let
      opts = config.${namespace}.apps.gopeed;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ gopeed ];
    };
}
