# ComfyUI: node-based image AND video generation (SD1.5/SDXL/Flux, and video
# models like Wan 2.x, LTX-Video, HunyuanVideo via the built-in workflow
# templates). Web UI on http://127.0.0.1:8188.
#
#   comfyui                       run in the foreground (first run installs)
#   comfyui update                git pull ComfyUI + custom nodes, reinstall
#   systemctl --user start comfyui   same, in the background
#
# Lives in <my.ai.dataDir>/comfyui. Models go to ~/AI/models/<type>/
# (checkpoints/, loras/, vae/, diffusion_models/, ...), shared with A1111;
# images and videos are written to ~/AI/outputs/comfyui. Low-VRAM tip (6-8 GB): use GGUF
# quantised Flux/Wan models through the ComfyUI-GGUF nodes installed below.
# Video on the GTX 1060 works but is slow (minutes per second of video);
# on Pascal, ComfyUI computes in fp32 and stores weights in fp16 by itself.
{
  config,
  lib,
  pkgs,
  ...
}: let
  ai = config.my.ai;
  cfg = ai.comfyui;
  aiLib = import ./lib.nix {
    inherit pkgs lib;
    cfg = ai;
  };

  # The shared ~/AI/models tree, listed first so downloads (e.g. from
  # ComfyUI-Manager) land there too. Folder names are ComfyUI's own.
  modelFolders = [
    "checkpoints"
    "diffusion_models"
    "text_encoders"
    "clip_vision"
    "vae"
    "loras"
    "controlnet"
    "upscale_models"
    "embeddings"
    "hypernetworks"
    "unet"
    "clip"
  ];
  extraModelPaths = pkgs.writeText "comfyui-extra-model-paths.yaml" (
    ''
      shared:
        base_path: ${ai.modelsDir}
        is_default: true
    ''
    + lib.concatMapStrings (d: "    ${d}: ${d}/\n") modelFolders
  );

  args =
    [
      "--listen=${cfg.listen}"
      "--port=${toString cfg.port}"
      "--enable-manager" # ComfyUI-Manager: install nodes/models from the UI
      "--preview-method=auto"
      "--extra-model-paths-config=${extraModelPaths}"
      "--output-directory=${ai.outputsDir}/comfyui"
    ]
    ++ cfg.extraArgs;

  launcher = aiLib.mkLauncher {
    name = "comfyui";
    script = ''
      root=${lib.escapeShellArg "${ai.dataDir}/comfyui"}
      src="$root/ComfyUI"
      venv="$root/venv"
      mkdir -p "$root" ${lib.escapeShellArgs (map (d: "${ai.modelsDir}/${d}") modelFolders)}

      ai_clone https://github.com/Comfy-Org/ComfyUI.git "$src"
      for url in ${lib.escapeShellArgs cfg.customNodes}; do
        ai_clone "$url" "$src/custom_nodes/$(basename "$url" .git)"
      done

      if [ "''${1-}" = update ]; then
        shift
        for repo in "$src" "$src"/custom_nodes/*/; do
          [ -d "$repo/.git" ] && { log "updating $repo"; git -C "$repo" pull --ff-only || log "pull failed: $repo"; }
        done
        rm -f "$venv/.setup-stamp"
        export AI_UPGRADE=1 # newest torch wheel + requirements too
      fi

      reqs=("$src/requirements.txt" "$src/manager_requirements.txt" "$src"/custom_nodes/*/requirements.txt)
      if ai_needs_setup "$venv/.setup-stamp" "$TORCH_INDEX ${cfg.python}" "''${reqs[@]}"; then
        ai_venv "$venv" ${cfg.python}
        ai_torch "$venv" torch torchvision torchaudio
        ai_reqs "$venv" "''${reqs[@]}"
        ai_setup_done "$venv/.setup-stamp" "$TORCH_INDEX ${cfg.python}" "''${reqs[@]}"
      fi

      cd "$src"
      exec "$venv/bin/python" main.py ${lib.escapeShellArgs args} "$@"
    '';
  };
in {
  options.my.ai.comfyui = {
    enable = lib.mkEnableOption "ComfyUI" // {default = ai.enable;};

    listen = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address to listen on. Custom nodes run arbitrary code - keep it local.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8188;
    };

    python = lib.mkOption {
      type = lib.types.str;
      # ComfyUI recommends 3.13; its cu126 (Pascal) builds are tested on 3.12
      default =
        if ai.legacyGpu
        then "3.12"
        else "3.13";
      description = "Python version for the venv (fetched by uv).";
    };

    customNodes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "https://github.com/city96/ComfyUI-GGUF" # quantised Flux/Wan/LTX for 6-8 GB cards
        "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite" # load/combine video frames
      ];
      description = "Custom node repos cloned on first start. Others can be added from ComfyUI-Manager.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["--lowvram" "--reserve-vram=1"];
      description = "Extra ComfyUI arguments (`comfyui --help`). VRAM handling is automatic by default.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [launcher];
    systemd.user.services.comfyui = aiLib.mkUserService {
      description = "ComfyUI";
      inherit launcher;
    };
  };
}
