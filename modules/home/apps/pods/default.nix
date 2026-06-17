{
  config,
  osConfig ? { },
  namespace,
  pkgs,
  lib,
  ...
}:
let
  osVirtualisationEnabled = osConfig.${namespace}.infra.virtualisation.enable or false;
in
{
  options.${namespace}.apps.pods = {
    enable = lib.mkEnableOption "Enable pods";
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
  };

  config =
    let
      opts = config.${namespace}.apps.pods;
    in
    lib.mkIf opts.enable {
      assertions = [
        (lib.${namespace}.failWhen {
          condition = osVirtualisationEnabled == false;
          message = "Pods require os level virtualisation enabled";
        })
      ];
      home.packages = with pkgs; [ pods ];
      ${namespace} = {
        infra.desktop-manager = {
          gnome.setFavoriteApps = [
            "com.github.marhkb.Pods.desktop"
          ];
        };
      };
    };
}
