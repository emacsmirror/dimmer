## Why

Dimmer's current adjustment modes (`:foreground`, `:background`, `:both`) all work by interpolating colors toward the opposite `default` face component — reducing contrast. Some users want different perceptual effects: desaturating colors toward gray while preserving their lightness, or shifting all dimmed colors toward a specific hue. This expands the `dimmer-adjustment-mode` variable to support these new transformations, resolving the remaining scope of issue #42.

## What Changes

- Add two new values for `dimmer-adjustment-mode`:
  - `:desaturate` — desaturate all color-bearing face attributes toward gray, preserving lightness/value
  - `:hueshift` — shift all color-bearing face attributes toward a configurable target hue, preserving saturation and lightness
- Add new `defcustom` `dimmer-hue-target` with values `:background` (default), `:foreground`, or a float 0.0–1.0
- Both new modes operate on **all** color-bearing attributes (foreground, background, box, underline, overline, strike-through, distant-foreground) — no halving of the dimming fraction
- Per-face target computation: unlike existing modes that use a global target (`def-bg`), `:desaturate` computes a gray of the same lightness per face, and `:hueshift` computes a color with the target hue and the face's own saturation/lightness
- Cache key stays unchanged (works per face-target pair); cache invalidation when changing `dimmer-hue-target` is handled separately (issue to be created)
- New helper functions: `dimmer--gray-of-same-lightness`, `dimmer--color-with-target-hue`

## Capabilities

### New Capabilities
- `desaturation-mode`: Rules for desaturating face colors toward gray while preserving lightness
- `hue-shift-mode`: Rules for shifting face colors toward a configurable target hue

### Modified Capabilities
- None

## Impact

- **Affects**: `dimmer-adjustment-mode` defcustom (new values), `dimmer-face-color` dispatch logic, new helper functions, new `dimmer-hue-target` defcustom
- **Resolves**: Part of issue #42 (more dimming modes)
- **Requires**: No new dependencies; reuses existing `dimmer-cached-compute-rgb` and HSL color math
- **Risk**: Low — new modes are opt-in via `dimmer-adjustment-mode`; existing modes unchanged; per-face target computation is naturally cached
