# zjp2 fzf UI wrapper.
# Reads rows from `sources.nu collect`, emits TSV, wraps fzf with
# source-cycling, kill/delete, reload, and preview.

use config.nu *
use sources.nu *

# TSV columns emitted: source, name, path, state, display
# `display` = "<icon><name>" (icon empty if disabled).
export def rows-to-tsv [rows: list] {
  $rows
  | each {|r| [$r.source, $r.name, $r.path, $r.state, $"($r.icon)($r.name)"] | str join "\t"}
  | str join "\n"
}

# Selector shortcut helpers used by fzf reload binds.
def sel-all         [] { {zellij: true,  zoxide: true,  config: true,  blacklisted: false} }
def sel-zellij-only [] { {zellij: true,  zoxide: false, config: false, blacklisted: false} }
def sel-zoxide-only [] { {zellij: false, zoxide: true,  config: false, blacklisted: false} }
def sel-config-only [] { {zellij: false, zoxide: false, config: true,  blacklisted: false} }
def sel-blacklisted [] { {zellij: true,  zoxide: true,  config: true,  blacklisted: true} }

# Keyword-based source selector (nu positional args can't start with '-').
# Accepts a single word: zellij, zoxide, config, all (default), blacklist.
export def parse-source [word: string] {
  match ($word | str downcase) {
    "zellij" | "z" | "sessions" | "t"     => (sel-zellij-only)
    "zoxide" | "dirs"                     => (sel-zoxide-only)
    "config" | "c"                        => (sel-config-only)
    "blacklist" | "blacklisted" | "b"     => (sel-blacklisted)
    _                                     => (sel-all)
  }
}

# Emit rows to stdout as TSV. `word` selects the source; empty/"all" = all.
export def list-cmd [word: string] {
  let cfg = (load)
  let sel = (parse-source $word)
  let rows = (collect $cfg $sel)
  print (rows-to-tsv $rows)
}

# Interactive picker.
# fzf binds:
#   ^t / ^z / ^c / ^a  : cycle sources
#   ^d                 : soft kill (zellij kill-session), reload
#   ctrl-alt-d         : hard delete (zellij delete-session), with confirm
#   ^r                 : reload
export def picker [] {
  let cfg = (load)
  let sel = (sel-all)
  let rows = (collect $cfg $sel)
  let tsv = (rows-to-tsv $rows)
  if ($tsv | is-empty) {
    print --stderr "zjp2: no sessions, no zoxide dirs, no config entries"
    return
  }

  # Use env var to point back at this script for reload/preview binds.
  # `zjp2` (the wrapper) invokes `nu main.nu`, so re-invoking `zjp2` is fine.
  let self = "zjp2"
  let prompt = "⚡  "
  let header = "^t zellij  ^z zoxide  ^c config  ^a all  ^d kill  ^alt-d delete  ^r reload"

  let selected = ($tsv
    | ^fzf --ansi --no-sort
        --delimiter "\t" --with-nth 5
        --prompt $prompt
        --header $header
        --bind $"ctrl-t:reload\(($self) list zellij)+change-prompt\(🪟  )"
        --bind $"ctrl-z:reload\(($self) list zoxide)+change-prompt\(📁  )"
        --bind $"ctrl-c:reload\(($self) list config)+change-prompt\(⚙️  )"
        --bind $"ctrl-a:reload\(($self) list all)+change-prompt\(⚡  )"
        --bind $"ctrl-r:reload\(($self) list all)"
        --bind $"ctrl-d:execute-silent\(($self) kill {2})+reload\(($self) list all)"
        --bind $"ctrl-alt-d:execute\(($self) delete {2})+reload\(($self) list all)"
        --preview $"($self) preview {}"
        --preview-window "right,60%"
    | complete
  )

  if $selected.exit_code != 0 {
    return
  }
  let line = ($selected.stdout | str trim)
  if ($line | is-empty) { return }

  # Prefer path when present (routes through wildcard resolution); else name.
  let parts = ($line | split row "\t")
  let name = ($parts | get -o 1 | default "")
  let path = ($parts | get -o 2 | default "")
  let target = (if ($path | is-not-empty) and ($path | path exists) { $path } else { $name })
  if ($target | is-empty) { return }

  use connect.nu *
  session-connect $cfg $target
}
