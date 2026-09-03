;;; esprit-line-test.el --- Test specifications for esprit-line.el -*- lexical-binding: t; -*-

(add-to-list 'load-path ".")

(require 'ert)
(require 'esprit-line)

;;; Code:

;; -------------------------------------------------------------------------- ;;
;;
;; Macros
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; esprit-line-defformat
;; ---------------------------------- ;;

(ert-deftest -defformat/padding ()
  "The expanded sequence should include the provided (or default) padding."
  (should (equal (esprit-line-defformat)
                 (list
                  ;; Left
                  '(" ")
                  ;; Right
                  '(" "))))
  (should (equal (esprit-line-defformat
                  :padding
                  "---")
                 (list
                  ;; Left
                  '("---")
                  ;; Right
                  '("---")))))

(ert-deftest -defformat/left-right-nil ()
  "The format sequence should expand if the left or right segment list is nil."
  (should (equal (esprit-line-defformat
                  :left
                  ("XYZ"))
                 (list
                  ;; Left
                  '(" " "XYZ")
                  ;; Right
                  '(" "))))
  (should (equal (esprit-line-defformat
                  :right
                  ("XYZ"))
                 (list
                  ;; Left
                  '(" ")
                  ;; Right
                  '("XYZ" " ")))))

(ert-deftest -defformat/left-right ()
  "The expanded sequence should include left and right segments lists."
  (should (equal (esprit-line-defformat
                  :left
                  ("ABC")
                  :right
                  ("XYZ"))
                 (list
                  ;; Left
                  '(" " "ABC")
                  ;; Right
                  '("XYZ" " ")))))

(ert-deftest -defformat/cons-cells ()
  "Cons cell segments should expand into their `car' and `cdr' values."
  (should (equal (esprit-line-defformat
                  :left
                  ("ABC" ("ABC" . "XYZ") "XYZ")
                  :right
                  ("..." ((some-fn) . " ") "..."))
                 (list
                  ;; Left
                  '(" " "ABC" "ABC" "XYZ" "XYZ")
                  ;; Right
                  '("..." (some-fn) " " "..." " ")))))

(ert-deftest -defformat/exp-separators ()
  "Non-string, non-cons expressions should expand followed by a blank string."
  (should (equal (esprit-line-defformat
                  :left
                  ("ABC" ("ABC" . "XYZ") some-exp "XYZ" (some-fn))
                  :right
                  ("..." ((some-fn) . " ") (another-fn) "..."))
                 (list
                  ;; Left
                  '(" " "ABC" "ABC" "XYZ" some-exp "" "XYZ" (some-fn) "")
                  ;; Right
                  '("..." (some-fn) " " (another-fn) "" "..." " ")))))

;; -------------------------------------------------------------------------- ;;
;;
;; Helper functions
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; esprit-line--get-glyph
;; ---------------------------------- ;;

(ert-deftest --get-glyph/unicode ()
  "Glyphs should be fethed from `esprit-line-glyph-alist'."
  (let ((esprit-line-glyph-alist '((:checker-info . ?🛈))))
    (should (string= (esprit-line--get-glyph :checker-info) "🛈"))))

(ert-deftest --get-glyph/fallback-ascii ()
  "Glyphs should be fetched from `esprit-line-glyphs-ascii' as a fallback."
  (let ((esprit-line-glyph-alist nil))
    (should (string= (esprit-line--get-glyph :checker-info) "i"))))

;; ---------------------------------- ;;
;; esprit-line--process-segments
;; ---------------------------------- ;;

(ert-deftest --process-segments/default ()
  "`esprit-line-format-default' should be processed without error."
  (let* ((left (car esprit-line-format-default))
         (right (cadr esprit-line-format-default))
         (left-str (esprit-line--process-segments left))
         (right-str (esprit-line--process-segments right)))
    (should (> (length left-str) 0))
    (should (> (length right-str) 0))))

(ert-deftest --process-segments/strings ()
  "Literal strings should be concatenated."
  (let* ((segments '("ABC" "   " "123" "   " "XYZ"))
         (segments-str (esprit-line--process-segments segments)))
    (should (string= segments-str "ABC   123   XYZ"))))

(ert-deftest --process-segments/nil-neighbor-exclusion ()
  "A nil value should mean skipping evaluation of the following segment."
  (let* ((segments '("ABC" nil "   " "123" nil "   " "XYZ" nil))
         (segments-str (esprit-line--process-segments segments)))
    (should (string= segments-str "ABC123XYZ"))))

(ert-deftest --process-segments/functions ()
  "Functions should be evaluated, and their return values concatenated."
  (let* ((segments '((string ?A ?B ?C)
                     (numberp nil) "   "
                     (number-to-string (+ 100 20 3))
                     (identity nil) "   "
                     (concat "X" "Y" "Z")))
         (segments-str (esprit-line--process-segments segments)))
    (should (string= segments-str "ABC123XYZ"))))

;; ---------------------------------- ;;
;; esprit-line--process-format
;; ---------------------------------- ;;

(ert-deftest --process-format/default ()
  "`esprit-line-format-default' should be processed without error."
  (let* ((format-str (esprit-line--process-format esprit-line-format-default)))
    (should (> (length format-str) 0))))

(ert-deftest --process-format/nil-okay ()
  "Either segment list should process without error if the other list is nil."
  (let* ((format-l-nil '(nil ("ABC" nil "   " "123" nil "   " "XYZ")))
         (format-r-nil '(("ABC" nil "   " "123" nil "   " "XYZ") nil))
         (format-l-nil-str (esprit-line--process-format format-l-nil))
         (format-r-nil-str (esprit-line--process-format format-r-nil)))
    (should (string-suffix-p "ABC123XYZ" format-l-nil-str))
    (should (string-prefix-p "ABC123XYZ" format-r-nil-str))))

;; -------------------------------------------------------------------------- ;;
;;
;; esprit-line-mode
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; esprit-line--activate
;; ---------------------------------- ;;

(ert-deftest --activate/mode-line-format ()
  "`mode-line-format' should be set by `esprit-line--activate'."
  (let* ((setting-val (alist-get 'mode-line-format
                                 esprit-line--settings-alist))
         (esprit-line--settings-alist `((mode-line-format . ,setting-val)))
         (esprit-line-format esprit-line-format-default)
         (mode-line-format '("ABC 123 XYZ"))
         (format-str (esprit-line--process-format esprit-line-format)))
    (esprit-line--activate)
    (should (string= (format-mode-line mode-line-format)
                     (format-mode-line format-str)))))

;; ---------------------------------- ;;
;; esprit-line--deactivate
;; ---------------------------------- ;;

(ert-deftest --deactivate/mode-line-format ()
  "`mode-line-format' should be restored by `esprit-line--deactivate'."
  (let* ((setting-val (alist-get 'mode-line-format
                                 esprit-line--settings-alist))
         (esprit-line--settings-alist `((mode-line-format . ,setting-val)))
         (esprit-line--settings-backup-alist nil)
         (esprit-line-format esprit-line-format-default)
         (mode-line-format "ABC 123 XYZ"))
    (esprit-line--activate)
    (esprit-line--deactivate)
    (should (string= mode-line-format "ABC 123 XYZ"))))

;;; esprit-line-test.el ends here
