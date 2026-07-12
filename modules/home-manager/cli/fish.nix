{...}: {
  programs.fish = {
    enable = true;

    # Suppresses fish's welcome banner
    shellInit = ''
      set -g fish_greeting ""
    '';

    interactiveShellInit = ''
      # Auto-start zellij: session named after the current directory;
      # attaches if live, resurrects if dead, creates otherwise (zellij.nix).
      # if not set -q ZELLIJ
      #     zellij-autostart
      # end

      # Rename the zellij tab to the current dir (at prompt) or the running
      # command (while it runs). `tn <name>` pins a manual name, `tn` unpins.
      function _zj_tab_pwd --on-event fish_prompt
          set -q ZELLIJ; or return
          set -q ZJ_TAB_NAME_LOCK; and return
          if test "$PWD" = "$HOME"
              zellij action rename-tab "~"
          else
              zellij action rename-tab (basename "$PWD")
          end
      end
      function _zj_tab_cmd --on-event fish_preexec
          set -q ZELLIJ; or return
          set -q ZJ_TAB_NAME_LOCK; and return
          set -l first (string split ' ' -- $argv[1])[1]
          test -n "$first"; and zellij action rename-tab $first
      end
      function tn
          if test (count $argv) -gt 0
              set -g ZJ_TAB_NAME_LOCK 1
              zellij action rename-tab "$argv"
          else
              set -e ZJ_TAB_NAME_LOCK
          end
      end

      # On cd into a dir with an existing zellij session, offer to switch
      # to it (exit 3 = declined; remember the decline for this shell).
      function _zj_cd_attach --on-variable PWD
          status is-interactive; or return
          set -q ZELLIJ; or return
          contains -- $PWD $ZJ_CD_DECLINED; and return
          zellij-cd-attach
          if test $status -eq 3
              set -ga ZJ_CD_DECLINED $PWD
          end
      end
    '';

    # fish's ctrl-h preset is backward-delete-char (single character);
    binds."ctrl-h" = {
      command = "backward-kill-word";
    };

    # Aliases come from shell-aliases.nix (shared across zsh/fish/nushell).
    # `y` is intentionally not aliased to `yazi`: yazi.nix provides its own.
  };
}
