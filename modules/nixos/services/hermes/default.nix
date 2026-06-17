{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.services.hermes = {
    enable = lib.mkEnableOption "Enable hermes";
    envFiles = lib.${namespace}.makeListOption {
      ofType = lib.types.path;
      default = [ ];
    };
  };

  config =
    let
      opts = config.${namespace}.services.hermes;
    in
    lib.mkIf opts.enable {
      services.hermes-agent = {
        enable = true;
        package = pkgs.llm-agents.hermes-agent;
        settings = {
          model = {
            default = "claude-sonnet-4-6";
            provider = "anthropic";
          };
          memory = {
            memory_enabled = true;
            user_profile_enabled = true;
          };
        };
        environmentFiles = opts.envFiles;
        addToSystemPackages = true;
      };
    };
}
