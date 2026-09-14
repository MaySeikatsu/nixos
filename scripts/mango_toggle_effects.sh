#!/usr/bin/env sh

# Toggles mango's blur, animations and window opacity off/on.
# Mango counterpart of niri_toggle_effects.sh (bound to Super+Shift+V).
#
# Mechanism: unlike niri there's no optional include to write, but mango has
# a `setoption` dispatcher that changes any config key at runtime without a
# reload. It's stateless, so a marker file in $XDG_RUNTIME_DIR remembers
# which way we last flipped. The "on" values must match config.conf; a
# `reload_config` (Super+Shift+Escape) also restores them and clears the state.

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="$STATE_DIR/mango-effects-off"

set_opt() {
	mmsg dispatch "setoption,$1,$2"
}

if [ -f "$STATE_FILE" ]; then
	# --- on: values from ~/.config/mango/config.conf ---
	set_opt blur 1
	set_opt blur_layer 1
	set_opt shadows 1
	set_opt animations 1
	set_opt layer_animations 1
	set_opt focused_opacity 0.96
	set_opt unfocused_opacity 0.90
	rm -f "$STATE_FILE"
	notify-send "mango" "Effects: on" 2>/dev/null
else
	set_opt blur 0
	set_opt blur_layer 0
	set_opt shadows 0
	set_opt animations 0
	set_opt layer_animations 0
	set_opt focused_opacity 1.0
	set_opt unfocused_opacity 1.0
	touch "$STATE_FILE"
	notify-send "mango" "Effects: off" 2>/dev/null
fi
