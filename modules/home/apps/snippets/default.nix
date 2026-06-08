{
  namespace,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.${namespace}.apps.snippets;
in
{
  options.${namespace}.apps.snippets = {
    extraSourceDirs = lib.${namespace}.makeListOption {
      ofType = lib.types.path;
      default = [ ];
      description = "Extra snippet source directories.";
    };

    nvimOutDir = lib.${namespace}.makeStrOption {
      default = ".config/nvim/snippets";
      description = "Home-relative output directory for Nvim LuaSnip snippets.";
    };

    vscodiumOutDir = lib.${namespace}.makeStrOption {
      default = ".config/VSCodium/User/snippets";
      description = "Home-relative output directory for VSCodium user snippets.";
    };

    built = {
      nvimSnippetDir = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        description = "Compiled Nvim/LuaSnip snippet package path.";
      };

      vscodiumSnippetDir = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        description = "Compiled VSCodium snippet directory path, without package.json.";
      };
    };
  };

  config =
    let
      builtinSourceDirs = lib.optionals (builtins.pathExists ./editor) [
        ./editor
      ];

      combinedSourceDirs = builtinSourceDirs ++ cfg.extraSourceDirs;

      # For LuaSnip from_vscode loader:
      # Keep package.json and the original folder structure.
      nvimSnippetDir = pkgs.runCommand "cirius-nvim-snippets" { } ''
        mkdir -p "$out"

        ${lib.concatMapStringsSep "\n" (sourceDir: ''
          if [ -d "${sourceDir}" ]; then
            cp -rf --no-preserve=mode,ownership "${sourceDir}/." "$out/"
            chmod -R u+rwX "$out"
          fi
        '') combinedSourceDirs}
      '';

      # For VSCodium:
      # User snippets directory should contain snippet json/code-snippets files.
      # package.json is only for VSCode-extension style / LuaSnip package loading,
      # so exclude it here.
      #
      # This flattens snippet files into the VSCodium User/snippets folder.
      vscodiumSnippetDir = pkgs.runCommand "cirius-vscodium-snippets" { } ''
        mkdir -p "$out"

        ${lib.concatMapStringsSep "\n" (sourceDir: ''
          if [ -d "${sourceDir}" ]; then
            while IFS= read -r -d "" file; do
              cp -f --no-preserve=mode,ownership "$file" "$out/$(basename "$file")"
            done < <(
              find "${sourceDir}" \
                -type f \
                \( -name "*.json" -o -name "*.code-snippets" \) \
                ! -name "package.json" \
                -print0
            )
          fi
        '') combinedSourceDirs}

        chmod -R u+rwX "$out"
      '';

      managedOutFiles = {
        ${cfg.nvimOutDir} = {
          source = nvimSnippetDir;
          recursive = false;
        };

        ${cfg.vscodiumOutDir} = {
          source = vscodiumSnippetDir;
          recursive = false;
        };
      };
    in
    {
      ${namespace}.apps.snippets.built = {
        inherit nvimSnippetDir vscodiumSnippetDir;
      };

      home.file = managedOutFiles;
    };
}
