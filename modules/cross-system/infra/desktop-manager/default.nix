{
  lib,
  namespace,
  pkgs,
  ...
}:
{
  options = {
    ${namespace}.infra.desktop-manager = {
      enable =
        if pkgs.stdenv.isDarwin then
          (lib.mkOption {
            type = with lib.types; boolean;
            readOnly = true;
            default = true;
            description = "Auto-enabled desktop manager on Darwin";
          })
        else
          (lib.mkEnableOption "Enable desktop manager");
    };
  };
}
