## Context

Dimmer currently dims colors by interpolating between a face color and a fixed target (the opposite `default` face component). All three existing modes (`:foreground`, `:background`, `:both`) use this same mechanism — they differ only in *which* attributes are processed. The `dimmer-cached-compute-rgb` pipeline handles the interpolation and caching transparently.

The two new modes (`:desaturate`, `:hueshift`) differ fundamentally: their target is **per-face** rather than global. For `:desaturate`, the target is a gray of the same lightness as the face color. For `:hueshift`, the target is a color with the configured target hue but the same saturation and lightness as the face color.

Fortunately, the existing architecture supports this naturally — `dimmer-cached-compute-rgb` accepts any `(c0, c1)` pair and caches by key. The per-face target just means `c1` varies per face, which still produces unique cache entries.

## Goals / Non-Goals

**Goals:**
- Add `:desaturate` and `:hueshift` values to `dimmer-adjustment-mode`
- Add `dimmer-hue-target` defcustom with `:background`, `:foreground`, or float 0.0–1.0
- Both modes affect all color-bearing attributes (fg, bg, box, underline, overline, strike-through, distant-foreground)
- No halving of the dimming fraction in either new mode
- Reuse existing `dimmer-cached-compute-rgb` for caching and interpolation

**Non-Goals:**
- Cache invalidation when changing `dimmer-hue-target` (handled separately in #82)
- Additional colorspace options specific to these modes
- Adding new customization variables beyond `dimmer-hue-target`
- Breaking existing `:foreground`/`:background`/`:both` behavior

## Decisions

### Decision 1: Per-face target via new helpers

Two new helper functions compute the per-face target:

```elisp
(defun dimmer--gray-of-same-lightness (color)
  "Return a gray (saturation 0) with the same lightness as COLOR."
  (let* ((rgb (color-name-to-rgb color))
         (hsl (apply #'color-rgb-to-hsl rgb))
         (l (nth 2 hsl)))
    (apply #'color-rgb-to-hex
           (apply #'color-hsl-to-rgb 0.0 0.0 l))))

(defun dimmer--color-with-target-hue (color target-hue)
  "Return a color with TARGET-HUE and COLOR's saturation and lightness."
  (let* ((rgb (color-name-to-rgb color))
         (hsl (apply #'color-rgb-to-hsl rgb))
         (s (nth 1 hsl))
         (l (nth 2 hsl)))
    (apply #'color-rgb-to-hex
           (apply #'color-hsl-to-rgb (mod target-hue 1.0) s l))))
```

Both convert to HSL, modify the relevant channel, and convert back to a hex string.

**Alternatives considered:**
- **Inlining in dimmer-face-color**: Duplicates HSL math across modes. New helpers keep concerns separate.
- **Extending dimmer-cached-compute-rgb with a mode parameter**: Overcomplicates the cached computation function. The per-face target is a caller concern.

### Decision 2: `dimmer-hue-target` resolution

`dimmer-hue-target` accepts three types of values. The resolution function extracts a 0.0–1.0 hue value:

```elisp
(defun dimmer--resolve-hue-target ()
  "Return the resolved hue value (0.0–1.0) from `dimmer-hue-target'."
  (pcase dimmer-hue-target
    (:background
     (nth 0 (apply #'color-rgb-to-hsl (color-name-to-rgb (face-background 'default)))))
    (:foreground
     (nth 0 (apply #'color-rgb-to-hsl (color-name-to-rgb (face-foreground 'default)))))
    ((pred floatp) dimmer-hue-target)))
```

**Alternatives considered:**
- **Resolving once per dimmer-process-all**: Possible optimization, but premature. The function is cheap and already cached per face-target pair.
- **Only accepting floats**: Less user-friendly. `:background` is an intuitive default.

### Decision 3: Dispatch in `dimmer-face-color`

The existing dispatch checks `dimmer-adjustment-mode` to decide which attributes to dim. The new modes always process all attributes. The target computation becomes:

```elisp
(pcase dimmer-adjustment-mode
  (:desaturate
   ;; fg → gray of same lightness
   (dimmer-cached-compute-rgb fg (dimmer--gray-of-same-lightness fg) frac ...))
  (:hueshift
   (let ((h (dimmer--resolve-hue-target)))
     ;; fg → same S+L, target hue
     (dimmer-cached-compute-rgb fg (dimmer--color-with-target-hue fg h) frac ...)))
  ;; existing modes unchanged
  ...
)
```

The `when` condition for the fg block expands from:

```elisp
(or (eq dimmer-adjustment-mode :foreground)
    (eq dimmer-adjustment-mode :both))
```

to:

```elisp
(memq dimmer-adjustment-mode
      '(:foreground :both :desaturate :hueshift))
```

Similarly for the background block, and the decorative attribute loop follows the same condition as foreground.

### Decision 4: No halving for new modes

The `my-frac` halving guard:

```elisp
(my-frac (if (eq dimmer-adjustment-mode :both)
             (/ frac 2.0)
           frac))
```

Grows to:

```elisp
(my-frac (if (memq dimmer-adjustment-mode '(:both :desaturate :hueshift))
             (/ frac 2.0)
           frac))
```

Wait — actually the user explicitly said "no halving." These modes shift toward a perceptual target, not toward each other. So only `:both` halves. Let me correct:

```elisp
(my-frac (if (eq dimmer-adjustment-mode :both)
             (/ frac 2.0)
           frac))
```

The `:desaturate` and `:hueshift` modes use the unadjusted `frac` — they're not blending toward a complementary color like `:both` does.

## Risks / Trade-offs

- **[Low] `face-background`/`face-foreground` on `'default` may return nil in non-graphical frames**: The `dimmer--resolve-hue-target` function calls `face-background 'default` when `dimmer-hue-target` is `:background`. If this returns nil, guard with `color-defined-p` and fall back to a default hue (e.g., 0.0). Mitigation: the existing code already guards `def-fg`/`def-bg` similarly. Follow the same pattern.
- **[Low] HSL round-trip precision**: Converting RGB → HSL → modifying → RGB loses some precision for extreme colors. This is inherent to the HSL representation and already present in `dimmer-lerp-in-hsl`. Not a new concern.
- **[None] Cache pollution**: Since `c1` varies per face (each face's gray or hue-shifted color is unique), the cache grows slightly but entries are naturally reused across `dimmer-process-all` calls. Same pattern as existing cache behavior.
