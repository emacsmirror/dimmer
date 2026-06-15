## 1. Add taint state and policy controls

- [ ] 1.1 Add buffer-local `dimmer-buffer-tainted` state
- [ ] 1.2 Add user option `dimmer-reprocess-tainted-buffers`
- [ ] 1.3 Ensure the default preserves current behavior as much as possible
- [ ] 1.4 Update the `dimmer.el` header commentary to document `dimmer-reprocess-tainted-buffers`
- [ ] 1.5 Update the corresponding `README.md` customization section to document `dimmer-reprocess-tainted-buffers`

## 2. Make restore best-effort

- [ ] 2.1 Wrap each `face-remap-remove-relative` call in `condition-case`
- [ ] 2.2 Continue removal after a failed cookie removal
- [ ] 2.3 Mark the buffer tainted if any removal fails
- [ ] 2.4 Keep debug logging for failures without crashing

## 3. Add explicit user override commands

- [ ] 3.1 Add an interactive command to mark the current buffer ignored by dimmer
- [ ] 3.2 Add an interactive command to unignore the current buffer
- [ ] 3.3 Ensure the override is buffer-local and easy to inspect

## 4. Integrate taint policy into buffer processing

- [ ] 4.1 Skip tainted buffers when `dimmer-reprocess-tainted-buffers` is nil
- [ ] 4.2 Continue to honor existing exclusion mechanisms
- [ ] 4.3 Verify tainted buffers can be reprocessed when policy allows it

## 5. Verify

- [ ] 5.1 Add or update regression coverage for partial restore failure
- [ ] 5.2 Add coverage for the taint/ignore policy behavior
- [ ] 5.3 Run tests and byte-compile `dimmer.el`
