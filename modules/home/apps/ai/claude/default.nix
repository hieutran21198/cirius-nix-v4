{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai.claude = {
    enable = lib.mkEnableOption "Enable claude";
  };
  config =
    let
      opts = config.${namespace}.apps.ai.claude;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [
        claude-code
        claude-monitor
      ];
      ${namespace} = {
        apps.vscodium.extensions."anthropic.claude-code" = {
          package = pkgs.nix-vscode-extensions.vscode-marketplace.anthropic.claude-code;
        };
      };
    };
}
