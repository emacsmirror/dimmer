## ADDED Requirements

### Requirement: Hue-shift adjustment mode

When `dimmer-adjustment-mode` is set to `:hueshift`, dimmer SHALL shift each color-bearing face attribute toward a configurable target hue, preserving the face color's saturation and lightness. The mode SHALL process all color-bearing face attributes (foreground, background, box, underline, overline, strike-through, distant-foreground) without halving the dimming fraction.

The dimming fraction (`dimmer-fraction`) SHALL control how far the color is shifted toward the target hue (0.0 = no change, 1.0 = fully at target hue).

#### Scenario: Hue-shift moves foreground toward target hue

- **WHEN** `dimmer-adjustment-mode` is `:hueshift` and `dimmer-hue-target` is `:background`
- **AND** a buffer with `default` face having background hue ~0.6 (blue)
- **AND** a processed face foreground has hue ~0.0 (red)
- **AND** `dimmer-fraction` is 0.5
- **THEN** the dimmed foreground hue SHALL be approximately 0.3 (midway between red and blue)
- **AND** the saturation and lightness SHALL match the original foreground

#### Scenario: Hue-shift at zero fraction is identity

- **WHEN** `dimmer-adjustment-mode` is `:hueshift` and `dimmer-fraction` is 0.0
- **THEN** all face attributes SHALL remain unchanged

#### Scenario: Hue-shift at full fraction matches target hue

- **WHEN** `dimmer-adjustment-mode` is `:hueshift` and `dimmer-fraction` is 1.0
- **THEN** each processed face attribute SHALL have the target hue exactly
- **AND** the saturation and lightness SHALL match the original face attribute

#### Scenario: Hue-shift does not halve fraction

- **WHEN** `dimmer-adjustment-mode` is `:hueshift` and `dimmer-fraction` is 0.8
- **THEN** the dimming effect SHALL use the full 0.8 fraction (not split across attributes)
- **AND** both foreground and background SHALL each be shifted by 80% toward target hue

### Requirement: dimmer-hue-target defcustom

A new defcustom `dimmer-hue-target` SHALL control the target hue for the `:hueshift` adjustment mode. It SHALL accept the following values:

- `:background` (default): Use the hue of the `default` face background color
- `:foreground`: Use the hue of the `default` face foreground color
- A float in range 0.0–1.0: Use the specified hue directly

#### Scenario: Default value uses background hue

- **WHEN** `dimmer-hue-target` is not customized (defaults to `:background`)
- **THEN** the resolved target hue SHALL be the hue of `(face-background 'default)`

#### Scenario: Explicit float hue

- **WHEN** `dimmer-hue-target` is set to `0.0`
- **THEN** the resolved target hue SHALL be 0.0 (red)

#### Scenario: Float values wrap via mod

- **WHEN** `dimmer-hue-target` is set to a float outside 0.0–1.0
- **THEN** the hue SHALL be wrapped using `(mod value 1.0)` to stay in range

### Requirement: Hue-shift per-face target preserves S and L

The target for each face attribute SHALL be a color with the target hue (from `dimmer-hue-target`) and the original face color's saturation and lightness.

#### Scenario: Target computed from face S and L

- **WHEN** a face foreground has RGB `#ff8800` (HSL hue ~0.07, saturation ~1.0, lightness ~0.5)
- **AND** `dimmer-hue-target` is resolved to hue 0.6 (blue)
- **THEN** the computed target SHALL be `#0077ff` (hue 0.6, saturation ~1.0, lightness ~0.5)
- **AND** interpolation toward this target SHALL shift hue while preserving saturation and lightness

### Requirement: Hue-shift affects all color-bearing attributes

When `dimmer-adjustment-mode` is `:hueshift`, dimmer SHALL dim all color-bearing face attributes (foreground, background, box, underline, overline, strike-through, distant-foreground) using the hue-shift transform.

#### Scenario: Box border color is hue-shifted

- **WHEN** a face has `:box '(:color "#ff0000" :line-width 1)` and `dimmer-adjustment-mode` is `:hueshift`
- **THEN** the `:color` value in the box plist SHALL be hue-shifted toward the target hue

#### Scenario: Underline color is hue-shifted

- **WHEN** a face has `:underline '(:color "#00ff00" :style wave)` and `dimmer-adjustment-mode` is `:hueshift`
- **THEN** the `:color` value in the underline plist SHALL be hue-shifted toward the target hue

### Requirement: `dimmer-hue-target` cache invalidation

Changing `dimmer-hue-target` at runtime SHALL clear the dimmed-face cache (`dimmer-dimmed-faces`) so subsequent dimming operations use the new target. DONE in GitHub issue #82.

#### Scenario: Cache clears on target change

- **WHEN** `dimmer-hue-target` is changed from `:background` to `0.3` via `customize-set-variable`
- **THEN** `dimmer-dimmed-faces` SHALL be cleared (via `:set` function)
- **AND** subsequent `dimmer-process-all` calls SHALL recompute with the new target hue
