# G1 verify report

**Counts.** 84 inventory claims, 100 phase-1 assertions. 80 MATCH, 3 DRIFT, 0 LOST, 1 deleted by ruling. No ADDED claim goes beyond a ruling, gloss or pointer. The checker prints `checks failed: 0`.

## DRIFT

- **G1-031.** Old: "The framework owns everything around them", right after the four-function block. New: R22's sentences now come between them, so "them" reads as the three optional hooks. Fix: "everything around the four functions".
- **G1-021.** The device gloss sits on "Input-only and output-only [devices] (attached participants in the periphery)", so it reads as defining those two uses only. It also uses *periphery* 35 lines before that term's gloss. Fix: "Input-only and output-only uses of a [device](#g-device) (an attached participant in the periphery) are degenerate…"
- **G1-062.** Old: "(Appendix A): loop on `running(handle)`, and make blocking calls interruptible". New: "The author loops on … and makes …". The obligation now reads as a description. Fix: "The two are: loop on `running(handle)`, and make blocking calls interruptible (`unblock!`, or timeouts)."

## Deletion

G1-025, the label "four functions, one optional", goes to `deleted.md`. R22 orders the label "The authoring contract", and D-366's draft Rejected list names the old claim. The deletion is valid, but it comes from R22's label line and D-366, not from an explicit delete instruction.

## Ruled wording

- R14, R20, R21 and R22 (with R12 merged) match the brief word for word. R20 differs only by the operator-interrupt link and its gloss, which is correct at first use.
- R20 matches `src/sim.jl` 1212–1227. Its phrase "releases each device it never spawned directly" is ambiguous. `src` means "an entry never spawned is released directly".
- R21 matches the `src/devices.jl` 395–399 docstring. Its comment is aligned at column 46.
- The new text matches the D-366 draft in `new_entries.md`.
- **Code.** All three blocks are byte-identical to old, except F56's two splats, R22's `unblock!` comment and R21's comment line.
- **R18.** It matches `src` in substance: the same positional types, keyword and default. But `rulings.md` names two differences and misses a third, `sim::Simulation` against an untyped `sim`. Also, `binding` as an argument name shadows the `binding(handle)` accessor the sketches use. Safest fix: use `src`'s spelling.

## Citations

Every old citation survives, except §11.1, which R14 removes.

**Position carries the claim:** D-025, D-244, D-177, D-216, D-366 (draft), D-102 ("framework owns"), D-138 ("brackets each `init!`"), D-268 bullets 6 and 7, D-132 (the R14 sentence), D-105, D-160.

**The four new bold citations:**
- D-138 for partial-init tolerance: Rationale only (log 4552–4553).
- D-132 for "never a `DeviceCrash`": Rationale only. It sits in a "fall out" consequence clause (log 4155).
- D-102 for "`should_close` dissolves": Rationale only (log 3149).
- D-138 for the `should_abort` keyword: Rationale only (log 4573–4574).

All four are listed correctly as Rationale-only, which spec_style allows. The log owes Positions for them. D-106 is Rationale-only and listed correctly.

**Landing:** the frozen spec has no link definitions for `[d-138]`, `[d-160]`, `[d-216]` or `[d-366]`. `rulings.md` does not mention this.

## Bold

There are 8 bolds. Each is a headline clause with its entry in the same sentence. None marks mechanism, consequence or lead-in.

**D-268 bullet 7.** The home is §11.6. The bullet's headline clause is "`shutdown!` may run on a device whose `init!` never began", which is the tolerance §11.6 bolds. The listing is the means the bullet gives, and §12.4's own paragraph defers the tolerance to §11.6. Chapter 12 should state its listing sentence plain, with D-268. Bullet 6 is bold only here.

## Moves and order

M54, M57 and M58 are done, and no other moves. Define-before-use holds at every seam: `should_abort` has its pointer at line 51, "departure" is defined before M57, "the same joystick" follows the T16000M sketch, and "handle below" points ahead.

## Reader-cold names

- **(1) Flight.jl machinery:** `should_close`, FlightCore's hook, used bare (line 175). `UDPInput`, FlightCore's type (D-132), in the sketch.
- **(2) Aerospace example:** "hardware-in-the-loop rig … plant interface" (line 190).
- **(3) Fine:** `T16000M` and `InputMappingError`, both introduced as FlightCore's.
- **Other:** R21's `task_state` comes before §11.8 defines it, with no pointer.

## Other

The kept sentence "lets the body leave through the ordinary `running(handle)` predicate" describes the withdrawn inline-GUI path. In `src`, `_wrap` catches the `InterruptException` after `loop` has already unwound. Its `finally` still evaluates `should_abort`, though `src` calls that consult inert. This goes in `rulings.md` as a factual question under D-310. R14 kept the sentence.

## Re-check

The checker prints `checks failed: 0`.

**Closed:**
- **G1-031.** D-102's Position says "author-owned loop body inside a framework-owned bracket", and it names the device's functions. That carries "everything around the four functions".
- **G1-021.** "A device is an attached participant in the periphery" matches the glossary ("any attached participant in the periphery"). It claims the weaker direction, so it gains no weight. The periphery gloss matches its glossary entry verbatim, and *periphery* is now defined before use.
- **G1-062.** "Must loop … must make" restores the obligation.
- **Claim sentence.** It matches the glossary ("the set of faces a device *may* write") and agrees with §11.3's bold (old 7160). The face gloss matches its glossary entry.
- **R25.** The deleted clause is verbatim in `deleted.md`, and §12.4(4) goes with it. "The wrapper forwards the control-plane stop" stays.
- **R18.** The block is now `src/sim.jl` 1716–1717 without `function`.
- **Reader-cold names.** `UDPInput` is checked against FlightCore/src/network.jl 19.
- **Landing.** The missing link definitions are now logged.

**Open:**
- **R20.** "releases each device it never spawned itself, not through a wrapper" still misreads. "Itself" now binds to "spawned", so "not through a wrapper" reads as part of how the device was never spawned. Fix: "`run!` releases directly, not through a wrapper, each device it never spawned". This departs from the ruling's dictated words. The departure is logged in `rulings.md`, but the orchestrator should approve it.
- **Fix 7.** The bold should cover the headline clause only. Fix: "FlightCore's device hook **`should_close` dissolves** ([D-102][d-102])".
- **Minor, unchanged.** `task_state` still has no §11.8 pointer, and "hardware-in-the-loop rig" still has no introducing clause.

**New:** lines 8, 42, 67, 100 and 175 run past the wrap width. This is cosmetic.

## Re-check 2

All three points are closed, and the checker prints `checks failed: 0`.

- **R31.** Lines 98–99 now read "`run!` releases directly, not through a wrapper, each device it never spawned", R31's wording exactly.
- **Bold.** Line 173 now reads "FlightCore's device hook **`should_close` dissolves** ([D-102][d-102])". The bold covers the headline clause only.
- **Rewrap.** A word-level diff of old against new, with link targets stripped, shows only the edits already verified, so the rewrap changed no words. The widest prose line renders at 80 columns. Code blocks are unchanged.
