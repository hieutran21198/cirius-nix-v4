{
  config,
  namespace,
  ...
}:
let
  inherit (config.snowfallorg) user;
  inherit (config) sops;
in
{
  ${namespace} = {
    infra.security = {
      secrets = {
        "personal/git/prv_key" = {
          key = "ssh/git/prv_key";
          path = "${user.home.directory}/.ssh/personal_git";
          mode = "0400";
        };
        "personal/git/pub_key" = {
          key = "ssh/git/pub_key";
          path = "${user.home.directory}/.ssh/personal_git.pub";
          mode = "0400";
        };
        "personal/git/config" = {
          key = "git/config";
          path = "${user.home.directory}/Workspaces/personal/.gitconfig";
          mode = "0400";
        };
        "personal/opencode/secured-env" = {
          key = "ai/opencode/env";
          mode = "0400";
        };
        "personal/api-key/deepseek" = {
          key = "ai/deepseek/api-key";
          mode = "0400";
        };
        "personal/ssh/config" = {
          key = "ssh/config";
          mode = "0400";
        };
        "personal/aws/config" = {
          key = "aws/config";
          mode = "0400";
        };
        "personal/syncthing/password" = {
          key = "syncthing/password";
          mode = "0400";
        };
      };
      templates = {
        "personal/opendesign/env-file" = {
          content = "";
        };
      };
    };
    services = {
      syncthing = {
        passwordFile = config.sops.secrets."personal/syncthing/password".path;
      };
    };
    apps = {
      git = {
        includes = [
          {
            condition = "gitdir:${user.home.directory}/Workspaces/personal/";
            path = "${user.home.directory}/Workspaces/personal/.gitconfig";
          }
        ];
      };
      ai = {
        opendesign.envFile = sops.templates."personal/opendesign/env-file".path;
        opencode = {
          providerAPIKeys = {
            deepseek = sops.secrets."personal/api-key/deepseek".path;
          };
        };
      };
    };
  };
}
