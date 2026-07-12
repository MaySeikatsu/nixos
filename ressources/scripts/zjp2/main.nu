#!/usr/bin/env nu
# zjp2 - sesh feature-parity zellij session picker (nushell prototype).
# See ~/.config/zjp/config.toml.example for the config schema.
#
# Subcommands:
#   list [-t|-z|-c|-a|-b]        list rows (default = all merged)
#   connect <target>             attach or create; target = name OR path
#   last                         switch to previously-attached session
#   root [path]                  connect to git top-level of path (or cwd)
#   kill <name>                  soft: zellij kill-session (keeps saved layout)
#   delete <name>                hard: zellij delete-session (removes serialization)
#   mkdir <path>                 mkdir -p + connect
#   clone <git-url> [dest]       git clone + connect
#   window [target] [--session s] list/switch/create tabs in a session
#   preview <line>               preview command (called by fzf)
#   picker | (no args)           interactive fzf picker (default)

use config.nu *
use sources.nu *
use connect.nu *
use fzf.nu *
use preview.nu
use window.nu

def do-list [args: list<string>] {
  let word = ($args | get -o 0 | default "all")
  list-cmd $word
}

def do-connect [args: list<string>] {
  if ($args | length) == 0 {
    print --stderr "zjp2 connect: missing target"; exit 1
  }
  let cfg = (load)
  session-connect $cfg ($args | get 0)
}

def do-last [] {
  let prev = (read-last)
  if ($prev | is-empty) {
    print --stderr "zjp2 last: no previous session recorded yet"
    exit 1
  }
  let cfg = (load)
  session-connect $cfg $prev
}

def do-root [args: list<string>] {
  let p = ($args | get -o 0 | default $env.PWD | (do { expand-path $in }))
  let top = (try {
    ^git -C $p rev-parse --show-toplevel | complete | get stdout | str trim
  } catch { "" })
  if ($top | is-empty) {
    print --stderr $"zjp2 root: ($p) is not inside a git repository"
    exit 1
  }
  let cfg = (load)
  session-connect $cfg $top
}

def do-kill [args: list<string>] {
  if ($args | length) == 0 { print --stderr "zjp2 kill: missing name"; exit 1 }
  let name = ($args | get 0)
  ^zellij kill-session $name
}

def do-delete [args: list<string>] {
  if ($args | length) == 0 { print --stderr "zjp2 delete: missing name"; exit 1 }
  let name = ($args | get 0)
  # Confirm on tty; skip when stdin isn't a terminal (e.g. fzf execute-silent).
  let is_tty = (try { ^test -t 0 | complete | get exit_code } catch { 1 })
  if $is_tty == 0 {
    print --no-newline $"Hard-delete zellij session \"($name)\"? [y/N] "
    let ans = (input)
    if not ($ans in ["y" "Y" "yes" "Yes"]) {
      print "aborted"
      return
    }
  }
  ^zellij delete-session $name
}

def do-mkdir [args: list<string>] {
  if ($args | length) == 0 { print --stderr "zjp2 mkdir: missing path"; exit 1 }
  let raw = ($args | get 0)
  let p = (try { expand-path $raw } catch { $raw })
  if not ($p | path exists) { mkdir $p }
  let cfg = (load)
  session-connect $cfg $p
}

def do-clone [args: list<string>] {
  if ($args | length) == 0 { print --stderr "zjp2 clone: missing url"; exit 1 }
  let url = ($args | get 0)
  let dest = ($args | get -o 1 | default (
    $url | path basename | str replace --regex '\.git$' ''
  ))
  let dest_p = (try { expand-path $dest } catch { $dest })
  if not ($dest_p | path exists) {
    ^git clone $url $dest_p
  }
  let cfg = (load)
  session-connect $cfg $dest_p
}

def main [...args: string] {
  let sub = ($args | get -o 0 | default "picker")
  let rest = ($args | skip 1)
  match $sub {
    "list"     => (do-list    $rest)
    "connect"  => (do-connect $rest)
    "last"     => (do-last)
    "root"     => (do-root    $rest)
    "kill"     => (do-kill    $rest)
    "delete"   => (do-delete  $rest)
    "mkdir"    => (do-mkdir   $rest)
    "clone"    => (do-clone   $rest)
    "window"   => (window $rest)
    "preview"  => {
      # preview receives the whole line (may itself contain spaces/tabs).
      let line = ($rest | str join " ")
      preview $line
    }
    "picker"   => (picker)
    "-h" | "--help" | "help" => {
      print "zjp2 - zellij session picker (sesh parity, nu prototype)"
      print ""
      print "Subcommands:"
      print "  list [zellij|zoxide|config|all|blacklist]  list rows (default: all)"
      print "  connect <target>              attach or create"
      print "  last                          switch to previous session"
      print "  root [path]                   connect to git top-level"
      print "  kill <name>                   soft kill (keeps saved layout)"
      print "  delete <name>                 hard delete (removes serialization)"
      print "  mkdir <path>                  mkdir -p + connect"
      print "  clone <git-url> [dest]        git clone + connect"
      print "  window [target] [--session s] tabs in session"
      print "  preview <line>                fzf preview command"
      print "  picker | (no args)            interactive picker"
    }
    _ => {
      # Unknown subcommand -> treat as connect target (sesh-ish shorthand).
      let cfg = (load)
      session-connect $cfg $sub
    }
  }
}
