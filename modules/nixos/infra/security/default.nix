{
  namespace,
  lib,
  config,
  pkgs,
  ...
}:
{
  options.${namespace}.infra.security = {
    sopsFormat = lib.${namespace}.makeStrOption {
      default = "yaml";
    };
    sopsKey = lib.${namespace}.makeStrOption {
      default = "/run/secure-store/host/sops-age/key.txt";
    };
  };

  config =
    let
      inherit (config.${namespace}.infra) security;
    in
    {
      environment.systemPackages = with pkgs; [
        sops
        age
      ];
      sops = {
        defaultSopsFormat = security.sopsFormat;
        age.keyFile = security.sopsKey;
      };
    };
}
