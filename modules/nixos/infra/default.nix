{
  config,
  namespace,
  lib,
  ...
}:
{
  options = {
    ${namespace}.infra = {
      hostName = lib.${namespace}.makeStrOption {
        default = "nixos";
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
