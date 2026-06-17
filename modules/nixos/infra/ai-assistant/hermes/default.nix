{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai-assistant.hermes = {
    enable = lib.mkEnableOption "Enable hermes";
    envFiles = lib.${namespace}.makeListOption {
      ofType = lib.types.path;
      default = [ ];
    };
  };

  config =
    let
      opts = config.${namespace}.apps.ai-assistant.hermes;
    in
    lib.mkIf opts.enable {
      services.hermes-agent = {
        enable = true;
        package = pkgs.llm-agents.hermes-agent;
        settings = { };
        environmentFiles = opts.envFiles;
        addToSystemPackages = true;
      };
    };
}
