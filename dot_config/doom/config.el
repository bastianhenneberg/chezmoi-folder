;;; config.el -*- lexical-binding: t; -*-

;; Nach Aenderungen an dieser Datei reicht meist ein Neustart von Emacs oder
;; 'M-x doom/reload'. Bei neuen Paketen/Modulen: 'doom sync' im Terminal.

;; --- Identitaet -------------------------------------------------------------
(setq user-full-name "Bastian Henneberg"
      user-mail-address "henneberg@peppermint-digital.de")

;; --- Font -------------------------------------------------------------------
;; JetBrains Mono Nerd Font ist installiert. Groesse nach Geschmack anpassen.
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 15)
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font" :size 15)
      doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 22))

;; --- Theme ------------------------------------------------------------------
;; doom-one ist ein solider dunkler Default. Alternativen zum Ausprobieren:
;; doom-vibrant, doom-tokyo-night, doom-gruvbox, doom-nord, catppuccin.
(setq doom-theme 'doom-one)

;; --- Zeilennummern ----------------------------------------------------------
;; 'relative = relative Nummern (Vim-Style, gut fuer 5j / 3k Spruenge).
(setq display-line-numbers-type 'relative)

;; --- Sprache / Rechtschreibung ---------------------------------------------
;; Standard-Woerterbuch Deutsch; Umschalten mit 'M-x ispell-change-dictionary'.
(after! ispell
  (setq ispell-dictionary "de_DE"))

;; --- PATH fuer Language-Server ---------------------------------------------
;; Aus Hyprland gestartetes Emacs erbt NICHT den zsh-PATH, kennt also
;; ~/.local/bin nicht -> die per npm installierten LSP-Server (intelephense,
;; typescript-language-server, vue-language-server) werden nicht gefunden.
;; Darum ~/.local/bin explizit auf exec-path und Prozess-PATH legen.
(let ((local-bin (expand-file-name "~/.local/bin")))
  (add-to-list 'exec-path local-bin)
  (setenv "PATH" (concat local-bin path-separator (getenv "PATH"))))

;; --- PHP: intelephense als eglot-Server erzwingen --------------------------
;; eglots EINGEBAUTER Default fuer php-mode ist phpactor bzw. felixfbeckers
;; php-language-server (beide nicht installiert) -> eglot startet einen
;; nicht existierenden Server -> "server died". Darum intelephense (per npm
;; in ~/.local/bin) voranstellen; add-to-list hat Vorrang vor dem Default.
(after! eglot
  (add-to-list 'eglot-server-programs
               '((php-mode phps-mode php-ts-mode) . ("intelephense" "--stdio"))))

;; --- Vue: .vue via typescript-language-server + @vue/typescript-plugin ------
;; Volar 3.x macht Script-Intelligenz nur noch über tsserver + Vue-Plugin
;; (Hybrid-Mode). Eigene Ableitung von web-mode NUR für .vue, damit der
;; Vue-/TS-Server nicht auch für andere web-mode-Dateien (HTML/Blade) startet.
(define-derived-mode vue-web-mode web-mode "Vue"
  "web-mode für .vue mit Volar-Anbindung über eglot (typescript-language-server + @vue/typescript-plugin).")
(add-to-list 'auto-mode-alist '("\\.vue\\'" . vue-web-mode))
(after! eglot
  (add-to-list 'eglot-server-programs
               `((vue-web-mode :language-id "vue")
                 . ("typescript-language-server" "--stdio"
                    :initializationOptions
                    (:plugins [(:name "@vue/typescript-plugin"
                                :location ,(expand-file-name "~/.local/lib/node_modules/@vue/typescript-plugin")
                                :languages ["vue"])])))))

;; --- Org --------------------------------------------------------------------
(setq org-directory "~/org/")

;; --- Wayland / Hyprland -----------------------------------------------------
;; Zwischenablage sauber mit dem restlichen Wayland-Desktop teilen.
(setq select-enable-clipboard t
      select-enable-primary t)

;; --- Kleine Komfort-Defaults ------------------------------------------------
(setq confirm-kill-emacs nil)              ; kein Nachfragen beim Beenden
(setq-default delete-by-moving-to-trash t) ; Loeschen -> Papierkorb
(setq window-combination-resize t)         ; neue Fenster teilen Platz fair auf

;; Beim Speichern automatisch trailing Whitespace behalten wie gehabt (Modul
;; whitespace +trim raeumt bereits auf). Format-on-save bewusst AUS, damit
;; grosse Diffs nicht ueberraschen -> manuell mit 'SPC c f'.

;; Hier ist Platz fuer deine eigenen Anpassungen. Nuetzliche Hilfe:
;;   'SPC h d h'  -> Doom-Handbuch
;;   'SPC h r r'  -> Config neu laden
;;   'K' auf einem Modulnamen in init.el -> dessen Doku
