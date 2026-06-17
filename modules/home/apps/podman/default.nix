{
  config,
  osConfig ? { },
  namespace,
  pkgs,
  lib,
  ...
}:
let
  osVirtualisationEnabled = osConfig.${namespace}.infra.virtualisation.enable or false;
in
{
  options.${namespace}.apps.podman = {
    enable = lib.mkEnableOption "Enable podman CLI tools";
    compose = lib.${namespace}.makeBoolOption {
      default = true;
    };
    distrobox = lib.${namespace}.makeBoolOption {
      default = true;
    };
    buildTools = lib.${namespace}.makeBoolOption {
      default = true;
    };
    debugTools = lib.${namespace}.makeBoolOption {
      default = true;
    };
  };

  config =
    let
      opts = config.${namespace}.apps.podman;
    in
    lib.mkIf opts.enable {
      assertions = [
        (lib.${namespace}.failWhen {
          condition = osVirtualisationEnabled == false;
          message = "Podman CLI tools require OS level virtualisation enabled";
        })
      ];

      home.packages =
        with pkgs;
        [
          podman
        ]
        ++ lib.optionals opts.compose [
          podman-compose
        ]
        ++ lib.optionals opts.distrobox [
          distrobox
        ]
        ++ lib.optionals opts.buildTools [
          buildah
          skopeo
        ]
        ++ lib.optionals opts.debugTools [
          dive
        ];
    };
}
