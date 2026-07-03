;; -*- no-byte-compile: t; -*-
;;; packages.el

;; Zusaetzliche Pakete kommen hier rein, z.B.:
;;   (package! some-cool-mode)
;; Danach 'doom sync' laufen lassen.

;; Claude Code IDE-Integration (MCP: Selektion, eglot-Diagnostics, Datei-Editing)
(package! claude-code-ide :recipe (:host github :repo "manzaltu/claude-code-ide.el"))

;; Vorschlaege fuer spaeter (auskommentiert lassen, bis gebraucht):
;; (package! catppuccin-theme)   ; falls dir doom-one nicht gefaellt
;; (package! blade-mode)         ; Laravel-Blade-Templates
