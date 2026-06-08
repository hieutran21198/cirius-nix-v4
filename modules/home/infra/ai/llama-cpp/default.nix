{
  config,
  lib,
  namespace,
  osConfig ? { },
  ...
}:
{
  options.${namespace}.infra.ai.llama-cpp = {
    cacheDir = lib.${namespace}.makeStrOption {
      default = "${config.snowfallorg.user.home.directory}/Workspaces/llama-cpp";
    };
    integrateNvim = lib.${namespace}.makeBoolOption {
      default = config.${namespace}.apps.nvim.enable;
    };
    qwenFIM = {
      enable = lib.${namespace}.makeBoolOption { default = false; };
      port = lib.${namespace}.makeIntOption { default = 8001; };
      model = lib.${namespace}.makeStrOption {
        default = "fim-qwen-3b-default";
      };
      extraArgs = lib.${namespace}.makeListOption {
        ofType = lib.types.str;
        default = [
          "--ctx-size"
          "4096"
          "--n-gpu-layers"
          "999"
          "--parallel"
          "1"
        ];
      };
    };
  };
  config =
    let
      osLlamaCpp = osConfig.${namespace}.infra.ai.llama-cpp;
      inherit (config.${namespace}.infra.ai) llama-cpp;

      qwenFIMArgs = [
        "--${llama-cpp.qwenFIM.model}"
        "--host"
        "127.0.0.1"
        "--port"
        (toString llama-cpp.qwenFIM.port)
      ]
      ++ llama-cpp.qwenFIM.extraArgs;

      llamaServer = lib.getExe' osLlamaCpp.package "llama-server";
    in
    lib.mkIf osLlamaCpp.enable {
      home.sessionVariables = {
        "LLAMA_CACHE" = llama-cpp.cacheDir;
      };
      systemd.user.services.llama-cpp-qwen-fim = {
        Unit = {
          Description = "llama.cpp Qwen FIM server";
          After = [ "default.target" ];
        };
        Service = {
          Type = "simple";
          Environment = [
            "LLAMA_CACHE=${llama-cpp.cacheDir}"
          ];
          ExecStart = "${llamaServer} ${lib.escapeShellArgs qwenFIMArgs}";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
      ${namespace} =
        let
          nvimQwenFIMSettings = {
            api_key = "TERM";
            name = "Llama.cpp ${llama-cpp.qwenFIM.model}";
            end_point = "http://127.0.0.1:${toString llama-cpp.qwenFIM.port}/v1/completions";
            # The model is set by the llama-cpp server and cannot be altered
            # post-launch.
            model = "PLACEHOLDER";
            optional = {
              max_tokens = 96;
              top_p = 0.9;
            };
            # Llama.cpp does not support the `suffix` option in FIM completion.
            # Therefore, we must disable it and manually populate the special
            # tokens required for FIM completion.
            template = {
              prompt = {
                __raw = ''
                  function(context_before_cursor, context_after_cursor, _)
                      return '<|fim_prefix|>'
                          .. context_before_cursor
                          .. '<|fim_suffix|>'
                          .. context_after_cursor
                          .. '<|fim_middle|>'
                  end
                '';
              };
              suffix = false;
            };
          };
        in
        {
          apps.nvim.ai = lib.mkIf llama-cpp.integrateNvim {
            setCompletionCap = lib.mkDefault 1;
            defaultOpenAIFIMCompatible = lib.mkDefault nvimQwenFIMSettings;
            fimPresets = {
              llama_cpp_qwen = {
                provider = "openai_fim_compatible";
                provider_options = {
                  openai_fim_compatible = nvimQwenFIMSettings;
                };
              };
            };
          };
        };
    };
}
