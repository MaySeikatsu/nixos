{pkgs, ...}: {
  programs.zed-editor = {
    enable = true;

    # ACP bridge so the agent panel can drive Claude Code.
    # The nixpkgs wrapper pins CLAUDE_CODE_EXECUTABLE to the nix `claude`
    # binary, so it reuses ~/.claude/.credentials.json (subscription OAuth).
    extraPackages = [pkgs.claude-agent-acp];

    # settings = {
    #   pane_gap = 12;
    # };

    # `<leader>gg` -> lazygit, LazyVim style.
    userTasks = [
      {
        label = "lazygit";
        command = "lazygit";
        use_new_terminal = false;
        allow_concurrent_runs = false;
        reveal = "always";
        hide = "on_success";
      }
    ];

    userKeymaps = [
      # ---------------------------------------------------------------
      # Vim normal/visual: leader map + pane/tab navigation.
      # VimControl excludes insert mode, so ctrl-hjkl stays literal
      # while typing, exactly like nvim.
      # ---------------------------------------------------------------
      {
        context = "VimControl && !menu";
        bindings = {
          # pane / dock traversal (ActivatePane* also steps into docks)
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";

          # buffer/tab cycling (displaces vim H/L, see z-T / z-B below)
          "shift-h" = "pane::ActivatePreviousItem";
          "shift-l" = "pane::ActivateNextItem";
          "z shift-t" = "vim::WindowTop";
          "z shift-b" = "vim::WindowBottom";

          # diagnostics: ] d / [ d already exist upstream, add severity filters
          "] e" = ["editor::GoToDiagnostic" {severity = {min = "error"; max = "error";};}];
          "[ e" = ["editor::GoToPreviousDiagnostic" {severity = {min = "error"; max = "error";};}];
          "] w" = ["editor::GoToDiagnostic" {severity = {min = "warning"; max = "warning";};}];
          "[ w" = ["editor::GoToPreviousDiagnostic" {severity = {min = "warning"; max = "warning";};}];

          # terminal
          "ctrl-/" = "terminal_panel::Toggle";

          # ---- leader ----
          "space e" = "project_panel::ToggleFocus";
          "space space" = "file_finder::Toggle";
          "space ," = "tab_switcher::ToggleAll";
          "space /" = "pane::DeploySearch";
          "space :" = "command_palette::Toggle";
          # "space a" = "agent::ToggleFocus";
          # new-thread menu: this is where external ACP agents (Claude Code)
          # are picked; the bottom-bar selector only switches Zed Agent models
          "space shift-a" = "agent::ToggleNewThreadMenu";

          # find
          "space f f" = "file_finder::Toggle";
          "space f n" = "workspace::NewFile";
          "space f t" = "terminal_panel::Toggle";
          # recent-projects picker; ctrl-shift-enter inside it adds the
          # highlighted project to the current workspace as a 2nd root
          "space f p" = "projects::OpenRecent";

          # buffers
          "space b d" = ["pane::CloseActiveItem" {close_pinned = false;}];
          "space b o" = ["pane::CloseOtherItems" {close_pinned = false;}];

          # code / LSP  (gd, grn, grr, gri, gra, K already match LazyVim upstream)
          "space c a" = "editor::ToggleCodeActions";
          "space c r" = "editor::Rename";
          "space c d" = "editor::Hover";
          "space c f" = "editor::Format";

          # diagnostics list (LazyVim <leader>xx = Trouble)
          "space x x" = "diagnostics::Deploy";

          # git
          "space g g" = ["task::Spawn" {task_name = "lazygit";}];
          "space g s" = "git_panel::ToggleFocus";
          "space g b" = "git::Blame";
          "space g d" = "git::Diff";

          # search / symbols
          "space s s" = "outline::Toggle";
          "space s shift-s" = "project_symbols::Toggle";
          "space s g" = "pane::DeploySearch"; # grep whole project -> multibuffer
          "space s r" = ["pane::DeploySearch" {replace_enabled = true;}];
          "space s f" = "file_finder::Toggle";
          "space s b" = "buffer_search::Deploy"; # search current buffer only

          # ui toggles
          "space u w" = "editor::ToggleSoftWrap";
          "space u t" = "theme_selector::Toggle";

          # windows
          "space w v" = "pane::SplitRight";
          "space w s" = "pane::SplitDown";
          "space w d" = ["pane::CloseActiveItem" {close_pinned = false;}];
          "space q q" = "zed::Quit";
        };
      }

      {
        # DeploySearch seeds its query from the active selection, so this
        # greps the project for whatever is highlighted.
        context = "vim_mode == visual";
        bindings = {
          "space s w" = "pane::DeploySearch";
        };
      }

      # ---------------------------------------------------------------
      # Workspace-level: works from panels that are not the editor.
      # ---------------------------------------------------------------
      {
        context = "Workspace";
        bindings = {
          "ctrl-/" = "terminal_panel::Toggle";
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";

          # displaced: ctrl-j was ToggleBottomDock (pairs with ctrl-alt-b = right dock)
          "ctrl-alt-j" = "workspace::ToggleBottomDock";

          # displaced: ctrl-k chord family -> ctrl-alt-k, same suffixes
          "ctrl-alt-k ctrl-t" = "theme_selector::Toggle";
          "ctrl-alt-k ctrl-shift-t" = "theme::ToggleMode";
          "ctrl-alt-k ctrl-s" = "zed::OpenKeymap";
          "ctrl-alt-k ctrl-o" = "workspace::Open";
          "ctrl-alt-k ctrl-p" = "workspace::ReopenLastPicker";
          "ctrl-alt-k m" = "language_selector::Toggle";
          "ctrl-alt-k n" = "encoding_selector::Toggle";
          "ctrl-alt-k s" = "workspace::SaveWithoutFormat";
        };
      }

      # ---------------------------------------------------------------
      # Editor: relocate the defaults the vim binds above displaced.
      # ---------------------------------------------------------------
      {
        context = "Editor && !menu";
        bindings = {
          # displaced: ctrl-/ was ToggleComments (gc/gcc still work)
          "ctrl-shift-/" = ["editor::ToggleComments" {advance_downwards = false;}];
          # displaced: ctrl-l was SelectLine (vim V still works)
          "ctrl-alt-shift-l" = "editor::SelectLine";
          # displaced: ctrl-k chord family -> ctrl-alt-k, same suffixes
          "ctrl-alt-k ctrl-i" = "editor::Hover";
          "ctrl-alt-k ctrl-b" = "editor::BlameHover";
          "ctrl-alt-k ctrl-z" = "editor::ToggleSoftWrap";
          "ctrl-alt-k ctrl-q" = "editor::Rewrap";
          "ctrl-alt-k ctrl-r" = "git::Restore";
          "ctrl-alt-k ctrl-l" = "editor::ToggleFold";
          "ctrl-alt-k ctrl-j" = "editor::UnfoldAll";
          "ctrl-alt-k ctrl-0" = "editor::FoldAll";
          "ctrl-alt-k p" = "editor::CopyPath";
          "ctrl-alt-k r" = "editor::RevealInFileManager";
        };
      }

      # ---------------------------------------------------------------
      # Project panel: j/k/o already work via vim mode.
      # ---------------------------------------------------------------
      {
        context = "ProjectPanel";
        bindings = {
          "space e" = "project_panel::Toggle";
          "escape" = "workspace::ActivatePaneRight";
          # grep scoped to the selected folder (Zed default: ctrl-alt-shift-f)
          "space s d" = "project_panel::NewSearchInDirectory";
          "/" = "project_panel::NewSearchInDirectory";
          "space s g" = "pane::DeploySearch";
          "space space" = "file_finder::Toggle";
          "ctrl-/" = "terminal_panel::Toggle";
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";
        };
      }

      # ---------------------------------------------------------------
      # Agent panel: escape returns to editor (space a only from editor).
      # ---------------------------------------------------------------
      #{
      #  context = "AgentPanel";
      #  bindings = {
      #    "escape" = "workspace::ActivatePaneRight";
      #  };
      #}

      # ---------------------------------------------------------------
      # Terminal: shift variants so readline ctrl-h/k/l stay intact.
      # ---------------------------------------------------------------
      {
        context = "Terminal";
        bindings = {
          "ctrl-/" = "terminal_panel::Toggle";
          "ctrl-shift-h" = "workspace::ActivatePaneLeft";
          "ctrl-shift-j" = "workspace::ActivatePaneDown";
          "ctrl-shift-k" = "workspace::ActivatePaneUp";
          "ctrl-shift-l" = "workspace::ActivatePaneRight";
        };
      }
    ];
  };
}
