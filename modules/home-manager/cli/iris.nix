{
  pkgs,
  lib,
  inputs,
  ...
}: let
  # IRIS wraps the shell in a PTY and draws its own completion overlay.
  # Only bash/zsh/fish have adapters upstream - nushell is unsupported.
  iris = inputs.iris.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # `iris init <shell>` prints a fixed snippet: bake it in at build time and
  # pin its bare `exec iris` to this build instead of a PATH lookup.
  irisInit = shell:
    pkgs.runCommand "iris-init.${shell}" {} ''
      export HOME=$TMPDIR
      ${lib.getExe iris} init ${shell} \
        | sed -E 's|^( *)exec iris$|\1exec ${lib.getExe iris}|' > $out
    '';
in {
  # First in the rc file: everything after it only runs in the shell iris spawns.
  # TERM=dumb (M-x shell) can't host the raw-mode overlay, so skip it there.
  # Multiplexer panes inherit a stale IRIS_PID from whatever launched the server,
  # which silently suppresses the overlay - only PPID == IRIS_PID is the real
  # inner shell. IRIS_PANE_RESTART caps the guard at one fire, so a bad guess
  # costs the overlay rather than looping.
  programs.zsh.initContent = lib.mkOrder 100 ''
    if [[ "$TERM" != "dumb" ]]; then
      if [[ -n "$IRIS_PID" && -z "$IRIS_PANE_RESTART" && ( -n "$ZELLIJ" || -n "$TMUX" ) ]]; then
        if [[ "$PPID" != "$IRIS_PID" ]]; then
          export IRIS_PANE_RESTART=1
          unset IRIS_PID IRIS_IS_CHILD IRIS_FD
        fi
      fi
      source ${irisInit "zsh"}
    fi
  '';

  # Same guard; fish has no $PPID, hence the ps call.
  programs.fish.interactiveShellInit = lib.mkOrder 100 ''
    if test "$TERM" != dumb
      if set -q IRIS_PID; and not set -q IRIS_PANE_RESTART
        if begin; set -q ZELLIJ; or set -q TMUX; end
          set -l iris_ppid (ps -o ppid= -p $fish_pid 2>/dev/null | string trim)
          if test "$iris_ppid" != "$IRIS_PID"
            set -gx IRIS_PANE_RESTART 1
            set -e IRIS_PID
            set -e IRIS_IS_CHILD
            set -e IRIS_FD
          end
        end
      end
      source ${irisInit "fish"}
    end
  '';
}
