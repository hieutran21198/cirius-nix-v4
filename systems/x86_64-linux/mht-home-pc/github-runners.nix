{ config, pkgs, ... }:
let
  inherit (config.cnix-sec) secret-mgt;
in
{
  users.groups.github-runners = { };

  services.github-runners = {
    cirius-go-platform = {
      enable = true;
      url = "https://github.com/hieutran21198/cirius-go-platform";
      tokenFile = secret-mgt.secrets."personal/github-runners/cirius-go-platform".path;
      extraLabels = [
        "nixos"
        "x86_64-linux"
      ];
      # Keep checkout, node_modules and HOME caches off the rotational NTFS disk.
      # The NixOS runner module cleans this directory on each service start.
      workDir = "/var/cache/github-runner/cirius-go-platform/work";
      user = "cirius";
      group = "github-runners";
      nodeRuntimes = [ "node24" ];
      extraPackages = with pkgs; [
        atmos
        awscli2
        curl
        unzip
        which
        jq
      ];
      extraEnvironment = {
        RUNNER_TOOL_CACHE = "/var/cache/github-runner/cirius-go-platform/toolcache";
        TF_PLUGIN_CACHE_DIR = "/var/cache/github-runner/cirius-go-platform/terraform-plugin-cache";
        CHECKPOINT_DISABLE = "1";
      };
      serviceOverrides = {
        CacheDirectory = [
          "github-runner/cirius-go-platform/work"
          "github-runner/cirius-go-platform/toolcache"
          "github-runner/cirius-go-platform/terraform-plugin-cache"
        ];
      };
    };
  };
}
