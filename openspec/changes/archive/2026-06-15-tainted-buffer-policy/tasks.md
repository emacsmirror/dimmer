## 1. Add taint state and policy controls

- [x] 1.1 Add buffer-local `dimmer-buffer-tainted` state
- [x] 1.2 Add user option `dimmer-reprocess-tainted-buffers`
- [x] 1.3 Ensure the default preserves current behavior as much as possible
- [x] 1.4 Update the `dimmer.el` header commentary to document `dimmer-reprocess-tainted-buffers`
- [x] 1.5 Update the corresponding `README.md` customization section to document `dimmer-reprocess-tainted-buffers`

## 2. Make restore best-effort

- [x] 2.1 Wrap each `face-remap-remove-relative` call in `condition-case`
- [x] 2.2 Continue removal after a failed cookie removal
- [x] 2.3 Mark the buffer tainted if any removal fails
- [x] 2.4 Keep debug logging for failures without crashing

## 3. Integrate taint policy into buffer processing

- [x] 3.1 Skip tainted buffers when `dimmer-reprocess-tainted-buffers` is nil
- [x] 3.2 Continue to honor existing exclusion mechanisms
- [x] 3.3 Verify tainted buffers can be reprocessed when policy allows it

## 4. Verify

- [x] 4.1 Add or update regression coverage for partial restore failure
- [x] 4.2 Add coverage for the taint policy behavior
- [x] 4.3 Run tests and byte-compile `dimmer.el`
