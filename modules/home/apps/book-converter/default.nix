{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.book-converter = {
    enable = lib.mkEnableOption "Enable book-converter";
  };

  config =
    let
      opts = config.${namespace}.apps.book-converter;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [
        calibre-no-speech
      ];
    };
}
