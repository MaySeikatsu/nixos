#!/usr/bin/env bash
# niri-session-restore-picker
#
# Interactive front-end for niri-session-restore
# (https://github.com/MaySeikatsu/niri-session-restore). Opened via
# Mod+Shift+R, it offers:
#
#   - Restore a saved session: pick a saved session file (autosaves and
#     named presets alike, newest first, with a live layout preview),
#     pick which of its workspaces to actually restore, then hand a
#     filtered copy of that JSON to `niri-session-manage --load`.
#   - Backup current session as a new preset: snapshot what's open right
#     now under a name you choose, so it shows up alongside the autosaves
#     next time you restore.
#   - Rename a saved session: rename any saved file/preset in place.
#
# Presets are just named files in the same session directory the
# autosaves (`session.json`, `last`) already live in -- no separate
# storage, so they show up in the same restore list.
#
# Meant to run inside a small floating terminal (see ../ressources/dots/niri
# for the niri window-rule + keybind that wire this up in the nixos config
# this currently lives in). Any extra CLI arguments given to this script are
# forwarded to `niri-session-manage --load` verbatim (e.g. --debug) when
# restoring.
set -euo pipefail

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "error: required command '$1' not found in PATH" >&2
    exit 1
  }
}

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

# Shell-quote a string for safe embedding in a --preview=... command string
# (fzf runs those through `sh -c`, so this needs to be POSIX-safe, not just
# bash-safe -- hence hand-rolled instead of printf %q).
shq() {
  printf "'%s'" "${1//\'/\'\\\'\'}"
}

# Repeat a (possibly multi-byte) character N times. Not `tr`: GNU tr works
# byte-wise on its char sets, so it mangles multi-byte UTF-8 box-drawing
# characters even under a UTF-8 locale.
hline() {
  local ch="$1" n="$2" s=""
  local i
  for ((i = 0; i < n; i++)); do
    s+="$ch"
  done
  printf '%s' "$s"
}

# --- box-art layout preview --------------------------------------------------
#
# Renders one workspace's tiled windows as stacked column boxes (one box per
# window, boxes in the same column stacked top-to-bottom, columns laid out
# left-to-right) plus a trailing floating-windows note. Mirrors the pane-box
# style our zellij picker (noren) uses for its session previews.

