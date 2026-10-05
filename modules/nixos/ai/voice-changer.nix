# Applio: RVC voice conversion (speech or singing into a target voice),
# model training from your own recordings, TTS->RVC and a realtime voice
# changer. Web UI on http://127.0.0.1:6969.
#
#   applio                         run in the foreground (first run installs)
#   applio update                  git pull + reinstall requirements
#   systemctl --user start applio  same, in the background
#
# Lives in <my.ai.dataDir>/applio. Voice models (.pth + .index) go to
# Applio/logs/<name>/ or are downloaded from the UI. Training works on the
# GTX 1060 but is slow; inference is fine on both GPUs. Only convert/train
# voices you have permission to use.
{
  config,
  lib,
  pkgs,
  ...
}: let
  ai = config.my.ai;
  cfg = ai.voiceChanger;
  aiLib = import ./lib.nix {
    inherit pkgs lib;
    cfg = ai;
  };

  launcher = aiLib.mkLauncher {
    name = "applio";
    script = ''
      root=${lib.escapeShellArg "${ai.dataDir}/applio"}
      src="$root/Applio"
      venv="$root/venv"
      mkdir -p "$root"

      ai_clone https://github.com/IAHispano/Applio.git "$src"
      if [ "''${1-}" = update ]; then
        shift
        git -C "$src" pull --ff-only
        rm -f "$venv/.setup-stamp"
      fi

      # Applio pins torch==2.11.0 itself; `==2.11.0` also matches the
      # 2.11.0+cu126/+cu130 builds on this GPU's index, which win over PyPI's
      # because local versions sort higher (the same trick its installer
      # uses with cu128 - which has no Pascal kernels).
      if ai_needs_setup "$venv/.setup-stamp" "$TORCH_INDEX" "$src/requirements.txt"; then
        ai_venv "$venv" 3.12
        uv pip install --python "$venv/bin/python" -r "$src/requirements.txt" python-ffmpeg \
          --extra-index-url "$TORCH_INDEX" --index-strategy unsafe-best-match
        ai_setup_done "$venv/.setup-stamp" "$TORCH_INDEX" "$src/requirements.txt"
      fi

      cd "$src"
      exec "$venv/bin/python" app.py --server-name 127.0.0.1 --port ${toString (aiLib.backendPort cfg.port)} "$@"
    '';
  };
in {
  options.my.ai.voiceChanger = {
    enable = lib.mkEnableOption "Applio (RVC voice conversion)" // {default = ai.enable;};

    port = lib.mkOption {
      type = lib.types.port;
      default = 6969;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [launcher];
    systemd.user = aiLib.mkWebService {
      name = "applio";
      description = "Applio RVC voice conversion";
      inherit launcher;
      inherit (cfg) port;
    };
  };
}
