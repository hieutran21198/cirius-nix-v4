{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.dialect-translator = {
    enable = lib.mkEnableOption "Enable dialect-translator";
  };

  config =
    let
      opts = config.${namespace}.apps.dialect-translator;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ dialect ];
    };
}
