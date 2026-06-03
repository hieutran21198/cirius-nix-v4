{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.proton-pass = {
    enable = lib.mkEnableOption "Enable proton-pass";
    integrateLibrewolf = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Integrate librewolf browser";
    };
  };
  config =
    let
      inherit (config.${namespace}) apps;
    in
    lib.mkIf apps.proton-pass.enable {
      home.packages = with pkgs; [ proton-pass ];

      ${namespace} =
        let
          firefoxExt = pkgs.firefox-extensions.proton-pass;
        in
        {
          apps = {
            librewolf.extensions.${firefoxExt.addonId} = lib.mkIf apps.proton-pass.integrateLibrewolf {
              package = firefoxExt;
            };
          };
        };
    };
}
