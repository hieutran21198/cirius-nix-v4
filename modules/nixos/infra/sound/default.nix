{
  namespace,
  lib,
  config,
  ...
}:
{
  options.${namespace}.infra.sound = {
    enableJack = lib.mkEnableOption "Enable pipewire jack";
  };
  config = {
    services = {
      # Enable sound with pipewire.
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = config.${namespace}.infra.sound.enableJack;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };
    };
  };
}
