{ namespace, config, ... }:
{
  ${namespace} = {
    infra = {
      shell = {
        fish.shellAbbrs = {
          rbnix = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/Workspaces/personal/dotfiles/cirius-nix-v4";
        };
      };
    };

    apps = {
      vscodium.enable = true;
      direnv.enable = true;
      devenv.enable = true;
      proton-pass.enable = true;
      ai = {
        claude.enable = true;
        codex.enable = true;
        opencode.enable = true;
      };
      librewolf = {
        enable = true;
        persistFingerprint = true;
        containers = {
          default = {
            id = 1;
            color = "pink";
            icon = "fruit";
          };
          buuuk = {
            id = 2;
            color = "orange";
            icon = "briefcase";
          };
        };
      };
    };
  };
}
