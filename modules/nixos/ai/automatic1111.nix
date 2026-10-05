# AUTOMATIC1111 stable-diffusion-webui (SD1.5/SDXL). Web UI on
# http://127.0.0.1:7860.
#
#   automatic1111                        run in the foreground (first run installs)
#   automatic1111 update                 git pull
#   systemctl --user start automatic1111 same, in the background
#
# Lives in <my.ai.dataDir>/automatic1111. Models go to ~/AI/models/
# (checkpoints/, loras/, vae/, ...), shared with ComfyUI; outputs are linked
# to ~/AI/outputs/automatic1111.
#
# Upstream has been unmaintained since v1.10.1 (2024) and has open security
# bugs, e.g. code execution through crafted model files/metadata, so only
# load models from sources you trust and keep it on localhost. Its own
# installer still works and pins torch 2.1.2 + CUDA 12.1, which has kernels
# for both the GTX 1060 and the RTX 3070, so the torch index is left alone.
{
  config,
  lib,
  pkgs,
  ...
}: let
  ai = config.my.ai;
  cfg = ai.automatic1111;
  aiLib = import ./lib.nix {
    inherit pkgs lib;
    cfg = ai;
  };

  args =
    [
      "--port=${toString (aiLib.backendPort cfg.port)}"
      # medvram only kicks in for SDXL, which doesn't fit 6-8 GB otherwise;
      # SD1.5 keeps running at full speed
      "--medvram-sdxl"
      "--api"
      # same model folders as ComfyUI (~/AI/models)
      "--ckpt-dir=${ai.modelsDir}/checkpoints"
      "--lora-dir=${ai.modelsDir}/loras"
      "--vae-dir=${ai.modelsDir}/vae"
      "--embeddings-dir=${ai.modelsDir}/embeddings"
      "--hypernetwork-dir=${ai.modelsDir}/hypernetworks"
      "--esrgan-models-path=${ai.modelsDir}/upscale_models"
    ]
    ++ cfg.extraArgs;

  launcher = aiLib.mkLauncher {
    name = "automatic1111";
    script = ''
      root=${lib.escapeShellArg "${ai.dataDir}/automatic1111"}
      src="$root/stable-diffusion-webui" # webui.sh expects this dir name
      venv="$root/venv"
      mkdir -p "$root" ${lib.escapeShellArg "${ai.outputsDir}"} ${lib.escapeShellArgs (map (d: "${ai.modelsDir}/${d}") ["checkpoints" "loras" "vae" "embeddings" "hypernetworks" "upscale_models"])}

      ai_clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "$src" master
      if [ "''${1-}" = update ]; then
        shift
        git -C "$src" pull --ff-only
      fi

      # torch 2.1.2 has no wheels beyond Python 3.11; 3.10 is what A1111 supports
      ai_venv "$venv" 3.10

      # Stability-AI deleted its GitHub repos at the end of 2025, which broke
      # fresh installs; this is the community mirror A1111's dev branch uses.
      export STABLE_DIFFUSION_REPO=https://github.com/w-e-w/stablediffusion.git
      # OpenAI's CLIP still imports pkg_resources in its setup.py, which
      # setuptools removed; keep the isolated build envs on an older one.
      echo 'setuptools<70' > "$root/build-constraints.txt"
      export PIP_CONSTRAINT="$root/build-constraints.txt"
      export PIP_BUILD_CONSTRAINT="$root/build-constraints.txt"

      # A1111 can't move its outputs from the command line; link them instead
      ln -sfn "$src/outputs" ${lib.escapeShellArg "${ai.outputsDir}/automatic1111"}

      export venv_dir="$venv"
      export COMMANDLINE_ARGS=${lib.escapeShellArg (lib.concatStringsSep " " args)}
      cd "$src"
      exec bash webui.sh "$@"
    '';
  };
in {
  options.my.ai.automatic1111 = {
    enable = lib.mkEnableOption "AUTOMATIC1111 stable-diffusion-webui" // {default = ai.enable;};

    port = lib.mkOption {
      type = lib.types.port;
      default = 7860;
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["--xformers" "--medvram"];
      description = "Extra webui arguments, appended to COMMANDLINE_ARGS.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [launcher];
    systemd.user = aiLib.mkWebService {
      name = "automatic1111";
      description = "AUTOMATIC1111 stable-diffusion-webui";
      inherit launcher;
      inherit (cfg) port;
    };
  };
}
