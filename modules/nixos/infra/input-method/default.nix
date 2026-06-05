{
  lib,
  namespace,
  config,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule
      [
        namespace
        "infra"
        "input-method"
        "enableLotus"
      ]
      [
        "services"
        "fcitx5-lotus"
        "enable"
      ]
    )
    (lib.mkAliasOptionModule
      [
        namespace
        "infra"
        "input-method"
        "enable"
      ]
      [
        "i18n"
        "inputMethod"
        "enable"
      ]
    )
  ];
  options.${namespace}.infra.input-method = {
    users = lib.${namespace}.makeListOption {
      ofType = lib.types.str;
      default = [ ];
    };
  };
  config = {
    i18n.inputMethod = {
      type = "fcitx5";
    };
    services.fcitx5-lotus = {
      inherit (config.${namespace}.infra.input-method) users;
    };
  };
}
