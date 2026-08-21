{
  osConfig ? { },
  config,
  namespace,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule
      [ namespace "infra" "shell" "fish" "shellAbbrs" ]
      [ "programs" "fish" "shellAbbrs" ]
    )
  ];
  options.${namespace}.infra.shell.fish = {
    enabled = lib.${namespace}.makeBoolOption {
      readOnly = true;
      default = osConfig.${namespace}.infra.shell.fish.enable;
      description = "Enable fish shell";
    };
    enableLinuxAbbrs = lib.${namespace}.makeBoolOption {
      default = pkgs.stdenv.hostPlatform.isLinux;
      description = "Enable Linux-specific shell abbreviations for fish shell";
    };
  };
  config =
    let
      opts = config.${namespace}.infra.shell.fish;
      hmLib = inputs.home-manager.lib;
    in
    lib.mkMerge [
      (lib.mkIf opts.enabled {
        programs.fish = {
          enable = true;
        };
      })
      (lib.mkIf (opts.enabled && opts.enableLinuxAbbrs) {
        programs.fish.shellAbbrs = {
          "make-boot-log" =
            "sudo journalctl -b -o short-precise --no-pager > ${config.xdg.stateHome}/boot-logs/$(date +%Y%m%d-%H%M%S).log";
        };
        home.activation.createBootLogDir = hmLib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "${config.xdg.stateHome}/boot-logs"
        '';
      })
    ];

}
