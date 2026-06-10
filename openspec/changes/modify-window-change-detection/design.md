## Context

Dimmer hooks into `window-configuration-change-hook` via `dimmer-config-change-handler`, which always calls `dimmer-process-all` with `force=t`. This force flag bypasses `dimmer-prevent-dimming-predicates` and processes every visible buffer, dimming any buffer that isn't the current selection.

Child frame popups (corfu, company-box, lsp-ui-doc, eldoc-box, posframe) trigger `window-configuration-change-hook` when they appear or disappear. The forced reprocess then incorrectly dims the user's active buffer because the child frame's buffer is now in the visible window list.

The current code (lines 557-560):

```elisp
(defun dimmer-config-change-handler ()
  "Process all buffers if window configuration has changed."
  (dimmer--dbg-buffers 1 "dimmer-config-change-handler")
  (dimmer-process-all t))
```

## Goals / Non-Goals

**Goals:**
- Prevent forced reprocessing when a window change is caused by a child frame appearing or disappearing
- Honor `dimmer-prevent-dimming-predicates` as an additional signal during window config changes
- Cover corfu, company-box, lsp-ui-doc, eldoc-box, posframe, and any future child-frame-based packages
- Zero behavioral change for users without child-frame packages

**Non-Goals:**
- Not adding new user-facing configuration or API
- Not modifying how `dimmer-prevent-dimming-predicates` works in `dimmer-command-handler` (that path is correct)
- Not addressing `face-remapping-alist` conflicts (a separate root cause)

## Decisions

### Decision 1: Detect child frames by scanning `(frame-list)` for `parent-frame` parameter

Child frames in Emacs 27+ have a non-nil `parent-frame` frame parameter. Scanning `(frame-list)` at hook invocation time gives an accurate snapshot. This is simpler and more reliable than stateful tracking (comparing "before" and "after" frame lists).

**Alternatives considered:**
- **Stateful tracking**: Save `(frame-list)` before each change, compare after. More complex, fragile if hooks fire asynchronously.
- **Filter in `dimmer-visible-buffer-list`**: Skip child frame windows during buffer collection. Would prevent child frame buffers from entering the visible set but wouldn't stop the forced reprocess itself. Less principled.
- **`window-configuration-change-hook` arguments**: This hook doesn't receive any arguments about what changed. No alternative hook available.

### Decision 2: Hybrid check — child frames OR predicates

The check fires if *either* a child frame exists *or* any `dimmer-prevent-dimming-predicate` is true:

```elisp
(defun dimmer-config-change-handler ()
  "Process all buffers unless the change was triggered by a child frame
or a prevent-dimming predicate is active."
  (dimmer--dbg-buffers 1 "dimmer-config-change-handler")
  (let ((ignore (or (cl-some (lambda (f)
                               (frame-parameter f 'parent-frame))
                             (frame-list))
                    (cl-some (lambda (f) (and (fboundp f) (funcall f)))
                             dimmer-prevent-dimming-predicates))))
    (unless ignore
      (dimmer-process-all t))))
```

**Why both**: The child frame scan catches packages the user hasn't configured a predicate for. The predicate check catches popups that aren't child frames (e.g., `which-key` overlay popups). Together they form a complete guard.

### Decision 3: No new predicate for "is there a child frame"

Rather than adding `dimmer-child-frame-active-p` to `dimmer-prevent-dimming-predicates` and asking users to configure it, we bake the child frame scan directly into the handler. This makes the fix automatic for all users.

## Risks / Trade-offs

- **[False positive] Real window config change while child frame is active**: If a user splits a window while a corfu popup is visible, the config change is skipped. Self-corrects on the next hook invocation (when the popup dismisses, another config change fires). In practice the window where behavior is stale is negligible — ~1 frame refresh.
- **[False negative] Child frame without `parent-frame` parameter**: Theoretical only. All child frames in Emacs 27+ set `parent-frame`. Non-child-frame popups (overlays, `which-key`) are covered by the predicate path.
- **[Logging noise] `cl-some` on `frame-list` at every config change**: `frame-list` is typically small (2-10 frames). Called only on window config changes, not on every `post-command-hook`. No measurable performance impact.
- **[Edge case] Ediff frames**: Ediff uses separate frames, not child frames. Not affected by this change — and would need a separate fix (frame awareness in `dimmer-visible-buffer-list`).