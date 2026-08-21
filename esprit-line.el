;;; esprit-line.el --- A minimal mode line inspired by doom-modeline -*- lexical-binding: t; -*-
;;
;; Author: Jessie Hildebrandt <jessieh.net>
;; Homepage: https://gitlab.com/ludamillion/esprit-line
;; Keywords: mode-line faces
;; Version: 3.1.0
;; Package-Requires: ((emacs "26.1"))
;;
;; This file is not part of GNU Emacs.

;;; Commentary:
;;
;; esprit-line is a lightweight, drop-in replacement for the default mode line.
;;
;; Features offered:
;; * Clean, informative design
;; * Customizable, modular segment format
;; * Customizable glyph sets
;; * Lazy-loaded extensions
;; * Lightweight, no dependencies
;;
;; To activate esprit-line:
;; (esprit-line-mode)
;;
;; For information on customizing esprit-line:
;; M-x customize-group esprit-line

;;; License:
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Code:

;; -------------------------------------------------------------------------- ;;
;;
;; Byte-compiler declarations
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; Required features
;; ---------------------------------- ;;

(eval-when-compile
  (require 'cl-lib))

;; ---------------------------------- ;;
;; External variable defs
;; ---------------------------------- ;;

(eval-when-compile
  (defvar anzu--cached-count)
  (defvar anzu--current-position)
  (defvar anzu--overflow-p)
  (defvar anzu--total-matched))

;; ---------------------------------- ;;
;; External function decls
;; ---------------------------------- ;;

(eval-when-compile
  (declare-function mc/num-cursors "multiple-cursors")
  (declare-function string-blank-p "subr-x"))

;; -------------------------------------------------------------------------- ;;
;;
;; Macros
;;
;; -------------------------------------------------------------------------- ;;

(defmacro esprit-line--deflazy (name)
  "Define dummy function NAME to `require' its module and call actual function."
  (let ((module (intern (car (split-string (symbol-name name) "--")))))
    `(defun ,name (&rest args)
       "Not yet loaded."
       (fmakunbound (quote ,name))
       (require (quote ,module))
       (apply (function ,name) args))))

(defmacro esprit-line-defformat (&rest spec)
  "Format :left and :right segment lists of plist SPEC for `esprit-line-format'.

A segment may be a string, a cons cell of the form (FUNCTION . SEPARATOR),
 or any expression that evaluates to a string or nil.

Strings will be collected into the format sequence unaltered.

Cons cells of the form (FUNCTION . SEPARATOR) will expand into the format
 sequence as FUNCTION, followed by SEPARATOR.

All other expressions will expand into the format sequence unaltered,
 followed by an empty string. This prevents accidental elision of the
 following segment should the expression evaluate to nil.

An optional key :padding may be provided, the value of which will be used as
 the padding for either side of the mode line. If :padding is nil, \"\s\" will
 be used as a default."
  (let* ((padding (or (plist-get spec :padding) "\s"))
         (left (append (list padding) (plist-get spec :left)))
         (right (append (plist-get spec :right) (list padding))))
    `(quote ,(mapcar
              (lambda (segments)
                (cl-loop for seg in segments
                         if (nlistp (cdr-safe seg)) append (list (car seg)
                                                                 (cdr seg))
                         else if (stringp seg) collect seg
                         else append (list seg "")))
              (list left right)))))

;; -------------------------------------------------------------------------- ;;
;;
;; Constants
;;
;; -------------------------------------------------------------------------- ;;

(defconst esprit-line-glyphs-ascii
  '((:checker-info . ?i)
    (:checker-issues . ?+)
    (:checker-good . ?-)
    (:checker-checking . ?~)
    (:checker-errored . ?x)
    (:checker-interrupted . ?=)

    (:vc-added . ?+)
    (:vc-needs-merge . ?>)
    (:vc-needs-update . ?v)
    (:vc-conflict . ?x)
    (:vc-good . ?-)

    (:buffer-narrowed . ?v)
    (:buffer-modified . ?*)
    (:buffer-read-only . ?#)
    (:buffer-remote . ?@)

    (:frame-client . ?@)

    (:count-separator . ?*))
  "Set of ASCII glyphs for use with esprit-line.")

(defconst esprit-line-glyphs-unicode
  '((:checker-info . ?🛈)
    (:checker-issues . ?⚑)
    (:checker-good . ?✔)
    (:checker-checking . ?🗘)
    (:checker-errored . ?✖)
    (:checker-interrupted . ?⏸)

    (:vc-added . ?🞤)
    (:vc-needs-merge . ?⟷)
    (:vc-needs-update . ?↓)
    (:vc-conflict . ?✖)
    (:vc-good . ?✔)

    (:buffer-narrowed . ?▼)
    (:buffer-modified . ?●)
    (:buffer-read-only . ?■)
    (:buffer-remote . ?⎘)

    (:frame-client . ?⇅)

    (:count-separator . ?✕))
  "Set of Unicode glyphs for use with esprit-line.")

(defconst esprit-line-format-default
  (esprit-line-defformat
   :left
   (((esprit-line-segment-modal)                  . " ")
    ((or (esprit-line-segment-buffer-status) " ") . " ")
    ((esprit-line-segment-buffer-name)            . "  ")
    ((esprit-line-segment-anzu)                   . "  ")
    ((esprit-line-segment-multiple-cursors)       . "  ")
    ((esprit-line-segment-cursor-position)        . " ")
    (esprit-line-segment-scroll))
   :right
   (((esprit-line-segment-vc)         . "  ")
    ((esprit-line-segment-major-mode) . "  ")
    ((esprit-line-segment-misc-info)  . "  ")
    ((esprit-line-segment-checker)    . "  ")
    ((esprit-line-segment-process)    . "  ")))
  "Default format for esprit-line.")

(defconst esprit-line-format-default-extended
  (esprit-line-defformat
   :left
   (((esprit-line-segment-modal)            . " ")
    ((or (esprit-line-segment-buffer-status)
         (esprit-line-segment-client)
         " ")                             . " ")
    ((esprit-line-segment-project)          . "/")
    ((esprit-line-segment-buffer-name)      . "  ")
    ((esprit-line-segment-anzu)             . "  ")
    ((esprit-line-segment-multiple-cursors) . "  ")
    (esprit-line-segment-cursor-position)
    #(":" 0 1 (face esprit-line-unimportant))
    ((esprit-line-segment-cursor-point)     . " ")
    ((esprit-line-segment-region)           . " ")
    (esprit-line-segment-scroll))
   :right
   (((esprit-line-segment-indentation) . "  ")
    ((esprit-line-segment-eol)         . "  ")
    ((esprit-line-segment-encoding)    . "  ")
    ((esprit-line-segment-vc)          . "  ")
    ((esprit-line-segment-major-mode)  . "  ")
    ((esprit-line-segment-misc-info)   . "  ")
    ((esprit-line-segment-checker)     . "  ")
    ((esprit-line-segment-process)     . "  ")))
  "Extended default format for esprit-line showcasing all included segments.")

;; -------------------------------------------------------------------------- ;;
;;
;; Custom definitions
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; Group definitions
;; ---------------------------------- ;;

(defgroup esprit-line nil
  "A minimal mode line configuration."
  :group 'mode-line)

(defgroup esprit-line-faces nil
  "Faces used by esprit-line."
  :group 'esprit-line
  :group 'faces)

;; ---------------------------------- ;;
;; Variable definitions
;; ---------------------------------- ;;

(defcustom esprit-line-glyph-alist esprit-line-glyphs-ascii
  "Alist mapping glyph names to characters used to draw some mode line segments.

esprit-line includes several sets of glyphs by default:

 `esprit-line-glyphs-ascii'     | Basic ASCII character glyphs
 `esprit-line-glyphs-unicode'   | Fancy unicode glyphs

Note that if a character provided by a glyph set is not included in your default
 font, the editor will render it with a fallback font.  If your fallback font is
 not the same height as your default font, the mode line may unexpectedly grow
 or shrink.

Keys are names for different mode line glyphs, values are characters for that
 glyph.  Glyphs used by esprit-line include:

 :checker-info        | Syntax checker reports notes
 :checker-issues      | Syntax checker reports issues
 :checker-good        | Syntax checker reports no issues
 :checker-checking    | Syntax checker is running
 :checker-errored     | Syntax checker is stopped due to an error
 :checker-interrupted | Syntax checker is paused

 :vc-added            | VC backend reports additions/changes
 :vc-needs-merge      | VC backend reports required merge
 :vc-needs-update     | VC backend reports upstream is ahead of local
 :vc-conflict         | VC backend reports conflict
 :vc-good             | VC backend has nothing to report

 :buffer-narrowed     | File-backed buffer is narrowed
 :buffer-modified     | File-backed buffer is modified
 :buffer-read-only    | File-backed buffer is read-only

 :frame-client        | Frame is a client for an Emacs daemon

 :count-separator     | Separates some indicator names from numerical counts

`esprit-line-glyphs-ascii' will be used as a fallback whenever a glyph is found
 to be missing in `esprit-line-glyph-alist'."
  :group 'esprit-line
  :type '(alist :tag "Character map alist"
                :key-type (symbol :tag "Glyph name")
                :value-type (character :tag "Character to use")))

(defcustom esprit-line-format esprit-line-format-default
  "List providing left and right lists of segments to format as the mode line.

The list should be of the form (L-SEGMENTS R-SEGMENTS), where L-SEGMENTS is a
 list of segments to be left-aligned, and R-SEGMENTS is a list of segments to
 be right-aligned. Lists are processed from first to last, and segments are
 displayed from left to right.

A segment may be any expression that evaluates to a string, or nil.
 Segment expressions evaluating to nil are not displayed.

When a segment evaluates to nil, the following segment will be skipped and not
 processed or displayed. This behavior may be used to, e.g., conditionally
 display separating whitespace after a segment.

Examples: `esprit-line-format-default' and `esprit-line-format-default-extended'

See `esprit-line-defformat' for a helpful formatting macro."
  :group 'esprit-line
  :type '(list :tag "Mode line segments"
               (repeat :tag "Left side" sexp)
               (repeat :tag "Right side" sexp)))

;; ---------------------------------- ;;
;; Face definitions
;; ---------------------------------- ;;

(defface esprit-line-buffer-name
  '((t (:inherit mode-line-buffer-id :italic t)))
  "Face used for displaying the value of `buffer-name'."
  :group 'esprit-line-faces)

(defface esprit-line-buffer-status-modified
  '((t (:inherit error :weight normal)))
  "Face used for the ':buffer-modified' buffer status indicator."
  :group 'esprit-line-faces)

(defface esprit-line-buffer-status-read-only
  '((t (:inherit shadow :weight normal)))
  "Face used for the ':buffer-read-only' buffer status indicator."
  :group 'esprit-line-faces)

(defface esprit-line-buffer-status-narrowed
  '((t (:inherit font-lock-doc-face :weight normal)))
  "Face used for the ':buffer-narrowed' buffer status indicator."
  :group 'esprit-line-faces)

(defface esprit-line-frame-status-client
  '((t (:inherit esprit-line-unimportant)))
  "Face used for the :frame-client frame status indicator.")

(defface esprit-line-major-mode
  '((t (:inherit bold)))
  "Face used for the major mode indicator."
  :group 'esprit-line-faces)

(defface esprit-line-status-neutral
  '((t (:inherit esprit-line-unimportant)))
  "Face used for neutral or inactive status indicators."
  :group 'esprit-line-faces)

(defface esprit-line-status-info
  '((t (:inherit font-lock-keyword-face :weight normal)))
  "Face used for generic status indicators."
  :group 'esprit-line-faces)

(defface esprit-line-status-success
  '((t (:inherit success :weight normal)))
  "Face used for success status indicators."
  :group 'esprit-line-faces)

(defface esprit-line-status-warning
  '((t (:inherit warning :weight normal)))
  "Face for warning status indicators."
  :group 'esprit-line-faces)

(defface esprit-line-status-error
  '((t (:inherit error :weight normal)))
  "Face for error status indicators."
  :group 'esprit-line-faces)

(defface esprit-line-encoding
  '((t (:inherit esprit-line-unimportant)))
  "Face used for buffer/file encoding information."
  :group 'esprit-line-faces)

(defface esprit-line-unimportant
  '((t (:inherit shadow :weight normal)))
  "Face used for less important mode line elements."
  :group 'esprit-line-faces)

;; -------------------------------------------------------------------------- ;;
;;
;; Helper functions
;;
;; -------------------------------------------------------------------------- ;;

(defvar esprit-line--escape-buffer (get-buffer-create " *esprit-line*")
  "Buffer used by `esprit-line--escape'.")

(defun esprit-line--escape (&rest strings)
  "Escape all mode line constructs in STRINGS."
  (with-current-buffer esprit-line--escape-buffer
    (erase-buffer)
    (apply #'insert strings)
    (while (search-backward "%" nil t)
      (goto-char (match-beginning 0))
      (insert-char ?% 1 t)
      (goto-char (- (point) 1)))
    (buffer-string)))

(defun esprit-line--get-glyph (glyph)
  "Return character from `esprit-line-glyph-alist' for GLYPH.
If a character could not be found for the requested glyph, a fallback will be
returned from `esprit-line-glyphs-ascii'."
  (char-to-string (or (alist-get glyph esprit-line-glyph-alist)
                      (alist-get glyph esprit-line-glyphs-ascii))))

(defun esprit-line--process-segments (segments)
  "Process list of segments SEGMENTS, returning a string.
Segments are processed according to the rules described in the documentation
for `esprit-line-format', which see."
  (cl-loop with last = t
           for seg in segments
           if last do (setq last (eval seg)) and concat last
           else do (setq last t)))

(defun esprit-line--process-format (format)
  "Format and return a mode line string according to FORMAT.
Returned string is padded in the center to fit the width of the window.
Left and right segment lists of FORMAT will be processed according to the rules
described in the documentation for `esprit-line-format', which see."
  (let ((right-str (esprit-line--process-segments (cadr format))))
    (esprit-line--escape
     (esprit-line--process-segments (car format))
     (propertize " " 'face 'shadow 'display '(raise +0.30))
     (propertize " "
                 'display `((space :align-to (- right (- 0 right-margin)
                                                ,(length right-str)))))
     (propertize " " 'face 'shadow 'display '(raise -0.30))
     right-str)))

;; -------------------------------------------------------------------------- ;;
;;
;; Optional/lazy-loaded segments
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; Modal editing
;; ---------------------------------- ;;

(esprit-line--deflazy esprit-line-segment-modal--evil-fn)
(esprit-line--deflazy esprit-line-segment-modal--meow-fn)
(esprit-line--deflazy esprit-line-segment-modal--xah-fn)
(esprit-line--deflazy esprit-line-segment-modal--god-fn)

(defun esprit-line-segment-modal ()
  "Return the correct mode line segment for the first active modal mode found.
Modal editing modes checked, in order:
`evil-mode', `meow-mode', `xah-fly-keys', `god-mode'"
  (cond
   ((bound-and-true-p evil-mode)
    (esprit-line-segment-modal--evil-fn))
   ((bound-and-true-p meow-mode)
    (esprit-line-segment-modal--meow-fn))
   ((bound-and-true-p xah-fly-keys)
    (esprit-line-segment-modal--xah-fn))
   ((or (bound-and-true-p god-local-mode)
        (bound-and-true-p god-global-mode))
    (esprit-line-segment-modal--god-fn))))

;; ---------------------------------- ;;
;; Indentation style
;; ---------------------------------- ;;

(esprit-line--deflazy esprit-line-segment-indentation)

;; ---------------------------------- ;;
;; Version control
;; ---------------------------------- ;;

(esprit-line--deflazy esprit-line-segment-vc--update)

(defvar-local esprit-line-segment-vc--text nil)

(defun esprit-line-segment-vc ()
  "Return color-coded version control information."
  esprit-line-segment-vc--text)

;; ---------------------------------- ;;
;; Checker status
;; ---------------------------------- ;;

(esprit-line--deflazy esprit-line-segment-checker--flycheck-update)
(esprit-line--deflazy esprit-line-segment-checker--flymake-update)

(defvar-local esprit-line-segment-checker--flycheck-text nil)
(defvar-local esprit-line-segment-checker--flymake-text nil)

(defun esprit-line-segment-checker ()
  "Return status information for Flycheck or Flymake, if active."
  (cond
   ((bound-and-true-p flycheck-mode)
    esprit-line-segment-checker--flycheck-text)
   ((bound-and-true-p flymake-mode)
    esprit-line-segment-checker--flymake-text)))

;; -------------------------------------------------------------------------- ;;
;;
;; Client segment
;;
;; -------------------------------------------------------------------------- ;;

(defun esprit-line-segment-client ()
  "Return an indicator representing the client status of the current frame."
  (when (frame-parameter nil 'client)
    (propertize (esprit-line--get-glyph :frame-client)
                'face 'esprit-line-frame-status-client)))

;; -------------------------------------------------------------------------- ;;
;;
;; Project segment
;;
;; -------------------------------------------------------------------------- ;;

(defun esprit-line-segment-project ()
  "Return project name from project.el or Projectile, if any."
  (or
   (and (fboundp 'project-name)
        (project-current)
        (project-name (project-current)))
   (and (fboundp 'projectile-project-name)
        (projectile-project-name))))

;; -------------------------------------------------------------------------- ;;
;;
;; anzu segment
;;
;; -------------------------------------------------------------------------- ;;

(defun esprit-line-segment-anzu ()
  "Return color-coded anzu status information."
  (when (bound-and-true-p anzu--state)
    (cond
     ((eq anzu--state 'replace-query)
      (format #("Replace%s%d"
                7 10 (face esprit-line-status-info))
              (esprit-line--get-glyph :count-separator)
              anzu--cached-count))
     (anzu--overflow-p
      (format #("%d/%d+"
                0 2 (face esprit-line-status-info)
                3 6 (face esprit-line-status-error))
              anzu--current-position anzu--total-matched))
     (t
      (format #("%d/%d"
                0 2 (face esprit-line-status-info))
              anzu--current-position anzu--total-matched)))))

;; -------------------------------------------------------------------------- ;;
;;
;; multiple-cursors segment
;;
;; -------------------------------------------------------------------------- ;;

(defun esprit-line-segment-multiple-cursors ()
  "Return the number of active multiple-cursors."
  (when (bound-and-true-p multiple-cursors-mode)
    (format #("MC%s%d"
              2 5 (face esprit-line-status-info))
            (esprit-line--get-glyph :count-separator)
            (mc/num-cursors))))

;; -------------------------------------------------------------------------- ;;
;;
;; Buffer information segments
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; Buffer status segment
;; ---------------------------------- ;;

(defun esprit-line-segment-buffer-status ()
  "Return an indicator representing the status of the current buffer."
  (if (buffer-file-name (buffer-base-buffer))
      (cond
       ((and (buffer-narrowed-p)
             (buffer-modified-p))
        (propertize (esprit-line--get-glyph :buffer-narrowed)
                    'face 'esprit-line-buffer-status-modified))
       ((and (buffer-narrowed-p)
             buffer-read-only)
        (propertize (esprit-line--get-glyph :buffer-narrowed)
                    'face 'esprit-line-buffer-status-read-only))
       ((buffer-narrowed-p)
        (propertize (esprit-line--get-glyph :buffer-narrowed)
                    'face 'esprit-line-buffer-status-narrowed))
       ((buffer-modified-p)
        (propertize (esprit-line--get-glyph :buffer-modified)
                    'face 'esprit-line-buffer-status-modified))
       (buffer-read-only
        (propertize (esprit-line--get-glyph :buffer-read-only)
                    'face 'esprit-line-buffer-status-read-only)))
    (when (buffer-narrowed-p)
      (propertize (esprit-line--get-glyph :buffer-narrowed)
                  'face 'esprit-line-buffer-status-narrowed))))

;; ---------------------------------- ;;
;; Buffer name segment
;; ---------------------------------- ;;

(defun esprit-line-segment-buffer-name ()
  "Return the name of the current buffer with an indicator for remote files."
  ;; (propertize (format "%s" (buffer-name)) 'face 'esprit-line-buffer-name)
  (let* ((name (buffer-name))
         (remote (and buffer-file-name
                      (file-remote-p buffer-file-name))))
    (if remote
        (concat
         (propertize name 'face 'esprit-line-buffer-name)
         (propertize (format " %s" (esprit-line--get-glyph :buffer-remote))
                     'help-echo (format "Remote: %s" (file-remote-p buffer-file-name 'host))
                     'face 'esprit-line-status-info))
      (propertize name 'face 'esprit-line-buffer-name))))

;; ---------------------------------- ;;
;; Cursor position segment
;; ---------------------------------- ;;

(defun esprit-line-segment-cursor-position ()
  "Return the position of the cursor in the current buffer."
  (format-mode-line "%l:%c"))

;; ---------------------------------- ;;
;; Cursor point segment
;; ---------------------------------- ;;

(defun esprit-line-segment-cursor-point ()
  "Return the value of `point' in the current buffer."
  (format #("%d"
            0 2 (face esprit-line-unimportant))
          (point)))

;; ---------------------------------- ;;
;; Region segment
;; ---------------------------------- ;;

(defun esprit-line-segment-region ()
  "Return the size of the active region in the current buffer, if any."
  (when (use-region-p)
    (format #("%sL:%sC"
              0 7 (face esprit-line-unimportant))
            (count-lines (region-beginning)
                         (region-end))
            (- (region-end) (region-beginning)))))

;; ---------------------------------- ;;
;; Scroll segment
;; ---------------------------------- ;;

(defun esprit-line-segment-scroll ()
  "Return the relative position of the viewport in the current buffer."
  (format-mode-line "%o" 'esprit-line-unimportant))

;; ---------------------------------- ;;
;; EOL segment
;; ---------------------------------- ;;

(defun esprit-line-segment-eol ()
  "Return the EOL type for the coding system of the current buffer."
  (when buffer-file-coding-system
    (pcase (coding-system-eol-type buffer-file-coding-system)
      (0 "LF")
      (1 "CRLF")
      (2 "CR"))))

;; ---------------------------------- ;;
;; Encoding segment
;; ---------------------------------- ;;

(defun esprit-line-segment-encoding ()
  "Return the name of the coding system of the current buffer."
  (when buffer-file-coding-system
    (let ((coding-system (coding-system-plist buffer-file-coding-system)))
      (cond
       ((memq (plist-get coding-system :category)
              '(coding-category-undecided coding-category-utf-8))
        "UTF-8")
       (t
        (upcase (symbol-name (plist-get coding-system :name))))))))

;; ---------------------------------- ;;
;; Major mode segment
;; ---------------------------------- ;;

(defun esprit-line-segment-major-mode ()
  "Return the name of the major mode of the current buffer."
  (propertize (substring-no-properties (format-mode-line mode-name))
              'face 'esprit-line-major-mode))

;; ---------------------------------- ;;
;; Misc. info segment
;; ---------------------------------- ;;

(defun esprit-line-segment-misc-info ()
  "Return the current value of `mode-line-misc-info'."
  (let ((misc-info (format-mode-line mode-line-misc-info)))
    (unless (string-blank-p misc-info)
      (propertize (string-trim misc-info)
                  'face 'esprit-line-unimportant))))

;; ---------------------------------- ;;
;; Process segment
;; ---------------------------------- ;;

(defun esprit-line-segment-process ()
  "Return the current value of `mode-line-process'."
  (let ((process-info (format-mode-line mode-line-process)))
    (unless (string-blank-p process-info)
      (string-trim process-info))))

;; -------------------------------------------------------------------------- ;;
;;
;; esprit-line-mode
;;
;; -------------------------------------------------------------------------- ;;

(defconst esprit-line--hooks-alist
  '((esprit-line-segment-checker--flycheck-update
     . (flycheck-mode-hook
        flycheck-status-changed-functions))
    (esprit-line-segment-vc--update
     . (find-file-hook
        after-save-hook)))
  "Alist of update functions and their corresponding hooks.")

(defconst esprit-line--advice-alist
  '((esprit-line-segment-checker--flymake-update
     . (flymake-start
        flymake--handle-report))
    (esprit-line-segment-vc--update
     . (vc-refresh-state)))
  "Alist of update functions and their corresponding advised functions.")

(defconst esprit-line--settings-alist
  '((anzu-cons-mode-line-p
     . nil)
    (mode-line-format
     . (:eval (esprit-line--process-format esprit-line-format))))
  "Alist providing symbol names and their desired values.
These settings are applied by `esprit-line--activate' when `esprit-line-mode'
is activated. The original value of each symbol will be stored in
`esprit-line--settings-backup-alist' until `esprit-line--deactivate' is called.")

(defvar esprit-line--settings-backup-alist nil
  "Alist storing symbol names and their original values.
Populated by `esprit-line--activate', and emptied by `esprit-line--deactivate'.")

;; ---------------------------------- ;;
;; Activation
;; ---------------------------------- ;;

(defun esprit-line--activate ()
  "Activate esprit-line, installing hooks and setting `mode-line-format'."
  ;; Install hooks and advice
  (cl-loop for (update-fn . hooks) in esprit-line--hooks-alist
           do (dolist (hook hooks)
                (add-hook hook update-fn)))
  (cl-loop for (update-fn . advised-fns) in esprit-line--advice-alist
           do (dolist (advised-fn advised-fns)
                (advice-add advised-fn :after update-fn)))
  ;; Install configuration, backing up original values
  (cl-loop for (var . new-val) in esprit-line--settings-alist
           when (boundp var) do (push (cons var (eval var))
                                      esprit-line--settings-backup-alist)
           do (set-default (intern (symbol-name var)) new-val)))

;; ---------------------------------- ;;
;; Deactivation
;; ---------------------------------- ;;

(defun esprit-line--deactivate ()
  "Deactivate esprit-line, uninstalling hooks and restoring `mode-line-format'."
  ;; Destroy hooks and advice
  (cl-loop for (update-fn . hooks) in esprit-line--hooks-alist
           do (dolist (hook hooks)
                (remove-hook hook update-fn)))
  (cl-loop for (update-fn . advised-fns) in esprit-line--advice-alist
           do (dolist (advised-fn advised-fns)
                (advice-remove advised-fn update-fn)))
  ;; Restore original configuration values
  (cl-loop for (var . old-val) in esprit-line--settings-backup-alist
           do (set-default (intern (symbol-name var)) old-val)))

;; ---------------------------------- ;;
;; Mode definition
;; ---------------------------------- ;;

;;;###autoload
(define-minor-mode esprit-line-mode
  "Toggle esprit-line on or off."
  :group 'esprit-line
  :global t
  :lighter nil
  (if esprit-line-mode
      (esprit-line--activate)
    (esprit-line--deactivate)))

;; -------------------------------------------------------------------------- ;;
;;
;; Provide package
;;
;; -------------------------------------------------------------------------- ;;

(provide 'esprit-line)

;;; esprit-line.el ends here
