{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.go-toolchain = {
    enable = lib.mkEnableOption "Enable go-toolchain";
  };
  config =
    let
      opts = config.${namespace}.apps.go-toolchain;
    in
    lib.mkIf opts.enable {
      programs.go = {
        enable = true;
      };
      ${namespace} = {
        apps.vscodium = {
          userSettings = {

          };
          extensions."golang.go" = {
            package = pkgs.nix-vscode-extensions.vscode-marketplace.golang.go;
          };
        };
      };
    };
}
