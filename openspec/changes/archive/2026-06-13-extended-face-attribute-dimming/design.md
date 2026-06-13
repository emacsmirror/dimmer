## Context

`dimmer-face-color` currently fetches `:foreground` and `:background` from a face, dims each via `dimmer-cached-compute-rgb` (interpolating toward the opposite `default` face component), and returns a plist of dimmed values. Other color-bearing face attributes (`:box`, `:underline`, `:overline`, `:strike-through`, `:distant-foreground`) are ignored — they pass through to `face-remap-add-relative` undimmed, creating visual inconsistency where decorative strokes appear at full intensity alongside dimmed text.

Emacs face attributes represent color in two forms:
- **Direct color string**: `:foreground "#fff"`, `:background "#000"`, `:distant-foreground "#eee"` — value is a string or `unspecified`/`reset`.
- **Plists with optional `:color` key**: `:box`, `:underline`, `:overline`, `:strike-through` — value may be `nil`, `t` (use foreground color), or a plist like `(:line-width 2 :color "red" :style pressed-button)`. When the `:color` key is missing, the rendering engine uses the face's `:foreground` (already dimmed).

`face-remap-add-relative` accepts plist face specs — any attribute we include in the spec overrides the corresponding attribute from lower priorities. We can include the full modified plist (`:box '(:color "#dimmed" :line-width 2)`) to override color while preserving style.

## Goals / Non-Goals

**Goals:**
- Dim all color-bearing face attributes automatically whenever a face specifies them
- Apply the same color math as existing foreground/background dimming (interpolate toward the opposite `default` face component)
- Preserve all non-color aspects of each attribute (line-width, style, position, etc.)
- Zero behavioral change for faces that don't use these attributes
- Zero new user-facing configuration

**Non-Goals:**
- Not adding new customization options or `dimmer-adjustment-mode` values
- Not dimming non-color attributes (line-width, underline-style, box-style, etc.)
- Not adding per-attribute opt-out — all color-bearing attributes are always dimmed

## Decisions

### Decision 1: Single helper function `dimmer--dim-face-attribute`

A focused helper that fetches a face attribute and dims its color component(s):

```elisp
(defun dimmer--dim-face-attribute (face attribute target-color)
  "Dim the color in FACE's ATTRIBUTE toward TARGET-COLOR.
ATTRIBUTE is a face attribute keyword like :box, :underline, etc.
Returns the dimmed attribute value suitable for inclusion in a face spec.
If ATTRIBUTE has no color component, returns nil."
  (let ((value (face-attribute face attribute nil 'inherit)))
    (cond
     ;; Direct color string (e.g., :distant-foreground)
     ((stringp value)
      (dimmer-cached-compute-rgb value target-color dimmer-fraction
                                 dimmer-use-colorspace))
     ;; Plist with optional :color key (e.g., :box, :underline)
     ((and (listp value) (plist-member value :color))
      (let ((color (plist-get value :color)))
        (when (and (stringp color) (color-defined-p color))
          (plist-put (copy-sequence value) :color
                     (dimmer-cached-compute-rgb
                      color target-color dimmer-fraction
                      dimmer-use-colorspace)))))
     ;; t or nil — no explicit color, skip
     (t nil))))
```

**Alternatives considered:**
- **Inline per attribute**: Duplicate logic for each attribute. More code, harder to test.
- **Generic walk of face-attribute vector**: Over-engineered for the known set of color-bearing attributes.

### Decision 2: Filtered attribute list in `dimmer-face-color`

`dimmer-face-color` will call the helper for each color-bearing attribute, dimming foreground-ish attributes toward `default` background and background toward `default` foreground. Only non-nil results are plist-put into the result:

```elisp
;; After existing foreground/background blocks:
(dolist (attr '(:distant-foreground :box :underline :overline :strike-through))
  (when-let ((dimmed (dimmer--dim-face-attribute f attr def-bg)))
    (setq result (plist-put result attr dimmed))))
```

All decorative attributes use `def-bg` as target (same as foreground), since they render as foreground-like strokes.

### Decision 3: Color-bearing attributes only

We do NOT dim `:inherit` (a face list), `:font` (a font spec), `:stipple` (a bitmap), `:width`/`:height`/`:weight`/`:slant` (typographic), or any boolean/numeric attributes. Only attributes that accept explicit color values are processed.

### Decision 4: Use `face-attribute` with `'inherit` priority

`(face-attribute face attr nil 'inherit)` fetches the attribute from the face with full inheritance. This is the same resolution used by the existing `face-foreground`/`face-background` calls. Using `'inherit` ensures we get the effective color, including theme and defface defaults.

### Decision 5: Preserve non-color parts of plist attributes

For `:box`, `:underline`, `:overline`, `:strike-through`, when the face specifies plist values, we `copy-sequence` the plist and `plist-put` only the `:color` key. This preserves line-width, style, and position information exactly as the face defined them.

## Risks / Trade-offs

- **[Low] Box borders on dimmed buffers**: Box borders will be dimmer. This is the desired effect — a dimmed buffer should have all visual elements consistently dimmed.
- **[Low] Color computation cost**: Up to 5 additional `face-attribute` lookups per face per dim. `face-attribute` is a C function in Emacs that traverses the face inheritance chain and caches results. The lookup cost is negligible compared to `dimmer-cached-compute-rgb` — and the RGB computation is cached in `dimmer-dimmed-faces`.
- **[Low] Non-standard face attribute plists**: If a third-party face uses an unusual format for `:box` or underline attributes, `plist-get`/`plist-put` may produce unexpected results. Mitigation: `dimmer--dim-face-attribute` only modifies attributes where `plist-member` finds `:color` with a string value. Non-standard formats pass through unmodified.
- **[None] Face that inherits but doesn't specify these attributes**: `face-attribute` with `'inherit` returns the inherited value. If the inherited value has a color (e.g., inherited `:box`), we dim it. Correct behavior.
