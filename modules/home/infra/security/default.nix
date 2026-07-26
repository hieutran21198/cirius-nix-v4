{
  namespace,
  lib,
  config,
  osConfig ? { },
  host,
  pkgs,
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
    ageKey = lib.${namespace}.makeStrOption {
      default = "/run/secure-store/users/${config.snowfallorg.user.name}/sops-age/key.txt";
    };
    sopsFormat = lib.${namespace}.makeStrOption {
      default = "yaml";
    };
  };

  config =
    let
      inherit (config.${namespace}.infra) security;
    in
    {
      home.packages = with pkgs; [ secretspec ];
      sops = {
        age = {
          keyFile = security.ageKey;
        };
        defaultSopsFile = ../../../../secrets/${config.snowfallorg.user.name}__${host}/default.${security.sopsFormat};
        defaultSopsFormat = security.sopsFormat;
      };
      programs.fish.shellAbbrs = {
        "u-sops" = "SOPS_AGE_KEY_FILE=${security.ageKey} sops --config .sops.yaml";
        "h-sops" = "sudo -E SOPS_AGE_KEY_FILE=${osConfig.sops.age.keyFile} sops --config .sops.yaml";
      };
    };
}
