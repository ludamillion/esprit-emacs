# <img src=".repo-assets/icon.png" width=50> esprit-line

A lightweight, drop-in replacement for the default Emacs mode line configuration.

## Features

* Clean, informative design

* Customizable, modular segment format

* Customizable glyph sets

* Lazy-loaded extensions

* [Lightweight](.repo-assets/benchmark.md), no dependencies

## Preview

![Preview Image](.repo-assets/preview.webp "Preview Image")

## Configuration

esprit-line is not published on a package archive; install it via `use-package`'s `:vc` keyword
or by adding it to your `load-path` directly.
After installation, you can activate the global minor mode with `M-x esprit-line-mode`.
Deactivating `esprit-line-mode` will restore the default `mode-line-format`.

If you are a user of `use-package`, it is easy to configure esprit-line directly in your init.el:

```elisp
(use-package esprit-line

  ;; Enable esprit-line
  :config
  (esprit-line-mode)

  ;; Use pretty Unicode-compatible glyphs
  :custom
  (esprit-line-glyph-alist esprit-line-glyphs-unicode))
```

### Format

esprit-line uses a modular segment format, and it is easy to reconfigure:

```elisp
;; Default format:
;;   * init.el  4:32 Top                                         ELisp  ! Issues: 2
(setq esprit-line-format esprit-line-format-default)

;; Extended format:
;;   * init.el  4:32:52 Top                    SPCx2  LF  UTF-8  ELisp  ! Issues: 2
(setq esprit-line-format esprit-line-format-default-extended)

;; Custom format:
;;   * init.el : ELisp                                     Top 4:32  |  ! Issues: 2
(setq esprit-line-format
      (esprit-line-defformat
       :left
       (((esprit-line-segment-buffer-status) . " ")
        ((esprit-line-segment-buffer-name)   . " : ")
        (esprit-line-segment-major-mode))
       :right
       (((esprit-line-segment-scroll)             . " ")
        ((esprit-line-segment-cursor-position)    . "  ")
        ((when (esprit-line-segment-checker) "|") . "  ")
        ((esprit-line-segment-checker)            . "  "))))
```

More information on the format specification is available in the documentation:\
`M-x describe-variable esprit-line-format`\
`M-x describe-function esprit-line-defformat`

### Glyphs

By default, esprit-line will use basic ASCII character glyphs to decorate mode line segments.
If you'd like to see prettier Unicode glyphs, you can change the value of `esprit-line-glyph-alist`:

```elisp
;; The default set of glyphs:
;;   * myModifiedFile.js  Replace*3                 + main  JavaScript  ! Issues: 2
(setq esprit-line-glyph-alist esprit-line-glyphs-ascii)

;; A set of Unicode glyphs:
;;   ● myModifiedFile.js  Replace✕3                 🞤 main  JavaScript  ⚑ Issues: 2
(setq esprit-line-glyph-alist esprit-line-glyphs-unicode)
```

If you'd like to supply your own glyphs, you can use the customization interface
(`M-x customize-variable esprit-line-glyph-alist`) or view the documentation
(`M-x describe-variable esprit-line-glyph-alist`) for more information.

You can further tweak the behavior and appearance of esprit-line by viewing the customizable variables
and faces in the `esprit-line` and `esprit-line-faces` customization groups. (`M-x customize-group esprit-line`)

## Testing

To run the included tests:

```bash
./ert-test.sh
```

## Feedback

If you experience any issues with this package, please
[open an issue](https://gitlab.com/ludamillion/esprit-line/-/issues/new)
on the issue tracker.

Suggestions for improvements and feature requests are always appreciated, as well!
