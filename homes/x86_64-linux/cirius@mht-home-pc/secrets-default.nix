{
  config,
  namespace,
  ...
}:
let
  inherit (config.snowfallorg) user;
  inherit (config) sops;
  sopsFile = ../../../secrets/cirius__mht-home-pc/default.yaml;
in
{
  ${namespace} = {
    infra.security = {
      secrets = {
        "personal/git/prv_key" = {
          inherit sopsFile;
          key = "ssh/git/prv_key";
          path = "${user.home.directory}/.ssh/personal_git";
          mode = "0400";
        };
        "personal/git/pub_key" = {
          inherit sopsFile;
          key = "ssh/git/pub_key";
          path = "${user.home.directory}/.ssh/personal_git.pub";
          mode = "0400";
        };
        "personal/git/config" = {
          inherit sopsFile;
          key = "git/config";
          path = "${user.home.directory}/Workspaces/personal/.gitconfig";
          mode = "0400";
        };
        "personal/opencode/secured-env" = {
          inherit sopsFile;
          key = "ai/opencode/env";
          mode = "0400";
        };
      };
      templates = {
        "personal/opendesign/env-file" = {
          content = "";
        };
        "personal/opencode/env-file" = {
          content = ''
            OPENCODE_SERVER_USERNAME=${user.name}

            # secured configuration
            ${sops.placeholder."personal/opencode/secured-env"}
          '';
        };
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
        opencode.webEnvFile = sops.templates."personal/opencode/env-file".path;
      };
    };
  };
}
