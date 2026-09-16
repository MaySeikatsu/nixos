;;; config.el -*- lexical-binding: t; -*-
;;
;; Personal Doom configuration. Most changes here apply with `SPC h r r`
;; (reload) — no `doom sync` needed unless init.el/packages.el changed.
;; Look anything up: `SPC h k` (key), `SPC h f` (function), `SPC h v` (var),
;; put cursor on a symbol and press `K`.

;;; ── identity ─────────────────────────────────────────────────────────
(setq user-full-name "Maike")

;; Emacs spawns child processes through `shell-file-name`; fish is not POSIX
;; and breaks diff-hl/TRAMP/etc. Use bash internally, fish only in terminals.
(setq shell-file-name (executable-find "bash"))
(setq-default explicit-shell-file-name (executable-find "fish"))

;;; ── look & feel ──────────────────────────────────────────────────────
;; rose-pine-doom-emacs ships bare *-theme.el files without registering a
;; theme dir, so add its build dir to the theme load path ourselves.
(when-let* ((lib (locate-library "doom-rose-pine-theme")))
  (add-to-list 'custom-theme-load-path (file-name-directory lib)))
;; Rosé Pine port looked washed out/low contrast — parked. Re-enable with
;; (setq doom-theme 'doom-rose-pine-moon). Try alternatives live: SPC h t
(setq doom-theme 'doom-tokyo-night  ; 'doom-moonlight 'doom-palenight 'doom-one are close relatives

      doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 13)
      doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 20)
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font" :size 13)
      doom-symbol-font (font-spec :family "Symbols Nerd Font Mono")
      display-line-numbers-type 'relative
      scroll-margin 6
      confirm-kill-emacs nil)      ; daemon: closing a frame shouldn't nag

;; Window/frame
(setq-default truncate-lines t)

;; Ligatures (JetBrainsMono supports the full set)
(plist-put! +ligatures-extra-symbols :name "»" :lambda "λ")

;; Which-key: show quicker, that's the "keybinds showing" part.
(setq which-key-idle-delay 0.3
      which-key-idle-secondary-delay 0.05
      which-key-max-description-length 40
      which-key-sort-order 'which-key-key-order-alpha)

;;; ── evil tweaks (vim/helix habits) ───────────────────────────────────
(setq evil-split-window-below t
      evil-vsplit-window-right t
      evil-want-fine-undo t
      evil-kill-on-visual-paste nil)      ; p in visual doesn't clobber register
(setq-default evil-escape-key-sequence "jk")
;; keep the cursor centered after search jumps like `scrolloff`
(advice-add #'evil-ex-search-next :after (lambda (&rest _) (recenter)))
(advice-add #'evil-ex-search-previous :after (lambda (&rest _) (recenter)))

;;; ── files, projects, tree ────────────────────────────────────────────
(setq projectile-project-search-path '("~/.config/nixos" "~/code" "~/git" "~/Documents")
      projectile-auto-discover t)

;; treemacs — sidebar (4a, primary)
(after! treemacs
  (setq treemacs-width 32
        treemacs-follow-mode t
        treemacs-filewatch-mode t
        treemacs-git-mode 'deferred
        treemacs-collapse-dirs 3
        treemacs-position 'left)
  (treemacs-project-follow-mode 1))

;; dirvish — dired replacement (4b). `SPC f d` / `-` in a buffer, `q` to quit.
;; To make dirvish the *sidebar* instead of treemacs: comment `(treemacs +lsp)`
;; in init.el, run `doom sync`, then bind `SPC o p` to #'dirvish-side below.
(after! dirvish
  (setq dirvish-attributes '(vc-state subtree-state nerd-icons collapse git-msg file-time file-size)
        dirvish-side-width 32
        dirvish-quick-access-entries
        '(("h" "~/" "Home")
          ("n" "~/.config/nixos/" "nixos")
          ("o" "~/Documents/obsidian/" "obsidian")
          ("g" "~/org/" "org")
          ("d" "~/Downloads/" "Downloads"))))

;;; ── completion ───────────────────────────────────────────────────────
(after! corfu
  (setq corfu-auto-delay 0.1
        corfu-auto-prefix 2
        corfu-preselect 'first))

;;; ── lsp-mode / lsp-ui (3a) ───────────────────────────────────────────
(after! lsp-mode
  (setq lsp-headerline-breadcrumb-enable t
        lsp-headerline-breadcrumb-segments '(project file symbols)
        lsp-lens-enable t
        lsp-inlay-hint-enable t
        lsp-signature-auto-activate t
        lsp-idle-delay 0.3
        lsp-log-io nil
        lsp-enable-suggest-server-download nil)  ; Nix provides servers
  ;; nix: prefer nil
  (setq lsp-nix-nil-formatter ["nixfmt"])
  ;; yaml: k8s + azure pipelines + gh actions schemas
  (setq lsp-yaml-schemas
        '((kubernetes . ["/*.k8s.yaml" "/k8s/*.yaml" "/manifests/*.yaml"])
          ("https://json.schemastore.org/github-workflow.json" . ["/.github/workflows/*"])
          ("https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/main/service-schema.json"
           . ["/azure-pipelines*.yml" "/pipelines/*.yml" "/.azure-pipelines/*.yml"])))
  ;; python
  (setq lsp-pyright-langserver-command "basedpyright"))

(after! lsp-ui
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-show-with-cursor nil     ; K shows docs; hover doesn't spam
        lsp-ui-doc-show-with-mouse t
        lsp-ui-doc-position 'at-point
        lsp-ui-doc-max-height 20
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-show-hover nil
        lsp-ui-peek-enable t))

;; hcl/terraform: lsp-mode's terraform-ls client
(after! terraform-mode
  (setq terraform-format-on-save t))
(add-hook 'terraform-mode-local-vars-hook #'lsp! 'append)

;; C#: omnisharp from Nix
(after! csharp-mode
  (setq lsp-csharp-server-path (executable-find "OmniSharp")))

;;; ── formatting (apheleia, format-on-save) ────────────────────────────
(after! apheleia
  (setf (alist-get 'nixfmt apheleia-formatters) '("nixfmt")
        (alist-get 'terraform apheleia-formatters) '("terraform" "fmt" "-")
        (alist-get 'ruff apheleia-formatters) '("ruff" "format" "-")
        (alist-get 'stylua apheleia-formatters) '("stylua" "-"))
  (setf (alist-get 'nix-mode apheleia-mode-alist) 'nixfmt
        (alist-get 'terraform-mode apheleia-mode-alist) 'terraform
        (alist-get 'python-mode apheleia-mode-alist) 'ruff
        (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff
        (alist-get 'lua-mode apheleia-mode-alist) 'stylua))
;; don't format these on save (yaml / markdown formatters tend to be opinionated)
(setq +format-on-save-disabled-modes
      '(sql-mode tex-mode latex-mode org-msg-edit-mode yaml-mode markdown-mode))

;;; ── diagnostics / spell ──────────────────────────────────────────────
(after! flymake (setq flymake-no-changes-timeout 0.5))
(after! ispell
  (setq ispell-program-name "hunspell"
        ispell-dictionary "en_US,de_DE"
        ispell-local-dictionary-alist ; silence "Missing equivalent for …" noise
        '(("en_US,de_DE" "[[:alpha:]]" "[^[:alpha:]]" "[']" t ("-d" "en_US,de_DE") nil utf-8)))
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "en_US,de_DE"))

;;; ── terminal ─────────────────────────────────────────────────────────
(after! vterm
  (setq vterm-max-scrollback 20000
        vterm-shell (or (executable-find "fish") shell-file-name)
        vterm-kill-buffer-on-exit t))

;;; ── git ──────────────────────────────────────────────────────────────
(after! magit
  (setq magit-diff-refine-hunk 'all
        magit-save-repository-buffers 'dontask
        git-commit-summary-max-length 72)
  ;; conventional commit prefix helper: SPC g c c then type `feat:` etc.
  (add-hook 'git-commit-setup-hook
            (lambda () (setq-local fill-column 72))))

;;; ── org: tasks, agenda, journal, capture (5a) ────────────────────────
(setq org-directory "~/org/")
(after! org
  (setq org-agenda-files (list org-directory (expand-file-name "journal/" org-directory))
        org-default-notes-file (expand-file-name "inbox.org" org-directory)
        org-log-done 'time
        org-log-into-drawer t
        org-hide-emphasis-markers t
        org-startup-folded 'content
        org-ellipsis " ▾"
        org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "|" "DONE(d)" "CANCELLED(c@)"))
        org-todo-keyword-faces
        '(("NEXT" . +org-todo-active) ("WAIT" . +org-todo-onhold) ("CANCELLED" . +org-todo-cancel))
        org-capture-templates
        `(("t" "Todo" entry (file+headline ,(expand-file-name "inbox.org" org-directory) "Inbox")
           "* TODO %?\n%U\n%a" :prepend t)
          ("n" "Note" entry (file+headline ,(expand-file-name "inbox.org" org-directory) "Notes")
           "* %?\n%U\n%i" :prepend t)
          ("w" "Work ticket" entry (file+headline ,(expand-file-name "work.org" org-directory) "Tickets")
           "* TODO %^{Ticket ID} — %^{Title}\n:PROPERTIES:\n:TICKET: %\\1\n:END:\n%U\n%?")
          ("j" "Journal" entry (function org-journal-find-location)
           "* %(format-time-string org-journal-time-format)%?" :empty-lines 1)))
  (add-hook 'org-mode-hook #'org-appear-mode))

(after! org-journal
  (setq org-journal-dir (expand-file-name "journal/" org-directory)
        org-journal-file-type 'weekly
        org-journal-date-format "%A, %d %B %Y"))

(use-package! org-super-agenda
  :after org-agenda
  :config
  (setq org-super-agenda-groups
        '((:name "Today" :time-grid t :scheduled today)
          (:name "Overdue" :deadline past :scheduled past)
          (:name "Next" :todo "NEXT")
          (:name "Work" :file-path "work")
          (:name "Waiting" :todo "WAIT")
          (:auto-category t)))
  (org-super-agenda-mode 1))

(after! org-download
  (setq org-download-method 'directory
        org-download-image-dir "images"))

;;; ── obsidian vault ───────────────────────────────────────────────────
(use-package! obsidian
  :init ; must be set before the package loads, it reads the dir at load time
  (setq obsidian-directory "~/Documents/obsidian/"
        obsidian-inbox-directory "personal (main)/1 - Projects"
        obsidian-daily-notes-directory "personal (main)/2 - Areas/Journal"
        markdown-enable-wiki-links t)
  :config
  (global-obsidian-mode t)
  (obsidian-backlinks-mode t))

;;; ── calendar (app/calendar shows org agenda) ─────────────────────────
(after! calfw
  (setq calendar-week-start-day 1
        cfw:org-overwrite-default-keybinding t))

;;; ── rss ──────────────────────────────────────────────────────────────
(after! elfeed
  (setq rss-feed-list-file (expand-file-name "elfeed.org" org-directory)
        elfeed-search-filter "@2-weeks-ago +unread"))
(after! elfeed-org
  (setq rss-org-files (list (expand-file-name "elfeed.org" org-directory))))

;;; ── password store (gopass, pass-compatible) ─────────────────────────
(setq auth-source-pass-filename "~/.password-store"
      password-store-executable "gopass")
(after! password-store
  (setq password-store-password-length 24))

;;; ── kubernetes / docker ──────────────────────────────────────────────
(use-package! kubernetes
  :commands (kubernetes-overview)
  :config
  (setq kubernetes-poll-frequency 3600
        kubernetes-redraw-frequency 3600))
(use-package! kubernetes-evil :after kubernetes)

;;; ── AI ───────────────────────────────────────────────────────────────
;; gptel: default backend Claude; API key read via auth-source from gopass:
;;   gopass insert api/anthropic   (username field irrelevant, secret = key)
;; Add an `api/openai` entry likewise if you want the OpenAI backend.
(after! gptel
  (setq gptel-default-mode 'org-mode
        gptel-model 'claude-sonnet-4-5
        gptel-backend (gptel-make-anthropic "Claude"
                        :stream t
                        :key (lambda () (auth-source-pass-get 'secret "api/anthropic"))))
  (gptel-make-openai "OpenAI" :stream t
    :key (lambda () (auth-source-pass-get 'secret "api/openai"))
    :models '(gpt-4o gpt-4.1)))

;; Copilot inline suggestions. Server comes from Nix (copilot-language-server).
;; Not enabled globally — an erroring hook at startup kills the daemon.
;; Toggle per buffer with SPC l p, `M-x copilot-login` once.
(use-package! copilot
  :commands (copilot-mode copilot-login)
  :config
  (setq copilot-server-executable (executable-find "copilot-language-server")
        copilot-indent-offset-warning-disable t
        copilot-idle-delay 0.5)
  (map! :map copilot-completion-map
        "<tab>"   #'copilot-accept-completion
        "TAB"     #'copilot-accept-completion
        "M-<tab>" #'copilot-accept-completion-by-word
        "M-n"     #'copilot-next-completion
        "M-p"     #'copilot-previous-completion))

;; claude-code.el: runs the `claude` CLI in a vterm side window.
(use-package! claude-code
  :commands (claude-code claude-code-toggle claude-code-send-command)
  :config
  (setq claude-code-terminal-backend 'vterm))

;;; ── keybindings ──────────────────────────────────────────────────────
;; All custom binds carry :desc so which-key shows them.
(map! :leader
      ;; file tree / explorer
      :desc "Toggle treemacs"          "o p" #'treemacs
      :desc "Treemacs: find file"      "o P" #'treemacs-find-file
      :desc "Dirvish here"             "f d" #'dirvish
      :desc "Dirvish side"             "o d" #'dirvish-side
      ;; terminals
      :desc "vterm here"               "o T" #'vterm
      ;; apps
      :desc "RSS (elfeed)"             "o e" #'elfeed
      :desc "Kubernetes"               "o k" #'kubernetes-overview
      :desc "Docker"                   "o D" #'docker
      :desc "Passwords"                "o w" #'password-store-copy
      ;; org / notes
      (:prefix ("n" . "notes")
       :desc "Agenda"                  "a" #'org-agenda
       :desc "Capture"                 "n" #'org-capture
       :desc "Inbox"                   "i" (cmd! (find-file (expand-file-name "inbox.org" org-directory)))
       :desc "Work tickets"            "w" (cmd! (find-file (expand-file-name "work.org" org-directory)))
       (:prefix ("o" . "obsidian")
        :desc "Jump to note"           "j" #'obsidian-jump
        :desc "Search vault"           "s" #'obsidian-search
        :desc "Capture (new note)"     "c" #'obsidian-capture
        :desc "Daily note"             "d" #'obsidian-daily-note
        :desc "Insert link"            "l" #'obsidian-insert-wikilink
        :desc "Backlinks"              "b" #'obsidian-backlink-jump
        :desc "Tags"                   "t" #'obsidian-find-tag))
      ;; AI
      (:prefix ("l" . "llm")
       :desc "gptel chat"              "l" #'gptel
       :desc "gptel send"              "s" #'gptel-send
       :desc "gptel menu"              "m" #'gptel-menu
       :desc "gptel rewrite region"    "r" #'gptel-rewrite
       :desc "Claude Code toggle"      "c" #'claude-code-toggle
       :desc "Claude Code command"     "C" #'claude-code-send-command
       :desc "Copilot toggle"          "p" #'copilot-mode)
      ;; help
      :desc "Cheat sheet"              "h SPC" #'+my/cheatsheet)

;; dired/dirvish: `-` opens parent dir, like vim-vinegar / oil.nvim
(map! :n "-" #'dired-jump)

;; treemacs/dirvish quick toggles, LazyVim style <leader>e
(map! :leader :desc "Explorer (treemacs)" "e" #'treemacs)

;; casual transient menus (discoverable menus inside dired/ibuffer/calc)
(after! dired (map! :map dired-mode-map :n "?" #'casual-dired-tmenu))
(after! ibuffer (map! :map ibuffer-mode-map :n "?" #'casual-ibuffer-tmenu))

;;; ── cheat sheet ──────────────────────────────────────────────────────
(defun +my/cheatsheet ()
  "Open the personal keybinding cheat sheet (cheatsheet.org next to config.el)."
  (interactive)
  (find-file-read-only (expand-file-name "cheatsheet.org" doom-user-dir)))
