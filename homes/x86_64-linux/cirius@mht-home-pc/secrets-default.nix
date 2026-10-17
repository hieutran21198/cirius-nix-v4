{
  config,
  namespace,
  ...
}:
let
  inherit (config.snowfallorg) user;
  inherit (config) sops;
  inherit (config.cnix-sec) secret-mgt;
in
{
  cnix-sec.secret-mgt.secrets = {
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
    "personal/azure-devops/prv_key" = {
      key = "ssh/azure-devops/prv_key";
      path = "${user.home.directory}/.ssh/personal_azure_devops";
      mode = "0400";
    };
    "personal/azure-devops/pub_key" = {
      key = "ssh/azure-devops/pub_key";
      path = "${user.home.directory}/.ssh/personal_azure_devops.pub";
      mode = "0400";
    };
    "personal/git/config" = {
      key = "git/config";
      path = "${user.home.directory}/Workspaces/personal/.gitconfig";
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
    "personal/aria2/rpc_secret" = {
      key = "aria2/rpc-secret";
      mode = "0400";
    };
  };

  cnix-dev.git.settings.includes = [
    {
      condition = "gitdir:${user.home.directory}/Workspaces/personal/";
      path = "${user.home.directory}/Workspaces/personal/.gitconfig";
    }
  ];

  cnix-utils.connectivity.settings.fileSync.settings.credentials.passwordFile =
    secret-mgt.secrets."personal/syncthing/password".path;
}
