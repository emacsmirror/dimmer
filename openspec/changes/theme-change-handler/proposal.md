## Why

Dimmer computes dimmed colors at the time `dimmer-mode` activates. If a user's theme loads *after* dimmer (common with `use-package` ordering), the first `dimmer-process-all` runs against the terminal's default colors rather than the theme's palette. CIELAB interpolation between theme face colors and these distant defaults can go out of gamut, producing clamped, overly-saturated artifact colors that persist because no event triggers a reprocess.

Additionally, when a user changes themes interactively, only the active window updates its dimmed colors — dimmed windows in other buffers retain the old theme's palette (upstream issue #72).

## What Changes

- Add `dimmer-theme-change-handler` that clears the `dimmer-dimmed-faces` cache and calls `dimmer-process-all t`
- Wire it into `enable-theme-functions` (Emacs 29+) with `advice-add` fallback for Emacs 27-28
- Install and remove the hook in `dimmer-mode` setup/teardown, matching the existing pattern used by `dimmer-manage-frame-focus-hooks`
- No changes to the public API, no new user-facing configuration

## Capabilities

### New Capabilities

- `theme-change-detection`: Rules for how dimmer responds to theme changes, including cache invalidation and reprocessing of dimmed buffers

### Modified Capabilities

None. This is an internal behavioral fix — no spec-level requirement changes.

## Impact

- **Affects**: New `dimmer-theme-change-handler` and `dimmer-manage-theme-hooks` functions; `dimmer-mode` setup/teardown in `dimmer.el`
- **Resolves**: Startup initialization bug (dimmer before theme produces saturated CIELAB artifacts); upstream issue #72 (dimmed windows don't update on theme change)
- **Requires**: No new dependencies, no API changes
- **Risk**: Low — the handler fires once per `enable-theme` call, clears a hash table, and calls existing `dimmer-process-all`