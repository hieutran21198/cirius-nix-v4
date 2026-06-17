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
    codexCLIPackage = lib.${namespace}.makePackageOption { default = pkgs.llm-agents.codex; };
  };
  config =
    let
      opts = config.${namespace}.apps.ai.codex;
    in
    lib.mkIf opts.enable {
      home = {
        packages = [
          opts.codexCLIPackage
        ]
        ++ (with pkgs; [ llm-agents.oh-my-codex ]);
      };
      ${namespace} = {
        apps.vscodium.extensions."openai.chatgpt" = {
          package = pkgs.nix-vscode-extensions.vscode-marketplace.openai.chatgpt;
        };
      };
    };
}
