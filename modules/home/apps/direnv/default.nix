{
  namespace,
  lib,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule [ namespace "apps" "direnv" ] [ "programs" "direnv" ])
  ];
}
