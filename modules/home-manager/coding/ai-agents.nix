# AI agents + tool use (toggle: my.coding.enable, modules/nixos/profiles.nix).
#
# MCP servers are declared once in programs.mcp and shared by Claude Code
# and Zed (enableMcpIntegration) and seeded into Goose's config. They start
# on demand when an agent session uses them; the app-side parts need a
# one-time step each (see the comment per server).
#
# Skills (~/.claude/skills/<name>/SKILL.md) teach Claude Code the local
# CLI tools of this system: ComfyUI, speech, Resolve helpers, Ollama.
{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  enabled = osConfig.my.coding.enable;
  ai = osConfig.my.ai;
  home = config.home.homeDirectory;
  stateDir = "${home}/.local/share/mcp-servers";

  uv = lib.getExe' pkgs.uv "uv";
  uvx = lib.getExe' pkgs.uv "uvx";
  npx = lib.getExe' pkgs.nodejs "npx";
  # npm packages start through `#!/usr/bin/env node`, so node must be on PATH
  nodePath = "${pkgs.nodejs}/bin:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin";

  asepriteMcp = pkgs.fetchFromGitHub {
    owner = "diivi";
    repo = "aseprite-mcp";
    rev = "90d1696a7e41edff89bbd0823ae6a5f86c114bcc";
    hash = "sha256-BnLBEhc5IpTh6ph5l4g0qgTN5KRS0Xf0pEcnox0EWjA=";
  };
  resolveMcp = pkgs.fetchFromGitHub {
    owner = "samuelgursky";
    repo = "davinci-resolve-mcp";
    rev = "53f8fc91524c71c19b28fceeafe7693eca8121e3";
    hash = "sha256-D8FDJ+CFOzTzYlgWAs0M9dm4mEs1fRAfFRxmGf3dfM4=";
  };
  bevyBrpMcp = pkgs.callPackage ../../../packages/bevy-brp-mcp.nix {};

  # Some servers write next to their own code (venv, logs), which the store
  # forbids: run them from a writable copy in ${stateDir}/<name>, refreshed
  # whenever the pinned source changes.
  fromSrc = name: src: cmd:
    toString (pkgs.writeShellScript "mcp-${name}" ''
      dir="${stateDir}/${name}"
      if [ "$(cat "$dir/.nix-src" 2>/dev/null)" != "${src}" ]; then
        rm -rf "$dir" && mkdir -p "$dir"
        cp -r --no-preserve=mode ${src}/. "$dir/"
        echo "${src}" > "$dir/.nix-src"
      fi
      cd "$dir"
      ${cmd}
    '');
  # the Resolve server and its bridge installer share one cached uv env
  resolveRun = ''${uv} run --no-project --python 3.12 --with-requirements "$dir/requirements.txt" python'';

  servers = {
    # Blender: one-time `blender-mcp-install-addon`, then in Blender the
    # "BlenderMCP" panel (N sidebar) -> Connect.
    blender = {
      command = uvx;
      args = ["blender-mcp"];
    };
    # Godot: launches the editor/projects, reads debug output, edits scenes.
    godot = {
      command = npx;
      args = ["-y" "@coding-solo/godot-mcp"];
      env = {
        GODOT_PATH = lib.getExe pkgs.godot;
        PATH = nodePath;
      };
    };
    # Aseprite: pixel art and sprite animation through Aseprite's batch mode.
    aseprite = {
      command = fromSrc "aseprite" asepriteMcp ''exec ${uv} run --frozen --directory "$dir" -m aseprite_mcp'';
      env.ASEPRITE_PATH = lib.getExe pkgs.aseprite;
    };
    # Bevy (0.19): inspect/modify a running game over the Bevy Remote
    # Protocol. The game needs bevy_brp_extras (or RemotePlugin +
    # RemoteHttpPlugin).
    bevy.command = lib.getExe bevyBrpMcp;
    # Reaper: tracks, MIDI, FX, markers via python-reapy. One-time: start
    # Reaper, then run `reaper-mcp-setup` (enables reapy's bridge), restart Reaper.
    reaper = {
      command = uvx;
      args = ["reaper-mcp"];
    };
    # DaVinci Resolve: free 21.0.x only through the in-app bridge (one-time
    # `resolve-mcp-bridge-install`, then in Resolve: Workspace > Scripts >
    # resolve_bridge). Resolve 21.1+ free moved Python scripting to Studio;
    # Studio can use external scripting directly.
    # (the Resolve scripting bridge fails to load on Python 3.13+)
    davinci-resolve.command = fromSrc "davinci-resolve" resolveMcp ''exec ${resolveRun} "$dir/src/server.py"'';
    # Browser automation (web apps, docs, forms) with nixpkgs' Chromium.
    playwright = {
      command = npx;
      args = ["-y" "@playwright/mcp@latest" "--executable-path" (lib.getExe pkgs.chromium)];
      env.PATH = nodePath;
    };
  };

  # Goose keeps provider settings in the same YAML file it rewrites itself,
  # so the extensions are merged in at activation instead of symlinking it.
  gooseExtensions = pkgs.writeText "goose-extensions.json" (builtins.toJSON (
    lib.mapAttrs (name: s: {
      inherit name;
      type = "stdio";
      enabled = true;
      cmd = s.command;
      args = s.args or [];
      envs = s.env or {};
      timeout = 300;
    })
    servers
  ));
  gooseMerge = pkgs.writers.writePython3 "goose-merge-extensions" {libraries = [pkgs.python3Packages.pyyaml];} ''
    import json
    import os
    import sys

    import yaml

    path = os.path.expanduser("~/.config/goose/config.yaml")
    cfg = {}
    if os.path.exists(path):
        with open(path) as f:
            cfg = yaml.safe_load(f) or {}
    with open(sys.argv[1]) as f:
        managed = json.load(f)
    exts = cfg.setdefault("extensions", {})
    for name, ext in managed.items():
        # keep the user's on/off choice for already known extensions
        enabled = exts.get(name, {}).get("enabled", ext["enabled"])
        exts[name] = dict(ext, enabled=enabled)
    # local model by default; change with `goose configure`
    cfg.setdefault("GOOSE_PROVIDER", "ollama")
    cfg.setdefault("GOOSE_MODEL", "qwen2.5-coder:7b")
    cfg.setdefault("OLLAMA_HOST", "http://127.0.0.1:11434")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        yaml.safe_dump(cfg, f, sort_keys=False)
  '';
in {
  config = lib.mkIf enabled {
    programs.mcp = {
      enable = true;
      inherit servers;
    };

    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true;
      skills = {
        comfyui-local = ''
          ---
          name: comfyui-local
          description: Generate images or video with the local ComfyUI (GPU) on this NixOS machine via its HTTP API. Use when asked to create/generate an image, sprite, texture, concept art or video locally.
          ---
          # Local ComfyUI

          - Server: http://127.0.0.1:${toString ai.comfyui.port}. Check with
            `curl -s 127.0.0.1:${toString ai.comfyui.port}/system_stats`; if it isn't up, start it with
            `systemctl --user start comfyui` and wait until that URL answers
            (first start installs for several minutes).
          - Models: ${ai.modelsDir}/<type>/ (checkpoints, loras, vae,
            diffusion_models, text_encoders, upscale_models). List installed
            checkpoints: `curl -s 127.0.0.1:${toString ai.comfyui.port}/object_info/CheckpointLoaderSimple`.
          - Outputs land in ${ai.outputsDir}/comfyui/.
          - Queue a job: POST an API-format workflow to /prompt as
            `{"prompt": <workflow>}`, then poll `/history/<prompt_id>` until it
            has outputs. Build the workflow from the standard txt2img graph
            (CheckpointLoaderSimple -> CLIPTextEncode x2 -> EmptyLatentImage ->
            KSampler -> VAEDecode -> SaveImage) using an installed checkpoint;
            workflows exported via "Save (API)" in the UI work as-is.
          - GPU: GTX 1060 6 GB on the PC (SD1.5 512px fast, SDXL 1024px slow;
            keep batch size 1). If VRAM is full, `ollama stop <model>` first.
        '';
        local-speech = ''
          ---
          name: local-speech
          description: Local text-to-speech, voice cloning and speech-to-text on this machine (piper, Coqui XTTS, whisper.cpp). Use when asked to read text aloud, create voice-over audio, clone a voice, or transcribe audio/video.
          ---
          # Local speech tools

          - Speak / TTS (fast, CPU): `piper-say 'text' [voice]` plays it;
            `echo 'text' | piper -m <voice> -f out.wav` writes a file. Voices
            download by name into ${ai.modelsDir}/piper (e.g.
            en_US-lessac-high, de_DE-thorsten-high, en_GB-alba-medium).
          - Voice cloning (XTTS-v2, GPU): `coqui-tts --model_name
            tts_models/multilingual/multi-dataset/xtts_v2 --speaker_wav ref.wav
            --language_idx en --text '...' --out_path out.wav`. Only clone
            voices the user has permission to use.
          - Transcribe (GPU): convert first `ffmpeg -i in.mp4 -ar 16000 -ac 1
            in.wav`, then `whisper-cli -m ${ai.modelsDir}/whisper/ggml-large-v3-turbo.bin
            -l auto -f in.wav` (add `-osrt` for subtitles). Download the model
            once with `cd ${ai.modelsDir}/whisper && whisper-cpp-download-ggml-model large-v3-turbo`.
        '';
        resolve-media = ''
          ---
          name: resolve-media
          description: Prepare footage for and deliver renders from DaVinci Resolve (free) on Linux. Use when the user wants to import H.264/H.265 (e.g. Nikon ZR, phone) clips into Resolve, or turn a Resolve render into an upload-ready MP4, including HDR (HLG/PQ).
          ---
          # Resolve helpers

          The free Resolve on Linux can neither decode nor encode H.264/H.265.
          - Import: `resolve-transcode <clips|dir> [-o outdir]` makes DNxHR
            (HQX 10-bit for 10-bit sources, HDR tags kept). Or drop clips into
            ~/Videos/Resolve-Ingest/ (auto, results in transcoded/).
          - Deliver: render a DNxHR HQX/ProRes master from Resolve, then
            `resolve-deliver <master> [-o dir] [--sdr|--hdr] [--h265]`: SDR ->
            H.264, HLG/PQ masters -> 10-bit HDR H.265 (auto-detected from the
            colour tags), GPU encoded. Or render into ~/Videos/Resolve-Exports/
            (auto, results in delivery/).
          - Logs: `journalctl --user -u resolve-ingest -u resolve-export`.
        '';
        local-llm = ''
          ---
          name: local-llm
          description: Use or manage the local Ollama LLM server on this machine. Use when asked to run something with a local model, compare local models, or when VRAM must be freed for other GPU work.
          ---
          # Local LLMs (Ollama)

          - API http://127.0.0.1:11434 (OpenAI-compatible under /v1). Runs as
            `systemctl --user` service `ollama`.
          - `ollama list`, `ollama ps` (what is loaded, % on GPU), `ollama run
            <model>`, `ollama pull <model>`, `ollama stop <model>` (frees VRAM;
            models otherwise stay loaded 30 min).
          - PC: GTX 1060 6 GB -> up to ~7-8B models at Q4 fully on the GPU.
            Before ComfyUI/Resolve/Blender GPU work, stop loaded models.
          - Other UIs on the same models: Open WebUI http://127.0.0.1:3000,
            Odysseus http://127.0.0.1:7000.
        '';
      };
    };

    programs.zed-editor.enableMcpIntegration = true;

    home.packages = [
      pkgs.goose-cli
      pkgs.goose-desktop
      # one-time setup helpers for the app side of the MCP servers
      (pkgs.writeShellScriptBin "blender-mcp-install-addon" ''
        exec ${uvx} mcp-for-blender install-addon "$@"
      '')
      (pkgs.writeShellScriptBin "resolve-mcp-bridge-install" ''
        exec ${fromSrc "davinci-resolve" resolveMcp ''exec ${resolveRun} "$dir/scripts/install_resolve_bridge.py" "$@"''} "$@"
      '')
      (pkgs.writeShellScriptBin "reaper-mcp-setup" ''
        # needs Reaper running; enables reapy's "distant API" inside Reaper
        exec ${uvx} --from python-reapy python -c 'import reapy; reapy.configure_reaper()'
      '')
    ];

    home.activation.gooseExtensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${gooseMerge} ${gooseExtensions}
    '';
  };
}
