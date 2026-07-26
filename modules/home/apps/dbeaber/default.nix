{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.dbeaver = {
    enable = lib.mkEnableOption "Enable dbeaver";
  };

  config =
    let
      opts = config.${namespace}.apps.dbeaver;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ dbeaver-bin ];
    };
}
