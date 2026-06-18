## Requirements

### Requirement: Restore is best-effort when remap cookies are stale
The system SHALL attempt to remove each saved face-remap cookie independently during `dimmer-restore-buffer`.

If a removal fails, the system SHALL continue attempting later removals for that buffer, and SHALL record that the buffer is tainted.

#### Scenario: One stale cookie among several valid cookies
- **WHEN** `dimmer-restore-buffer` removes multiple cookies
- **AND** one removal signals an error
- **THEN** the remaining cookies are still attempted
- **AND** the buffer is marked tainted
- **AND** the failure is logged at debug level

#### Scenario: All removals succeed
- **WHEN** every saved cookie is still valid
- **THEN** the buffer is restored normally
- **AND** the taint flag is not set

### Requirement: Tainted buffers follow user policy
The system SHALL honor `dimmer-reprocess-tainted-buffers` when deciding whether to continue processing a tainted buffer.

#### Scenario: Tainted buffer and reprocess enabled
- **WHEN** a buffer is tainted
- **AND** `dimmer-reprocess-tainted-buffers` is non-nil
- **THEN** dimmer may continue processing the buffer normally

#### Scenario: Tainted buffer and reprocess disabled
- **WHEN** a buffer is tainted
- **AND** `dimmer-reprocess-tainted-buffers` is nil
- **THEN** dimmer SHALL skip further automatic processing of that buffer
