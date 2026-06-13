## Why

Dimmer currently only dims `:foreground` and `:background` face attributes. Faces with decorative color-bearing attributes (`:box`, `:underline`, `:overline`, `:strike-through`, `:distant-foreground`) retain their full-intensity colors while the rest of the face is dimmed. This creates a visually inconsistent appearance — the border or underline "pops" against the dimmed foreground/background. Resolves upstream issues #70 and #46.

## What Changes

- Extend `dimmer-face-color` to detect and dim color values in all color-bearing face attributes, not just `:foreground` and `:background`
- Add a helper function `dimmer--dim-face-attribute` that fetches a face attribute and dims its color component(s) using the same color math as the existing foreground/background dimming
- Handle both direct color values (`:distant-foreground`) and nested plist attributes (`:box`, `:underline`, `:overline`, `:strike-through`) that have an optional `:color` key
- Return a face spec that includes dimmed versions of ALL color-bearing attributes the face specifies
- No changes to the public API, no new user-facing configuration

## Capabilities

### New Capabilities
- `extended-color-bearing-attributes`: Rules for how dimmer handles face attributes beyond `:foreground` and `:background`, including `:box`, `:underline`, `:overline`, `:strike-through`, and `:distant-foreground`

### Modified Capabilities

None. This is an internal enhancement — no spec-level requirement changes.

## Impact

- **Affects**: `dimmer-face-color` function in `dimmer.el`; one new helper function `dimmer--dim-face-attribute`
- **Resolves**: Upstream issues #70 (`:box` not dimmed) and #46 (`:underline`/`:overline` not dimmed)
- **Requires**: No new dependencies, no API changes, no new configuration
- **Risk**: Low — adds color processing for attributes that were previously ignored. Attributes absent from a face are skipped with no effect.
