## ADDED Requirements

### Requirement: Dim all color-bearing face attributes

When dimmer adjusts a face, it SHALL dim the color component of every color-bearing face attribute, not only `:foreground` and `:background`.

The color-bearing attributes are:
- `:box` — border box of characters
- `:underline` — underline decoration
- `:overline` — overline decoration
- `:strike-through` — strikethrough decoration
- `:distant-foreground` — alternative foreground for low-contrast backgrounds

#### Scenario: Face with box attribute

- **WHEN** a face specifies `:box '(:color "#ff0000" :line-width 2 :style released-button)`
- **THEN** dimmer SHALL dim `#ff0000` to a muted equivalent while preserving `:line-width`, `:style`, and all other non-color sub-attributes of `:box`

#### Scenario: Face with underline attribute

- **WHEN** a face specifies `:underline '(:color "#00ff00" :style wave)`
- **THEN** dimmer SHALL dim `#00ff00` while preserving `:style wave` unchanged

#### Scenario: Face with overline attribute

- **WHEN** a face specifies `:overline "#0000ff"`
- **THEN** dimmer SHALL dim `#0000ff`

#### Scenario: Face with strike-through attribute

- **WHEN** a face specifies `:strike-through "#ff00ff"`
- **THEN** dimmer SHALL dim `#ff00ff`

#### Scenario: Face with distant-foreground attribute

- **WHEN** a face specifies `:distant-foreground "#888888"`
- **THEN** dimmer SHALL dim `#888888`

### Requirement: Preserve non-color attribute components

When dimming a color-bearing face attribute whose value is a plist, dimmer SHALL modify only the `:color` key within that plist. All other keys (`:line-width`, `:style`, `:position`, etc.) SHALL pass through unchanged.

#### Scenario: Box plist with non-color keys preserved

- **WHEN** a face specifies `:box '(:color "#ff0000" :line-width 3 :style sunken-button)`
- **THEN** the dimmed face spec SHALL include `:box '(:color "<dimmed>" :line-width 3 :style sunken-button)` with only `:color` modified

### Requirement: Skip attributes without explicit color

When a color-bearing attribute has no explicit color value (value is `t`, `nil`, or a plist without a `:color` key), dimmer SHALL leave that attribute unmodified. These attributes use the face's `:foreground` color by convention, which is already dimmed independently.

#### Scenario: Box with no explicit color

- **WHEN** a face specifies `:box t`
- **THEN** dimmer SHALL NOT modify the `:box` attribute

#### Scenario: Underline plist without :color key

- **WHEN** a face specifies `:underline '(:style wave)` (no `:color` key)
- **THEN** dimmer SHALL NOT modify the `:underline` attribute

#### Scenario: Underline plist with foreground-color symbol

- **WHEN** a face specifies `:underline '(:color foreground-color :style wave)`
- **THEN** dimmer SHALL NOT modify the `:underline` attribute because `foreground-color` means "use the foreground color", which is already dimmed independently

#### Scenario: Box with bare string color name

- **WHEN** a face specifies `:box "#ff0000"` (bare string, not a plist)
- **THEN** dimmer SHALL dim `#ff0000` and return `:box "<dimmed>"` (a bare string)

#### Scenario: Overline with boolean t

- **WHEN** a face specifies `:overline t`
- **THEN** dimmer SHALL NOT modify the `:overline` attribute, because `t` means "use the foreground color"

### Requirement: Use same color math as foreground/background dimming

Dimmer SHALL apply the same `dimmer-cached-compute-rgb` interpolation for all color-bearing attributes, using the same `dimmer-fraction` and `dimmer-use-colorspace` settings that govern foreground and background dimming. Decorative attributes (box, underline, overline, strike-through) SHALL dim toward the opposite `default` face background (same target as foreground).

#### Scenario: Decorative attribute dimming direction

- **WHEN** a face's foreground is dimmed toward `default` background by 30%
- **THEN** any `:box`, `:underline`, `:overline`, `:strike-through`, or `:distant-foreground` color on that face SHALL be dimmed toward the same `default` background by the same 30%
