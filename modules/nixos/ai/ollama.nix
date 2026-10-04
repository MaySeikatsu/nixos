# Ollama: local LLM server + CLI, with CUDA.
# Runs as a systemd *user* service so models stay where `ollama pull` has
# always put them (~/.ollama/models). Logs: journalctl --user -u ollama
{
  config,
  lib,
  pkgs,
  ...
}: let
  ai = config.my.ai;
  cfg = ai.ollama;
in {
  options.my.ai.ollama = {
    enable = lib.mkEnableOption "ollama" // {default = ai.enable;};

    package = lib.mkOption {
      type = lib.types.package;
      # plain `ollama` is CPU-only; -cuda has the GGML CUDA backend
      default = pkgs.ollama-cuda;
      defaultText = lib.literalExpression "pkgs.ollama-cuda";
      description = "Ollama package.";
    };

    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Start the server at login. Idle it holds no VRAM; a loaded model stays
        resident for OLLAMA_KEEP_ALIVE (free it early with `ollama stop <model>`).
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      # Flash attention plus an 8-bit KV cache shrink the context enough that
      # 7B Q4 models still fit fully on the GTX 1060 (6 GB, ~4.2 GB usable
      # once the desktop has its share); a partial offload is what makes
      # generation feel slow. Same settings just leave more headroom on 8 GB.
      default = {
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0"; # needs flash attention
        OLLAMA_KEEP_ALIVE = "30m"; # default ~4 min; reloading costs seconds
        OLLAMA_NUM_PARALLEL = "1"; # one context's worth of KV, not several
      };
      description = "Environment for the ollama server (also exported to login shells for a manual `ollama serve`).";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [cfg.package];
    environment.sessionVariables = cfg.environment;

    systemd.user.services.ollama = {
      description = "Ollama LLM server";
      wantedBy = lib.optional cfg.autostart "default.target";
      after = ["network.target"];
      inherit (cfg) environment;
      unitConfig.ConditionUser = ai.user;
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} serve";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
