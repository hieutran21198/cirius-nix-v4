{
  config,
  namespace,
  ...
}:
let
  inherit (config.snowfallorg) user;
  sopsFile = ../../../secrets/cirius__mht-home-pc/buuuk.yaml;
in
{
  ${namespace} = {
    infra.security = {
      secrets = {
        "buuuk/git/prv_key" = {
          inherit sopsFile;
          key = "ssh/git/prv_key";
          path = "${user.home.directory}/.ssh/buuuk_git";
          mode = "0400";
        };
        "buuuk/git/pub_key" = {
          inherit sopsFile;
          key = "ssh/git/pub_key";
          path = "${user.home.directory}/.ssh/buuuk_git.pub";
          mode = "0400";
        };
        "buuuk/bas/prv_key" = {
          inherit sopsFile;
          key = "ssh/bas/prv_key";
          path = "${user.home.directory}/.ssh/buuuk_bas";
          mode = "0400";
        };
        "buuuk/bas/pub_key" = {
          inherit sopsFile;
          key = "ssh/bas/pub_key";
          path = "${user.home.directory}/.ssh/buuuk_bas.pub";
          mode = "0400";
        };
        "buuuk/git/config" = {
          inherit sopsFile;
          key = "git/config";
          path = "${user.home.directory}/Workspaces/buuuk/.gitconfig";
          mode = "0400";
        };
        "buuuk/ssh/config" = {
          inherit sopsFile;
          key = "ssh/config";
          mode = "0400";
        };
        "buuuk/aws/config" = {
          inherit sopsFile;
          key = "aws/config";
          mode = "0400";
        };
      };
    };
    apps = {
      git = {
        includes = [
          {
            condition = "gitdir:${user.home.directory}/Workspaces/buuuk/";
            path = "${user.home.directory}/Workspaces/buuuk/.gitconfig";
          }
        ];
      };
    };
  };
}
