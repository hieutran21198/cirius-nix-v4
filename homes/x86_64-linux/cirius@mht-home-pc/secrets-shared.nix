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
    services.autossh.additionalConfig = [
      "${user.home.directory}/.ssh/config.d/10-sops.conf"
    ];
    infra.security = {
      templates = {
        "ssh/config" = {
          content = ''
            # Personal configuration
            ${sops.placeholder."personal/ssh/config"}

            # Buuuk configuration
            ${sops.placeholder."buuuk/ssh/config"}
          '';
          path = "${user.home.directory}/.ssh/config.d/10-sops.conf";
          mode = "0400";
        };
        "aws/config" = {
          content = ''
            # Personal configuration
            ${sops.placeholder."personal/aws/config"}

            # Buuuk configuration
            ${sops.placeholder."buuuk/aws/config"}
          '';
          path = "${user.home.directory}/.aws/config";
          mode = "0400";
        };
      };
    };
  };
}
