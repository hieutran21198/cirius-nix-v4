{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.yt-dlp = {
    enable = lib.mkEnableOption "Enable yt-dlp";
  };

  config =
    let
      opts = config.${namespace}.apps.yt-dlp;
    in
    lib.mkIf opts.enable {
      ${namespace}.infra.shell.fish.shellAbbrs = {
        "yt-mp3" =
          ''yt-dlp -o "${config.snowfallorg.user.home.directory}/Music/%(artist)s/%(title)s.%(ext)s" -t mp3'';
      };
      home.packages = with pkgs; [ yt-dlp ];
    };
}
