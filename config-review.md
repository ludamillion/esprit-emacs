# Emacs Config Review

Veteran minimalist perspective. Bugs first, then conflicts, redundancies, and anti-patterns.

This file is a living document:

- **TODO** lists open issues. Line numbers refer to the file state on the date of the last review.
- **History** lists fixed issues, with the fix date. If the fix date is not known, the entry
  gives the date that the agent examined the config and found the fix.
- **Notes** lists patterns, preferences, and decisions to keep in mind for the next review.

Last review: 2026-10-05 (Emacs 31.1, `emacs-plus@31`).

## TODO

### Conflicts

- [ ] `s-p` has two bindings: `consult-buffer` (`init.el:759`) and `swiss-move-line-up`
  (`init.el:1050`). The later binding wins, so the `consult-buffer` binding is dead. (With the
  macOS modifier swap, `s-` is the physical Control key.)
- [ ] `M-m` (`init.el:685`) binds `flymake-follow-toggle-diagnostics` and removes
  `back-to-indentation`. The comment at `init.el:100` says `M-M` "expands M-m", but `M-m` no
  longer does the base action. Also, `C-a` (`esprit-movement`) already toggles to indentation.
  Decide which binding to keep.
- [ ] `mini-ontop` (`init.el:71`) and `emacs-mini-frame` (`init.el:1652`) both load.
  `mini-ontop` stops the main window from scrolling when the minibuffer grows. `mini-frame`
  moves the minibuffer to a child frame, so the main window does not change size.
  `mini-ontop` has no job when `mini-frame` is on. Keep one after the `mini-frame` trial.
- [ ] `init.el:1375` the side-window rule for `(derived-mode . special-mode)` is very broad.
  It also catches `magit-status` (`magit-section-mode` derives from `special-mode`), `ibuffer`,
  `proced`, and `*Messages*`. All of these open in an 80-column right side window that
  `delete-other-windows` cannot remove. Make sure that this is the intended behavior. If not,
  list the help modes by name.
- [ ] `init.el:1226-1233` `project-find-go-module` puts `go.mod` directories before VC roots
  for all project lookups, after the first Go buffer. `project-vc-extra-root-markers`
  (`init.el:138`) already has `go.mod`. Remove one of the two mechanisms.
- [ ] `init.el:1189-1198` `treesit-env` and `treesit-auto-install-grammar t` (`init.el:158`)
  both install grammars. Also, `treesit-env-abi-max 14` is below the maximum ABI (15) that
  Emacs 31 supports. Keep one installer.

### Redundancies

- [ ] `init.el:326-332` `esprit-emacs/prefer-spaces` in `emacs-lisp-mode-hook` duplicates the
  global `(setopt indent-tabs-mode nil)` at `init.el:557`.
- [ ] `init.el:116` `trash-directory` has no effect. `move-file-to-trash` calls
  `system-move-file-to-trash` first when it is defined (`init.el:255`). The comment at
  `init.el:254` describes the opposite.
- [ ] `init.el:578-588` `savehist-watchlist` lists minibuffer histories that
  `savehist-save-minibuffer-history` already saves. Only `kill-ring` is new.
- [ ] `init.el:93` `RET` → `newline-and-indent` duplicates `electric-indent-mode` (on by
  default). `init.el:103` `C-s` → `isearch-forward` is the default binding.
- [ ] `init.el:988` `C-z` and `init.el:97` `M-Z` both bind `zap-up-to-char`.
- [ ] `init.el:559` `editorconfig` `:ensure t`. EditorConfig is built in since Emacs 30. `:ensure t`
  can install the ELPA copy over the built-in copy.
- [ ] `early-init.el:60` `esprit-emacs-package-initialize-and-refresh` has no reader.
- [ ] `init.el:317` `esprit-emacs/copy-whole-word` has no key binding and no caller.

### Dead or unused packages

- [ ] `monet` (`init.el:1584`) installs, but nothing enables it. `claude-code` needs
  `monet-mode` and `monet-start-server-function` in
  `claude-code-process-environment-functions` to use it.
- [ ] `ct` (`init.el:1670`) installs, but no file in the repo calls it.
- [ ] `:diminish` (`init.el:1317`, `init.el:1320`) has no effect. The `diminish` package is not
  installed, and `esprit-line` does not show minor modes.
