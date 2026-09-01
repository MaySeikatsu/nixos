#!/usr/bin/env sh

# Toggles niri's blur, animations and window opacity off/on.
#
# Mechanism: config.kdl has `include optional=true "effects-toggle.kdl"` at
# the end. Optional includes are still watched for changes (and for
# appearing/disappearing), so writing or removing this file makes niri
# hot-reload on its own - no reload command needed. The file itself is not
# managed by home-manager (unlike the rest of ~/.config/niri/*.kdl, which
# are read-only store symlinks), so it's free to be rewritten at runtime.

TOGGLE_FILE="$HOME/.config/niri/effects-toggle.kdl"

if [ -f "$TOGGLE_FILE" ]; then
	rm -f "$TOGGLE_FILE"
	notify-send "niri" "Effects: on" 2>/dev/null
else
	cat >"$TOGGLE_FILE" <<'EOF'
// Written by niri_toggle_effects.sh - delete this file (or press the bind
// again) to restore blur/animations/opacity to their normal config.kdl
// values.
blur {
    off
}
animations {
    off
}
window-rule {
    opacity 1.0
}
EOF
	notify-send "niri" "Effects: off" 2>/dev/null
fi
