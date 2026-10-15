# Unit G (§12.7): verification

Counts: 162 claims. MATCH 158, DRIFT 4, LOST 0. ADDED 20, none meaning-changing. Citation findings 2, bold findings 1.

## DRIFT

- **C-008, C-011 (V14, V16).** "`replay!` restores the trace's checkpoint" and "`replay!` stands in the `init!` position … does what `restore!` does" read as both forms. Neither holds under `restore = false`. Fix: "It restores …" and "This form stands in …".
- **C-150 (V144).** "Replay restores `t₀` …" still reads as both forms, and the next sentence contradicts it. Fix: "That form restores `t₀` with the rest of the clock, so …".
- **C-034 (V169–V170).** Old: "Anything else is refused before any write". New: only the clock arm keeps "before any write". The lifecycle gate also precedes every write (`src/sim.jl` 933, docstring 916–918). Fix: add "Both refusals precede any write."

## Hazards settled

- **F83.** The rewriter's "halts exactly at the frame top after it" is exact. The brief's "halts at its top" is one frame early, because frame `k`'s top is where frame `k` begins. `src/sim.jl` 1432 numbers each frame before its drain, and 1423 halts at `run.frame == k`. §13.4 (spec 10186–10196) halts where the failing frame begins. The survey halted at t = 1.0 = t₀ + 10h.
- **"Under either form" (V60) is correct.** `src/sim.jl` 962–966 uses the header's `t₀` and `h` under both forms. 820–822 require the simulation's `t₀` to equal it under `restore = false`.
- Moves: M56, M57, M60 done, no others; fence verbatim.

## Citations

- **`[d-127]` has no link definition** in the frozen spec. Add `[d-127]: decisions.md#d-127--add-a-deployment-block-to-the-trace-header-for-replay-validation`.
- **D-176** (V126) carries the single inverse-conversion path but not "once, off the loop". D-101's Rationale (log 3175) carries that clause. Cite D-101 too.
- The other added citations carry their claims.

## Bold

- **D-218 bullet 2 is stated twice.** "In `:replay` the recording is the bound" comes first and is plain. The bold is on F55's halt sentence. `spec_style.md` bolds the first statement, and F55 dictates the other. This needs a ruling (rulings Q3).
- The other 11 bolds pass.

## Other

- **Rulings item 1.** "§10.4 separates the two indices … boundaries are the reporting index" is stale. The proposed fix is inexact too. §10.4 (spec 5961–5965) indexes pointers and errors by the frame-entry index and snapshots by the ordinal. Suggest: "The trace stays frame-indexed, replay pointers and error messages use the frame-entry boundary index, and snapshots carry the published-boundary ordinal." This needs a ruling.
- **Rulings item 2.** The code raises `MissingInit` at `built` and `ServiceLifecycle` in the other states (`src/sim.jl` 401–411). Naming them needs a ruling.
- V5's drain gloss says "publishes". The glossary and spec 7658 say "applies", and "publish" belongs to snapshots. Use "applies".
- Some links come late. Root inputs are first used at line 10 but linked at line 210. Input mode and what-if replay first appear unlinked in the roadmap (lines 24–25).
- Reader-cold names: none in classes 1–3.

## Re-check (after R16–R18 and the fix list)

`build_inventory.py ch12 G`: 161 claims, 21 added, checks failed 0. The code-span diff is the de-indented fence only.

- The fixes hold. C-008 now reads "It restores", C-011 "This form stands in", and C-149 "That form restores `t₀`". C-122 cites D-101 beside D-176. The drain gloss says "applies". Root inputs are linked at their first use, line 10. Their gloss now adds "the only thing the periphery may write", which is the glossary's wording. Input mode and what-if replay are linked in the roadmap with glossary-sourced glosses, and the later links are gone.
- R16 holds. The bold is on "In `:replay` the recording is the bound" (D-218). F55's sentence is plain, scoped, and cited to D-218. There are 12 bolds, one per ruling.
- R17 holds. Its sentence matches §10.4 (spec 5961–5965) and cites §10.4.
- R18 holds. The kinds match `src/sim.jl` 401–411.
- **One finding remains.** "One grid is thus an invariant of every replay" used to follow the origin and frame check. It now follows "The lifecycle refusals precede any write too", so "thus" points at the wrong sentence. Fix: fold the lifecycle sentence into the gate sentence, as in "… meets the lifecycle gate before any write, with `MissingInit` …".
- Cosmetic: line 11 and lines 229–230 are not rewrapped.
- Second re-check. The fold holds: the gate sentence now says "before any write", and "thus" follows the clock arm again. Line 11 and lines 229–230 are rewrapped. `build_inventory.py`: 161 claims, 21 added, checks failed 0. Cosmetic: line 296 ("arm. One grid is thus an invariant of") is a short line that still needs rewrapping.
