;;; init.el -*- lexical-binding: t; -*-
;;
;; Doom module selection. After editing: `doom sync` then `SPC q r`.
;; `SPC h d m` (or M-x doom/help-modules) documents every module + flags.
;; Managed in ~/.config/nixos/ressources/dots/doom (symlinked to ~/.config/doom).

(doom! :input
       ;;japanese

       :completion
       (corfu +orderless +icons)   ; in-buffer completion popup (like blink.cmp)
       (vertico +icons)            ; minibuffer search (like telescope/snacks.picker)

       :ui
       doom                        ; base theme framework
       dashboard                   ; splash screen (was doom-dashboard)
       (emoji +unicode)
       hl-todo                     ; highlight TODO/FIXME/NOTE/HACK
       indent-guides
       ligatures                   ; JetBrainsMono has them
       modeline
       nav-flash                   ; flash line after big jumps
       ophints                     ; highlight region an op acts on
       (popup +defaults)           ; tame temporary windows
       (smooth-scroll +interpolate)
       (treemacs +lsp)             ; file tree sidebar (snacks.explorer equivalent)
       (vc-gutter +pretty)         ; git signs in the fringe
       vi-tilde-fringe
       window-select               ; SPC w w with hints
       workspaces                  ; SPC TAB: tab-like workspaces
       zen                         ; SPC t z distraction free

       :editor
       (evil +everywhere)          ; vim everywhere
       file-templates
       fold                        ; za zm zr
       (format +onsave)            ; apheleia: fmt on save (terraform fmt, nixfmt…)
       multiple-cursors            ; gzz / gzA
       snippets
       (whitespace +guess +trim)
       word-wrap

       :emacs
       (dired +dirvish +icons)     ; dirvish = dired on steroids (4b)
       electric
       (ibuffer +icons)
       tramp                       ; edit files over ssh: /ssh:host:/path
       undo                        ; persistent undo tree
       vc

       :term
       vterm                       ; real terminal (SPC o t)

       :checkers
       (syntax +flymake +icons)    ; diagnostics
       (spell +hunspell +everywhere)
       grammar

       :tools
       (debugger +lsp)             ; dap-mode
       direnv                      ; picks up devshells → LSPs find project tools
       docker
       editorconfig
       (eval +overlay)
       llm                         ; gptel (Claude/OpenAI/Copilot/…)
       lookup                      ; K, gd, SPC s o
       (lsp +peek)                 ; lsp-mode + lsp-ui
       magit                       ; SPC g g
       make
       (pass +auth)                ; gopass
       pdf
       terraform
       tree-sitter

       :os
       tty

       :lang
       (cc +lsp +tree-sitter)
       (csharp +lsp +tree-sitter)
       data                        ; csv, xml
       emacs-lisp
       (go +lsp +tree-sitter)
       (javascript +lsp +tree-sitter)   ; js/ts
       (json +lsp +tree-sitter)
       (lua +lsp +tree-sitter)
       (markdown +grip)
       (nix +lsp +tree-sitter)
       (org +pretty +journal +pandoc +present +dragndrop)
       (python +lsp +tree-sitter +pyright)
       (rust +lsp +tree-sitter)
       (sh +lsp +tree-sitter)
       (web +lsp +tree-sitter)          ; html/css
       (yaml +lsp +tree-sitter)
       plantuml
       ;;(latex +lsp)

       :email
       ;; Proton needs protonmail-bridge + mbsync + mu. Later project:
       ;;(mu4e +org +gmail)

       :app
       calendar                    ; SPC o c — calfw showing org agenda
       (rss +org)                  ; elfeed, SPC o e (custom bind in config.el)
       ;;everywhere

       :config
       (default +bindings +smartparens))
