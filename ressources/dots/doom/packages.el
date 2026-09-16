;; -*- no-byte-compile: t; -*-
;;; packages.el
;;
;; Extra elisp packages beyond the modules in init.el. Run `doom sync` after
;; editing. `doom upgrade` bumps Doom + pins, `doom sync -u` updates unpinned.

;; ── provided by Nix (programs.emacs.extraPackages) ─────────────────────
;; vterm's C module is compiled by Nix; tell straight not to build it.
(package! vterm :built-in t)

;; ── theme ─────────────────────────────────────────────────────────────
(package! rose-pine-doom-emacs
  :recipe (:host github :repo "donniebreve/rose-pine-doom-emacs"
           :files ("*.el")))

;; ── notes / organisation ──────────────────────────────────────────────
(package! obsidian)                 ; browse/edit the Obsidian vault
(package! org-super-agenda)         ; grouped agenda views
(package! org-appear)               ; reveal markup under cursor
(package! org-download)             ; paste images into org
(package! org-modern)               ; pulled by +pretty on new Doom; harmless
(package! toc-org)

;; ── infra ─────────────────────────────────────────────────────────────
(package! kubernetes)
(package! kubernetes-evil)
(package! k8s-mode)
(package! jinja2-mode)

;; ── AI ────────────────────────────────────────────────────────────────
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))
(package! claude-code
  :recipe (:host github :repo "stevemolitor/claude-code.el" :files ("*.el")))

;; ── QoL ───────────────────────────────────────────────────────────────
(package! evil-textobj-tree-sitter) ; vif / vaf etc. via treesitter (if not pulled by module)
(package! casual)                   ; transient menus for dired/calc/ibuffer/etc.
(package! rainbow-delimiters)
