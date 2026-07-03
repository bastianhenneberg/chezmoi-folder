;;; init.el -*- lexical-binding: t; -*-

;; Doom-Module fuer Bastians Setup: PHP/Laravel, Vue, React/TypeScript,
;; Markdown, Shell. Vim-nah (evil). Nach Aenderungen: 'doom sync' laufen lassen.

(doom! :input

       :completion
       (corfu +orderless)  ; complete with cap(f), cape and a flying feather!
       vertico             ; the search engine of the future

       :ui
       doom                ; what makes DOOM look the way it does
       dashboard           ; a nifty splash screen for Emacs
       hl-todo             ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       (ligatures +extra)  ; ligatures and symbols to make your code pretty again
       modeline            ; snazzy, Atom-inspired modeline, plus API
       ophints             ; highlight the region an operation acts on
       (popup +defaults)   ; tame sudden yet inevitable temporary windows
       treemacs            ; a project drawer, like neotree but cooler
       (vc-gutter +pretty) ; vcs diff in the fringe
       vi-tilde-fringe     ; fringe tildes to mark beyond EOB
       workspaces          ; tab emulation, persistence & separate workspaces

       :editor
       (evil +everywhere)  ; come to the dark side, we have cookies
       file-templates      ; auto-snippets for empty files
       fold                ; (nigh) universal code folding
       (format)            ; automated prettiness (manuell via SPC c f)
       snippets            ; my elves. They type so I don't have to
       (whitespace +guess +trim)

       :emacs
       dired               ; making dired pretty [functional]
       electric            ; smarter, keyword-based electric-indent
       tramp               ; remote files at your arthritic fingertips
       undo                ; persistent, smarter undo
       vc                  ; version-control and Emacs, sitting in a tree

       :term
       vterm               ; almost the best terminal emulation in Emacs

       :checkers
       syntax                    ; tasing you for every semicolon you forget
       (spell +flyspell +hunspell) ; deutsche/englische Rechtschreibpruefung

       :tools
       docker
       editorconfig        ; let someone else argue about tabs vs spaces
       (eval +overlay)     ; run code, run (also, repls)
       lookup              ; navigate your code and its documentation
       (lsp +eglot)        ; M-x vscode (eglot = eingebauter LSP-Client)
       magit               ; a git porcelain for Emacs
       tree-sitter         ; syntax and parsing, sitting in a tree...

       :os
       (:if (featurep :system 'macos) macos)
       ;;tty

       :lang
       emacs-lisp          ; drown in parentheses
       (javascript +lsp +tree-sitter) ; JS/TS/JSX/TSX + Vue-Script
       json                ; At least it ain't XML
       (markdown +grip)    ; writing docs for people to ignore
       (org +pretty)       ; organize your plain life in plain text
       (php +lsp)          ; Laravel & Co.
       (rust +lsp +tree-sitter) ; Fe2O3.unwrap() — via rust-analyzer
       sh                  ; she sells {ba,z,fi}sh shells
       (web +lsp)          ; Vue-Templates, HTML, CSS
       yaml                ; JSON, but readable

       :email

       :app

       :config
       (default +bindings +smartparens))
