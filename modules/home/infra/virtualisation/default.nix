{
  config,
  osConfig ? { },
  namespace,
  lib,
  ...
}:
let
  osVirtualisationEnabled = osConfig.${namespace}.infra.virtualisation.enable or false;
in
{
  options.${namespace}.infra.virtualisation = {
    enable = lib.${namespace}.makeBoolOption {
      default = osVirtualisationEnabled;
    };
    defaultRegistry = lib.${namespace}.makeStrOption {
      default = "docker.io";
    };
  };
  config =
    let
      opts = config.${namespace}.infra.virtualisation;
    in
    lib.mkIf opts.enable {
      assertions = [
        (lib.${namespace}.failWhen {
          condition = osVirtualisationEnabled == false;
          message = "Home virtualisation requires OS level virtualisation enabled";
        })
      ];

      xdg.configFile."containers/registries.conf".text = ''
        unqualified-search-registries = ["${opts.defaultRegistry}"]
      '';
    };
}
