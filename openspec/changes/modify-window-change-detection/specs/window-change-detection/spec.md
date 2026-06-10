## ADDED Requirements

### Requirement: Window configuration changes from child frames are ignored
The system SHALL detect when a `window-configuration-change-hook` event was triggered by a child frame appearing or disappearing, and SHALL NOT reprocess dimming state in that case.

#### Scenario: Child frame appears during normal editing
- **WHEN** a child frame appears (e.g., corfu popup, company-box popup, lsp-ui-doc frame)
- **AND** `window-configuration-change-hook` fires
- **THEN** the system detects the child frame via `parent-frame` parameter
- **AND** skips the forced reprocess of dimming state
- **AND** the active buffer remains undimmed

#### Scenario: Child frame disappears
- **WHEN** a child frame is dismissed
- **AND** `window-configuration-change-hook` fires
- **THEN** the system detects no child frames remain
- **AND** processes the configuration change normally (restoring any buffers that were previously dimmed)

#### Scenario: Real window change with no child frame
- **WHEN** the user splits a window or switches frames
- **AND** no child frames exist
- **AND** no prevent-dimming predicate is active
- **THEN** the system processes the configuration change with `force=t` as before
- **AND** dimming state is correctly updated

### Requirement: Prevent-dimming predicates are honored during config changes
The system SHALL evaluate `dimmer-prevent-dimming-predicates` during `dimmer-config-change-handler`, and SHALL skip forced reprocessing when any predicate is true.

#### Scenario: Prevent predicate active with no child frame
- **WHEN** a prevent-dimming predicate is active (e.g., `which-key--popup-showing-p`)
- **AND** no child frames exist
- **THEN** the system skips forced reprocessing due to the active predicate

#### Scenario: Neither child frame nor predicate present
- **WHEN** no child frames exist
- **AND** no prevent-dimming predicates are active
- **THEN** the system processes the configuration change with `force=t`