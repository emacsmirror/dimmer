## Context

Dimmer computes dimmed colors once and caches them in `dimmer-dimmed-faces` (a `defconst` hash table). The computation interpolates each face's foreground/background toward the `default` face's colors in the configured colorspace (default: CIELAB).

On startup, if `dimmer-mode` activates before the user's theme loads (common with `use-package` ordering), the `default` face resolves to terminal defaults or Emacs defface values — not the theme's palette. CIELAB interpolation between these distant color points can go outside the RGB gamut, and `color-clamp` produces saturated artifact colors.

No existing mechanism triggers a reprocess when a theme loads, so the bad cache persists until the user manually intervenes. This also means changing themes interactively only updates the active window — dimmed buffers keep the old theme's colors (#72).

The current cache:

```elisp
(defconst dimmer-dimmed-faces (make-hash-table :test 'equal)
  "Cache of face names with their computed dimmed values.")
```

The current `dimmer-mode` setup (lines 615-624):

```elisp
(if dimmer-mode
    (progn
      (dimmer-manage-frame-focus-hooks t)
      (add-hook 'post-command-hook #'dimmer-command-handler)
      (add-hook 'window-configuration-change-hook
                #'dimmer-config-change-handler))
  (dimmer-manage-frame-focus-hooks nil)
  (remove-hook 'post-command-hook #'dimmer-command-handler)
  (remove-hook 'window-configuration-change-hook
               #'dimmer-config-change-handler))
```

## Goals / Non-Goals

**Goals:**
- Clear the `dimmer-dimmed-faces` cache and reprocess all buffers whenever a theme is enabled
- Support all supported Emacs versions (27.1+) via appropriate hook mechanism
- Fix both the startup initialization bug and interactive theme-change bug (#72)
- Zero behavioral change for users who never change themes (hook simply never fires)

**Non-Goals:**
- Not adding new user-facing configuration or API
- Not preventing the first `dimmer-process-all` from computing with pre-theme colors (that would require a blocking guard — the hook approach fixes it after the fact within one frame refresh)
- Not addressing other cache-staleness scenarios (face color changes outside of theme loads)

## Decisions

### Decision 1: Clear cache and reprocess on `enable-theme`

The handler does two things: `(clrhash dimmer-dimmed-faces)` to invalidate stale entries, then `(dimmer-process-all t)` to re-dim all buffers with the new theme's colors. The `force=t` argument ensures even previously-excluded buffers are processed.

**Alternatives considered:**
- **Lazy invalidation**: Check a theme-version counter on each face lookup. More complex, no benefit over eager clearing.
- **Per-face invalidation**: Only clear entries for faces the theme changes. Impractical — Emacs doesn't expose which faces a theme modifies.
- **Skip first `dimmer-process-all` entirely**: Add a flag `dimmer--theme-not-yet-loaded` that blocks processing until `enable-theme-functions` fires. Would prevent the bad first render entirely but introduces a state variable and a one-frame delay for all users. Over-engineered for a cosmetic issue.

### Decision 2: `enable-theme-functions` with `advice-add` fallback

`enable-theme-functions` is available on Emacs 29+. For 27-28, advice `enable-theme` directly.

```elisp
(defun dimmer-manage-theme-hooks (install)
  (if install
      (if (boundp 'enable-theme-functions)
          (add-hook 'enable-theme-functions #'dimmer-theme-change-handler)
        (advice-add 'enable-theme :after #'dimmer-theme-change-handler))
    (if (boundp 'enable-theme-functions)
        (remove-hook 'enable-theme-functions #'dimmer-theme-change-handler)
      (advice-remove 'enable-theme #'dimmer-theme-change-handler))))
```

**Alternatives considered:**
- **`advice-add` only**: Works on all versions. But `enable-theme-functions` is the proper hook, fires for all theme-enable paths (including `load-theme`), and integrates with other packages. Prefer the hook when available.
- **Watch `custom-enabled-themes`**: Would catch both enable and disable, but doesn't tell you *which* theme changed. Overly complex.
- **Advise `load-theme`**: `load-theme` calls `enable-theme` internally, so advising `enable-theme` covers all entry points with a single advice.

### Decision 3: Match the `dimmer-manage-frame-focus-hooks` pattern

Hook install/remove follows the existing convention: a `dimmer-manage-*-hooks` function called from `dimmer-mode` with an `install` flag. This keeps the setup/teardown logic self-contained and the `dimmer-mode` function linear.

```elisp
;; In dimmer-mode setup:
(dimmer-manage-frame-focus-hooks t)
(dimmer-manage-theme-hooks t)           ;; ← new
(add-hook 'post-command-hook #'dimmer-command-handler)

;; In dimmer-mode teardown:
(dimmer-manage-frame-focus-hooks nil)
(dimmer-manage-theme-hooks nil)         ;; ← new
(remove-hook 'post-command-hook #'dimmer-command-handler)
```

## Risks / Trade-offs

- **[One frame of stale colors] Theme loads after dimmer**: On startup, there's still one frame refresh where the first `dimmer-process-all` computes with pre-theme defaults. Mitigation: the `enable-theme` call happens within the same init sequence, so the window is invisible to the user. In practice, the hook clears and reprocesses before the frame is ever displayed.
- **[Double reprocess] Theme reloaded**: If a user calls `enable-theme` for a theme already active, `enable-theme-functions` fires again, clearing and reprocessing. This is harmless (cache is repopulated with same values).
- **[Edge case] `advice-add` on `enable-theme` in Emacs 27-28**: The `:after` advice fires even if `enable-theme` errors. Unlikely, but if it does, the cache is cleared unnecessarily but harmlessly.