# niri-session-restore-picker

A small interactive picker that sits in front of
[niri-session-restore](https://github.com/MaySeikatsu/niri-session-restore)'s
`niri-session-manage --load`. Instead of blindly restoring the entire last
session on every niri startup, it:

1. lists saved session files (newest first, with a window count) and lets you
   pick one via [fzf](https://github.com/junegunn/fzf);
2. lists that file's workspaces (output, name, and which apps are on it) and
   lets you multi-select which ones to actually restore;
3. filters the session JSON down to just those workspaces and hands it to
   `niri-session-manage --load`.

Everything is a single POSIX-ish bash script (`niri-session-restore-picker.sh`)
with no state of its own — it just reads whatever `niri-session-manage --save`
already wrote.

## Why this exists

Auto-restoring the full session on every startup has two problems: it has no
concept of "I don't want that workspace back right now", and it races against
any apps you also statically autostart elsewhere (niri fires `spawn-at-startup`
entries concurrently, not in sequence — see the "Duplicate handling" section of
the writeup this came out of). Running this on-demand from a keybind sidesteps
both.

## Dependencies

Runtime: `jq`, `fzf`, `libnotify` (for `notify-send`), `coreutils`,
`findutils`, `gawk`, and separately, **`niri-session-manage` itself** (from
the niri-session-restore fork) — that one is intentionally *not* bundled by
`package.nix` here, since in the parent nixos config it's already installed
by the sibling home-manager module that manages saving. If you lift this
directory into its own repo, make sure `niri-session-manage` ends up on
`PATH` some other way.

## Usage

Run directly:

```sh
./niri-session-restore-picker.sh [-- extra args forwarded to niri-session-manage --load]
```

Or build the nix package (`package.nix`, a `pkgs.writeShellApplication`) and
put the result on `PATH`. In the parent nixos config this is wired up as:

- a package added to `home.packages` (see
  `modules/home-manager/desktop/niri/niri-session-restore-picker.nix`)
- a niri window-rule that opens it floating (`match title="niri-session-restore-picker"`
  in `ressources/dots/niri/config.kdl`)
- a keybind that spawns it in a floating terminal (`Mod+Shift+R` in
  `ressources/dots/niri/binds.kdl`)

## Status

First pass, not yet battle-tested against a real multi-workspace session. If
this earns its keep, it's self-contained enough to split into its own repo —
nothing in this directory reaches outside of itself except the
`niri-session-manage` binary on `PATH` at runtime.