- [ ] `eglot-ltex` is in `package-selected-packages` (`custom.el`) but not in `init.el`. Run
  `package-autoremove`.
- [ ] `places.eld` (repo root, last write 2026-09-02) is a leftover from before the XDG fix.
  The live file is in `~/.local/state/emacs/saveplace/`. Delete the old file.

### Anti-patterns and cleanup

- [ ] `init.el:1391` `C-c C-c C-p` is a global binding in a key space that major modes own.
  Bind it in `markdown-mode-map`. `init.el:1370` `C-c C-d` (`helpful-at-point`) has the same
  problem.
- [ ] `init.el:429-468` the TRAMP memo helpers (`memoize-remote`, `clear-memoized-caches`,
  `project-current-cache`, and others) have no package prefix. The `avy-action-*` functions
  (`init.el:934-975`) use the `avy-` prefix that belongs to `avy`. Use `esprit/`.
- [ ] `init.el:286-288` `EDITOR`, `GIT_EDITOR`, and `JJ_EDITOR` start a full new Emacs for each
  commit. Consider `emacsclient` with `server-start`. Also, `PAGER=cat` (`init.el:289`) applies
  to `ghostel` terminals, where a pager is useful.
- [ ] `init.el:552` `recentf-exclude` excludes only `/ssh:`, `/su:`, and `/sudo:`. Other TRAMP
  methods (`rpc`, `sshx`, `docker`) go into recentf. Use `file-remote-p` as a predicate.
- [ ] `init.el:25` `exec-path-from-shell` `:if (memq window-system ...)` is false in a daemon,
  but the config supports a daemon (`init.el:1071`). Add `(daemonp)` to the condition.
- [ ] `init.el:1204`, `1220`, `1236`, `1249` the `:mode` regexes end with `eow`, not `eos`. Thus
  `bundle.js.map` opens in `js-ts-mode`, and `x.go.tmpl` opens in `go-ts-mode`. The `(in ?x ?m)`
  suffix matches `.tsm`/`.jsm`, but misses `.mts`/`.mjs`/`.cjs`. On Emacs 31,
  `treesit-enabled-modes t` already maps these extensions.
- [ ] `init.el:1447-1459` `setq` on undeclared `esprit/*` variables. Use `defvar`.
- [ ] `init.el:1606` `esprit-emacs--success` is set before 9 more `use-package` forms. An error
  in those forms does not cause the startup error message. Move the line to the end of the file.
- [ ] `init.el:364`, `357-359`, `370-374` anonymous lambdas in hooks and advice. Each
  `esprit/reload-init-file` (`<f5>`) adds a new copy. Use named functions.
- [ ] `init.el:855` `eglot` `:demand t` and `init.el:1243` `web-mode` `:demand t` load at
  startup. `eglot-ensure` is autoloaded. Only the `eglot-server-programs` additions need
  `eglot` (use `with-eval-after-load`).
- [ ] `init.el:1620-1624` `obsidian` loads only through `obsidian-capture` or `obsidian-search`.
  `global-obsidian-mode` is in `:config`, so it does not start until one of these commands runs.
  Make sure that this is the intended behavior.
- [ ] `init.el:1473` `org-agenda-files` includes the iCloud beorg directory. On a machine
  without this directory, `org-agenda` prompts to remove the entry.
- [ ] `lisp/esprit-themes/esprit-blue-dark-theme.elc` exists, and `load-prefer-newer` is not
  set. A stale `.elc` file can hide changes to the `.el` file. Set `load-prefer-newer` to `t` in
  `early-init.el`, or delete the `.elc` file.
- [ ] `early-init.el:5` and `init.el:5` `Package-Requires: ((emacs "29.1"))` and `CLAUDE.md`
  say Emacs 29.1+. The config uses Emacs 30 and 31 features without guards (`lua-ts-mode`,
  `which-key`, the `EMACS-31` settings).
- [ ] `CLAUDE.md` is out of date: it names `eat` (now `ghostel`) and does not list
  `prose-mode.el`, `esprit-side-note.el`, or `reasonable-colors.el`.

## Notes

- **Emacs version**: the target is Emacs 31 (`emacs-plus@31`). The `; EMACS-31` comments mark
  31-only settings. An unknown variable or command on an older Emacs is harmless, but a call to
  a 31-only function needs a version guard (as at `init.el:391`).
