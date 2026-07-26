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
    markAsFavorite = lib.mkEnableOption "Mark codex as favorite";
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
        ++ (with pkgs; [
          # llm-agents.oh-my-codex
        ]);
      };
      programs.codexDesktopLinux = {
        enable = true;
        cliPackage = opts.codexCLIPackage;
        computerUseUi.enable = true;
        remoteMobileControl.enable = true;
      };
      ${namespace} = {
        apps.vscodium.extensions."openai.chatgpt" = {
          package = pkgs.nix-vscode-extensions.vscode-marketplace.openai.chatgpt;
        };
        infra.desktop-manager = {
          gnome.setFavoriteApps = [ "codex-desktop.desktop" ];
        };
      };
    };
}
