{
  config,
  namespace,
  lib,
  ...
}:
{
  options.${namespace}.apps.obsidian = {
    enable = lib.mkEnableOption "Enable obsidian";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };
  config =
    let
      opts = config.${namespace}.apps.obsidian;
    in
    lib.mkIf opts.enable {
      programs.obsidian = {
        enable = true;
        cli.enable = true;
        defaultSettings = {
          communityPlugins = [ ];
        };
      };
      ${namespace} = {
        infra.desktop-manager = {
          core.setFavoriteApps = lib.mkIf opts.markAsFavorite [ "obsidian.desktop" ];
        };
      };
    };
}
