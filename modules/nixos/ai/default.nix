# Local AI stack shared by every desktop host: LLMs (ollama), image/video
# generation (ComfyUI, AUTOMATIC1111), speech-to-text (whisper.cpp),
# text-to-speech + voice cloning (piper, Coqui XTTS) and voice conversion
# (Applio/RVC). Each tool has its own file and `my.ai.<tool>.enable` toggle.
#
# The only thing a host has to set is its GPU, everything GPU-specific is
# derived from that:
#   my.ai.cudaCapability = "6.1"; # GTX 1060 (Pascal)
#   my.ai.cudaCapability = "8.6"; # RTX 3070 (Ampere)
#
# Two kinds of tools live here:
# - nixpkgs-native (ollama, whisper.cpp, piper): built by Nix, CUDA kernels
#   compiled for nixpkgs.config.cudaCapabilities.
# - pip-managed web UIs (ComfyUI, A1111, Applio, Coqui): ./lib.nix runs them
#   in an FHS env with their own venv under `my.ai.dataDir`. Not packaged
#   natively on purpose: nixpkgs' comfyui pins torch to CUDA 13, which has no
#   Pascal kernels, and building torch from source per host takes hours. The
#   prebuilt PyTorch wheels from `my.ai.torchIndexUrl` cover both GPUs.
{
  config,
  lib,
  ...
}: let
  cfg = config.my.ai;
in {
  imports = [
    ./ollama.nix
    ./comfyui.nix
    ./automatic1111.nix
    ./stt.nix
    ./tts.nix
    ./voice-changer.nix
    ./open-webui.nix
    ./odysseus.nix
  ];

  options.my.ai = {
    enable = lib.mkEnableOption "the local AI stack" // {default = true;}; # toggle, see ../profiles.nix

    user = lib.mkOption {
      type = lib.types.str;
      default = "maike";
      description = "User that runs the AI services (as systemd user units).";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.users.users.${cfg.user}.home}/.local/share/ai";
      description = ''
        Root for the pip-managed tools: git checkouts, venvs and the shared
        uv/HuggingFace caches (models you download yourself go to
        modelsDir). Keep it on one Linux filesystem (not NTFS): uv hardlinks
        wheels from its cache, so torch is stored once for all venvs.
      '';
    };

    modelsDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.users.users.${cfg.user}.home}/AI/models";
      description = ''
        One visible place for downloaded models, shared by the tools:
        checkpoints/, loras/, vae/, ... (ComfyUI's folder names, which
        A1111 is pointed at too), plus piper/ and whisper/ for speech.
      '';
    };

    outputsDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.users.users.${cfg.user}.home}/AI/outputs";
      description = "Where generated images/videos end up (one subfolder per tool).";
    };

    cudaCapability = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "8.6";
      description = "CUDA compute capability of this host's NVIDIA GPU (nvidia-smi --query-gpu=compute_cap --format=csv).";
    };

    legacyGpu = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      default = cfg.cudaCapability != null && lib.versionOlder cfg.cudaCapability "7.5";
      description = ''
        Pre-Turing GPU (Maxwell/Pascal/Volta). CUDA 13 and the PyTorch cu128+
        wheels have no kernels for these, so they need the CUDA 12.6 builds.
      '';
    };

    torchIndexUrl = lib.mkOption {
      type = lib.types.str;
      # cu126 is the last wheel series with Pascal kernels, and PyTorch 2.14
      # is the last release published for it - the index simply stops there.
      # cu130 is what ComfyUI requires for RTX 20 series and newer.
      default =
        if cfg.legacyGpu
        then "https://download.pytorch.org/whl/cu126"
        else "https://download.pytorch.org/whl/cu130";
      description = "PyTorch wheel index the pip-managed tools install torch from.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.cudaCapability != null;
        message = "my.ai.enable needs my.ai.cudaCapability set for this host.";
      }
    ];

    # nixpkgs builds CUDA code for Turing ("7.5") and newer by default; a
    # Pascal card gets a CUDA backend with no kernels it can run and ollama /
    # whisper.cpp silently fall back to the CPU. Newer GPUs are left on the
    # defaults on purpose, so they keep matching what binary caches build.
    # CUDA 12.x is the last series supporting Pascal; do not move to
    # cudaPackages_13 on such a host.
    # (mkIf around the whole attrset: nixpkgs.config is merged as a plain
    # attrset, so a mkIf nested inside it would be passed through as-is)
    nixpkgs.config = lib.mkIf cfg.legacyGpu {
      cudaCapabilities = [cfg.cudaCapability];
    };
  };
}
