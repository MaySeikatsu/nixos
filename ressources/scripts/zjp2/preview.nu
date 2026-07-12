# zjp2 preview: rendered for a single fzf line.
# Line format from `list` output is TSV:
#   <source>\t<name>\t<path>\t<state>\t<display>
# where <display> is "<icon><name>" (icon may be empty).
#
# Preview policy:
#   - live/exited zellij session with saved layout -> trimmed layout
#   - config entry with preview_command       -> run it (substitute {})
#   - anything else with a valid path         -> eza tree fallback, else ls -la
#   - nothing usable                          -> friendly stub

use config.nu *
use sources.nu *

def render-layout [name: string] {
  let f = $"($env.HOME)/.cache/zellij/contract_version_1/session_info/($name)/session-layout.kdl"
  if not ($f | path exists) {
    return "(no saved layout)"
  }
  # Trim off swap_tiled_layout tail (matches old zjp preview behaviour).
  try {
    open --raw $f
    | lines
    | take while {|l| not ($l =~ 'swap_tiled_layout')}
    | str join "\n"
  } catch { "(unable to read layout)" }
}

def render-path [cfg: record, p: string, preview_cmd: string] {
  if ($preview_cmd | is-not-empty) {
    let cmd = ($preview_cmd | str replace --all '{}' $p)
    try {
      ^sh -c $cmd | complete | get stdout
    } catch { $"(preview command failed: ($cmd))" }
  } else if ($p | is-not-empty) and ($p | path exists) {
    let has_eza = (which eza | is-not-empty)
    if $has_eza {
      try { ^eza --tree --level=2 --color=always $p | complete | get stdout } catch { try { ^ls -la $p | complete | get stdout } }
    } else {
      try { ^ls -la $p | complete | get stdout } catch { "" }
    }
  } else {
    "(no path)"
  }
}

# Parse a TSV line back into a record. Robust to icon prefixes on the display
# column: we use the first 4 tab-delimited fields directly.
def parse-line [line: string] {
  let parts = ($line | split row "\t")
  {
    source:  ($parts | get -o 0 | default "")
    name:    ($parts | get -o 1 | default "")
    path:    ($parts | get -o 2 | default "")
    state:   ($parts | get -o 3 | default "")
    display: ($parts | get -o 4 | default "")
  }
}

export def main [line: string] {
  let r = (parse-line $line)
  let cfg = (load)
  match $r.state {
    "live" | "exited" => (render-layout $r.name)
    "config" => {
      let s = (find-session $cfg $r.name)
      let pv = (if $s != null { $s.preview_command? | default "" } else { "" })
      render-path $cfg $r.path $pv
    }
    _ => {
      # For zoxide/dir rows: check wildcard preview_command match, then eza fallback.
      let w = (if ($r.path | is-not-empty) { match-wildcard $cfg $r.path } else { null })
      let pv = (if $w != null { $w.preview_command? | default "" } else { "" })
      render-path $cfg $r.path $pv
    }
  }
}
