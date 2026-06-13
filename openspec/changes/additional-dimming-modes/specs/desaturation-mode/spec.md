## ADDED Requirements

### Requirement: Desaturation adjustment mode

When `dimmer-adjustment-mode` is set to `:desaturate`, dimmer SHALL desaturate each color-bearing face attribute toward a gray of the same lightness. The mode SHALL process all color-bearing face attributes (foreground, background, box, underline, overline, strike-through, distant-foreground) without halving the dimming fraction.

The dimming fraction (`dimmer-fraction`) SHALL control how far the color is desaturated toward gray (0.0 = no change, 1.0 = fully gray).

#### Scenario: Desaturate dims foreground toward gray

- **WHEN** `dimmer-adjustment-mode` is `:desaturate` and `dimmer-fraction` is 0.5
- **AND** a buffer with face `(background-color . "#ff0000")` is processed
- **THEN** the dimmed background color SHALL be perceptually lighter/darker (same desaturation, toward gray)
- **AND** the resulting color SHALL have saturation approximately 50% of the original
- **AND** the resulting color SHALL preserve the original lightness

#### Scenario: Desaturate does not halve fraction

- **WHEN** `dimmer-adjustment-mode` is `:desaturate` and `dimmer-fraction` is 0.8
- **THEN** the dimming effect SHALL use the full 0.8 fraction (not split across attributes)
- **AND** both foreground and background SHALL each be desaturated by 80%

#### Scenario: Desaturate at zero fraction is identity

- **WHEN** `dimmer-adjustment-mode` is `:desaturate` and `dimmer-fraction` is 0.0
- **THEN** all face attributes SHALL remain unchanged

#### Scenario: Desaturate at full fraction produces gray

- **WHEN** `dimmer-adjustment-mode` is `:desaturate` and `dimmer-fraction` is 1.0
- **THEN** each processed face attribute SHALL be replaced by a gray of equivalent lightness (chroma ≈ 0)

### Requirement: Desaturate per-face target is gray of same lightness

The target for each face attribute SHALL be a gray color with the same lightness (L from HSL) as the original face color.

#### Scenario: Gray target preserves face lightness

- **WHEN** a face foreground has RGB value `#ff8800` (HSL lightness ~0.52)
- **THEN** the computed target SHALL be a gray with the same lightness (equivalent to `#858585`)
- **AND** interpolation from `#ff8800` toward this gray SHALL progressively reduce saturation while keeping lightness

### Requirement: Desaturate affects all color-bearing attributes

When `dimmer-adjustment-mode` is `:desaturate`, dimmer SHALL dim all color-bearing face attributes (foreground, background, box, underline, overline, strike-through, distant-foreground) using the desaturation transform.

#### Scenario: Box border color is desaturated

- **WHEN** a face has `:box '(:color "#ff0000" :line-width 1)` and `dimmer-adjustment-mode` is `:desaturate`
- **THEN** the `:color` value in the box plist SHALL be desaturated toward gray of same lightness

#### Scenario: Underline color is desaturated

- **WHEN** a face has `:underline '(:color "#00ff00" :style wave)` and `dimmer-adjustment-mode` is `:desaturate`
- **THEN** the `:color` value in the underline plist SHALL be desaturated toward gray of same lightness
