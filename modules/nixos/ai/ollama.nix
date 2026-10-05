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
        # Ollama probes the GPU once at startup with a 30 s watchdog. Under
        # heavy load (e.g. a big local build) the probe can time out and the
        # server then silently stays CPU-only until restarted (seen
        # 2026-10-04: 1.5 tok/s instead of GPU speed). This check fails the
        # start in that case, so Restart= retries the GPU detection.
        ExecStartPost = lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers) (toString (pkgs.writeShellScript "ollama-gpu-check" ''
          # no NVIDIA GPU usable (e.g. the laptop's no-nvidia boot entry): fine
          ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -L >/dev/null 2>&1 || exit 0
          for _ in $(seq 90); do
            line=$(${pkgs.systemd}/bin/journalctl --user -u ollama _PID="$MAINPID" -o cat \
              | ${pkgs.gnugrep}/bin/grep 'msg="inference compute"' | ${pkgs.coreutils}/bin/tail -n1)
            if [ -n "$line" ]; then
              case "$line" in
                *library=cpu*) echo "ollama started without GPU, retrying" >&2; exit 1 ;;
                *) exit 0 ;;
              esac
            fi
            sleep 1
          done
        ''));
        Restart = "on-failure";
        RestartSec = 5;
      };
      unitConfig.StartLimitIntervalSec = 300;
      unitConfig.StartLimitBurst = 5;
    };
  };
}