- **Modifier swap on macOS**: Command → Control, Option → Meta, Control → Super. A `s-` binding
  is on the physical Control key. Look for collisions between `s-` bindings.
- **Key space**: `C-c <letter>` is the user prefix (`C-c g` VC, `C-c t` toggles, `C-c n` notes,
  `C-c w` window). `M-n` is the frame prefix. `C-x C-m` replaces the `C-x RET` coding prefix
  on purpose.
- **`C-x b`** is `consult-bookmark`, not `switch-to-buffer`. Buffer switch is `M-s SPC`. This
  is intentional. Do not report it.
- **XDG**: state and cache files use the `:xdg-state` and `:xdg-cache` keywords of
  `use-package-xdg`. The live state is in `~/.local/state/emacs/<package>/`. Some state is
  still in the repo root (`projects.eld`, `tramp`, `transient/`, `eshell/`, `elgrep-data.el`).
  `.gitignore` covers these files.
- **`custom.el`** is set in `early-init.el` but never loaded. Customize writes there and the
  config ignores it. `package-selected-packages` collects there.
- **TRAMP**: `project-current`, `magit-toplevel`, and `vc-git-root` are memoized for remote
  paths. Direct async processes apply only around `compilation-start`, so Eglot keeps normal
  connection tracking.
- **Spell and grammar**: `jinx` checks spelling. `ltex-ls-plus` checks grammar with its spelling
  rule (`MORFOLOGIK_RULE_EN_US`) off. Do not report double spell checking.
- **Notes stack**: `org` + `denote` + `consult-notes` for org notes. `obsidian` + `xeft` for the
  `~/pkm` vault. The two systems are separate on purpose.
- **Review method**: the agent reads `init.el` and `early-init.el` in full, then examines
  suspect behavior against the installed Emacs source and `elpa/` packages before it adds a
  TODO.

## History

| Date | Fix |
|---|---|
| 2026-04-29 | `helpful-switch-to-buffer` typo and broken `if` (`d33cab5`) |
| 2026-09-02 | `save-place-mode` state file moves to `:xdg-state` (`places.eld` untracked and in `.gitignore`) (`8fb0e1b`) |
| 2026-09-02 | Dead `declare-function` for `esprit-emacs/disable-global-scrolling-in-ansi-term` removed (`8fb0e1b`) |
| 2026-10-05 (confirmed) | `avy` dispatch alist moved from `:custom` to `:config` |
| 2026-10-05 (confirmed) | Malformed nested `ghostel` block |
| 2026-10-05 (confirmed) | `org` `:custom`/`:config` misplacement |
| 2026-10-05 (confirmed) | Cross-file duplicate settings (`early-init.el` vs `init.el`) |
| 2026-10-05 (confirmed) | Redundant `recentf-mode`/`savehist-mode`/`global-auto-revert-mode` activations |
| 2026-10-05 (confirmed) | Leftover `straight.el` bootstrap and `:straight` keywords removed (move to `package.el`/`:vc`) |
| 2026-10-05 (confirmed) | `asdf` and `mise` both loaded (only `mise` remains) |
| 2026-10-05 (confirmed) | `web-mode` declared twice (one declaration remains) |
| 2026-10-05 (confirmed) | `cape` capf setup accumulation bug (`setq-local` replaces the list) |
| 2026-10-05 | `tooltip-mode` and `tty-tip-mode` called with `-1` (`nil` enabled them) |
| 2026-10-05 | `auto-save-list-prefix` changed to `auto-save-list-file-prefix` (`:xdg-state`) |
| 2026-10-05 | `completion-category-overrides` set in `orderless` only (`cape` no longer replaces it) |
| 2026-10-05 | `yaml-ts-mode` sets `tab-width` buffer-locally (`esprit/yaml-tab-width`) |
| 2026-10-05 | `marginalia--align` changed to `marginalia-align` |
| 2026-10-05 | ibuffer "Magit" group: `magit-status-Mode` changed to `magit-status-mode` |
| 2026-10-05 | `unpropertize-kill-ring` moved from `kill-emacs-hook` to `savehist-save-hook` |
| 2026-10-05 | `.tsx` opens in `tsx-ts-mode`, with Eglot (`typescriptreact` language ID) |
| 2026-10-05 | `typescript-indent-level` changed to `typescript-ts-mode-indent-offset` |
