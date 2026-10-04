# Helpers for the pip-managed AI tools. Not a module: import it with
#   aiLib = import ./lib.nix {inherit pkgs lib; cfg = config.my.ai;};
#
# mkLauncher wraps a bash script in an FHS env, because manylinux wheels
# (torch, onnxruntime, ...) expect a regular /usr/lib. The FHS env's
# ld.so.conf already includes /run/opengl-driver/lib, so torch finds the
# driver's libcuda.so.1 without any LD_LIBRARY_PATH juggling.
{
  pkgs,
  lib,
  cfg,
}: let
  # Shell functions available to every launcher script.
  preamble = ''
    set -euo pipefail

    # One cache for all tools, on the same filesystem as the venvs, so uv
    # hardlinks packages instead of copying them (torch alone is ~3 GB).
    export UV_CACHE_DIR=${lib.escapeShellArg "${cfg.dataDir}/.cache/uv"}
    # uv downloads standalone CPython builds (A1111 still needs 3.10, which
    # nixpkgs dropped); nix pythons are not meant for pip-managed venvs.
    export UV_PYTHON_INSTALL_DIR=${lib.escapeShellArg "${cfg.dataDir}/.python"}
    export UV_PYTHON_PREFERENCE=only-managed
    export PIP_CACHE_DIR=${lib.escapeShellArg "${cfg.dataDir}/.cache/pip"}
    export HF_HOME=${lib.escapeShellArg "${cfg.dataDir}/.cache/huggingface"}
    # uv's standalone CPython looks for CA certs in its own build prefix, not
    # NixOS' /etc/ssl: without this any HTTPS from Python (model downloads,
    # ComfyUI-Manager) fails with CERTIFICATE_VERIFY_FAILED
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    export REQUESTS_CA_BUNDLE=$SSL_CERT_FILE
    TORCH_INDEX=${lib.escapeShellArg cfg.torchIndexUrl}

    log() { printf '\e[1;35m[%s]\e[0m %s\n' "$APP" "$*" >&2; }

    # ai_clone <url> <dir> [branch]
    ai_clone() {
      if [ ! -d "$2/.git" ]; then
        log "cloning $1"
        git clone ''${3:+--branch "$3"} "$1" "$2"
      fi
    }

    # ai_venv <dir> <python-version>; --seed adds pip for tools that call it
    ai_venv() {
      [ -x "$1/bin/python" ] || uv venv --seed --python "$2" "$1"
    }

    # ai_torch <venv> <packages...>: torch from this GPU's wheel index, then
    # pin it so later requirement installs can't swap in a PyPI build (which
    # targets CUDA 13 and has no Pascal kernels).
    ai_torch() {
      local venv=$1; shift
      uv pip install --python "$venv/bin/python" ''${AI_UPGRADE:+--upgrade} "$@" --index-url "$TORCH_INDEX"
      uv pip freeze --python "$venv/bin/python" \
        | grep -E '^(torch|torchvision|torchaudio)==' > "$venv/torch-constraints.txt"
    }

    # ai_reqs <venv> <requirements files...>: missing files are skipped
    ai_reqs() {
      local venv=$1; shift
      for r in "$@"; do
        [ -f "$r" ] || continue
        log "installing $r"
        uv pip install --python "$venv/bin/python" ''${AI_UPGRADE:+--upgrade} -r "$r" \
          --constraint "$venv/torch-constraints.txt" \
          --extra-index-url "$TORCH_INDEX" --index-strategy unsafe-best-match
      done
    }

    # `<tool> update` sets AI_UPGRADE=1 so the installs above also upgrade.

    # ai_needs_setup <stamp> <key> <files...>: true when the key or any of
    # the files changed since ai_setup_done last ran with the same arguments.
    # (cat only with files given: a bare `cat` would wait on the terminal)
    ai_hash() { { printf '%s\n' "$2"; [ $# -lt 3 ] || cat "''${@:3}" 2>/dev/null || true; } | sha256sum | cut -d' ' -f1; }
    ai_needs_setup() { [ "$(cat "$1" 2>/dev/null)" != "$(ai_hash "$@")" ]; }
    ai_setup_done() { ai_hash "$@" > "$1"; }
  '';
in {
  mkLauncher = {
    name,
    script,
  }:
    pkgs.buildFHSEnv {
      inherit name;
      targetPkgs = p:
        with p; [
          bash
          coreutils
          gnugrep
          git
          git-lfs
          uv
          curl
          wget
          which
          pciutils # A1111's webui.sh probes the GPU with lspci
          bc # ...and compares the glibc version with bc
          procps
          # some requirements only ship sdists and compile on install
          gcc
          gnumake
          cmake
          pkg-config
          stdenv.cc.cc.lib # libstdc++ for nearly every wheel
          zlib
          zstd
          xz
          bzip2
          libffi
          openssl
          glib
          libGL # opencv
          libglvnd
          # opencv-python (the non-headless build custom nodes pull in) links X11
          libxcb
          libx11
          libxext
          libsm
          libice
          ffmpeg # torchaudio/torchcodec, video nodes, audio tools
          ffmpeg.lib
          portaudio # sounddevice (Applio realtime)
          libsndfile # soundfile
          sox
          espeak-ng # phonemizer for TTS models
          gperftools # tcmalloc, picked up by A1111 to curb memory growth
        ];
      runScript = pkgs.writeShellScript "${name}-run" ''
        APP=${name}
        ${preamble}
        ${script}
      '';
    };

  # A systemd *user* unit for a launcher. Not started automatically: these
  # web UIs keep a CUDA context (and on the laptop the dGPU awake) for as
  # long as they run. Start with `systemctl --user start <name>`.
  mkUserService = {
    description,
    launcher,
  }: {
    inherit description;
    unitConfig.ConditionUser = cfg.user;
    serviceConfig = {
      ExecStart = "${launcher}/bin/${launcher.name}";
      # first start installs several GB of wheels
      TimeoutStartSec = "infinity";
    };
  };
}
