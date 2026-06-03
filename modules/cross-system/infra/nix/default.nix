{ pkgs, ... }:
{
  config = {
    environment.systemPackages = with pkgs; [ nixfmt ];
  };
}
