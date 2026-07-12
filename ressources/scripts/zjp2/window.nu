# zjp2 window: list/switch/create tabs in a zellij session.
# Analog of `sesh window`.
#
# Usage:
#   zjp2 window                          # list tabs in current session
#   zjp2 window <name>                   # switch to (or create) tab named <name>
#   zjp2 window <path>                   # create tab named basename(path) at cwd
#   zjp2 window <target> --session <s>   # target a different session

use config.nu *
use sources.nu *

def current-session [] {
  $env.ZELLIJ_SESSION_NAME? | default ""
}

def resolve-session [flag_session: string] {
  if ($flag_session | is-not-empty) { $flag_session } else { current-session }
}

# Query the currently focused session for its tab names.
# `zellij action query-tab-names` outputs one name per line.
def list-tabs [] {
  try {
    ^zellij action query-tab-names
    | complete
    | get stdout
    | lines
    | where {|l| ($l | str trim) != ""}
  } catch { [] }
}

# `--session` targeting requires ZELLIJ_SESSION_NAME override for `zellij action`.
def with-session [name: string, cmd: closure] {
  if ($name | is-empty) or ($name == (current-session)) {
    do $cmd
  } else {
    ZELLIJ_SESSION_NAME=$name do $cmd
  }
}

# Guess whether the argument is a path we should mkdir/cwd into.
def is-pathlike [arg: string] {
  ($arg | str starts-with "/") or ($arg | str starts-with "~") or ($arg | str starts-with "./") or ($arg | str starts-with "../")
}

# Main entry point.
export def main [args: list<string>] {
  # Extract --session <name> if present, plus positional target.
  mut sess = ""
  mut target = ""
  mut i = 0
  while $i < ($args | length) {
    let a = ($args | get $i)
    if $a == "--session" or $a == "-s" {
      $sess = ($args | get -o ($i + 1) | default "")
      $i = $i + 2
    } else {
      $target = $a
      $i = $i + 1
    }
  }

  # Shadow mutables into immutables so they can be captured in closures.
  let sess_final = $sess
  let target = $target
  let session = (resolve-session $sess_final)
  if ($session | is-empty) {
    print --stderr "zjp2 window: not inside a zellij session and no --session given"
    exit 1
  }

  # No target -> list tabs.
  if ($target | is-empty) {
    let tabs = (with-session $session { list-tabs })
    print ($tabs | str join "\n")
    return
  }

  # Path-like target: create a new tab at that cwd.
  if (is-pathlike $target) {
    let p = (try { expand-path $target } catch { $target })
    if not ($p | path exists) {
      print --stderr $"zjp2 window: path does not exist: ($p)"
      exit 1
    }
    let name = ($p | path basename)
    with-session $session {
      ^zellij action new-tab --cwd $p --name $name
    }
    return
  }

  # Named target: switch if exists, else create empty tab with that name.
  let tabs = (with-session $session { list-tabs })
  if $target in $tabs {
    let idx = ($tabs | enumerate | where item == $target | get -o 0.index | default 0)
    with-session $session {
      ^zellij action go-to-tab ($idx + 1)
    }
  } else {
    with-session $session {
      ^zellij action new-tab --name $target
    }
  }
}
