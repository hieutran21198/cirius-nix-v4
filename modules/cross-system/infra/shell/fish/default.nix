{
  namespace,
  lib,
  ...
}:
{
  imports = [
    (lib.mkAliasOptionModule [ namespace "infra" "shell" "fish" ] [ "programs" "fish" ])
  ];
}
