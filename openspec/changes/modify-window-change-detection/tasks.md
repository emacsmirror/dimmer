## 1. Implement hybrid child frame detection

- [x] 1.1 Modify `dimmer-config-change-handler` to scan `(frame-list)` for child frames via `parent-frame` parameter
- [x] 1.2 Add `dimmer-prevent-dimming-predicates` check alongside the child frame scan
- [x] 1.3 Guard `dimmer-process-all t` behind the combined check, skipping forced reprocess when either signal is active
- [x] 1.4 Verify the debug message at verbosity 1 still fires before the guard (log the handler entry, not the skip)

## 2. Exclude child frame windows from visible buffer list

- [x] 2.1 Modify `dimmer-visible-buffer-list` to skip windows whose frame has a non-nil `parent-frame` parameter
- [x] 2.2 Confirm `make lint` passes with no new issues
- [x] 2.3 Run `make test` to confirm existing tests pass
- [ ] 2.4 Manual check: child frame buffers (corfu, company-box, lsp-ui-doc) are no longer dimmed during normal operation

## 3. Update changelog

- [x] 3.1 Add entry to `CHANGELOG.md` under `Latest snapshot` > Bugfixes referencing upstream issues #49, #62, #48, #65, #67