## 1. Implement theme-change handler

- [x] 1.1 Add `dimmer-theme-change-handler` function that clears `dimmer-dimmed-faces` cache and calls `dimmer-process-all t`
- [x] 1.2 Add `dimmer-manage-theme-hooks` function with `enable-theme-functions` primary path and `advice-add` fallback for Emacs 27-28

## 2. Wire into dimmer-mode lifecycle

- [x] 2.1 Add `(dimmer-manage-theme-hooks t)` to the `dimmer-mode` install block
- [x] 2.2 Add `(dimmer-manage-theme-hooks nil)` to the `dimmer-mode` teardown block

## 3. Verify correctness

- [x] 3.1 Confirm `make lint` passes with no new issues
- [x] 3.2 Run `make test` to confirm existing tests pass
- [x] 3.3 Manual check: startup with dimmer before theme no longer shows saturated CIELAB artifacts
- [x] 3.4 Manual check: changing themes interactively updates all dimmed windows (resolves #72)

## 4. Update changelog

- [x] 4.1 Add entry to `CHANGELOG.md` under `Latest snapshot` > Bugfixes referencing the startup initialization bug and upstream issue #72