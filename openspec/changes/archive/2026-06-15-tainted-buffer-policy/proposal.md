## Why

Dimmer can lose sync with `face-remapping-alist` when a buffer’s face remaps are reshaped by another package or when a cloned indirect buffer inherits stale remap cookies. Today, the restore path has only one recovery shape: remove cookies or fail. We want a clearer policy for partially successful restore so users can choose whether tainted buffers stay in dimmer’s rotation or get opted out.

## What Changes

- Introduce a buffer-local `dimmer-buffer-tainted` flag to record that a restore/remap operation found stale cookies in a buffer
- Add a user option `dimmer-reprocess-tainted-buffers` to control whether tainted buffers continue to be processed automatically
- During restore, attempt to remove as many remaps as possible, logging failures without crashing
- Allow user policy to coexist with other exclusions, including regex-based exclusion lists

## Impact

- **Affects**: buffer restore bookkeeping and buffer selection policy
- **Resolves**: recovery behavior for stale face-remap cookies seen in #54 and #73
- **Risk**: Medium — adds a new buffer-local state and a user-facing policy option, but keeps the removal logic best-effort and local
