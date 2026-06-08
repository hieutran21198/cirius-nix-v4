{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.apps.fastfetch = {
    enable = lib.mkEnableOption "Enable fastfetch";
  };

  config =
    let
      opts = config.${namespace}.apps.fastfetch;
      inherit (config.${namespace}.infra) shell;
      package = pkgs.fastfetch;
    in
    lib.mkIf opts.enable {
      programs.fastfetch = {
        enable = true;
        inherit package;
      };

      programs.fish.interactiveShellInit = lib.mkIf shell.fish.enabled ''
        ${lib.getExe package}
      '';
    };
}
