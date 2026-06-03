{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
{
  options.${namespace}.apps.vscodium = {
    enable = lib.mkEnableOption "Enable vscodium editor";
    extensions = lib.mkOption {
      type =
        with lib.types;
        attrsOf (submodule {
          options = {
            package = lib.mkOption { type = with lib.types; package; };
            settings = lib.mkOption {
              type = with lib.types; attrsOf anything;
              default = { };
            };
          };
        });
      default = { };
      description = "Extensions";
    };
  };
  config =
    let
      opts = config.${namespace}.apps.vscodium;

      extensionsPackages =
        (with pkgs.nix-vscode-extensions.vscode-marketplace; [
          arrterian.nix-env-selector
          jnoortheen.nix-ide
          mkhl.direnv
        ])
        ++ (lib.mapAttrsToList (_: value: value.package) opts.extensions);
      extensionsSettings = lib.foldl' lib.recursiveUpdate { } (
        lib.mapAttrsToList (_: value: value.settings) opts.extensions
      );
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ nixfmt ];
      programs.vscodium = {
        enable = true;
        profiles.default = {
          enableUpdateCheck = false;
          extensions = extensionsPackages;
          userSettings = extensionsSettings // {
            "explorer.confirmDelete" = false;
            "explorer.confirmDragAndDrop" = false;
            "nix.formatterPath" = "nixfmt";
            "editor.formatOnSave" = true;
          };
        };
      };
    };
}
