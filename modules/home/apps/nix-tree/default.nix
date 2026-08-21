{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.apps.nix-tree = {
    enable = lib.mkEnableOption "Enable nix-tree";
  };

  config =
    let
      opts = config.${namespace}.apps.nix-tree;
    in
    lib.mkIf opts.enable {
      home.packages = with pkgs; [ nix-tree ];
    };
}
