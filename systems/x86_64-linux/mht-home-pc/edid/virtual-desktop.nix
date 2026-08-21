{ pkgs, ... }:
let
  customEdids = pkgs.runCommand "custom-display-edids" { } ''
    mkdir -p $out/lib/firmware/edid

    cp ${./mi15tp60.bin} \
      $out/lib/firmware/edid/mi15tp60.bin
  '';
in
{
  hardware.display = {
    edid = {
      enable = true;

      # old school settings
      modelines = {
        # "pad6p60" = "264.50  2240 2400 2640 3040  1400 1403 1409 1451 -hsync +vsync";
        # "mi15tp60" = "236.75  2240 2392 2632 3024  1260 1263 1268 1307 -hsync +vsync";
      };
      packages = [
        customEdids
      ];
    };

    outputs = {
      "DP-2" = {
        edid = "mi15tp60.bin";
        mode = "1920x1080@60e";
      };
    };
  };
}
