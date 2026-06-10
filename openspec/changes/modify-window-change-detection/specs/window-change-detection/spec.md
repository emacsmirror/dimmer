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

### Requirement: Child frame buffers are excluded from visible buffer list
The system SHALL exclude windows belonging to child frames when building the visible buffer list, so that child frame buffers are never dimmed by dimmer.

#### Scenario: Child frame buffer not in visible set
- **WHEN** a child frame is visible (e.g., corfu popup, company-box popup)
- **AND** `dimmer-visible-buffer-list` is called
- **THEN** the child frame's buffer is not included in the returned list
- **AND** any normal frame buffers remain in the list

#### Scenario: No child frames present
- **WHEN** no child frames exist
- **THEN** `dimmer-visible-buffer-list` returns the same set as before the change