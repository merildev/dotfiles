;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Doom config
(setq-default
 doom-theme 'doom-monokai-pro
 doom-font (font-spec :family "monospace" :size 13)
 doom-variable-pitch-font (font-spec :family "Overpass")
 doom-big-font (font-spec :family "monospace" :size 15)
 doom-serif-font (font-spec :family "Droid Sans" :weight 'light)
 doom-themes-enable-bold t
 doom-themes-enable-italic t)

;; Misc. settings
(setq org-directory "~/docs")
(setq display-line-numbers-type 'relative)
(setq-default show-trailing-whitespace t)
(setq-default fill-column 80)

;; Indentation madness...
(setq-default evil-shift-width 2
              standard-indent 2
              tab-width 2)
(setq indent-tabs-mode nil)
(setq javascript-indent-level 2)
(setq typecript-indent-level 2)
(setq js-indent-level 2)
(setq jsx-indent-level 2)
(setq js2-basic-offset 2)
(setq web-mode-markup-indent-offset 2)
(setq web-mode-css-indent-offset 2)
(setq web-mode-code-indent-offset 2)
(setq css-indent-offset 2)

;; LSP
(setq lsp-file-watch-threshold 20000)

;; Prioritise javascript-eslint checker
(setq-hook! 'js2-mode-hook flycheck-checker 'javascript-eslint)
(setq-hook! 'typescript-tsx-mode-hook flycheck-checker 'javascript-eslint)
(setq-hook! 'typescript-mode-hook flycheck-checker 'javascript-eslint)

;; Format on save -- Disable LSP
(setq-hook! 'js2-mode-hook +format-with-lsp nil)
(setq-hook! 'typescript-tsx-mode-hook +format-with-lsp nil)
(setq-hook! 'typescript-mode-hook +format-with-lsp nil)
(setq-hook! 'web-hook +format-with-lsp nil)

(setq +format-on-save-enabled-modes
      '(not emacs-lisp-mode  ; elisp's mechanisms are good enough
            sql-mode         ; sqlformat is currently broken
            tex-mode         ; latexindent is broken
            java-mode
            latex-mode))

;; Better window selection
(map!
 (:leader
  :desc "Switch to window 0" :n "0" #'treemacs-select-window
  :desc "Switch to window 1" :n "1" #'winum-select-window-1
  :desc "Switch to window 2" :n "2" #'winum-select-window-2
  :desc "Switch to window 3" :n "3" #'winum-select-window-3
  :desc "Switch to window 4" :n "4" #'winum-select-window-4
  :desc "Switch to window 5" :n "5" #'winum-select-window-5
  :desc "Switch to window 6" :n "6" #'winum-select-window-6
  :desc "Switch to window 7" :n "7" #'winum-select-window-7
  :desc "Switch to window 8" :n "8" #'winum-select-window-8
  :desc "Switch to window 9" :n "9" #'winum-select-window-9))

(add-hook! typescript-mode
  (setq typescript-indent-level 2))
(setq-hook! 'typescript-tsx-mode-hook web-mode-code-indent-offset 2)


;; Improve ivy
(map!
 :leader
 :desc "Resume latest ivy" :nv "r l" #'ivy-resume)

;; Email configuration
(setq
 mu4e-attachment-dir "~/dl"
 mu4e-headers-include-related nil
 mu4e-index-lazy-check nil)
(setq +mu4e-backend 'offlineimap)
(after! mu4e
  (setq mail-envelope-from 'header
        mail-user-agent 'mu4e-user-agent
        mail-specify-envelope-from 't
        message-kill-buffer-on-exit 't
        message-send-mail-function #'message-send-mail-with-sendmail
        message-sendmail-envelope-from 'header
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-sendmail-f-is-evil 't
        send-mail-function #'smtpmail-send-it
        sendmail-program "/usr/bin/msmtp"))

;; Modeline
(use-package! mu4e
  :config
  (setq
   doom-modeline-height 25
   doom-modeline-enable-word-count t
   doom-modeline-buffer-encoding nil
   doom-modeline-github t
   doom-modeline-mu4e t
   doom-modeline-gnus nil))

(after! ivy-posframe
  (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-center))))

;; Treemacs config
(remove-hook 'doom-load-theme-hook #'doom-themes-treemacs-config)
(after! treemacs
  (setq treemacs-no-png-images t)
  (treemacs-follow-mode))

;; GPG settings/keyring
(setq auth-sources '("~/.authinfo.gpg")
      auth-source-cache-expiry nil) ; default is 7200 (2h)
(setq password-cache-expiry nil)
(setq epa-armor t)
(setq epg-pinentry-mode 'loopback)
(after! pinentry
  :config
  (pinentry-start))
(keychain-refresh-environment)

;; Auto flyspell
(add-hook! 'mu4e-compose-mode-hook
          (defun my-do-compose ()
            "My settings for message composition."
            (set-fill-column 80)
            (flyspell-mode)))
(defun +markdown-flyspell-word-p ()
  "Return t if point is on a word that should be spell checked.
Return nil if on a link url, markup, html, or references."
  (let ((faces (doom-enlist (get-text-property (point) 'face))))
    (or (and (memq 'font-lock-comment-face faces)
             (memq 'markdown-code-face faces))
        (not (cl-loop with unsafe-faces = '(markdown-reference-face
                                            markdown-url-face
                                            markdown-markup-face
                                            markdown-comment-face
                                            markdown-html-attr-name-face
                                            markdown-html-attr-value-face
                                            markdown-html-tag-name-face
                                            markdown-code-face)
                      for face in faces
                      if (memq face unsafe-faces)
                      return t)))))
(set-flyspell-predicate! '(markdown-mode gfm-mode)
  #'+markdown-flyspell-word-p)
(add-hook 'markdown-mode-hook 'flyspell-mode)

;; Magit inline diff
(setq magit-diff-refine-hunk (quote all))

;; vterm
(evil-define-key 'insert vterm-mode-map (kbd "C-k") #'vterm-send-up)
(evil-define-key 'insert vterm-mode-map (kbd "C-j") #'vterm-send-down)

;; Load private stuff
(when (file-exists-p "~/.config/priv/config.el")
  (load-file "~/.config/priv/config.el"))
