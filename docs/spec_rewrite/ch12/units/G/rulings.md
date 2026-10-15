# Unit G (§12.7): rulings, citations and open questions

Old lines are `old.md` lines; `spec` lines are the frozen `scratch_survey/h2/spec.md`;
`log` lines are its `decisions.md`.

## Corrections proposed

1. **"§10.4 separates the two indices. The trace stays frame-indexed, and
   boundaries are the reporting index."** Old 88–89, kept as written. Since
   D-230 the reporting index is the published-boundary ordinal, and §10.4
   (spec 5961–5965) and §12.3 (spec 8785–8796) name three indices. D-128's
   Rationale (log 4108), the sentence's source, still says "the boundary
   counter". Proposed: "§10.4 separates the indices. The trace stays
   frame-indexed, and the published-boundary ordinal is the reporting index
   ([D-230][d-230])."
2. **The `restore = false` lifecycle gate names no kind.** F56's dictated
   text, "A simulation that is not `initialized` meets the lifecycle gate",
   is applied as written. The survey ran `MissingInit` on `built` (part C),
   and `src/sim.jl` 401–411 raises `ServiceLifecycle` on the other states.
   Proposed: name both in one clause, as the `live!` paragraph now does
   (F59).
3. **Appendix C's kinds for §12.7's refusals** (outside the unit, track 2).
   `ArgumentInvalid` (spec 13428) does not cite §12.7 and omits `live!` and
   the halt's range; `MissingInit` (spec 13301) omits `replay!(…; restore =
   false)` and `live!`; `ServiceLifecycle` (spec 13303) omits `live!`.

## Citations added or replaced

- **D-101** at "`replay!` is the ordinary loop with exactly one
  substitution" (bold), beside D-274. Position log 3155–3156: "is the
  ordinary loop with exactly two substitutions". D-274 bullet 4, log
  11665–11666, "so D-101's two substitutions become one", gives the count.
  D-101 is cited for the ordinary loop only; its "two" is stale (track 2).
- **D-274** at "with the trace header as the checkpoint". Position log
  11641–11642: "It is the trace's header, and replay is a restore followed by
  the feed."
- **D-101** at "for that frame ordinal". Position log 3157–3158: "the
  frame-top drain fed by the recording's batches keyed by frame ordinal".
- **D-101** at "verbatim, with no surface re-check". Position log
  3158–3159: "applied verbatim with no surface re-check (the write-surface
  rule ran at recording time)".
- **D-218** at the input-mode bold, moved from the paragraph's end into the
  sentence. Position log 8273–8275.
- **D-218** at "`replay!` attaches the recording and enters `:replay`"
  (bold). Bullet 1, log 8277.
- **D-218** at "A mode that outlives the call …". Rationale log 8289–8292
  (Rationale-only, below).
- **D-218** at "In `:replay` the recording is the bound". Bullet 2, log
  8280: "While the mode is `:replay` the recording is the bound".
- **D-128** at the `to_boundary` bold, and at "A localized `t*` boundary
  … is reproduced but not stoppable-at". Position log 4094–4098: "running
  through the frame …, so replay always halts at a frame top"; "a localized
  `t*` boundary is reproduced but not stoppable-at". The bold carries F83's
  correction, not D-128's "published boundary `k`" wording.
- **D-255, D-316** at "`t_end` and `ignore_stop_requests` are keywords of
  `replay!` exactly as of `run!`". D-255 bullet 5, log 10061–10062: "keywords
  of `run!` and `replay!`"; D-316, log 13645–13646: "`run!`, `replay!` and
  `step!` take `ignore_stop_requests = ()`".
- **D-127** at "A termination the recorded session hit through a stop
  request reproduces itself anyway". Rejected log 4081–4082: "a recorded
  `stop_on` termination reproduces itself anyway" (Rationale-only, below).
- **D-219** at the `to_time` bold, moved from the next paragraph. Bullet 1,
  log 8321–8323.
- **D-218** at "The mode becomes `:live` exactly when …" (bold). Bullet 3,
  log 8283–8284.
- **D-219** at the `live!` bold, moved from the paragraph's end. Bullet 2,
  log 8326–8327: "sets the input mode to `:live` and detaches the recording's
  remainder, touching nothing else".
- **D-218** at F55's bold, as R10 orders. Bullet 2, log 8281–8282: "the halt
  leaves the simulation `initialized`".
- **D-101** at "three promised workflows". Rationale log 3167–3169.
- **D-101** at "Replay re-records" (bold). Rationale log 3169–3170.
- **D-101** at "Pacing and the control plane are unchanged" (bold).
  Rationale log 3170–3171.
- **§12.1** at "`replay!` takes `pace` and `margin`", the pointer R5 orders.
- **D-218** at "Devices are readers". Bullet 1, log 8278–8279: "devices
  running as readers".
- **D-101** at "Validation is loud and up front" (bold). Rationale log
  3172: "entry validation loud and up front".
- **D-176** at the reverse conversion "once, off the loop". Position log
  6563–6564: "replay one inverse-conversion path".
- **D-101** at "*Parametric* difference is not". Rationale log 3176–3177:
  "structural mismatch errors, parametric difference = the what-if replay".
- **§2.4** at "Bit-identity is promised only against the identical build".
  Spec 574–576: "That promise holds only against the identical build running
  identical compiled code".
- **D-133** at `firing_budget`. Annotation log 4347–4349: "`firing_budget`
  joins them as a third recorded parameter".
- **D-127** at "Mismatch is `CheckpointMismatch` … never a what-if".
  Position log 4062–4065: "structural, never a what-if, since a deployment
  change moves the times at which frame-ordinal batches apply". Cited for
  that clause only; the kind name there, `ReplayHeaderMismatch`, is old.
- **D-127** at "Replay restores `t₀` …, so `replay!` takes no `t0`
  argument", now scoped to the default form. Position log 4065–4067: "`t₀`
  applied rather than compared … no new `replay!` argument". Its unscoped
  form is what F57 corrects (track 2).
- **§12.6** at the gloss "an entry point that builds a run", R14's one
  definition of *door*.
- **Removed: §11.5** at "on the *structural* side of that line" (F52).

## Rationale-only rulings

- D-218 Rationale, log 8289–8292: the mode outliving the call makes a
  partial replay resumable.
- D-127 Rejected, log 4081–4082: a recorded stop-request termination
  reproduces itself.
- D-101 Rationale, log 3167–3177: three workflows (3167–3169), re-records
  (3169–3170), pacing and control unchanged (3170–3171), validation loud and
  up front (3172), structural against parametric (3176–3177). Three of these
  are bold here (re-records, pacing and control, validation); the log owes a
  Position.
- Already cited before the rewrite, unchanged: D-274 Rationale (log
  11708–11714, nothing applied twice; the seek), D-219 Rejected (log
  8359–8362, the rounding), D-218 Rationale (log 8292–8293, one loop and one
  drain). Uncited, kept as written: D-254 Rationale (log 10006–10009, one
  expression), D-133 Rationale (log 4327–4330, the event trio).

## Bold on the same entry elsewhere

- **D-274**: §11.5 (spec 7714) bolds bullet 4's header clause. This unit's
  first bold cites D-274 beside D-101 for "exactly one substitution", a later
  sentence of the same bullet. The headline is D-101's Position (the ordinary
  loop), bold nowhere else.
- **D-254**: §9.2 bolds bullet 1's "scalar-free" sentence (spec 4403), its
  two-steps sentence (4314) and bullet 3 (4541). This unit bolds bullet 1's
  own sentence "Replay compares two deployments as values", where the check
  runs.
- **D-218** carries four bolds here: its Position, bullet 1, bullet 2 (F55's
  dictated bold) and bullet 3. Bullet 2 is stated twice; the first statement,
  "In `:replay` the recording is the bound", stays plain because R10 places
  the bold at the halt.
- D-101, D-128, D-219: bold nowhere else in the frozen spec. D-176, D-217,
  D-255, D-269, D-316 and D-133 are bold elsewhere and cited plain here.
- Siblings A, B and F (`new.md` grepped at finish): none bolds D-101,
  D-127, D-128, D-218, D-219, D-254 or D-274. A bolds D-255, D-269 and D-133,
  B bolds D-133, and F bolds D-255 and D-316, each on rulings this unit cites
  plain.

## Inbound citations affected

- Glossary *replay* (spec 14372–14376) says replay validates "the
  checkpoint's fingerprint (stores, root-input faces and the `Deployment`)"
  and restores the clock unscoped. It disagrees with R12's naming and F57's
  scope; track 2.
- Appendix C rows for `ArgumentInvalid`, `MissingInit` and
  `ServiceLifecycle`: §12.7 now names each at its condition (Corrections
  proposed, item 3).
- §13.4 (spec 10183–10196) agrees with F54 and F83. §12.4 (spec 8942–8945)
  holds, since the compared set still excludes the join cap. No `####`
  anchor of the chapter is linked from elsewhere.

## Open questions

1. F83's dictated "replay runs through frame `k` and halts at its top" is
   written "halts exactly at the frame top after it", since a frame's own top
   is where it begins. Evidence: D-218 Rationale (log 8289–8290), a `step!`
   after `to_boundary = k` re-executes frame k+1; the survey's run halted
   `to_boundary = 10` at frame 10, t = 1.0.
2. The two-forms rule added "under either form" to `to_time`'s "against the
   header's `t₀`". It rests on the `restore = false` origin check (old 60–63).
3. D-218 bullet 2's bold sits at the halt (F55), not at its first statement
   (item above under bold). Confirm.
4. Root inputs first appear unlinked inside the drain's gloss in the opening,
   as §10.1 does, and are linked at the validation paragraph.
