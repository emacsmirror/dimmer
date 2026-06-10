## Why

Dimmer's `dimmer-config-change-handler` fires indiscriminately when any child frame appears or disappears, causing unwanted dimming of the active buffer. This affects corfu, company-box, lsp-ui-doc, eldoc-box, and posframe — collectively the largest source of open compatibility issues. The current workarounds require users to override internal functions with `advice-add`, which is fragile and error-prone.

## What Changes

- Modify `dimmer-config-change-handler` to detect whether the window configuration change was caused by a child frame appearing/disappearing, and skip forced reprocessing when it is
- Honor `dimmer-prevent-dimming-predicates` as an additional signal that a popup/child frame is active
- No changes to the public API, no new user-facing configuration

## Capabilities

### New Capabilities

- `window-change-detection`: Rules for how dimmer responds to window configuration changes, including child frame detection and predicate evaluation

### Modified Capabilities

None. This is an internal behavioral fix — no spec-level requirement changes.

## Impact

- **Affects**: `dimmer-config-change-handler` in `dimmer.el` (lines 557-560)
- **Resolves**: Upstream issues #49 (lsp-ui-doc), #62 (corfu), #48 (company-box), #65 (ctrlf/lsp-ui/doom-modeline), #67 (eldoc-box)
- **Requires**: No new dependencies, no API changes
- **Risk**: Low — the change adds an early-return guard to a single function. False positives (skipping a real config change) self-correct on the next hook invocation.