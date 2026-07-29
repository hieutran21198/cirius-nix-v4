{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.cpp-toolchain = {
    enable = lib.mkEnableOption "Enable the C++ toolchain";
  };

  config =
    let
      opts = config.${namespace}.apps.cpp-toolchain;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [
        clang
        clang-tools
        cmake
        ninja
        gnumake
        pkg-config
        gdb
        lldb
        ccache
      ];

      ${namespace} = {
        apps.vscodium = {
          extensions."llvm-vs-code-extensions.vscode-clangd" = {
            package = pkgs.nix-vscode-extensions.vscode-marketplace.llvm-vs-code-extensions.vscode-clangd;
          };
        };

        apps.nvim = {
          extraPackagesAfter = with pkgs; [
            clang-tools
          ];

          lsp.servers.clangd = {
            enable = true;
            package = pkgs.clang-tools;
            packageFallback = true;
            config = {
              cmd = [
                (lib.getExe' pkgs.clang-tools "clangd")
                "--background-index"
                "--clang-tidy"
                "--completion-style=detailed"
                "--header-insertion=iwyu"
              ];

              filetypes = [
                "c"
                "cpp"
                "objc"
                "objcpp"
                "cuda"
              ];

              root_markers = [
                "compile_commands.json"
                "compile_flags.txt"
                "CMakeLists.txt"
                "Makefile"
                ".git"
              ];
            };
          };

          formatter = {
            byFileType = {
              c = [ "clang_format" ];
              cpp = [ "clang_format" ];
              objc = [ "clang_format" ];
              objcpp = [ "clang_format" ];
              cuda = [ "clang_format" ];
            };

            setFormatters.clang_format = {
              command = lib.getExe' pkgs.clang-tools "clang-format";
            };
          };
        };
      };
    };
}
