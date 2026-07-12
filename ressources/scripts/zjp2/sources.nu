# zjp2 sources: zellij (live/exited), zoxide, config [[session]] entries.
# All produce records with schema:
#   { source, name, path, state, icon, layout, startup, preview }
# state ∈ {live, exited, dir}
# layout/startup/preview default to "" (resolver enriches later).

use config.nu *

# ---- zellij ----------------------------------------------------------------

# Path of the session's first tab, derived from serialized layout.
# Cheap enough for a few dozen sessions; skipped silently on failure.
def session-path [name: string] {
  let f = $"($env.HOME)/.cache/zellij/contract_version_1/session_info/($name)/session-layout.kdl"
  if not ($f | path exists) { return "" }
  # First `cwd "..."` line in the file.
  try {
    open --raw $f
    | lines
    | where {|l| $l =~ '\s*cwd\s+"'}
    | get -o 0
    | default ""
    | str replace --regex '.*cwd\s+"([^"]+)".*' '$1'
  } catch { "" }
}

export def zellij-sessions [cfg: record] {
  let raw = (try {
    ^zellij list-sessions -n
    | complete
    | get stdout
    | lines
    | where {|l| ($l | str trim) != ""}
  } catch { [] })
  $raw | each {|line|
    let name = ($line | split row " " | get 0)
    let state = (if ($line | str contains "EXITED") { "exited" } else { "live" })
    let path = (session-path $name)
    {
      source: "zellij"
      name:   $name
      path:   $path
      state:  $state
      icon:   (icon-for $cfg "zellij" $state)
      layout: ""
      startup: ""
      preview: ""
    }
  }
}

# ---- zoxide ----------------------------------------------------------------

export def zoxide-dirs [cfg: record] {
  let raw = (try {
    ^zoxide query -l
    | complete
    | get stdout
    | lines
    | where {|l| ($l | str trim) != ""}
  } catch { [] })
  $raw | each {|p|
    let name = (name-from-path $p $cfg.dir_length)
    {
      source: "zoxide"
      name:   $name
      path:   $p
      state:  "dir"
      icon:   (icon-for $cfg "zoxide" "dir")
      layout: ""
      startup: ""
      preview: ""
    }
  }
}

# ---- config [[session]] ----------------------------------------------------

export def config-sessions [cfg: record] {
  $cfg.session | each {|s|
    let p = (try { expand-path ($s.path? | default "") } catch { "" })
    {
      source: "config"
      name:   ($s.name? | default (name-from-path $p $cfg.dir_length))
      path:   $p
      state:  "config"
      icon:   (icon-for $cfg "config" "config")
      layout:  ($s.layout?          | default "")
      startup: ($s.startup_command? | default "")
      preview: ($s.preview_command? | default "")
    }
  }
}

# ---- merge & filter --------------------------------------------------------

# Dedupe: prefer earlier entries (per sort_order). Uniqueness key = name.
def dedupe [rows: list] {
  $rows
  | reduce --fold {seen: [], out: []} {|row, acc|
      if ($row.name in $acc.seen) {
        $acc
      } else {
        {
          seen: ($acc.seen | append $row.name)
          out:  ($acc.out  | append $row)
        }
      }
    }
  | get out
}

# Sort by cfg.sort_order (unknown sources sort after known ones, stable within).
def sort-by-source [rows: list, order: list] {
  let indexed = ($rows | enumerate | each {|e|
    let idx = ($order | enumerate | where item == $e.item.source | get -o 0.index | default 999)
    {orig: $e.index, key: $idx, row: $e.item}
  })
  $indexed | sort-by key orig | get row
}

# Load and merge selected sources. `sel` is a record with bool flags:
#   {zellij, zoxide, config, blacklisted}
# blacklisted=true INVERTS: shows only blacklisted entries.
export def collect [cfg: record, sel: record] {
  mut rows = []
  if $sel.config { $rows = ($rows | append (config-sessions $cfg)) }
  if $sel.zellij { $rows = ($rows | append (zellij-sessions $cfg)) }
  if $sel.zoxide { $rows = ($rows | append (zoxide-dirs $cfg)) }

  let sorted = (sort-by-source $rows $cfg.sort_order)
  let deduped = (dedupe $sorted)

  let bl = $cfg.blacklist
  if $sel.blacklisted {
    $deduped | where {|r| $r.name in $bl}
  } else {
    $deduped | where {|r| not ($r.name in $bl)}
  }
}
