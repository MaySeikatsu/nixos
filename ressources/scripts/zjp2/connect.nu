# zjp2 resolver + connect logic.
# Resolver: given a target (name or path), determine {name, path, layout,
# startup, preview} using the precedence:
#   1) explicit [[session]] with matching name or path
#   2) live/exited zellij session with matching name
#   3) [[wildcard]] match on path
#   4) fallback: sanitized basename, no layout/startup

use config.nu *
use sources.nu *

# Sanitize a name the same way zellij-autostart does. Mirrors:
#   basename "$PWD" | tr -c 'a-zA-Z0-9._\n-' '-' | sed 's/^-*//'
export def sanitize [name: string] {
  let s = ($name | str replace --all --regex '[^a-zA-Z0-9._\-]' '-' | str replace --regex '^-+' '')
  if ($s | is-empty) { "session" } else { $s }
}

export def resolve [cfg: record, target: string] {
  # (1) explicit [[session]] by name or path
  let s = (find-session $cfg $target)
  if $s != null {
    let p = (try { expand-path ($s.path? | default "") } catch { "" })
    return {
      name:    ($s.name? | default (sanitize (name-from-path $p $cfg.dir_length)))
      path:    $p
      layout:  ($s.layout?          | default $cfg.default_session.layout)
      startup: ($s.startup_command? | default $cfg.default_session.startup_command)
      preview: ($s.preview_command? | default $cfg.default_session.preview_command)
      source:  "config"
    }
  }

  # (2) live/exited zellij session by name
  let live_names = ((zellij-sessions $cfg) | get name)
  if $target in $live_names {
    return {
      name:    $target
      path:    ""
      layout:  $cfg.default_session.layout
      startup: ""
      preview: $cfg.default_session.preview_command
      source:  "zellij"
    }
  }

  # (3) wildcard match on path (if target looks like a path)
  let candidate_path = (if ($target | str starts-with "/") or ($target | str starts-with "~") or ($target | str starts-with "./") {
    try { expand-path $target } catch { "" }
  } else { "" })

  if ($candidate_path | is-not-empty) and ($candidate_path | path exists) {
    let w = (match-wildcard $cfg $candidate_path)
    if $w != null {
      return {
        name:    (sanitize (name-from-path $candidate_path $cfg.dir_length))
        path:    $candidate_path
        layout:  ($w.layout?          | default $cfg.default_session.layout)
        startup: ($w.startup_command? | default $cfg.default_session.startup_command)
        preview: ($w.preview_command? | default $cfg.default_session.preview_command)
        source:  "wildcard"
      }
    }
    # (4) fallback for a path
    return {
      name:    (sanitize (name-from-path $candidate_path $cfg.dir_length))
      path:    $candidate_path
      layout:  $cfg.default_session.layout
      startup: $cfg.default_session.startup_command
      preview: $cfg.default_session.preview_command
      source:  "fallback"
    }
  }

  # (4) fallback for a plain name
  {
    name:    (sanitize $target)
    path:    ""
    layout:  $cfg.default_session.layout
    startup: ""
    preview: ""
    source:  "fallback"
  }
}

# --- last-session state ------------------------------------------------------

def last-file [] {
  $"($env.HOME)/.local/state/zjp/last"
}

export def record-last [name: string] {
  let f = (last-file)
  let dir = ($f | path dirname)
  if not ($dir | path exists) { mkdir $dir }
  # Rotate: previous "current" becomes "last".
  let curr = (try { open --raw $f | str trim } catch { "" })
  if ($curr | is-not-empty) and $curr != $name {
    $curr | save --force $"($dir)/previous"
  }
  $name | save --force $f
}

export def read-last [] {
  let f = $"($env.HOME)/.local/state/zjp/previous"
  if ($f | path exists) { open --raw $f | str trim } else { "" }
}

# --- connect -----------------------------------------------------------------

# Perform the connection. Behavior:
#  - Inside zellij: switch current client in place via zellij-switch plugin.
#    If session doesn't exist, create it detached first, then switch.
#  - Outside zellij: attach (create if missing) with layout/cwd/startup.
export def session-connect [cfg: record, target: string] {
  let r = (resolve $cfg $target)
  let live = ((zellij-sessions $cfg) | get name)
  let exists = ($r.name in $live)

  let inside = (($env.ZELLIJ? | default "") | is-not-empty)

  if not $exists {
    # Create the session before switching. Prefer --new-session-with-layout
    # when a layout is set (creates with the layout); otherwise plain create.
    let cwd = (if ($r.path | is-not-empty) and ($r.path | path exists) { $r.path } else { $env.PWD })
    if $inside {
      # Create detached background session, then switch client to it.
      if ($r.layout | is-not-empty) {
        let layout_path = $"($env.HOME)/.config/zellij/layouts/($r.layout).kdl"
        if ($layout_path | path exists) {
          ^zellij --session $r.name --new-session-with-layout $layout_path -- true out+err> /dev/null
        } else {
          ^zellij attach --create-background $r.name out+err> /dev/null
        }
      } else {
        ^zellij attach --create-background $r.name out+err> /dev/null
      }
      # give it a moment to register
      sleep 300ms
    }
    # startup_command: fire once, in a new pane (or as the main pane if fresh).
    # We inject it via a floating pane after the session exists.
    if ($r.startup | is-not-empty) {
      # Best-effort; ignore failures.
      try {
        ^zellij --session $r.name run -c -- sh -c $r.startup out+err> /dev/null
      }
    }
  }

  record-last $r.name

  if $inside {
    # Switch client in place via zellij-switch plugin (no nesting).
    let plugin = $"file:($env.HOME)/.config/zellij/plugins/zellij-switch.wasm"
    ^zellij pipe --plugin $plugin -- $"--session ($r.name)"
  } else {
    # Outside zellij: attach (create if still not present).
    if ($r.layout | is-not-empty) and (not $exists) {
      let layout_path = $"($env.HOME)/.config/zellij/layouts/($r.layout).kdl"
      if ($layout_path | path exists) {
        exec zellij --session $r.name --new-session-with-layout $layout_path
      } else {
        exec zellij --create $r.name
      }
    } else {
      exec zellij attach --create $r.name
    }
  }
}
