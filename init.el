;;; init.el --- Init -*- lexical-binding: t; -*-

;; Author: Luke Inglis
;; URL: https://github.com/ludamillion/esprit-emacs
;; Package-Requires: ((emacs "29.1"))
;; Keywords: maint
;; Version: 0.1.0
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;;; Code:

(require 'package)
(package-initialize)
(require 'use-package)
(setq use-package-vc-prefer-newest t)

(use-package use-package-xdg
  :vc (:url "https://codeberg.org/rossabaker/use-package-xdg")
  :demand t)

;; (use-package exec-path-from-shell
;;   :ensure t
;;   :if (memq window-system '(mac ns x))
;;   :custom
;;   (exec-path-from-shell-variables '("PATH" "MANPATH" "XDG_CONFIG_DIRS" "XDG_DATA_DIRS"))
;;   :config
;;   (exec-path-from-shell-initialize))

(let ((inhibit-message t))
  (message "Welcome to GNU Emacs / Esprit Edition")
  (message (format "Initialization time: %s" (emacs-init-time))))

(defun esprit/reload-init-file ()
  "Reload the init.el file in the Emacs directory."
  (interactive)
  (load-file (expand-file-name "init.el" user-emacs-directory)))

(keymap-global-set "<f5>" 'esprit/reload-init-file)

(set-fontset-font
 t 'symbol
 (cond
  ((member "Symbola" (font-family-list)) "Symbola")
  ((member "Symbols Nerd Font" (font-family-list)) "Symbols Nerd Font")
  ((member "Apple Symbols" (font-family-list)) "Apple Symbols")))

(set-fontset-font
 t 'emoji
 (cond
  ((member "Apple Color Emoji" (font-family-list)) "Apple Color Emoji")
  ((member "Symbols Nerd Font" (font-family-list)) "Symbols Nerd Font")
  ((member "Symbola" (font-family-list)) "Symbola")))

(set-fontset-font "fontset-default" nil "Symbola")

(defvar esprit-prose-modes
  '(
    bibtex-mode
    context-mode
    git-commit-elisp-text-mode
    latex-mode
    markdown-mode
    org-mode
    rst-mode
    text-mode
    )
  "List of which modes esprit considers prose.")

(use-package mini-ontop
  :vc (:url "https://github.com/hkjels/mini-ontop.el")
  :hook
  (after-init . mini-ontop-mode))

;;; ├──────────────────── GENERAL EMACS CONFIG
;;; │ EMACS
(use-package emacs
  :ensure nil
  :xdg-state
  (auto-save-list-prefix "saves/")
  :bind
  (("M-g r" . recentf)
   ("C-x ;" . comment-line)
   ("M-s f" . find-name-dired)
   ("C-x p l". project-list-buffers)
   ("C-x w t"  . window-layout-transpose)            ; EMACS-31
   ("C-x w r"  . window-layout-rotate-clockwise)     ; EMACS-31
   ("C-x w f h"  . window-layout-flip-leftright)     ; EMACS-31
   ("C-x w f v"  . window-layout-flip-topdown)       ; EMACS-31
   ("C-x 5 l"  . select-frame-by-name)
   ("C-x 5 s"  . set-frame-name)
   ("RET" . newline-and-indent)
   ("C-M-z" . delete-pair)
   ("M-J" . duplicate-dwim)                          ; As suggest on r/emacs by the_cecep:
   ("M-K" . kill-paragraph)                          ; Expands M-k for kill-sentence
   ("M-Z" . zap-up-to-char)                          ; Expands M-z for zap-to-char
   ("M-F" . forward-to-word)                         ; Expands M-f to jump to beginning of next word
   ("M-B" . backward-to-word)                        ; Expands M-b to jump to end of previous word
   ("M-M" . end-of-line)                             ; Expands M-m to jump to end line
   ("M-T" . transpose-sentences)                     ; Expands M-t for transposing words
   ("C-x M-t" . transpose-paragraphs)                ; Expands C-x C-t for transposing lines
   ("C-s" . isearch-forward)
   ("C-x C-m" . execute-extended-command)
   ("C-s-p"   . execute-extended-command)
   ("s-\\" . indent-region)
   ([remap capitalize-word] . capitalize-dwim)       ; Make M-c work on regions
   ([remap downcase-word] . downcase-dwim)           ; Make M-l work on regions
   ([remap upcase-word] . upcase-dwim)               ; Make M-u work on regions
   ([remap kill-buffer] . kill-current-buffer)       ; C-x k stops prompting for buffer to kill
   ([remap delete-horizontal-space] . cycle-spacing) ; M-\. Called twice, remap has same effect
   :map isearch-mode-map
   ("C-o" . isearch-occur))
  :custom
  (fill-column 100)
  (trash-directory "~/.Trash")
  (ad-redefinition-action 'accept)
  (auto-save-default t)
  (line-spacing 0.15)
  (completion-ignore-case t)
  (completions-detailed t)
  (delete-by-moving-to-trash t)
  (delete-pair-blink-delay 0)
  (delete-pair-push-mark t)                   ; EMACS-31 for easy subsequent C-x C-x
  (display-line-numbers-widen t)
  (display-fill-column-indicator-warning nil) ; EMACS-31
  (enable-recursive-minibuffers t)
  (find-ls-option '("-exec ls -ldh {} +" . "-ldh"))  ; find-dired results with human readable sizes
  (browse-url-secondary-browser-function 'eww-browse-url) ; C-u C-c RET on URLs open in EWW
  (help-window-select t)
                                        ; EMACS-31
  (kill-do-not-save-duplicates t)
  (kill-region-dwim 'emacs-word)  ; EMACS-31
  (create-lockfiles nil)   ; No lock files
  (make-backup-files nil)  ; No backup files
  (native-comp-async-on-battery-power nil)  ; No compilations when on battery EMACS-31
  (pixel-scroll-precision-use-momentum nil)
  (project-vc-extra-root-markers '("Cargo.toml" "package.json" "go.mod" "*.asd")) ; Excelent for mono repos with multiple langs, makes Eglot happy
  (vc-handled-backends '(Git))
  (ring-bell-function 'ignore)
  (read-answer-short t)
  (read-process-output-max (* 4 1024 1024)) ; 4MB
  (redisplay-skip-fontification-on-input t)
  
  (register-use-preview t)
  (resize-mini-windows 'grow-only)
  (save-interprogram-paste-before-kill t)
  (savehist-save-minibuffer-history t)    ; t is default
  (save-place-limit 600)
  (set-mark-command-repeat-pop t) ; So we can use C-u C-SPC C-SPC C-SPC... instead of C-u C-SPC C-u C-SPC...
  (split-width-threshold 170)     ; So vertical splits are preferred
  (split-height-threshold nil)
  (shr-use-colors nil)
  (switch-to-buffer-obey-display-actions t)
  (tab-always-indent 'complete)
  (tab-width 4)
  (treesit-font-lock-level 4)
  (treesit-auto-install-grammar t) ; EMACS-31
  (treesit-enabled-modes t)        ; EMACS-31
  (visible-bell nil)
  (view-lossage-auto-refresh t)  ; EMACS-31 auto updates C-h l usefull when teaching/debugging
  (window-combination-resize t)
  (window-resize-pixelwise nil)
  (xref-search-program 'ripgrep)
  (zone-all-frames t)            ; EMACS-31
  (zone-all-windows-in-frame t)  ; EMACS-31
  (zone-programs '[zone-pgm-rat-race])
  (grep-command "rg -nS --no-heading ")
  (grep-find-ignored-directories
   '("SCCS" "RCS" "CVS" "MCVS" ".src" ".svn" ".jj" ".git" ".hg" ".bzr" "_MTN" "_darcs" "{arch}" "node_modules" "build" "dist"))
  :config
  (global-goto-address-mode t)
  (pixel-scroll-precision-mode t)
  (delete-selection-mode t)
  ;; Make C-x 5 o repeatable
  (defvar-keymap frame-repeat-map
    :repeat t
    "o" #'other-frame
    "n" #'make-frame
    "d" #'delete-frame)
  (put 'other-frame 'repeat-map 'frame-repeat-map)

  ;; Makes everything accept utf-8 as default, so buffers with tsx and so
  ;; won't ask for encoding (because undecided-unix) every single keystroke
  (modify-coding-system-alist 'file "" 'utf-8)

  ;; MacOS specific customizations
  (when (eq system-type 'darwin)
    (setq insert-directory-program "gls"))

  (defvar xterm-extra-capabilities
    '(getSelection setSelection modifyOtherKeys)
    "For OSC 52 compatible terminals support.")
  
  ;; TERMs should use the entire window space
  (defun esprit-emacs/disable-global-scrolling-in-ansi-term ()
    "Disable global scrolling behavior in ansi-term buffers."
    (setq-local scroll-conservatively 101)
    (setq-local scroll-margin 0)
    (setq-local scroll-step 0))
  (add-hook 'term-mode-hook #'esprit-emacs/disable-global-scrolling-in-ansi-term)

  (with-eval-after-load 'term
    (define-key term-raw-map (kbd "M-v") 'term-paste)
    (define-key term-raw-map (kbd "M-e") (lambda () (interactive) (term-send-raw-string "\e"))))

  ;; TRAMP specific HACKs
  ;; See https://coredumped.dev/2025/06/18/making-tramp-go-brrrr./
  ;; A connection-local `tramp-direct-async-process' applies to every
  ;; async process Tramp starts on the host, including Eglot's LSP
  ;; server. That process is long-lived and needs Tramp's normal
  ;; connection tracking; direct-async bypasses it, so a dropped SSH
  ;; connection leaves Eglot reporting "connected" while requests go
  ;; nowhere. Toggle the connection property instead, only around
  ;; `compilation-start', so only compile/recompile get the speedup.
  (defun esprit/compilation-start-with-direct-async-process (orig-fn &rest args)
    "Enable direct async Tramp processes only for this compilation."
    (if-let* ((vec (and (file-remote-p default-directory)
                         (tramp-dissect-file-name default-directory))))
        (unwind-protect
            (progn
              (tramp-set-connection-property vec "direct-async-process" t)
              (apply orig-fn args))
          (tramp-flush-connection-property vec "direct-async-process"))
      (apply orig-fn args)))
  (advice-add 'compilation-start :around
              #'esprit/compilation-start-with-direct-async-process)

  ;; vc-ignore-dir-regexp can accumulate a tramp-file-name-regexp alternative
  ;; at runtime, which matches the "/method:host:" prefix of every remote
  ;; path and so stops locate-dominating-file (vc-find-root, project-try-vc)
  ;; from ever walking up a TRAMP directory tree. Reset to the stock value.
  (setq vc-ignore-dir-regexp locate-dominating-stop-dir-regexp)

  ;; Starts `completion-preview-mode' automatically in some modes
  (add-hook 'prog-mode-hook #'completion-preview-mode)
  (add-hook 'text-mode-hook #'completion-preview-mode)
  (add-hook 'rcirc-mode-hook #'completion-preview-mode)
  (add-hook 'erc-mode-hook #'completion-preview-mode)

  ;; A Protesilaos life savier HACK
  ;; Add option "d" to whenever using C-x s or C-x C-c, allowing a quick preview
  ;; of the diff (if you choose `d') of what you're asked to save.
  (add-to-list 'save-some-buffers-action-alist
               (list "d"
                     (lambda (buffer) (diff-buffer-with-file (buffer-file-name buffer)))
                     "show diff between the buffer and its file"))

  ;; On Terminal: changes the vertical separator to a full vertical line
  ;;              and truncation symbol to a right arrow
  (set-display-table-slot standard-display-table 'vertical-border ?\u2502)
  (set-display-table-slot standard-display-table 'truncation ?\u2192)

  ;; See `trash-directory' as it requires defining `system-move-file-to-trash'.
  (defun system-move-file-to-trash (file)
    "Use \"trash\" to move FILE to the system trash."
    (cl-assert (executable-find "trash") nil "'trash' must be installed. Needs \"brew install trash\"")
    (call-process "trash" nil 0 nil "-F"  file))
    
  (defun esprit-emacs/filtered-project-buffer-completer (project files-only)
    "A function that filters special buffers and uses `completing-read`."
    (let* ((project-buffers (project-buffers project))
           (filtered-buffers
            (cl-remove-if
             (lambda (buffer)
               (let* ((name (buffer-name buffer))
                      (trimmed-name (string-trim name)))
                 (or
                  (and (> (length trimmed-name) 1)
                       (string-prefix-p "*" trimmed-name)
                       (string-suffix-p "*" trimmed-name))
                  (and files-only (not (buffer-file-name buffer))))))
             project-buffers)))

      (if filtered-buffers
          (let* ((buffer-names (mapcar #'buffer-name filtered-buffers))
                 (selection (completing-read "Switch to project buffer: " buffer-names nil t)))
            (when selection
              (switch-to-buffer selection)))
        (message ">>> esprit-emacs: No suitable project buffers to switch to."))))
  ;; Tell project.el filter out *special buffers* on `C-x p C-b'
  (setq project-buffers-viewer 'esprit-emacs/filtered-project-buffer-completer)


  ;; So eshell git commands open an instance of THIS config of Emacs
  (setenv "GIT_EDITOR" (format "emacs --init-dir=%s " (shell-quote-argument user-emacs-directory)))
  (setenv "JJ_EDITOR" (format "emacs --init-dir=%s " (shell-quote-argument user-emacs-directory)))
  (setenv "EDITOR" (format "emacs --init-dir=%s " (shell-quote-argument user-emacs-directory)))
  (setenv "PAGER" "cat")
  ;; So rebase from eshell opens with a bit of syntax highlight
  (add-to-list 'auto-mode-alist '("/git-rebase-todo\\'" . conf-mode))

  ;; Mute NPM loglevel so it wont interfer with other issued commands like grep
  (setenv "NPM_CONFIG_LOGLEVEL" "silent")

  ;; ELISP evaluations show results in an overlay
  (defun esprit-emacs/eval-last-sexp-overlay (arg)
    "Eval last sexp and show result inline as overlay.
With prefix ARG, insert the result inline instead.
Use ⇒ if displayable, otherwise fallback to =>."
    (interactive "P")
    (let ((arrow (if (char-displayable-p ?⇒) " ; ⇒ " " ; => ")))
      (if arg
          (let ((value (elisp--eval-last-sexp nil)))
            (insert arrow (format "%S" value)))
        (let* ((value (elisp--eval-last-sexp nil))
               (str (concat arrow (format "%S" value)))
               (ov (make-overlay (point) (point))))
          (overlay-put ov 'after-string
                       (propertize str 'face 'font-lock-comment-face))
          (run-with-timer
           3 nil
           (lambda (o) (delete-overlay o))
           ov)))))
  (global-set-key (kbd "C-x C-e") #'esprit-emacs/eval-last-sexp-overlay)

  (defun esprit-emacs/copy-whole-word ()
    "Copy the symbol at point to the kill ring without moving point."
    (interactive)
    (let ((bounds (bounds-of-thing-at-point 'symbol)))
      (when bounds
        (kill-ring-save (car bounds) (cdr bounds)))))


  ;; TODO: move this to an emacs-lisp use-package section
  (defun esprit-emacs/prefer-spaces ()
    "Disable indent-tabs-mode to prefer spaces over tabs."
    (interactive)
    (setq indent-tabs-mode nil))

  ;; Only override where necessary
  (add-hook 'emacs-lisp-mode-hook #'esprit-emacs/prefer-spaces)

  ;; Colorize the '*Messages*' buffer
  (defun esprit-emacs/messages-font-lock-setup ()
    (unless font-lock-defaults
      (setq-local font-lock-defaults '(nil nil nil nil nil)))
    (font-lock-add-keywords nil
                            '(("^Loading .*"                      0 'shadow prepend)
                              ("^Package .*"                      0 'shadow prepend)
                              ("^line-move.*"                     0 'shadow prepend)
                              ("^For information abou.*"          0 'shadow prepend)
                              ("^Importing package-keyring.gpg.*" 0 'shadow prepend)
                              ("^.*[Ee]rror:? .*"                 0 'compilation-error prepend)
                              ("\\[.* times\\]"                   0 'font-lock-regexp-face prepend)
                              ("done$"                            0 'font-lock-regexp-face prepend)
                              ("^>>>.*"                           0 'font-lock-function-name-face prepend)))
    (font-lock-mode 1)
    (font-lock-flush)
    (font-lock-ensure))

  (add-hook 'messages-buffer-mode-hook #'esprit-emacs/messages-font-lock-setup)

  (with-current-buffer (messages-buffer)
    (esprit-emacs/messages-font-lock-setup))

  ;; Force abbrev-mode off entering message/mail
  (add-hook 'message-mode-hook (lambda () (abbrev-mode -1)))
  (add-hook 'mail-mode-hook    (lambda () (abbrev-mode -1)))


  ;; Recenter after save-place restore
  ;; Reference: https://emacsredux.com/blog/2026/04/07/stealing-from-the-best-emacs-configs/
  (advice-add 'save-place-find-file-hook :after
              (lambda (&rest _)
                (when buffer-file-name (ignore-errors (recenter)))))


  ;; Runs 'private.el' after Emacs inits
  (add-hook 'after-init-hook
            (lambda ()
              (let ((private-file (expand-file-name "private.el" user-emacs-directory)))
                (when (file-exists-p private-file)
                  (load private-file)))))

  :init
  ;; Keep margins from automatic resizing
  (defun esprit-emacs/set-default-window-margins ()
    "Set default left and right margins for all windows.
Unless the buffer uses `esprit-emacs/center-document-mode`
or is an ERC buffer."
    (interactive)
    (dolist (window (window-list))
      (with-current-buffer (window-buffer window)
        (unless (or (bound-and-true-p esprit-emacs/center-document-mode)
                    (derived-mode-p 'erc-mode))
          (set-window-margins window 2 0))))) ;; (LEFT RIGHT)

  (add-hook 'window-configuration-change-hook #'esprit-emacs/set-default-window-margins)

  (when (>= emacs-major-version 31)
    (tty-tip-mode nil))   ;; EMACS-31
  (tooltip-mode nil)

  (select-frame-set-input-focus (selected-frame))
  (blink-cursor-mode 0)
  (repeat-mode 1)
  (save-place-mode 1)
  (winner-mode)
  (xterm-mouse-mode 1)
  (file-name-shadow-mode 1) ; allows us to type a new path without having to delete the current one
  (global-visual-line-mode 1)
  (global-display-line-numbers-mode 1)
  )

(use-package tramp
  :custom
  (remote-file-name-inhibit-delete-by-moving-to-trash t)
  (remote-file-name-inhibit-auto-save t)
  (remote-file-name-inhibit-locks t)
  (remote-file-name-inhibit-auto-save-visited t)
  (tramp-copy-size-limit (* 2 1024 1024)) ;; 2MB
  (tramp-use-scp-direct-remote-copying t)
  (tramp-verbose 1)
  (shell-history-file-name t)
  :config
  ;; NB: must be absolute paths, not "~/.local/bin" -- tramp's
  ;; directory-existence check for tramp-remote-path entries quotes the
  ;; path when testing it remotely (test -d "$file"), so a literal ~
  ;; never gets shell-expanded and the entry is silently dropped.
  ;;
  ;; NB: this must go in :config, not :custom -- tramp-loaddefs.el
  ;; pre-binds `tramp-remote-path' via a plain `defvar' before tramp.el's
  ;; own `defcustom' runs, so `custom-initialize-reset' sees it's already
  ;; bound and silently discards any `:custom' value that references the
  ;; variable's own prior value (e.g. via `append').
  (dolist (dir '("/home/linglis/.local/bin" "/home/linglis/.local/share/mise/shims"))
    (add-to-list 'tramp-remote-path dir))
  (defun clear-memoized-caches (&rest _)
    (setq project-current-cache nil)
    (setq magit-toplevel-cache nil)
    (setq vc-git-root-cache nil))
  (defun memoize-remote (key cache orig-fn &rest args)
    "Memoize a value if the key is a remote path."
    (if (and key
             (file-remote-p key))
        (if-let* ((current (assoc key (symbol-value cache))))
            (cdr current)
          (let ((current (apply orig-fn args)))
            (set cache (cons (cons key current) (symbol-value cache)))
            current))
      (apply orig-fn args)))

  ;; Memoize current project
  (defvar project-current-cache nil)
  (defun memoize-project-current (orig &optional prompt directory)
    (memoize-remote (or directory
                        project-current-directory-override
                        default-directory)
                    'project-current-cache orig prompt directory))
  (advice-add 'project-current :around #'memoize-project-current)

  ;; Memoize magit top level
  (defvar magit-toplevel-cache nil)
  (defun memoize-magit-toplevel (orig &optional directory)
    (memoize-remote (or directory default-directory)
                    'magit-toplevel-cache orig directory))
  (advice-add 'magit-toplevel :around #'memoize-magit-toplevel)

  ;; memoize vc-git-root
  (defvar vc-git-root-cache nil)
  (defun memoize-vc-git-root (orig file)
    (let ((value (memoize-remote (file-name-directory file) 'vc-git-root-cache orig file)))
      ;; sometimes vc-git-root returns nil even when there is a root there
      (when (null (cdr (car vc-git-root-cache)))
        (setq vc-git-root-cache (cdr vc-git-root-cache)))
      value))
  (advice-add 'vc-git-root :around #'memoize-vc-git-root)
  :hook
  ((tramp-cleanup-connection . clear-memoized-caches)
   (tramp-cleanup-all-connections . clear-memoized-caches)))

(use-package tramp-rpc
  :after tramp
  :vc (:url "https://github.com/ArthurHeymans/emacs-tramp-rpc"
       :rev :newest
       :lisp-dir "lisp"))

(use-package ibuffer
  :init
  (setq ibuffer-saved-filter-groups
        '(("Default"
           ("Fundamental" (or
                           (mode . fundamental-mode)
                           (mode . text-mode)))
           ("Org"     (or
                       (mode  . org-mode)
                       (name  . "^\\*Org Src")
                       (name  . "^\\*Org Agenda\\*$")))
           ("Tramp"   (name   . "^\\*tramp.*"))
           ("Emacs"   (or
                       (name  . "^\\*scratch\\*$")
                       (name  . "^\\*Messages\\*$")
                       (name  . "^\\*Warnings\\*$")
                       (name  . "^\\*Shell Command Output\\*$")
                       (name  . "^\\*Async-native-compile-log\\*$")))
           ("Ediff"   (name   . "^\\*[Ee]diff.*"))
           ("VC"      (name   . "^\\*vc-.*"))
           ("Dired"   (mode   . dired-mode))
           ("Terminal" (or
                        (mode . term-mode)
                        (mode . shell-mode)
                        (mode . eshell-mode)
                        (mode . ghostel-mode)))
           ("Help"    (or
                       (name  . "^\\*Help\\*$")
                       (name  . "^\\*info\\*$")
                       (mode  . helpful-mode)))
           ("Markup"  (or
                       (mode . markdown-mode)))
           ("Magit" (or
                     (mode . magit-blame-mode)
                     (mode . magit-cherry-mode)
                     (mode . magit-diff-mode)
                     (mode . magit-log-mode)
                     (mode . magit-process-mode)
                     (mode . magit-status-Mode)))
           ("News"    (name   . "^\\*Newsticker.*"))
           ("chat"    (or
                       (mode  . rcirc-mode)
                       (mode  . erc-mode)
                       (name  . "^\\*rcirc.*")
                       (name  . "^\\*ERC.*"))))))

  (defun esprit/open-ibuffer-with-filters (&optional filter-group)
    "Open ibuffer using a saved filter group from `ibuffer-saved-filter-groups'.
Uses the \"Default\" group when FILTER-GROUP is nil; a prefix arg
prompts for a group name via `completing-read'."
    (interactive)
    (let* ((name (if current-prefix-arg
                      (completing-read "Filter group: " ibuffer-saved-filter-groups nil t)
                    (or filter-group "Default")))
           (fg (cdr (assoc name ibuffer-saved-filter-groups))))
      (ibuffer nil nil nil nil nil fg)))
  :bind
  (("C-x C-b" . esprit/open-ibuffer-with-filters))
  :custom
  (ibuffer-human-readable-size t)
  (ibuffer-show-empty-filter-groups nil))

(use-package autorevert
  :hook
  (after-init . global-auto-revert-mode))

(use-package recentf
  :hook
  (after-init . recentf-mode)
  :custom
  (recentf-max-saved-items 300)
  (recentf-max-menu-items 15)
  (recentf-auto-cleanup (if (daemonp) 300 'never))
  (recentf-exclude (list "^/\\(?:ssh\\|su\\|sudo\\)?:"))
  :xdg-state
  (recentf-save-file "recentf"))

(setopt inhibit-eol-conversion t)
(setopt indent-tabs-mode nil)

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package dired
  :custom
  (dired-dwim-target t))

(use-package bookmark
  :commands (bookmark-set)
  :xdg-state
  (bookmark-default-file "bookmarks.eld"))

(use-package saveplace
  :xdg-state
  (save-place-file "places.eld"))

(setq savehist-watchlist
      '(bookmark-history
        command-history
        custom-variable-history
        face-name-history
        file-name-history
        minibuffer-history
        query-replace-history
        read-char-history
        read-expression-history
        set-variable-value-history
        kill-ring))

(use-package savehist
  :hook
  (after-init . savehist-mode)
  :xdg-state
  (savehist-file "history")
  :custom
  (kill-ring-max 50)
  (history-length 300)
  (history-delete-duplicates t)
  (savehist-additional-variables savehist-watchlist))

;;;; Savehist items above are saved when Emacs quits
;;;; When that happens strip text properties from the
;;;; kill-ring entries. This makes them much faster to
;;;; load when savehist restores them.

(defun unpropertize-kill-ring ()
  "Strip all text properties from text save to the `kill-ring'."
  (setq kill-ring (mapcar 'substring-no-properties kill-ring)))

(add-hook 'kill-emacs-hook 'unpropertize-kill-ring)

;;;; Make keys a little more ergonomic in macOS and tell Dired not to
;;;; use the underlying ls

(when (eq system-type 'darwin)
  (setopt mac-option-modifier 'meta)
  (setopt mac-command-modifier 'control)
  (setopt mac-control-modifier 'super)
  (setq ns-use-srgb-colorspace nil)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))

(setq process-adaptive-read-buffering nil)

;; Function and key binds to create new frames by either cloning the
;; current buffer or jumping to the scratch buffer.

(defun esprit/make-scratch-frame ()
  "Create a new frame and switch to *scratch* buffer."
  (interactive)
  (select-frame (make-frame))
  (switch-to-buffer "*scratch*"))

(defun esprit/make-ghostel-frame ()
  "Create a new frame and create a ghostel buffer in current project directory."
  (interactive)
  (select-frame (make-frame))
  (ghostel-project))

(defvar-keymap esprit-frame-map
  :doc "Prefix map for frame operations."
  "m" #'make-frame
  "n" #'esprit/make-scratch-frame
  "t" #'esprit/make-ghostel-frame)

(keymap-global-set "M-n" esprit-frame-map)

;; Esprit Configuation
;;   - Set up my own little bundle of packages to tailor the Emacs experience

(use-package esprit-themes)

;;; Choose light or dark theme based on the time of day at my location

(use-package circadian
  :ensure t
  :demand t
  :custom
  (calendar-latitude 42.4)
  (calendar-longitude -71.0)
  (circadian-themes '((:sunrise . esprit-cerulean-light)
                      (:sunset  . esprit-cerulean-dark)))
  :config
  (circadian-setup))

(use-package esprit-line
  :custom
  (esprit-line-glyph-alist esprit-line-glyphs-unicode)
  (esprit-line-format esprit-line-format-default)
  :config (esprit-line-mode))

(use-package flymake
  :bind (("M-]" . flymake-goto-next-error)
         ("M-[" . flymake-goto-prev-error))
  :custom
  (flymake-suppress-zero-counters t)
  (flymake-mode-line-format
   '("" flymake-mode-line-exception flymake-mode-line-counters))
  (flymake-mode-line-counter-format
   '("" flymake-mode-line-error-counter
     flymake-mode-line-warning-counter
     flymake-mode-line-note-counter "")))

(use-package flymake-follow-mode
  :after flymake
  :bind (("M-m" . flymake-follow-toggle-diagnostics))
  :hook (flymake-mode . flymake-follow-mode))

(defun esprit-minibuffer ()
  "A setup function for minibuffer customizations."
  (setq-local line-spacing nil))

(use-package minibuffer
  :hook (minibuffer-setup . esprit-minibuffer))

;; Integrated into literate config file
(use-package jinx
  :ensure t
  :hook (after-init . global-jinx-mode)
  :custom (jinx-languages "en_US es")
  :bind
  (("C-;" . jinx-correct-nearest)
   ("C-x j a" . jinx-correct-all)
   ("C-x j n" . jinx-next)
   ("C-x j p" . jinx-previous)))

(dolist (mode esprit-prose-modes)
  (add-hook (intern (format "%s-hook" mode)) #'eglot-ensure))

(use-package quick-sdcv
  :ensure t
  :bind (("C-c s" . quick-sdcv-search-at-point)
         ("C-c S" . quick-sdcv-search-input))
  :custom
  ;; When non-nil, a distinct buffer is created for each word searched.
  (quick-sdcv-unique-buffers t)

  ;; Change the prefix character used before dictionary names, replacing the
  ;; default `-->`:
  (quick-sdcv-dictionary-prefix-symbol "►")

  ;; Change the quick-sdcv dictionaries ellipsis from … to " ▼"
  ;; (In quick-sdcv buffers, `outline-minor-mode' is enabled by default, which
  ;; allows sections corresponding to individual dictionaries to be folded. The
  ;; ellipsis … indicates a folded section, making it easy to collapse all
  ;; dictionaries and expand only those of interest.)
  (quick-sdcv-ellipsis " ▼")

  ;; Automatically fold all dictionary entries when performing a search.
  ;; You can then unfold the dictionaries you want to read.
  (quick-sdcv-fold-on-search nil))

(use-package vertico
  :ensure t
  :bind (:map vertico-map
              ("C-<backspace>" . 'vertico-directory-up))
  :init
  (vertico-mode)
  :custom
  (vertico-count 20)
  (vertico-resize t))

(use-package consult
  :ensure t
  :preface
  (defun wrapper/consult-ripgrep (&optional dir given-initial)
    "Pass the region to `consult-ripgrep' if available.

  DIR and GIVEN-INITIAL match the method signature of `consult-wrapper'."
    (interactive "P")
    (let ((initial
           (or given-initial
               (when (use-region-p)
                 (buffer-substring-no-properties (region-beginning) (region-end))))))
      (consult-ripgrep dir initial)))
  :bind (("M-s d"     . consult-fd) ;; Requires having fd installed otherwise use consult-find
         ("M-s r"     . wrapper/consult-ripgrep)
         ("M-s l"     . consult-line)
         ("M-s <SPC>" . consult-buffer)
         ("s-p"       . consult-buffer)
         ("M-y"       . consult-yank-pop)
         ("C-x M-k"   . consult-kmacro)
         ("M-g i"     . consult-imenu)
         ("M-g o"     . consult-outline)
         ("C-x b"     . consult-bookmark))
  :init
  (advice-add #'register-preview :override #'consult-register-window)
  :custom
  (register-preview-delay 0.5)
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  (consult-preview-key "M-.")
  (consult-narrow-key "<"))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless partial-completion basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package corfu
  :ensure t
  :preface
  (defun corfu-x-eshell-hook ()
    "Set up Corfu behaviors in a shell friendly way."
    (setq-local corfu-auto nil)
    (corfu-mode))
  (defun esprit/corfu-modes ()
    "Activate the desired corfu modes."
    (corfu-history-mode)
    (corfu-echo-mode)
    (global-corfu-mode))
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-on-exact-match nil)
  :hook
  (after-init . esprit/corfu-modes)
  (eshell-mode . corfu-x-eshell-hook))

(use-package cape
  :ensure t
  :preface
  (defun esprit/eglot-completion-at-point-safe ()
    "Call `eglot-completion-at-point' only when a server is attached.
Avoids a jsonrpc-error from Corfu's deferred auto-complete timer
firing after Eglot has disconnected from the buffer."
    (when (eglot-current-server)
      (eglot-completion-at-point)))
  (defun esprit/cape-capf-setup-eglot ()
    "Configure cape completion at point functions for Eglot managed modes."
    (setq-local completion-at-point-functions
                (list (cape-capf-super
                       (cape-capf-buster #'esprit/eglot-completion-at-point-safe)
                       #'cape-file
                       #'cape-dabbrev))))
  (defun esprit/cape-capf-setup-prose ()
    "Configure cape completion at point functions for org mode."
    (setq-local completion-at-point-functions
                (list (cape-capf-super #'cape-dict #'cape-dabbrev))))
  :custom
  (completion-category-overrides '((eglot (styles orderless))
                                   (eglot-capf (styles orderless))))
  :hook
  ((eglot-managed-mode . esprit/cape-capf-setup-eglot)
   (org-mode . esprit/cape-capf-setup-prose)
   (git-commit-mode . esprit/cape-capf-setup-prose)))

(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode)
  :custom (marginalia--align 'right)
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle)))

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("M-." . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t)

(use-package eglot
  :demand t
  :bind (:map eglot-mode-map
              ("C-x l r" . eglot-rename)
              ("C-x l R" . esprit/eglot-reconnect-after-tramp-drop)
              ("M-k" . eglot-code-actions))
  :custom
  (eglot-events-buffer-config '(:size 2000000 :format lisp))
  :config
  (defun esprit/eglot-reconnect-after-tramp-drop ()
    "Kill Eglot's stale server process and flush Tramp's cache for it.
For when a kept-alive SSH connection drops silently: Eglot keeps
reporting \"connected\" while requests go nowhere, and a plain
`eglot-reconnect' hangs trying to gracefully shut down the dead
process."
    (interactive)
    (when-let* ((vec (and (file-remote-p default-directory)
                           (tramp-dissect-file-name default-directory))))
      (tramp-cleanup-connection vec))
    (eglot-reconnect (eglot--current-server-or-lose) t))
  (defun esprit/eglot-angular-contact (_interactive)
    "Build ngserver contact using nearest angular.json as project root."
    (let* ((root (locate-dominating-file default-directory "angular.json"))
           (probe (expand-file-name "node_modules" root)))
      `("ngserver" "--stdio"
        "--tsProbeLocations" ,probe
        "--ngProbeLocations" ,probe)))
  (defun esprit/eglot-typescript-contact (_interactive)
    "Use Angular LS in Angular projects, typescript-language-server elsewhere."
    (if (locate-dominating-file default-directory "angular.json")
        (esprit/eglot-angular-contact _interactive)
      '("typescript-language-server" "--stdio")))
  (defvar eglot-enabled-modes
    '(js-ts-mode
      typescript-ts-mode
      ruby-ts-mode
      go-ts-mode
      astro-mode
      esprit-vue-mode)
    "Opt in list of modes which Eglot should manage.")
  (dolist (mode eglot-enabled-modes)
    (add-hook (intern (concat (symbol-name mode) "-hook")) #'eglot-ensure))
  (add-to-list 'eglot-server-programs
               '(ruby-ts-mode . ("ruby-lsp" :initializationOptions
                                 (:formatter "standard" :linters ["standard"] :enabledFeatures (:codeActions t :diagnostics t :formatting t)))))
  (add-to-list 'eglot-server-programs
               '((typescript-ts-mode html-ts-mode json-ts-mode) . esprit/eglot-typescript-contact))
  (add-to-list 'eglot-server-programs
               '(((rst-mode :language-id "restructuredtext")
                  latex-mode context-mode bibtex-mode org-mode
                  (text-mode :language-id "plaintext"))
                 . ("ltex-ls-plus")))
  (add-to-list 'eglot-server-programs
               '(markdown-mode . ("rass" "--" "marksman" "server"
                                  "--" "ltex-ls-plus")))
  (dolist (hook '(html-ts-mode-hook json-ts-mode-hook))
    (add-hook hook (lambda ()
                     (when (locate-dominating-file default-directory "angular.json")
                       (eglot-ensure)))))
  (setq-default eglot-workspace-configuration
                '(:ltex (:language "en-US"
                                   :disabledRules (:en-US ["MORFOLOGIK_RULE_EN_US"])))))

(use-package eldoc
  :custom
  (eldoc-idle-delay 0)
  (eldoc-echo-area-use-multiline-p nil)
  (eldoc-echo-area-display-truncation-message nil)
  :init
  (global-eldoc-mode))

(use-package eldoc-box
  :ensure t
  :bind (("C-c k" . eldoc-box-help-at-point)))

(use-package avy
  :ensure t
  :bind ("M-j" . avy-goto-char-timer)
  :config
  (defun avy-action-embark (pt)
    "Invoke embark at PT."
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  (defun avy-action-copy-whole-line (pt)
    "Copy entire line starting at PT."
    (save-excursion
      (goto-char pt)
      (cl-destructuring-bind (start . end)
          (bounds-of-thing-at-point 'line)
        (copy-region-as-kill start end)))
    (select-window
     (cdr
      (ring-ref avy-ring 0)))
    t)

  (defun avy-action-yank-whole-line (pt)
    "Yank line starting at PT."
    (avy-action-copy-whole-line pt)
    (save-excursion (yank))
    t)

  (defun avy-action-kill-whole-line (pt)
    "Kill line starting at PT."
    (save-excursion
      (goto-char pt)
      (kill-whole-line))
    (select-window
     (cdr
      (ring-ref avy-ring 0)))
    t)

  (defun avy-action-teleport-whole-line (pt)
    "Teleport whole line starting at PT."
    (avy-action-kill-whole-line pt)
    (save-excursion (yank)) t)

  (setf (alist-get ?. avy-dispatch-alist) 'avy-action-embark
        (alist-get ?k avy-dispatch-alist) 'avy-action-kill-stay
        (alist-get ?K avy-dispatch-alist) 'avy-action-kill-whole-line
        (alist-get ?t avy-dispatch-alist) 'avy-action-teleport
        (alist-get ?T avy-dispatch-alist) 'avy-action-teleport-whole-line
        (alist-get ?y avy-dispatch-alist) 'avy-action-yank
        (alist-get ?w avy-dispatch-alist) 'avy-action-copy
        (alist-get ?W avy-dispatch-alist) 'avy-action-copy-whole-line
        (alist-get ?Y avy-dispatch-alist) 'avy-action-yank-whole-line))

(use-package misc
  :bind ("C-z" . #'zap-up-to-char))

(use-package elec-pair
  :hook (after-init . electric-pair-mode))

(use-package proced
  :ensure nil
  :defer t
  :custom
  (proced-enable-color-flag t)
  (proced-tree-flag t)
  (proced-auto-update-flag 'visible)
  (proced-auto-update-interval 1)
  (proced-descend t)
  (proced-format 'medium)
  (proced-filter 'user))

(use-package accent
  :ensure t
  :bind ("C-x '" . #'accent-menu)
  :custom
  ;; Use the character after the cursor instead of before
  (accent-position 'after)
  (accent-custom '((0 (°)))))

;; (keymap-global-set [remap dabbrev-expand] 'hippie-expand)

(keymap-global-set "C-j" #'join-line)

(use-package multiple-cursors
  :ensure t
  :bind
  ("C->" . #'mc/mark-next-like-this)
  ("C-<" . #'mc/mark-previous-like-this)
  ("C-c C->" . #'mc/mark-all-like-this)
  ("C-S-c C-S-c" . #'mc/edit-lines))

(use-package ace-window
  :ensure t
  :bind
  ("M-o" . 'ace-window)
  :custom
  (aw-keys '(?a ?s ?d ?f ?j ?k ?l))
  (aw-dispatch-always t)
  (aw-dispatch-alist
   '((?x aw-delete-window "Ace - Delete Window")
     (?c aw-swap-window "Ace - Swap Window")
     (?n aw-flip-window)
     (?v aw-split-window-vert "Ace - Split Vert Window")
     (?h aw-split-window-horz "Ace - Split Horz Window")
     (?m delete-other-windows "Ace - Maximize Window")
     (?b balance-windows)
     (?u (lambda ()
           (progn
             (winner-undo)
             (setq this-command 'winner-undo))))
     (?r winner-redo))))

(keymap-global-set "C-M-o" 'mode-line-other-buffer)

(use-package swiss-move
  :bind (("s-n" . swiss-move-line-down)
	 ("s-p" . swiss-move-line-up)))

;; (defun esprit/quit-dwim (&optional arg)
;;     "If current frame is the last frame kill Emacs, else delete it."
;;     (interactive "i")

;;     (if (> (length (visible-frame-list)) 1)
;;         (delete-frame arg)
;;       (if (y-or-n-p (format "Are you sure you want to close the last frame?"))
;;   	(save-buffers-kill-terminal arg)
;;     (message "Great, back to what you were doing then."))))

;; (global-set-key (kbd "C-x C-c") 'esprit/quit-dwim)

(defun za/emacsclient-c-x-c-c (&optional arg)
    "If running in emacsclient, make C-x C-c exit frame, and C-u C-x C-c exit Emacs."
    (interactive "P") ; prefix arg in raw form
    (if arg
        (save-buffers-kill-emacs)
    (save-buffers-kill-terminal)))

(if (daemonp)
    (global-set-key (kbd "C-x C-c") #'za/emacsclient-c-x-c-c))


(use-package fontaine
  :ensure t
  :demand t
  :xdg-state
  (fontaine-latest-state-file "fontaine-latest-state.eld")
  :custom
  (fontaine-presets
   '((small :default-height 80)
     (regular) ; like this it uses all the fallback values and is named `regular'
     (medium  :default-height 140 :bold-weight semi-bold)
     (laptop  :inherit medium :default-height 130)
     (desktop :inherit medium :default-height 150)
     (large   :inherit medium :default-height 180)
     (t
      :default-family "JuliaMono"
      :variable-pitch-family "Atkinson Hyperlegible Next"
      :fixed-pitch-height 1.0
      :fixed-pitch-serif-height 1.0
      :variable-pitch-height 1.0)))
  :config
  (fontaine-set-preset (or (fontaine-restore-latest-preset) 'medium))
  ;; Persist the latest font preset when closing/starting Emacs and
  ;; while switching between themes.
  (fontaine-mode 1)
  :bind
  ("C-c f" . #'fontaine-set-preset))

(use-package magit
  :ensure t
  :bind
  ("C-M-;" . magit-status)
  :config
  (defvar-keymap esprit-vc-branch-map
    :doc "Esprit prefix map for version control branch actions."
    "b" #'magit-checkout
    "c" #'magit-branch-create)

  (defvar-keymap esprit-vc-pull-map
    :doc "Esprit prefix map for version control pull/fetch actions."
    "p" #'magit-pull-from-pushremote
    "u" #'magit-pull-from-upstream
    "e" #'magit-pull-branch)

  (defvar-keymap esprit-vc-file-map
    :doc "Esprit prefix map for version control file actions."
    "r" #'magit-file-rename)

  (defvar-keymap esprit-vc-map
    :doc "Esprit prefix key maps version control operations."
    "b" esprit-vc-branch-map
    "F" esprit-vc-pull-map
    "f" esprit-vc-file-map)

  (keymap-set global-map "C-c g" esprit-vc-map))

(use-package ediff
  :hook ((ediff-before-setup . esprit/store-pre-ediff-winconfig)
         (ediff-quit . esprit/restore-pre-ediff-winconfig))
  :config
  (defvar esprit/ediff-original-windows nil)

  (defun esprit/store-pre-ediff-winconfig ()
    "Store the window arrangement before opening Ediff."
    (setq esprit/ediff-original-windows (current-window-configuration)))

  (defun esprit/restore-pre-ediff-winconfig ()
    "Reset original window arrangement."
    (set-window-configuration esprit/ediff-original-windows))

  (setq ediff-window-setup-function 'ediff-setup-windows-plain)
  (setq ediff-split-window-function 'split-window-horizontally))

(use-package ghostel
  :ensure t
  :bind (("C-x m" . ghostel)
         :map ghostel-semi-char-mode-map
         ("C-s"  . consult-line)
         ("M-<backspace>" . ghostel-backward-kill-word)
         ;; ;; I'm used to go up/down the shell history with M-n/p from eshell
         ;; ;; Simulate this behavior in ghostel by sending C-p and C-n
         ("M-p" . (lambda () (interactive) (ghostel-send-key "p" "ctrl")))
         ("M-n" . (lambda () (interactive) (ghostel-send-key "n" "ctrl")))
         :map project-prefix-map
         ("m" . ghostel-project)
         ("M" . ghostel-project-list-buffers))
  :custom
  (ghostel-tramp-shell-integration t)
  (ghostel-tramp-shells
   '(("ssh" login-shell)
     ("sshx" login-shell)
     ("scp" login-shell)
     ("rpc" login-shell)
     ("docker" "/bin/sh")))
  :config
  (defun ghostel-send-C-k-and-kill ()
    "Send `C-k' to ghostel.
Like normal Emacs `C-k'.  Kill to end of line and put content in kill-ring."
    (interactive)
    (kill-ring-save (point) (line-end-position))
    (ghostel-send-key "k" "ctrl"))

  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands '(ghostel-project-list-buffers "Ghostel buffers") t)
  (add-to-list 'ghostel-eval-cmds '("magit-status-setup-buffer" magit-status-setup-buffer)))

(use-package ghostel-eshell
  :hook (eshell-load . ghostel-eshell-visual-command-mode))

(use-package ghostel-compile
  :hook (after-init . ghostel-compile-global-mode))

(use-package ghostel-comint
  :hook (after-init . ghostel-comint-global-mode))

(use-package treesit-env
  :vc (:url "https://github.com/cottontailia/treesit-env")
  :custom
  (treesit-env-default-revision-auto t)
  (treesit-env-abi-max 14)
  :config
  (treesit-env typescript javascript go ruby lua css)
  ;; Use the provided minimal sample recipes (Optional)
  (require 'treesit-env-recipe-placeholder)
  (treesit-env-source treesit-env-recipe-placeholder))

(use-package css-mode
  :custom
  (css-indent-offset 2))

(use-package js-ts-mode
  :mode (rx (: ".js" (? (in ?x ?m)) eow))
  :custom
  (js-indent-level 2))

(use-package ruby-ts-mode
  :mode (rx (: (| ".rb" "Rakefile" "Gemfile") eos))
  :hook (ruby-ts-mode . subword-mode)
  :bind (:map ruby-ts-mode-map
              ("C-c r b" . 'treesit-beginning-of-defun)
              ("C-c r e" . 'treesit-end-of-defun))
  :custom
  (ruby-indent-level 2)
  (ruby-indent-tabs-mode nil))

(use-package go-ts-mode
  :mode (rx (: ".go" eow))
  :custom
  (go-ts-mode-indent-offset 4)
  :config
  (require 'project)

  (defun project-find-go-module (dir)
    (when-let* ((root (locate-dominating-file dir "go.mod")))
      (cons 'go-module root)))

  (cl-defmethod project-root ((project (head go-module)))
    (cdr project))

  (add-hook 'project-find-functions #'project-find-go-module))

(use-package typescript-ts-mode
  :mode  (rx (: ".ts" (? (in ?x ?m)) eow))
  :custom
  (typescript-indent-level 2)
  :config
  (unbind-key "M-." typescript-ts-base-mode-map))

(use-package web-mode
  :ensure t
  :demand t
  :custom
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2)
  :mode  (rx (: ".html" (? ".erb") eow))
  :config
  (define-derived-mode astro-mode web-mode "astro")
  (add-to-list 'auto-mode-alist '("\\.astro\\'" . astro-mode))

  (define-derived-mode esprit-vue-mode web-mode "ES-Vue"
    "A major mode derived from web-mode, for editing .vue files with LSP support.")
  (add-to-list 'auto-mode-alist '("\\.vue\\'" . esprit-vue-mode))

  (defun esprit/eglot-vue-contact (_interactive)
    "Contact form for vue-language-server, pointing it at the project's local typescript."
    (let* ((root (or (locate-dominating-file default-directory "node_modules")
                      default-directory))
           ;; vue-language-server runs on the same host as `root' (remote,
           ;; under TRAMP), so tsdk must be a path local to that host --
           ;; strip any /method:host: prefix before sending it over.
           (tsdk (file-local-name (expand-file-name "node_modules/typescript/lib" root))))
      `("vue-language-server" "--stdio"
        :initializationOptions
        (:typescript (:tsdk ,tsdk) :vue (:hybridMode :json-false)))))
  (add-to-list 'eglot-server-programs '(esprit-vue-mode . esprit/eglot-vue-contact)))

(use-package lua-ts-mode
  :mode (rx ".lua" eos))

(use-package tempel
  :ensure t
  :custom
  (tempel-trigger-prefix "<")
  :bind (("M-=" . tempel-complete) ;; Alternative tempel-expand
         ("M-*" . tempel-insert)))

;; Optional: Add tempel-collection.
;; The package is young and doesn't have comprehensive coverage.
(use-package tempel-collection
  :ensure t
  :after tempel)

(defvar-keymap esprit-toggles-map
  :name "esprit-toggles"
  :doc "Esprit prefix key maps | minor mode toggling."
  "v" #'global-visual-line-mode
  "f" #'toggle-frame-fullscreen
  "w" #'whitespace-mode
  "c" #'command-log-mode)

(use-package whitespace
  :custom
  (whitespace-style
   '(face
     tabs
     spaces
     trailing
     lines-char
     space-before-tab
     newline
     indentation
     empty
     space-after-tab
     space-mark
     tab-mark
     newline-mark
     missing-newline-at-eof
     )))

(keymap-global-set "C-c t" esprit-toggles-map)

(use-package outline
  :diminish "¶")

(use-package which-key
  :diminish which-key-mode
  :custom
  (which-key-idle-delay 1)
  :hook
  (after-init . which-key-mode))

;; Clean and straightforward undo/redo
(use-package undo-fu
  :ensure t
  :custom
  (undo-fu-allow-undo-in-region t)
  (undo-limit 67108864) ; 64mb.
  (undo-strong-limit 100663296) ; 96mb.
  (undo-outer-limit 1006632960) ; 960mb.
  :bind
  ("C-/" . undo-fu-only-undo)
  ("C-?" . undo-fu-only-redo))

;; Persist undo history across sessions
(use-package undo-fu-session
  :ensure t
  :hook
  (after-init . undo-fu-session-global-mode)
  :xdg-state
  (undo-fu-session-directory "undo-fu-session")
  :custom
  (undo-fu-session-compression 'nil)
  (undo-fu-session-incompatible-files
   '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'")))

(use-package helpful
  :ensure t
  :custom
  (helpful-switch-to-buffer #'esprit/helpful-switch-to-buffer)
  :config
  (defun esprit/helpful-switch-to-buffer (buffer-or-name)
    "Switch to helpful BUFFER-OR-NAME.

If we're already in a helpful buffer than reuse its window;
otherwise create a new window."
    (if (eq major-mode 'helpful-mode)
        (switch-to-buffer buffer-or-name)
      (pop-to-buffer buffer-or-name)))
  :bind
  ("C-h o"    . #'helpful-symbol)
  ("C-h f"    . #'helpful-callable)
  ("C-c F"    . #'helpful-function)
  ("C-h v"    . #'helpful-variable)
  ("C-h k"    . #'helpful-key)
  ("C-h x"    . #'helpful-command)
  ("C-c C-d"  . #'helpful-at-point))

;; Special mode is "A special major mode is intended to view specially formatted data
;; rather than files.". Most practically this means help(ful) buffers and the like.
;; I prefer this kind of informational display to be in a side window.
(add-to-list 'display-buffer-alist
             '((derived-mode . special-mode)
               (display-buffer-in-side-window)
               (side . right)
               (slot . 0)
               (window-width . 80)
               (window-parameters
                (no-delete-other-windows . t))))

(use-package nxml-mode
  :mode (rx (| ".xml" ".svg") eos))

(use-package markdown-mode
  :ensure t
  :mode ((rx ".md" eos) . gfm-mode)
  :commands (markdown-mode gfm-mode)
  :bind ("C-c C-c C-p" . 'esprit/markdown-preview)
  :config
  (setq markdown-command "pandoc -t html5"))

(use-package prose-mode
  :hook markdown-mode)

(use-package simple-httpd
  :ensure t
  :config
  (setq httpd-host 'local)
  (setq httpd-port 7070))

(use-package impatient-mode
  :ensure t
  :commands impatient-mode)

(defun esprit/markdown-filter (buffer)
  (princ
   (with-temp-buffer
     (let ((tmp (buffer-name)))
       (set-buffer buffer)
       (set-buffer (markdown tmp))
       (format "<!DOCTYPE html><html><title>Markdown preview</title><link rel=\"stylesheet\" href = \"https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/3.0.1/github-markdown.min.css\"/>
<body><article class=\"markdown-body\" style=\"box-sizing: border-box;min-width: 200px;max-width: 980px;margin: 0 auto;padding: 45px;\">%s</article></body></html>" (buffer-string))))
   (current-buffer)))

(defun esprit/markdown-preview ()
  "Open a live, styled markdown preview."
  (interactive)
  (unless (process-status "httpd")
    (httpd-start))
  (impatient-mode)
  (imp-set-user-filter 'esprit/markdown-filter)
  (imp-visit-buffer))

(use-package md-mermaid
  :vc (:url "https://github.com/ahmetus/md-mermaid")
  :commands (md-mermaid-render-current
             md-mermaid-preview-last-svg
             md-mermaid-transient))

(use-package yaml-ts-mode
  :mode (rx (| ".yml" ".yaml") eos)
  :custom
  (tab-width 2))

(use-package command-log-mode
  :vc (:url "https://github.com/ludamillion/command-log-mode"))

(defvar esprit/local-root "~/"
  "The explicit root directory value.")

(defvar esprit/default-org-directory
  (expand-file-name "org" esprit/local-root))

(setq esprit/sync-org-directory (expand-file-name "Dropbox/org" esprit/local-root))
(setq esprit/beorg-directory
      (expand-file-name "Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org" esprit/local-root))

(setq esprit/org-dir
      (if (file-directory-p esprit/default-org-directory)
          esprit/default-org-directory
        esprit/sync-org-directory))

(setq esprit/journal-file (expand-file-name "journal.org" esprit/org-dir))
(setq esprit/projects-file (expand-file-name "projects.org" esprit/org-dir))
(setq esprit/notes-directory (expand-file-name "notes" esprit/org-dir))
(setq esprit/org-id-locations-file (expand-file-name ".org-id-locations" esprit/org-dir))

(use-package org
  :init
  (setq org-export-backends '(ascii md html icalendar latex))
  :custom
  (org-default-notes-file (expand-file-name "inbox.org" esprit/org-dir)) ;; Should maybe be inbox
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-capture-bookmark nil)
  (org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id)
  (org-id-locations-file esprit/org-id-locations-file)
  (org-id-locations-file-relative t)
  (org-fontify-whole-heading-line t)
  (org-agenda-files `(,esprit/org-dir ,esprit/beorg-directory))
  (org-latex-pdf-process '("tectonic %f"))
  (org-checkbox-hierarchical-statistics nil)

  (org-capture-templates
   '(("f" "Fleeting note" item
      (file+headline org-default-notes-file "Notes")
      "- %?")
     ("p" "Permanent note" plain
      (file denote-last-path)
      #'denote-org-capture
      :no-save t
      :immediate-finish nil
      :kill-buffer t
      :jump-to-captured t)
     ("t" "New task" entry
      (file+headline org-default-notes-file "Tasks")
      "* TODO %i%?")))
  :config
  (add-to-list 'org-structure-template-alist '("sl" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("s#" . "src csharp"))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)
     (lua . t)))
  :bind
  ("C-c a" . org-agenda)
  ("C-c c" . org-capture)
  ("C-c l" . org-store-link))

(use-package esprit-side-note)

(use-package denote
  :ensure t
  :init
  (denote-rename-buffer-mode 1)
  :custom
  (denote-directory esprit/notes-directory)
  :hook
  (dired-mode . denote-dired-mode)
  :custom-face
  (denote-faces-link ((t (:slant italic))))
  :config
  (defun esprit/denote-bench-note-p ()
    "Non-nil if the current buffer is visiting a denote note tagged \"bench\"."
    (and buffer-file-name
         (denote-file-is-note-p buffer-file-name)
         (member "bench" (denote-extract-keywords-from-path buffer-file-name))))
  (add-to-list 'esprit-side-note-predicates #'esprit/denote-bench-note-p)

  (defun esprit/bench-note-open ()
    "Find or create this project's bench note, shown in the side window."
    (interactive)
    (let* ((proj (project-current))
           (label (if proj
                      (file-name-nondirectory (directory-file-name (project-root proj)))
                    (read-string "Bench note label: ")))
           (candidates (seq-filter
                        (lambda (f)
                          (let ((kw (denote-extract-keywords-from-path f)))
                            (and (member "bench" kw) (member label kw))))
                        (denote-directory-files nil nil t))))
      (cond
       ((null candidates) (denote (format "Bench notes: %s" label) (list "bench" label)))
       ((= (length candidates) 1) (find-file (car candidates)))
       (t (find-file (completing-read "Bench note: " candidates nil t))))))
  :bind
  ("C-c n b" . esprit/bench-note-open))

(use-package consult-notes
  :ensure t
  :bind
  ("M-s n" . #'consult-notes)
  :commands (consult-notes
             consult-notes-search-in-all-notes)
  :custom
  (consult-notes-file-dir-sources
   `(("Denote" ?d ,esprit/notes-directory))))

(use-package emacs-lock
  :config
  (with-current-buffer "*scratch*"
    (emacs-lock-mode 'kill)))

(use-package wgrep
  :ensure t
  :custom
  (wgrep-auto-save-buffer t))

(use-package combobulate
  :vc (:url "https://github.com/mickeynp/combobulate")
  :custom
  ;; You can customize Combobulate's key prefix here.
  ;; Note that you may have to restart Emacs for this to take effect!
  (combobulate-key-prefix "C-c o")
  :hook (prog-mode))

(use-package esprit-movement
  :bind ("C-a" . #'esprit/beginning-of-line))

(use-package ipe
  :vc (:url "https://github.com/BriansEmacs/insert-pair-edit.el")
  :bind ("M-(" . #'ipe-insert-pair-edit)
  :custom
  (ipe-menu-support-p t))

;; install required inheritenv dependency:
(use-package inheritenv
  :vc (:url "https://github.com/purcell/inheritenv"))

(use-package monet
  :vc (:url "https://github.com/stevemolitor/monet"))

(use-package claude-code
  :vc (:url "https://github.com/stevemolitor/claude-code.el" :branch "main" :ignored-files ("images/*"))
  :bind-keymap
  ("C-x c" . claude-code-command-map) ;; or your preferred key
  ;; Optionally define a repeat map so that "M" will cycle thru Claude auto-accept/plan/confirm modes after invoking claude-code-cycle-mode / C-c M.
  :bind
  (:repeat-map my-claude-code-map ("M" . claude-code-cycle-mode))
  :init
  (defun esprit/claude-display-fn (buffer)
  "Display Claude buffer in right side window."
  (display-buffer buffer '((display-buffer-in-side-window)
                           (side . right)
                           (window-width . 90))))
  :custom
  (claude-code-terminal-backend 'ghostel)
  (claude-code-display-window-fn #'esprit/claude-display-fn)
  :config
  (claude-code-mode))

(setq esprit-emacs--success t)

(defun esprit/tear-off-window ()
  "Delete the selected window, and create a new frame displaying its buffer."
  (interactive)
  (let* ((window (selected-window))
     (buf (window-buffer window))
     (frame (make-frame)))          
    (select-frame frame)
    (switch-to-buffer buf)
    (delete-window window)))

(keymap-global-set "C-c w p" #'esprit/tear-off-window)

(use-package obsidian
  :ensure t
  :commands (obsidian-capture obsidian-search)
  :config
  (global-obsidian-mode t)
  (obsidian-backlinks-mode t)
  :custom
  (obsidian-directory "~/pkm")

  ;; These bindings are only suggestions; it's okay to use other bindings
  :bind (:map obsidian-mode-map
              ;; Create note
              ("C-c C-n" . obsidian-capture)
              ;; If you prefer you can use `obsidian-insert-wikilink'
              ("C-c C-l" . obsidian-insert-link)
              ;; Open file pointed to by link at point
              ("C-c C-o" . obsidian-follow-link-at-point)
              ;; Open a different note from vault
              ("C-c C-p" . obsidian-jump)
              ;; Follow a backlink for the current file
              ("C-c C-b" . obsidian-backlink-jump)))

(use-package xeft
  :ensure t
  :after obsidian
  :bind ((:map obsidian-mode-map (("C-c C-g" . xeft))))
  :custom
  (xeft-directory obsidian-directory)
  (xeft-recursive t)
  (xeft-file-filter #'obsidian-file-p)
  (xeft-title-function #'obsidian-file-title-function))

(use-package csv-mode
  :ensure t
  :mode (rx ".csv" eos))

(use-package mise
  :ensure t
  :hook (after-init . global-mise-mode))

(use-package ct
  :vc (:url "https://github.com/neeasade/ct.el" :branch "master"))

(provide 'init)
;;; init.el ends here
