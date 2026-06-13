## ADDED Requirements

### Requirement: Dimmed face cache is invalidated on theme change
The system SHALL clear the `dimmer-dimmed-faces` cache and reprocess all buffers whenever a theme is enabled.

#### Scenario: Theme loads at startup
- **WHEN** Emacs starts with `dimmer-mode` enabled
- **AND** a theme is loaded via `enable-theme` or `load-theme`
- **THEN** the dimmed face cache is cleared
- **AND** `dimmer-process-all` is called with `force=t`
- **AND** all dimmed buffers are refreshed with the theme's face colors

#### Scenario: Theme changed interactively
- **WHEN** the user changes themes via `M-x load-theme`
- **THEN** the dimmed face cache is cleared
- **AND** `dimmer-process-all` is called with `force=t`
- **AND** both the active window and all dimmed windows update to the new theme's colors

#### Scenario: Same theme re-enabled
- **WHEN** the user re-enables the currently active theme
- **THEN** the dimmed face cache is cleared
- **AND** `dimmer-process-all` is called with `force=t`
- **AND** dimmed colors are recomputed (results in the same values — no visible change)

### Requirement: Theme hooks are managed during dimmer-mode lifecycle
The system SHALL install theme-change hooks when `dimmer-mode` is activated and remove them when deactivated.

#### Scenario: dimmer-mode enabled
- **WHEN** `dimmer-mode` is enabled
- **THEN** the theme-change handler is registered via `enable-theme-functions` (Emacs 29+) or `advice-add` on `enable-theme` (Emacs 27-28)

#### Scenario: dimmer-mode disabled
- **WHEN** `dimmer-mode` is disabled
- **THEN** the theme-change handler is unregistered from `enable-theme-functions` or via `advice-remove` on `enable-theme`