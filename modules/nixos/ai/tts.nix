# Text-to-speech.
#
# piper (native Nix, CPU): fast, natural voices, faster than real time even
# without a GPU. Voices: https://huggingface.co/rhasspy/piper-voices
# (samples: https://rhasspy.github.io/piper-samples). The wrapper adds a
# default voice and downloads voices by name into ~/AI/models/piper:
#   piper-say 'Hello there'                    # speak with the default voice
#   piper-say 'Hallo Welt' de_DE-thorsten-high # any voice name, fetched once
#   echo 'Hallo' | piper -m de_DE-thorsten-high -f out.wav
#
# coqui-tts / XTTS-v2 (pip-managed, CUDA): zero-shot voice cloning from a
# ~10 s reference clip, 17 languages. Lives in <my.ai.dataDir>/coqui-tts.
#   coqui-tts --model_name tts_models/multilingual/multi-dataset/xtts_v2 \
#     --speaker_wav ref.wav --language_idx de --text 'Hallo' --out_path out.wav
#   coqui-tts server --model_name ...   # small web UI on :5002
#   coqui-tts update
# XTTS-v2 asks once to accept its non-commercial license (CPML) on first use.
# Only clone voices you have permission to use.
#
# VOICEVOX: Japanese character voices with an editor for intonation and
# timing; its engine also serves an HTTP API on :50021 while the app runs.
# CPU inference (nixpkgs ships the CPU onnxruntime), which is plenty for it.
#
# OpenUtau: free UTAU/Vocaloid-style singing synthesis editor. With
# DiffSinger voicebanks it does AI singing; voicebanks are installed from
# inside the app (drag & drop the downloaded .zip).
{
  config,
  lib,
  pkgs,
  ...
}: let
  ai = config.my.ai;
  cfg = ai.tts;
  aiLib = import ./lib.nix {
    inherit pkgs lib;
    cfg = ai;
  };

  voices = "${ai.modelsDir}/piper";
  # piper with a default voice, voices fetched by name on first use, and
  # ffplay on PATH (piper plays audio through it when no -f is given)
  piper = pkgs.writeShellApplication {
    name = "piper";
    runtimeInputs = [pkgs.curl pkgs.ffmpeg];
    text = ''
      data=${lib.escapeShellArg voices}
      mkdir -p "$data"

      fetch() { # <voice name>, e.g. de_DE-thorsten-high
        local name=$1 locale speaker quality url
        [ -f "$data/$name.onnx" ] && return 0
        IFS=- read -r locale speaker quality <<< "$name"
        url="https://huggingface.co/rhasspy/piper-voices/resolve/main/''${locale%%_*}/$locale/$speaker/$quality/$name"
        echo "piper: downloading voice $name" >&2
        curl -fL --progress-bar -o "$data/$name.onnx.json" "$url.onnx.json"
        curl -fL --progress-bar -o "$data/$name.onnx.part" "$url.onnx"
        mv "$data/$name.onnx.part" "$data/$name.onnx"
      }

      model=""
      prev=""
      for a in "$@"; do
        case "$prev" in -m | --model) model=$a ;; esac
        case "$a" in --model=*) model=''${a#*=} ;; esac
        prev=$a
      done
      if [ -z "$model" ]; then
        model=${lib.escapeShellArg cfg.piperVoice}
        set -- -m "$model" "$@"
      fi
      # bare names (no path, no .onnx) are voices from the catalogue
      case "$model" in */* | *.onnx) ;; *) fetch "$model" ;; esac

      exec ${pkgs.piper-tts}/bin/piper --data-dir "$data" "$@"
    '';
  };

  piperSay = pkgs.writeShellApplication {
    name = "piper-say";
    runtimeInputs = [piper];
    text = ''
      if [ $# -lt 1 ]; then
        echo "usage: piper-say <text> [voice]   (default voice: ${cfg.piperVoice})" >&2
        exit 1
      fi
      if [ $# -ge 2 ]; then
        printf '%s\n' "$1" | piper -m "$2"
      else
        printf '%s\n' "$1" | piper
      fi
    '';
  };

  # OpenUtau (Avalonia, X11-only) never draws its main window under mango's
  # built-in XWayland: the X window maps but no frame is ever committed, so
  # mango never shows it (only the splash appears). The same build renders
  # fine on a plain X server and through xwayland-satellite (what niri uses),
  # so on Wayland it gets a private xwayland-satellite, which turns its
  # windows into normal Wayland windows on any compositor.
  openutau = let
    # Not named "OpenUtau": the app counts processes with that name to
    # enforce a single instance, and would see this wrapper and exit.
    runner = pkgs.writeShellScriptBin "openutau-xwayland" ''
      n=20
      while [ -e "/tmp/.X11-unix/X$n" ] || [ -e "/tmp/.X$n-lock" ]; do n=$((n + 1)); done
      ${lib.getExe pkgs.xwayland-satellite} ":$n" >/dev/null 2>&1 &
      satellite=$!
      trap 'kill "$satellite" 2>/dev/null' EXIT
      for _ in $(seq 100); do [ -S "/tmp/.X11-unix/X$n" ] && break; sleep 0.1; done
      DISPLAY=":$n" ${pkgs.openutau}/bin/OpenUtau "$@"
    '';
    launcher = pkgs.writeShellScriptBin "OpenUtau" ''
      if [ -z "''${WAYLAND_DISPLAY-}" ]; then
        exec ${pkgs.openutau}/bin/OpenUtau "$@"
      fi
      exec ${lib.getExe runner} "$@"
    '';
  in
    # launcher first: symlinkJoin keeps the first bin/OpenUtau it sees; the
    # .desktop entry runs OpenUtau from PATH, so the app menu uses it too
    pkgs.symlinkJoin {
      name = "openutau-${pkgs.openutau.version}";
      paths = [launcher pkgs.openutau];
    };

  coqui = aiLib.mkLauncher {
    name = "coqui-tts";
    script = ''
      venv=${lib.escapeShellArg "${ai.dataDir}/coqui-tts/venv"}
      mkdir -p "$(dirname "$venv")"

      if [ "''${1-}" = update ]; then
        shift
        rm -f "$venv/.setup-stamp"
        export AI_UPGRADE=1
      fi
      # coqui-tts accepts any transformers >= 4.57 but breaks on 5.x
      # (removed isin_mps_friendly); [codec] adds torchcodec, which newer
      # torchaudio needs to load the reference clips
      reqs="$(dirname "$venv")/requirements.txt"
      printf '%s\n' 'coqui-tts[server,codec]' 'transformers<5' > "$reqs"
      if ai_needs_setup "$venv/.setup-stamp" "$TORCH_INDEX" "$reqs"; then
        ai_venv "$venv" 3.12
        ai_torch "$venv" torch torchaudio
        ai_reqs "$venv" "$reqs"
        ai_setup_done "$venv/.setup-stamp" "$TORCH_INDEX" "$reqs"
      fi

      export TTS_HOME=${lib.escapeShellArg "${ai.modelsDir}/coqui"} # downloaded voices/models

      cmd=tts
      if [ "''${1-}" = server ]; then
        cmd=tts-server
        shift
      fi
      exec "$venv/bin/$cmd" "$@"
    '';
  };
in {
  options.my.ai.tts = {
    enable = lib.mkEnableOption "text-to-speech (piper, Coqui XTTS)" // {default = ai.enable;};

    piperVoice = lib.mkOption {
      type = lib.types.str;
      default = "en_US-lessac-high";
      example = "de_DE-thorsten-high";
      description = "Default piper voice (name from https://huggingface.co/rhasspy/piper-voices).";
    };

    voicevox = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Install VOICEVOX (unfree; built locally on first rebuild).";
    };

    singing = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Install OpenUtau for singing synthesis.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      [
        piper
        piperSay
        coqui
      ]
      ++ lib.optional cfg.voicevox pkgs.voicevox
      ++ lib.optional cfg.singing openutau;
  };
}
