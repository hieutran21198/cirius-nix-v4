{
  namespace,
  lib,
  config,
  osConfig ? { },
  ...
}:
{
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
      sops = {
        age = {
          keyFile = security.ageKey;
        };
        defaultSopsFormat = security.sopsFormat;
      };
      programs.fish.shellAbbrs = {
        "u-sops" = "SOPS_AGE_KEY_FILE=${security.ageKey} sops --config .sops.yaml";
        "h-sops" = "sudo -E SOPS_AGE_KEY_FILE=${osConfig.sops.age.keyFile} sops --config .sops.yaml";
      };
    };
}
