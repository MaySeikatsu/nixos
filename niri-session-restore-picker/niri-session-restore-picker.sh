#!/usr/bin/env bash
# niri-session-restore-picker
#
# Interactive front-end for niri-session-restore
# (https://github.com/MaySeikatsu/niri-session-restore): pick a saved
# session file, pick which of its workspaces to actually restore, then hand
# a filtered copy of that JSON to `niri-session-manage --load`.
#
# Meant to run inside a small floating terminal (see ../ressources/dots/niri
# for the niri window-rule + keybind that wire this up in the nixos config
# this currently lives in). Any extra CLI arguments given to this script are
# forwarded to `niri-session-manage --load` verbatim (e.g. --debug).
set -euo pipefail

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "error: required command '$1' not found in PATH" >&2
    exit 1
  }
}
for cmd in jq fzf niri-session-manage notify-send; do
  require "$cmd"
done

notify() {
  notify-send "niri-session-restore-picker" "$1" 2>/dev/null || true
}

die() {
  echo "error: $*" >&2
  notify "$*"
  read -rp "Press Enter to close..." _ || true
  exit 1
}

# Mirrors niri-session-manage's own directory resolution priority
# (env var -> [session].default_session_dir in config -> built-in default),
# just enough of it to know where to look for files to list.
resolve_session_dir() {
  if [[ -n "${NIRI_SESSION_DIR:-}" ]]; then
    printf '%s\n' "${NIRI_SESSION_DIR/#\~/$HOME}"
    return
  fi

  local conf="${XDG_CONFIG_HOME:-$HOME/.config}/niri-session/niri-session.conf"
  if [[ -f "$conf" ]]; then
    local dir
    dir=$(awk '
      /^\[session\]/ { in_session=1; next }
      /^\[/          { in_session=0 }
      in_session && $0 ~ /^[[:space:]]*default_session_dir[[:space:]]*=/ {
        sub(/^[^=]*=[[:space:]]*/, "")
        gsub(/^"|"$/, "")
        print
      }
    ' "$conf")
    if [[ -n "$dir" ]]; then
      printf '%s\n' "${dir/#\~/$HOME}"
      return
    fi
  fi

  printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/niri-session/sessions"
}

session_dir="$(resolve_session_dir)"
[[ -d "$session_dir" ]] || die "no session directory at $session_dir (nothing saved yet?)"

mapfile -t session_files < <(
  find "$session_dir" -maxdepth 1 -type f \( -name '*.json' -o -name 'last' \) -printf '%T@ %p\n' 2>/dev/null \
    | sort -rn \
    | cut -d' ' -f2-
)
[[ ${#session_files[@]} -gt 0 ]] || die "no saved sessions in $session_dir yet (run niri-session-manage --save first)"

# --- Step 1: pick a session file -------------------------------------------------

declare -a display_lines=()
declare -A path_by_display=()
for f in "${session_files[@]}"; do
  base="$(basename "$f")"
  win_count="$(jq -r '.windows | length' "$f" 2>/dev/null || echo '?')"
  mtime="$(date -r "$f" '+%Y-%m-%d %H:%M' 2>/dev/null || echo '?')"
  line="$base  —  $win_count window(s), saved $mtime"
  display_lines+=("$line")
  path_by_display["$line"]="$f"
done

chosen_display="$(
  printf '%s\n' "${display_lines[@]}" \
    | fzf --prompt="restore which session file? > " \
          --header=$'Enter: pick this file    Esc: cancel'
)" || { notify "cancelled"; exit 0; }
[[ -n "$chosen_display" ]] || { notify "cancelled"; exit 0; }
chosen_file="${path_by_display[$chosen_display]}"

# --- Step 2: pick which workspaces from that file to restore ---------------------

mapfile -t ws_rows < <(
  jq -r '
    . as $root
    | ($root.workspaces // []) as $wsmeta
    | ([$root.windows[] | {output, workspace_idx}] | unique | sort_by(.output, .workspace_idx))[]
    | . as $key
    | (([$wsmeta[]? | select(.output == $key.output and .idx == $key.workspace_idx) | .name][0]) // "-") as $name
    | ([$root.windows[] | select(.output == $key.output and .workspace_idx == $key.workspace_idx) | (.app_id // .title // "?")] | join(", ")) as $apps
    | "\($key.output)\t\($key.workspace_idx)\t[\($key.output) ws\($key.workspace_idx)] \($name) — \($apps)"
  ' "$chosen_file"
)
[[ ${#ws_rows[@]} -gt 0 ]] || die "$chosen_file has no windows to restore"

selection="$(
  printf '%s\n' "${ws_rows[@]}" \
    | fzf --multi \
          --delimiter=$'\t' \
          --with-nth=3 \
          --prompt="restore which workspaces? > " \
          --header=$'TAB: toggle    Ctrl-A: select all    Enter: restore selection    Esc: cancel' \
          --bind='ctrl-a:select-all'
)" || { notify "cancelled"; exit 0; }
[[ -n "$selection" ]] || { notify "nothing selected, cancelled"; exit 0; }

keys_json="$(
  echo "$selection" \
    | awk -F'\t' '{printf "{\"output\":%s,\"workspace_idx\":%s}\n", "\""$1"\"", $2}' \
    | jq -s '.'
)"

# --- Step 3: filter the session down to the selected workspaces and restore ------

tmp_session="$(mktemp --suffix=.json)"
trap 'rm -f "$tmp_session"' EXIT

jq --argjson keys "$keys_json" '
  .windows |= [
    .[]
    | . as $w
    | select(any($keys[]; .output == $w.output and .workspace_idx == $w.workspace_idx))
  ]
' "$chosen_file" > "$tmp_session"

count="$(jq '.windows | length' "$tmp_session")"
[[ "$count" -gt 0 ]] || die "filtered selection ended up with 0 windows — nothing to restore"

notify "restoring $count window(s)..."
if niri-session-manage --load "$tmp_session" "$@"; then
  notify "restore finished"
else
  status=$?
  notify "restore finished with errors (exit $status) — see terminal"
  read -rp "Press Enter to close..." _ || true
  exit "$status"
fi
