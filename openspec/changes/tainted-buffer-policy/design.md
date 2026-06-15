## Context

Dimmer uses `face-remap-add-relative` / `face-remap-remove-relative` cookies to manage buffer-local dimming. These cookies are valid only as long as the underlying `face-remapping-alist` structure remains compatible. In practice, that means a restore pass can partially succeed: some cookies may still be removable, while others are stale.

Rather than treating this as an all-or-nothing failure, the design introduces a small amount of state:

- `dimmer-buffer-tainted` records that a buffer has experienced a desync
- `dimmer-reprocess-tainted-buffers` determines whether dimmer continues to manage such buffers automatically

This keeps the recovery policy explicit and user-configurable, while preserving the existing best-effort API usage.

## Goals / Non-Goals

**Goals:**
- Remove as many valid remaps as possible when restore encounters stale cookies
- Record partial desync in a buffer-local flag
- Let users decide whether tainted buffers continue to be processed

**Non-Goals:**
- Perfect ownership tracking for remap entries
- Deep repair of `face-remapping-alist`
- Special-casing magit-delta or indirect buffers in the core restore path

## Decisions

### Decision 1: Best-effort restore

`dimmer-restore-buffer` should wrap each removal in `condition-case` and continue removing remaining cookies. A single stale cookie does not imply that the rest are unusable.

### Decision 2: Taint on partial failure

If any removal fails, the buffer is marked with `dimmer-buffer-tainted`. This flag captures that the buffer may need policy-based handling on future passes.

### Decision 3: User-controlled policy

`dimmer-reprocess-tainted-buffers` controls whether tainted buffers remain eligible for dimmer processing.

- If non-nil, dimmer continues to process tainted buffers and attempts to recover on future passes.
- If nil, tainted buffers are skipped until the user clears the state.

## State Model

- **clean**: normal buffer; dimmer processes it as usual
- **tainted**: a partial restore failure occurred; policy decides whether the buffer is processed again

The taint flag is descriptive; `dimmer-reprocess-tainted-buffers` is the policy control.
