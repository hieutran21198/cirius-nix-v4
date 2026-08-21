# REPL utilities to fast access configuration.
info: final: prev:
let
  flake = builtins.getFlake (toString ./.);
  host = flake.nixosConfigurations.mht-home-pc;

  home = host.config.home-manager.users.cirius;
in
{
  inherit
    flake
    host
    home
    ;
  inherit (host) config;
  inherit (home.programs) plasma;
}
