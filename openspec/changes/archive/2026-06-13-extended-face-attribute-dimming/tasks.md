## 1. Helper Function

- [x] 1.1 Add `dimmer--dim-face-attribute` function that fetches a face attribute and dims its color component(s) — supporting both direct color strings and plists with `:color` key
- [x] 1.2 Add `dimmer-color-bearing-attributes` constant listing `(:distant-foreground :box :underline :overline :strike-through)`

## 2. Modify dimmer-face-color

- [x] 2.1 Add a loop at the end of `dimmer-face-color` that iterates over `dimmer-color-bearing-attributes`, calls `dimmer--dim-face-attribute` for each, and `plist-put` non-nil results into the result plist
- [x] 2.2 Ensure decorative attributes use `def-bg` as target (same as foreground)
- [x] 2.3 Ensure `distant-foreground` also uses `def-bg` as target

## 3. Verification

- [x] 3.1 Run existing unit tests: `make test` — 33 tests pass, 0 unexpected
- [x] 3.2 Create a test face with `:box`, `:underline`, `:overline`, `:strike-through`, and `:distant-foreground`; dim it; verify all attributes appear dimmed in the face spec
- [x] 3.3 Test edge case: face with `:box t` (no explicit color) — verify `:box` is absent from dimmed spec (not erroneously dimmed)
- [x] 3.4 Test edge case: face with `:underline '(:style wave)` (no `:color` key) — verify `:underline` passes through unmodified

## 4. Documentation

- [x] 4.1 Update CHANGELOG.md with entry describing extended color-bearing attribute dimming
- [x] 4.2 Update `dimmer-face-color` docstring to mention extended attributes