render_workspace() {
  local file="$1" out="$2" idx="$3"
  local name
  name="$(jq -r --arg out "$out" --argjson idx "$idx" '
    ([(.workspaces // [])[] | select(.output == $out and .idx == $idx) | .name][0]) // empty
  ' "$file")"
  [[ -n "$name" ]] || name="unnamed"

  printf '  ws%s (%s)\n' "$idx" "$name"

  local grouped
  grouped="$(jq -c --arg out "$out" --argjson idx "$idx" '
    [.windows[] | select(.output == $out and .workspace_idx == $idx and (.is_floating | not))]
    | sort_by(.column, .tile)
    | group_by(.column)
  ' "$file")"

  local -A cell=()
  local -a col_height=() col_width=()
  local c=0
  while IFS= read -r col_json; do
    local -a lines=()
    while IFS= read -r tile_json; do
      local app focused label inner w top mid bot
      app="$(jq -r '.app_id // .title // empty' <<<"$tile_json")"
      [[ -n "$app" ]] || app="?"
      focused="$(jq -r '.was_focused // false' <<<"$tile_json")"
      label="$app"
      (( ${#label} > 14 )) && label="${label:0:13}…"
      if [[ "$focused" == "true" ]]; then
        inner=" $label *"
      else
        inner=" $label "
      fi
      w=${#inner}
      if [[ "$focused" == "true" ]]; then
        top="┏$(hline '━' "$w")┓"
        mid="┃${inner}┃"
        bot="┗$(hline '━' "$w")┛"
      else
        top="┌$(hline '─' "$w")┐"
        mid="│${inner}│"
        bot="└$(hline '─' "$w")┘"
      fi
      lines+=("$top" "$mid" "$bot")
    done < <(jq -c '.[]' <<<"$col_json")

    local block_width=0 ln
    for ln in "${lines[@]}"; do
      (( ${#ln} > block_width )) && block_width=${#ln}
    done
    local r=0
    for ln in "${lines[@]}"; do
      cell["$c,$r"]="$(printf '%-*s' "$block_width" "$ln")"
      ((++r))
    done
    col_height+=("${#lines[@]}")
    col_width+=("$block_width")
    ((++c))
  done < <(jq -c '.[]' <<<"$grouped")

  local num_cols=$c
  if (( num_cols > 0 )); then
    local max_h=0
    for ((c = 0; c < num_cols; c++)); do
      (( col_height[c] > max_h )) && max_h=${col_height[c]}
    done
    local r row cellval
    for ((r = 0; r < max_h; r++)); do
      row=""
      for ((c = 0; c < num_cols; c++)); do
        cellval="${cell[$c,$r]:-}"
        [[ -n "$cellval" ]] || cellval="$(printf '%*s' "${col_width[c]}" '')"
        row+="$cellval "
      done
      printf '  %s\n' "$row"
    done
  fi

  local -a floating=()
  while IFS= read -r label; do
    [[ -n "$label" ]] && floating+=("$label")
  done < <(jq -r --arg out "$out" --argjson idx "$idx" '
    .windows[] | select(.output == $out and .workspace_idx == $idx and .is_floating)
    | (.app_id // .title // "?")
  ' "$file")
  if [[ ${#floating[@]} -gt 0 ]]; then
    local joined
    joined="$(IFS=', '; echo "${floating[*]}")"
    printf '  (floating: %s)\n' "$joined"
  fi

  echo
}

render_session_overview() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "(no such session file)"
    return
  fi
  local niri_version win_count
  niri_version="$(jq -r '.niri_version // "?"' "$file")"
  win_count="$(jq -r '.windows | length' "$file")"
  printf 'niri %s — %s window(s)\n\n' "$niri_version" "$win_count"

  while IFS= read -r out; do
    printf '── %s ──\n' "$out"
    while IFS= read -r idx; do
      render_workspace "$file" "$out" "$idx"
    done < <(jq -r --arg out "$out" '
      [.windows[] | select(.output == $out) | .workspace_idx] | unique | sort | .[]
    ' "$file")
  done < <(jq -r '[.windows[].output] | unique | sort | .[]' "$file")
}

# --- hidden preview subcommands ----------------------------------------------
# Invoked by fzf itself (as the installed `niri-session-restore-picker`
# binary, so this works regardless of how the interactive picker was
# launched) to render the --preview pane. Exits before the interactive
# `require` checks below -- only jq is needed here.

if [[ "${1:-}" == "__preview" ]]; then
  command -v jq >/dev/null 2>&1 || { echo "(jq not found)"; exit 0; }
  render_session_overview "${2:-}"
  exit 0
fi

if [[ "${1:-}" == "__preview-ws" ]]; then
  command -v jq >/dev/null 2>&1 || { echo "(jq not found)"; exit 0; }
  file="${2:-}"
  out="${3:-}"
  idx="${4:-}"
  if [[ ! -f "$file" ]]; then
    echo "(no such session file)"
    exit 0
  fi
  printf '── %s ──\n' "$out"
  render_workspace "$file" "$out" "$idx"
  exit 0
fi

for cmd in jq fzf niri-session-manage notify-send; do
  require "$cmd"
done

sanitize_name() {
  local raw="$1" safe
  safe="$(printf '%s' "$raw" | tr -c 'A-Za-z0-9_.-' '-')"
  [[ "$safe" == *.json ]] || safe="${safe}.json"
  printf '%s\n' "$safe"
}

session_dir="$(resolve_session_dir)"
mkdir -p "$session_dir"

declare -a session_files=()

list_session_files() {
  mapfile -t session_files < <(
    find "$session_dir" -maxdepth 1 -type f \( -name '*.json' -o -name 'last' \) -printf '%T@ %p\n' 2>/dev/null \
      | sort -rn \
      | cut -d' ' -f2-
  )
}

require_session_files() {
  list_session_files
  [[ ${#session_files[@]} -gt 0 ]] \
    || die "no saved sessions in $session_dir yet (run niri-session-manage --save, or use \"Backup current session\" from this picker)"
}

# Pick one session file (autosave or preset) via fzf, with a live layout
# preview. Echoes the chosen path on success; returns 1 on cancel.
pick_session_file() {
  local prompt="$1"
  require_session_files

  local -a rows=()
  local f base win_count mtime tag
  for f in "${session_files[@]}"; do
    base="$(basename "$f")"
    win_count="$(jq -r '.windows | length' "$f" 2>/dev/null || echo '?')"
    mtime="$(date -r "$f" '+%Y-%m-%d %H:%M' 2>/dev/null || echo '?')"
    if [[ "$base" == "last" || "$base" == "session.json" ]]; then
      tag="auto"
    else
      tag="preset"
    fi
    rows+=("$f"$'\t'"[$tag] $base  —  $win_count window(s), saved $mtime")
  done

  local chosen
  chosen="$(
    printf '%s\n' "${rows[@]}" \
      | fzf --delimiter=$'\t' --with-nth=2 \
            --prompt="$prompt > " \
            --header=$'Enter: pick this file    Esc: cancel' \
            --preview='niri-session-restore-picker __preview {1}' \
            --preview-window='right:55%:wrap'
  )" || return 1
  [[ -n "$chosen" ]] || return 1
  printf '%s\n' "${chosen%%$'\t'*}"
}

restore_flow() {
  local chosen_file
  chosen_file="$(pick_session_file "restore which session file?")" || { notify "cancelled"; exit 0; }

  # --- pick which workspaces from that file to restore ---------------------
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

  local selection
  selection="$(
    printf '%s\n' "${ws_rows[@]}" \
      | fzf --multi \
            --delimiter=$'\t' \
            --with-nth=3 \
            --prompt="restore which workspaces? > " \
            --header=$'TAB: toggle    Ctrl-A: select all    Enter: restore selection    Esc: cancel' \
            --bind='ctrl-a:select-all' \
            --preview="niri-session-restore-picker __preview-ws $(shq "$chosen_file") {1} {2}" \
            --preview-window='right:50%:wrap'
  )" || { notify "cancelled"; exit 0; }
  [[ -n "$selection" ]] || { notify "nothing selected, cancelled"; exit 0; }

  local keys_json
  keys_json="$(
    echo "$selection" \
      | awk -F'\t' '{printf "{\"output\":%s,\"workspace_idx\":%s}\n", "\""$1"\"", $2}' \
      | jq -s '.'
  )"

  # --- filter the session down to the selected workspaces and restore ------
  # Not `local`: the EXIT trap below fires after this function has already
  # returned (at actual process exit), by which point a local var's scope
  # would be gone -- tmp_session needs to outlive the function.
  tmp_session="$(mktemp --suffix=.json)"
  trap 'rm -f "$tmp_session"' EXIT

  jq --argjson keys "$keys_json" '
    .windows |= [
      .[]
      | . as $w
      | select(any($keys[]; .output == $w.output and .workspace_idx == $w.workspace_idx))
    ]
  ' "$chosen_file" > "$tmp_session"

  local count
  count="$(jq '.windows | length' "$tmp_session")"
  [[ "$count" -gt 0 ]] || die "filtered selection ended up with 0 windows — nothing to restore"

  notify "restoring $count window(s)..."
  if niri-session-manage --load "$tmp_session" "$@"; then
    notify "restore finished"
  else
    local status=$?
    notify "restore finished with errors (exit $status) — see terminal"
    read -rp "Press Enter to close..." _ || true
    exit "$status"
  fi
}

backup_flow() {
  local preset_name
  read -rp "name for this preset (blank to cancel): " preset_name || true
  [[ -n "$preset_name" ]] || { notify "cancelled"; exit 0; }

  local safe_name target
  safe_name="$(sanitize_name "$preset_name")"
  target="$session_dir/$safe_name"

  if [[ -e "$target" ]]; then
    local confirm
    confirm="$(
      printf 'Overwrite\nCancel\n' \
        | fzf --prompt="\"$safe_name\" already exists — overwrite? > "
    )" || { notify "cancelled"; exit 0; }
    [[ "$confirm" == "Overwrite" ]] || { notify "cancelled"; exit 0; }
  fi

  notify "backing up current session as $safe_name..."
  if niri-session-manage --save "$safe_name"; then
    notify "saved $safe_name"
  else
    local status=$?
    notify "backup failed (exit $status) — see terminal"
    read -rp "Press Enter to close..." _ || true
    exit "$status"
  fi
}

rename_flow() {
  local chosen_file base
  chosen_file="$(pick_session_file "rename which session file?")" || { notify "cancelled"; exit 0; }
  base="$(basename "$chosen_file")"

  if [[ "$base" == "last" || "$base" == "session.json" ]]; then
    local confirm
    confirm="$(
      printf 'Rename anyway\nCancel\n' \
        | fzf --prompt="\"$base\" is auto-managed (snapshot timer / graceful shutdown) and will reappear on its own — rename anyway? > "
    )" || { notify "cancelled"; exit 0; }
    [[ "$confirm" == "Rename anyway" ]] || { notify "cancelled"; exit 0; }
  fi

  local new_name safe_name target
  read -rp "new name for \"$base\" (blank to cancel): " new_name || true
  [[ -n "$new_name" ]] || { notify "cancelled"; exit 0; }
  safe_name="$(sanitize_name "$new_name")"
  target="$session_dir/$safe_name"
  [[ -e "$target" ]] && die "\"$safe_name\" already exists"

  mv -- "$chosen_file" "$target"
  notify "renamed to $safe_name"
}

main_choice="$(
  printf '%s\n' \
    "Restore a saved session" \
    "Backup current session as a new preset" \
    "Rename a saved session" \
    | fzf --prompt="niri session restore — what do you want to do? > " \
          --header=$'Enter: choose    Esc: cancel'
)" || { notify "cancelled"; exit 0; }
[[ -n "$main_choice" ]] || { notify "cancelled"; exit 0; }

case "$main_choice" in
  "Restore a saved session")
    restore_flow "$@"
    ;;
  "Backup current session as a new preset")
    backup_flow
    ;;
  "Rename a saved session")
    rename_flow
    ;;
esac
