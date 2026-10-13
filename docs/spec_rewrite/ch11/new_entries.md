# New log entries chapter 11 lands

Chapter 11's entry block is D-366 to D-385. Each entry is formatted to
`docs/design/tools/decisions_style.md` at landing, before the
link-definition block.

## D-366 — Make `loop` the device contract's one mandatory function

- Status: ratified.
- Position: a device must define `loop(dev, handle)`, and `attach!` refuses
  a device with no `loop` method (`DeviceContractMismatch`, D-216). `init!`,
  `shutdown!` and `unblock!` are optional, each with a no-op default.
- Spec: §11.6.
- Rationale: a device with no OS resources has nothing to acquire or
  release, so a mandatory `init!` or `shutdown!` would only force empty
  methods. The code already gives the three hooks no-op defaults
  (`src/devices.jl` 67–85). The owner ruled this on 2026-10-13, when chapter
  11's rewrite found the spec reading as three mandatory functions.
- Rejected: mandatory `init!` and `shutdown!`, as §11.6 read before
  ("four functions, one optional"). Every device without OS resources would
  define two empty methods.

# Outside edits at landing (owner's rulings)

- E3: §12.4's sketch (old 8788) drops `mark_dead!` the same way R21 drops
  it in §11.6.
- E5: the glossary's `should_abort` entry (old 14098–14099) drops "The
  shipped GUI attaches with `true` ([§11.6], [§12.4])." The glossary's
  greedy-claim entry (old 14015–14016), "the shipped GUI binding is the
  shipped instance", becomes "the standard GUI binding is its instance".
  Appendix B (old 12637), "the standard GUI binding is the shipped greedy
  one", becomes "the standard GUI binding is the greedy one".

# Track 2 annotations (owner's rulings)

- E2: annotate D-268 under D-310. Its 2026-09-30 amendment describes the
  withdrawn calling-task device; the repeated `shutdown!` arises in `run!`'s
  interrupt arm.
- E3: annotate D-160, whose Position names `mark_dead!`; no dead-marking
  exists (D-138 Rationale, `src/devices.jl` 395–399).
- E5: annotate D-138, whose Rationale has the shipped GUI attach with
  `should_abort = true` under the withdrawn `gui = true`.

# Outside edits at landing (chapter 11's rulings)

- R4 / RP-9: Appendix B (old 12795) and the glossary's harness-writer
  entries (old 14019, 14023) say the harness writer stages from the calling
  task. They become "from any task, the calling task included" (D-200), and
  the glossary's gloss follows §11.8's, "the framework-owned write path
  `stage!(sim, …)`".
- The inbound checks' RETARGET and MISSING rows, as `rulings_batch.md` rules
  them.
- §11.8's retitle: the Contents entry, then `linkify.jl` regenerates every
  `[s11-8]` definition.
