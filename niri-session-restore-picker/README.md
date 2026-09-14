# niri-session-restore-picker

A small interactive picker that sits in front of
[niri-session-restore](https://github.com/MaySeikatsu/niri-session-restore)'s
`niri-session-manage --save`/`--load`. Instead of blindly restoring the
entire last session on every niri startup, opening it (Mod+Shift+R) offers
three actions:

- **Restore a saved session** — pick a saved session file (autosaves and
  named presets alike, newest first, with a window count and a live layout
  preview showing which windows are on which monitor/workspace), then
  multi-select which of its workspaces to actually restore. The session JSON
  is filtered down to just those workspaces and handed to
  `niri-session-manage --load`.
- **Backup current session as a new preset** — snapshot what's open right
  now under a name you choose (`niri-session-manage --save <name>.json`), so
  it shows up in the restore list alongside the autosaves next time.
- **Rename a saved session** — rename any saved file/preset in place (with a
  warning if you pick one of the two auto-managed names, `session.json` /
  `last`, since those get regenerated on their own).

Presets are just named files living in the same session directory the
autosaves already use — there's no separate storage, so anything you back up
shows up in the same restore list, tagged `[preset]` vs `[auto]`.

The layout preview (fzf's `--preview` pane) draws each workspace's tiled
windows as stacked boxes — columns left-to-right, windows within a column
stacked top-to-bottom, the focused window double-bordered — plus a trailing
note for floating windows. Same idea as the pane-box previews our zellij
picker ([noren](https://github.com/MaySeikatsu/noren)) draws for sessions,
adapted to niri's output/workspace/column model.

Everything is a single POSIX-ish bash script (`niri-session-restore-picker.sh`)
with no state of its own — it just reads and writes whatever
`niri-session-manage --save`/`--load` already understand. No new runtime
dependency for any of this — see [Dependencies](#dependencies).

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

Core logic (file listing, layout preview rendering, backup/rename/restore
control flow) exercised against a real multi-monitor/multi-workspace session
file and with `niri-session-manage`/`fzf`/`notify-send` stubbed out — not yet
run end-to-end against a live niri compositor. If this earns its keep, it's
self-contained enough to split into its own repo — nothing in this directory
reaches outside of itself except the `niri-session-manage` binary on `PATH`
at runtime.

## Roadmap

An "exact layout" restore mode — close windows that aren't in the saved
snapshot instead of only adding the saved ones on top, so restoring a preset
reproduces it exactly — is deliberately not implemented here yet (it's
destructive by nature and belongs behind an explicit opt-in). Sketched out in
the niri-session-restore fork's own
[ROADMAP.md](https://github.com/MaySeikatsu/niri-session-restore/blob/main/ROADMAP.md#exact-layout-restore-mode),
since it needs a flag on `--load` itself before this picker can expose it as
a toggle.
