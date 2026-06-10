## 1. Implement hybrid child frame detection

- [x] 1.1 Modify `dimmer-config-change-handler` to scan `(frame-list)` for child frames via `parent-frame` parameter
- [x] 1.2 Add `dimmer-prevent-dimming-predicates` check alongside the child frame scan
- [x] 1.3 Guard `dimmer-process-all t` behind the combined check, skipping forced reprocess when either signal is active
- [x] 1.4 Verify the debug message at verbosity 1 still fires before the guard (log the handler entry, not the skip)

## 2. Verify correctness

- [x] 2.1 Confirm `make lint` passes with no new issues
- [x] 2.2 Run `make test` to confirm existing tests pass
- [x] 2.3 Verify no behavioral change when no child frames exist (normal window splits, frame switches)
- [x] 2.4 Manual check: corfu, company-box, or lsp-ui-doc popup no longer triggers unwanted dimming

## 3. Update changelog

- [x] 3.1 Add entry to `CHANGELOG.md` under `Latest snapshot` > Bugfixes referencing upstream issues #49, #62, #48, #65, #67