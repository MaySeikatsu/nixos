# AI typing help in every text field, through Fcitx5 (which this config
# already runs for Japanese input). Toggle: my.inputAssist.enable
# (modules/nixos/profiles.nix).
#
# XType: inline autocomplete. A small local model (Ollama, qwen2.5:1.5b)
#   continues your sentence as grey ghost text: Tab = next word,
#   Shift+Tab = whole suggestion, Esc = dismiss.
#   Enable once: `fcitx5-configtool` -> add "XType" to the input methods, then
#   switch to it like a keyboard layout (Ctrl+Space by default). It types
#   plain English/German letters, so it can stay active for normal typing.
#   Settings: ~/.config/xtype/config.toml (model, speed, per-app overrides);
#   logs: ~/.local/share/xtype/{fcitx5,inference}.log.
#
# fcitx5-vinput: voice input (dictation) into any text field, works next to
#   any input method. Local offline speech recognition (sherpa-onnx) or cloud
#   providers, optional LLM post-processing (punctuation, rewriting, ...).
#   Setup once: open "Vinput" (app menu) -> Resources -> Models -> download +
#   activate a model (e.g. a Whisper/SenseVoice one for German + English).
#   Keys: tap the trigger key to start/stop recording, hold it for
#   push-to-talk; Shift_R opens its command palette. The default trigger
#   Alt_R is AltGr on this keyboard layout (needed for accents), so set
#   another one in fcitx5-configtool -> Addons -> Vinput -> Trigger Key.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.my.inputAssist;
  ollama = config.my.ai.ollama;
  xtype = pkgs.callPackage ../../../packages/xtype-fcitx5.nix {};
  xtypeModel = "qwen2.5:1.5b";
  vinput = inputs.fcitx5-vinput.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  options.my.inputAssist = {
    xtype.enable =
      lib.mkEnableOption "XType inline AI autocomplete"
      // {default = cfg.enable;};
    vinput.enable =
      lib.mkEnableOption "fcitx5-vinput voice input"
      // {default = cfg.enable;};
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.vinput.enable) {
      i18n.inputMethod.fcitx5.addons = [vinput];
      environment.systemPackages = [vinput]; # `vinput` CLI + Vinput settings app
      # the package's own user unit + D-Bus activation (store paths, not /usr)
      systemd.packages = [vinput];
      services.dbus.packages = [vinput];
      systemd.user.services.vinput-daemon.wantedBy = ["default.target"];
    })
    (lib.mkIf (cfg.enable && cfg.xtype.enable) {
      assertions = [
        {
          assertion = ollama.enable;
          message = "XType (my.inputAssist.xtype) needs Ollama: enable my.ai / my.ai.ollama.";
        }
      ];

      i18n.inputMethod.fcitx5.addons = [xtype];

      # One-time setup per user, after Ollama is up: pull XType's model and seed
      # a config that keeps suggestions out of terminals and password managers.
      # Existing configs are never overwritten.
      systemd.user.services.xtype-setup = {
        description = "Prepare XType (model + starter config)";
        wantedBy = ["default.target"];
        after = ["ollama.service"];
        wants = ["ollama.service"];
        unitConfig.ConditionUser = config.my.ai.user;
        serviceConfig.Type = "oneshot";
        script = ''
          conf="$HOME/.config/xtype/config.toml"
          if [ ! -e "$conf" ]; then
            mkdir -p "$(dirname "$conf")"
            cat > "$conf" <<'EOF'
          # Starter config from the NixOS module; all keys are optional, see
          # https://github.com/KS0Code/XType#5-configuration
          [inference]
          model = "${xtypeModel}"

          [behaviour]
          # no ghost text in terminals and password managers
          blocklist_apps = ["foot", "ghostty", "kitty", "alacritty", "wezterm", "konsole", "keepassxc", "1password", "bitwarden", "proton-pass"]
          EOF
          fi
          for _ in $(seq 60); do
            ${lib.getExe ollama.package} list >/dev/null 2>&1 && break
            sleep 2
          done
          ${lib.getExe ollama.package} list | grep -q '^${xtypeModel} ' \
            || ${lib.getExe ollama.package} pull ${xtypeModel}
        '';
      };
    })
  ];
}
