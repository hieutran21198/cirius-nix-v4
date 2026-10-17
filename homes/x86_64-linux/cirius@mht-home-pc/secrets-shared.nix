{
  config,
  namespace,
  ...
}:
let
  inherit (config.snowfallorg) user;
  inherit (config.cnix-sec) secret-mgt;
in
{
  cnix-sec = {
    secret-mgt.templates = {
      "ssh/config" = {
        content = ''
          # Personal configuration
          ${secret-mgt.placeholder."personal/ssh/config"}

          # Buuuk configuration
          ${secret-mgt.placeholder."buuuk/ssh/config"}
        '';
        path = "${user.home.directory}/.ssh/config.d/10-sops.conf";
        mode = "0400";
      };
      "aws/config" = {
        content = ''
          # Personal configuration
          ${secret-mgt.placeholder."personal/aws/config"}

          # Buuuk configuration
          ${secret-mgt.placeholder."buuuk/aws/config"}
        '';
        path = "${user.home.directory}/.aws/config";
        mode = "0400";
      };
    };
    ssh.additionalConfigPaths = [
      secret-mgt.templates."ssh/config".path
    ];
  };
}
