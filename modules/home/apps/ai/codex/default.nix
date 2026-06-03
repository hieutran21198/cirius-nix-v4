{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.ai.codex = {
    enable = lib.mkEnableOption "Enable codex";
  };
  config =
    let
      opts = config.${namespace}.apps.ai.codex;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ codex ];
      ${namespace} = {
        apps.vscodium.extensions."openai.chatgpt" = {
          package = pkgs.nix-vscode-extensions.vscode-marketplace.openai.chatgpt;
        };
      };
    };
}
