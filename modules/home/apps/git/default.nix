{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule [ namespace "apps" "git" "includes" ] [ "programs" "git" "includes" ])
  ];
  options.${namespace}.apps.git = { };
  config = {
    programs = {
      git = {
        enable = true;
        settings = {
          core.whitespace = "trailing-space,space-before-tab";
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          color.ui = "auto";
          diff = {
            tool = "vimdiff";
            mnemonicprefix = true;
          };
          merge.tool = "splice";
          push.default = "simple";
          pull.rebase = true;
          branch.autosetupmerge = true;
          rerere.enabled = true;
          extraConfig = { };
        };

      };
      gh = {
        enable = true;
        extensions = with pkgs; [
          gh-eco
          gh-dash
        ];
        gitCredentialHelper = {
          enable = true;
          hosts = [ "https://github.com" ];
        };
        settings = {
          prompt = "enabled";
          git_protocol = "ssh";
        };
      };
      lazygit = {
        enable = true;
        enableFishIntegration = config.${namespace}.infra.shell.fish.enabled;
      };
    };
  };
}
