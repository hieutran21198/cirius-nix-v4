{
  config,
  namespace,
  lib,
  ...
}:
{
  options = {
    ${namespace}.infra = {
      hostName = lib.mkOption {
        type = with lib.types; str;
        default = "nixos";
        description = "Machine hostname";
      };
      networking = {
        enable = lib.mkEnableOption "Enable networking feature";
      };
    };
  };
  config =
    let
      opts = config.${namespace}.infra;
    in
    {
      networking = {
        inherit (opts) hostName;
        networkmanager = {
          inherit (opts.networking) enable;
        };
      };
    };
}
