# zjp2 config loader.
# Loads ~/.config/zjp/config.toml, applies defaults, exposes helpers to
# look up per-project session/wildcard entries.
#
# Schema (see config.toml.example):
#   sort_order = ["config", "zellij", "zoxide"]
#   blacklist  = ["scratch"]
#   dir_length = 1
#   icons      = false
#   [default_session]
#     startup_command = "..."
#     preview_command = "eza --all --git --icons --color=always {}"
#     layout          = ""
#   [[session]]
#     name = "..."; path = "..."; startup_command = "..."; preview_command = "..."; layout = "..."
#   [[wildcard]]
#     pattern = "~/projects/*"; startup_command = "..."; preview_command = "..."; layout = "..."

export def defaults [] {
  {
    sort_order: ["config", "zellij", "zoxide"]
    blacklist:  []
    dir_length: 1
    icons:      false
    default_session: {
      startup_command: ""
      preview_command: ""
      layout:          ""
    }
    session:  []
    wildcard: []
  }
}

def path [] {
  $"($env.HOME)/.config/zjp/config.toml"
}

# Merge parsed config over defaults (recursively for nested tables).
def merge-defaults [cfg: record] {
  let d = (defaults)
  {
    sort_order: ($cfg.sort_order? | default $d.sort_order)
    blacklist:  ($cfg.blacklist?  | default $d.blacklist)
    dir_length: ($cfg.dir_length? | default $d.dir_length)
    icons:      ($cfg.icons?      | default $d.icons)
    default_session: ($d.default_session | merge ($cfg.default_session? | default {}))
    session:  ($cfg.session?  | default [])
    wildcard: ($cfg.wildcard? | default [])
  }
}

export def load [] {
  let p = (path)
  if ($p | path exists) {
    try {
      open $p | merge-defaults $in
    } catch {
      # Malformed TOML: warn on stderr, fall back to defaults.
      print --stderr $"zjp2: warning: failed to parse ($p), using defaults"
      defaults
    }
  } else {
    defaults
  }
}

# Expand ~ and environment variables in a path string.
export def expand-path [p: string] {
  $p | path expand --no-symlink
}

# Find a [[session]] entry matching either name or path (path-expanded compare).
export def find-session [cfg: record, target: string] {
  let target_expanded = (try { expand-path $target } catch { $target })
  $cfg.session
  | where {|s|
      let path_match = ((try { expand-path ($s.path? | default "") } catch { "" }) == $target_expanded)
      ($s.name? == $target) or $path_match
    }
  | get -o 0
}

# Match a path against wildcard patterns. Returns the first matching wildcard
# entry or null. Uses nushell's `path expand` for ~/ and glob for matching via
# `str` operations (Go filepath.Match compatibility approximated).
export def match-wildcard [cfg: record, target_path: string] {
  let p = (expand-path $target_path)
  $cfg.wildcard
  | where {|w|
      let pat = (expand-path ($w.pattern? | default ""))
      # Convert glob-ish pattern to a regex: * -> [^/]*, ** -> .*, ? -> [^/]
      let re = ($pat
        | str replace --all --regex '([\.\+\(\)\|\^\$\{\}\[\]\\])' '\$1'
        | str replace --all '**' '\x00'
        | str replace --all '*' '[^/]*'
        | str replace --all '\x00' '.*'
        | str replace --all '?' '[^/]')
      ($p | str replace --regex $"^($re)$" '__MATCH__') == '__MATCH__'
    }
  | get -o 0
}

# Icons per state/source. Returns "" when icons disabled.
export def icon-for [cfg: record, source: string, state: string] {
  if not $cfg.icons { return "" }
  match $source {
    "zellij" => (if $state == "live" { "\u{f2db} " } else { "\u{f0a30} " })
    "zoxide" => "\u{f07b} "
    "config" => "\u{f013} "
    _ => ""
  }
}

# Apply dir_length to derive a display name from a path.
# dir_length = 1 -> basename, 2 -> "parent/basename", etc.
export def name-from-path [p: string, dir_length: int] {
  let parts = ($p | path split)
  let n = ([$dir_length ($parts | length)] | math min)
  $parts | last $n | path join
}
