# niri-session-restore: saves/restores niri window sessions via IPC.
#
# Source: /home/maike/Projects/forks/niri-session-restore (fork of a niri
# session saver, wired in via flake input `niri-session-restore` in
# ./flake.nix). Full option reference lives in that repo's
# docs/en/CONFIG.md and docs/en/LOAD_RESTORE.md.
#
# What this module does:
#   - installs `niri-session-manage` and lets Home Manager render
#     ~/.config/niri-session/niri-session.conf from `settings` below;
#   - periodically snapshots the current session (systemd user timer);
#   - snapshots once more right before suspend/hibernate;
#   - actual restore-on-startup is wired separately, in
#     ressources/dots/niri/init.kdl (`spawn-at-startup "niri-session-manage"
#     "--load-last"`), since this fork's upstream module intentionally
#     leaves restore manual.
{inputs, ...}: {
  imports = [
    inputs.niri-session-restore.homeModules.niri-session
  ];

  services.niri-session = {
    enable = true;

    # Rendered to ~/.config/niri-session/niri-session.conf as TOML. Leave
    # settings = {} to keep the file entirely unmanaged (e.g. to hand-edit
    # it in place instead).
    settings = {
      # [session] -- where snapshots live and what --load-last reads.
      # session = {
      #   default_session_dir = "~/.local/state/niri-session/sessions";
      #   graceful_shutdown_name = "last"; # -> .../sessions/last (or "last.json")
      # };

      # [load] -- timings/behavior for --load and --load-last. All optional;
      # defaults shown as comments (see docs/en/CONFIG.md for the full table).
      # load = {
      #   ipc_settle_ms = 80; # pause after IPC focus + after each spawn
      #   spawn_start_delay_ms = 0; # extra pause after spawn, before next window
      #   no_await = false; # true = fire-and-forget, don't wait for the new window
      #   spawn_deadline = 10000; # ms to wait for a new window after spawn
      #   notify_on_spawn_failure = true; # notify-send on spawn/launch errors
      #   open_forcefully = false; # true = always spawn, even if a match exists
      #   resume_focused = true; # refocus the window that was focused at save time
      # };

      # [[launch]] -- override the relaunch command for windows whose saved
      # command isn't portable across restarts (xwayland-satellite bridges,
      # PWAs, flatpaks, ...). First matching rule wins; put narrower rules
      # (both app_id + title_contains) above broader ones.
      # launch = [
      #   {
      #     app_id = "Google-chrome";
      #     resolve = "xwayland-satellite";
      #     command = ["google-chrome-stable"];
      #   }
      #   {
      #     app_id = "org.mozilla.firefox";
      #     command = ["flatpak" "run" "org.mozilla.firefox"];
      #   }
      # ];
    };

    # Periodic snapshot while the graphical session is up, so there's always
    # something recent to restore from after a crash or unclean shutdown.
    snapshot = {
      enable = true;
      interval = "60s"; # systemd.time syntax, e.g. "2min"
      onSessionStart = true; # also snapshot ~30s after session start
    };

    # Snapshot right before suspend/hibernate -- the main recovery path when
    # a suspend/resume cycle goes wrong.
    saveOnSleep.enable = true;

    # Extra args appended to every internal `--save` call (snapshot timer +
    # sleep hook), e.g. for verbose debugging.
    # extraSaveArgs = ["--debug"];
  };
}
