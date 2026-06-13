## 1. Add `dimmer-hue-target` defcustom

- [x] 1.1 Add `dimmer-hue-target` defcustom with type `(choice (const :background) (const :foreground) float)` defaulting to `:background`, with docstring explaining each value
- [x] 1.2 Add `dimmer--resolve-hue-target` helper that converts `:background`/`:foreground` to a float hue via `color-rgb-to-hsl` on the `'default` face, or returns the float directly (wrapped via `mod`)
- [x] 1.3 Guard `face-background`/`face-foreground` calls with nil check in case of non-graphical frames; fall back to hue 0.0

## 2. Add HSL helper functions

- [x] 2.1 Add `dimmer--gray-of-same-lightness` helper: takes a color string, returns a hex string with same lightness but zero saturation
- [x] 2.2 Add `dimmer--color-with-target-hue` helper: takes a color string and target hue float, returns a hex string with same S and L but target hue

## 3. Add `:desaturate` dispatch in `dimmer-face-color`

- [ ] 3.1 In the foreground dimming block, add `:desaturate` to the `memq` condition that selects which modes process foreground
- [ ] 3.2 In the background dimming block, add `:desaturate` to the `memq` condition
- [ ] 3.3 In the decorative attribute loop, add `:desaturate` to the `memq` condition
- [ ] 3.4 In the foreground dimming branch, compute the desaturate target via `(dimmer--gray-of-same-lightness fg)` and call `dimmer-cached-compute-rgb`
- [ ] 3.5 In the background dimming branch, compute the desaturate target via `(dimmer--gray-of-same-lightness bg)` similarly
- [ ] 3.6 In the decorative attribute loop, compute the desaturate target per-attribute
- [ ] 3.7 Ensure no halving: the `my-frac` binding only halves for `:both`, not for `:desaturate`

## 4. Add `:hueshift` dispatch in `dimmer-face-color`

- [ ] 4.1 In the foreground dimming block, add `:hueshift` to the `memq` condition
- [ ] 4.2 In the background dimming block, add `:hueshift` to the `memq` condition
- [ ] 4.3 In the decorative attribute loop, add `:hueshift` to the `memq` condition
- [ ] 4.4 In the foreground dimming branch, compute the hue target via `(dimmer--color-with-target-hue fg (dimmer--resolve-hue-target))` and call `dimmer-cached-compute-rgb`
- [ ] 4.5 In the background dimming branch, compute the hue target similarly
- [ ] 4.6 In the decorative attribute loop, compute the hue target per-attribute
- [ ] 4.7 Ensure no halving: same as `:desaturate`

## 5. Update defcustom `dimmer-adjustment-mode` type

- [ ] 5.1 Add `:desaturate` and `:hueshift` to the `(choice (const :foreground) (const :background) (const :both) (const :desaturate) (const :hueshift))` type spec
- [ ] 5.2 Update the docstring to describe the two new modes, including the effect on all color-bearing attributes and the no-halving behavior

## 6. Update Commentary and documentation

- [ ] 6.1 Update `dimmer.el` Commentary section header/doc to mention the two new modes
- [ ] 6.2 Update CHANGELOG.md with entry for the new modes
- [ ] 6.3 Update docstring of `dimmer-adjustment-mode` with the new values

## 7. Tests

- [x] 7.1 Add unit tests for `dimmer--gray-of-same-lightness` in `test/color-math-test.el`
- [x] 7.2 Add unit tests for `dimmer--color-with-target-hue` in `test/color-math-test.el`
- [x] 7.3 Add unit test for `dimmer--resolve-hue-target` with each value type
- [ ] 7.4 Add graphical ERT test for `:desaturate` mode (verify dimmed result via `face-attribute`)
- [ ] 7.5 Add graphical ERT test for `:hueshift` mode (verify dimmed result via `face-attribute`)

## 8. Verify

- [x] 8.1 Run unit tests (`ert-run-tests-batch-and-exit` for `test/color-math-test.el`)
- [ ] 8.2 Run graphical tests in an Emacs GUI session
- [ ] 8.3 Byte-compile `dimmer.el` with no warnings
