{
  namespace,
  lib,
  config,
  pkgs,
  host,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule
      [
        namespace
        "infra"
        "security"
        "secrets"
      ]
      [ "sops" "secrets" ]
    )
    (lib.mkAliasOptionModule
      [
        namespace
        "infra"
        "security"
        "templates"
      ]
      [ "sops" "templates" ]
    )
  ];
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
        useTmpfs = true;
        defaultSopsFile = ../../../../secrets/${host}/default.${security.sopsFormat};
        useSystemdActivation = true;
      };
    };
}
