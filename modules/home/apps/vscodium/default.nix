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
    markAsFavorite = lib.mkEnableOption "Mark this app as favorite";
    extensions = lib.${namespace}.makeAttrsOption {
      ofType = lib.types.submodule {
        options = {
          package = lib.${namespace}.makePackageOption { };
          settings = lib.${namespace}.makeAttrsOption { default = { }; };
        };
      };
      default = { };
    };
    userSettings = lib.${namespace}.makeAttrsOption { };
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
      ${namespace} = {
        infra.desktop-manager = {
          gnome.setFavoriteApps = [
            "codium.desktop"
          ];
        };
      };
      programs.vscodium = {
        enable = true;
        profiles.default = {
          enableUpdateCheck = false;
          extensions = extensionsPackages;
          userSettings =
            extensionsSettings
            // {
              "explorer.confirmDelete" = false;
              "explorer.confirmDragAndDrop" = false;
              "editor.formatOnSave" = true;
              "nix.formatterPath" = "nixfmt";
              "editor.fontFamily" =
                let
                  stylixFont = config.stylix.fonts.monospace.name;
                in
                "${if stylixFont != "" then "'${stylixFont}'," else ""} 'Droid Sans Mono', monospace";
            }
            // opts.userSettings;
          languageSnippets = {
          };
        };
      };
    };
}
