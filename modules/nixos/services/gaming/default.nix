{
  config,
  namespace,
  pkgs,
  lib,
  ...
}:
{
  options.${namespace}.services.gaming = {
    enable = lib.mkEnableOption "Enable gaming mode";
    stream = {
      enable = lib.mkEnableOption "Enable streaming mode";
      users = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of users allowed to stream games";
      };
      displayID = lib.mkOption {
        type = lib.types.str;
        default = "0";
        description = "Display ID to use for streaming";
      };
      applications = lib.mkOption {
        type = with lib.types; listOf (attrsOf anything);
        default = [ ];
        description = "List of applications allowed to be streamed";
      };
    };
    emulator = {
      eden = {
        enable = lib.mkEnableOption "Enable Eden emulator";
      };
    };
    gamescope = {
      enable = lib.mkEnableOption "Enable Gamescope for gaming mode";
      enableHDR = lib.mkEnableOption "Enable HDR support in Gamescope";
    };
  };
  config =
    let
      opts = config.${namespace}.services.gaming;
    in
    lib.mkMerge [
      (lib.mkIf opts.enable {
        environment.systemPackages = with pkgs; [
          protonup-qt
          wine
          mangohud
          protontricks
        ];
        hardware.graphics.enable32Bit = true;
        programs = {
          gamemode.enable = true;
          steam = {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
            gamescopeSession = lib.mkIf opts.gamescope.enable {
              enable = true;
            };
          };
        };
      })
      (lib.mkIf (opts.enable && opts.gamescope.enable) {
        programs.gamescope = {
          enable = true;
          capSysNice = true;
          enableWsi = opts.gamescope.enableHDR;
        };
      })
      (lib.mkIf (opts.enable && opts.emulator.eden.enable) {
        environment.systemPackages = with pkgs; [
          vulkan-tools
        ];
        programs.eden = {
          enable = true;
        };
      })
      (lib.mkIf (opts.enable && opts.stream.enable) {
        services.sunshine = {
          enable = true;
          package = pkgs.sunshine.override {
            cudaSupport = true;
          };
          openFirewall = true;
          capSysAdmin = true;
          applications = {
            env = { };
            apps = opts.stream.applications;
          };
          # TODO: this configuration is for NVIDIA
          settings = {
            capture = "kms";
            encoder = "nvenc";
            hevc_mode = 0;
            av1_mode = 0;
            nvenc_preset = 1;
            nvenc_twopass = "quarter_res";
            nvenc_spatial_aq = "disabled";
            nvenc_vbv_increase = 0;
            nvenc_h264_cavlc = "disabled";
            max_bitrate = 0;
            minimum_fps_target = 0;
            fec_percentage = 20;
            qp = 28;
            output_name = opts.stream.displayID;
          };
        };

        users.users = builtins.listToAttrs (
          map (user: {
            name = user;
            value = {
              extraGroups = [
                "uinput"
                "input"
              ];
            };
          }) opts.stream.users
        );
      })
    ];
}
