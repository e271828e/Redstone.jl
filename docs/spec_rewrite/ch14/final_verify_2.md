# Chapter 14, step 6b: the final verifier, half 2 (units F, G and H)

Verified commit `b187775`, current commit `bfcf024`. The logs replayed are
`chapter_fixes_2.md`, then `ruled_edits_2.md`.

## Counts

- Hunks: 57 by `diff -U0` (F 17, G 21, H 19). Every one is accounted for by a
  log entry.
- Edits checked: 70. That is 56 fixer entries (55 paragraph edits and P2-18's
  blank line) and 14 ruled entries (B4, B7 to B18, B11 twice).
- Findings: 6, all minor. None is an unlogged hunk, and none changes a
  claim's strength or scope. Five are antecedent or link nits, and one is a
  reserved word.

## Replay

The script `scratch_final/h2/replay.py` replays both logs in order on
`git show b187775:…/units/<U>/new.md`. Each old block occurs exactly once, at
the line its heading names. The result matches `bfcf024`'s `new.md` for F, G
and H byte for byte. The worktree's `new.md` files equal `bfcf024`'s, and
`chapter_new.md` equals the units assembled by `checks/assemble.sh`'s rule.
There is one blank line at the F/G seam (P2-18).

`python3 checks/build_inventory.py ch14 <U>` printed `checks failed: 0` for A,
B, F, G and H. B also printed a note at its line 277: D-414 left the span's
citations with no `newcites`. That belongs to half 1. The rewritten
`inventory.json` files are byte-identical to the committed ones. Every ruled
edit's id (B4, B7 to B18) is in its unit's `claims.md`.

## The special checks

- **B4.** `c172.jl` 796 holds `TrimState <: AbstractTrimState{7}`, and
  FlightPhysics' `aircraftbase.jl` holds `θ_constraint` (110) and
  `AbstractTrimState` (92). The bold "Flight.jl's trim formulation is correct
  at its core and survives verbatim as user math" is one headline clause, cited
  to D-069 in its own sentence, and it matches D-069 bullet 4. "Flight.jl's" is
  true of both owners. The owner clauses after it, FlightPhysics'
  `θ_constraint` and `c172.jl`'s `TrimState`, match the source. No finding.
- **B7.** The only change inside the `at` lift sketch is the comment, "the
  prefix is prepended to the read set's mount chain". It matches D-277 and the
  prose "prepends the prefix to that chain and joins nothing". **B17** changes
  one word of one cell ("input entry"). The table's rows, columns and layout
  are unchanged, and the cell now matches the prose at H 111. No finding.
- **B11.** "For design tasks the rig stays `design_world(ac)`" is the old
  sentence with only "shipped" cut. After the test-rig idiom, it carries the
  one claim the bold lacks: design tasks still use `design_world(ac)`. It is
  also the right antecedent for "That keeps…", which is old text verbatim.
  `claims.md` lists the cut word's fate. No finding.
- **B15.** `_check_seedable` (`src/linearize.jl` 336–347) pushes `:unseedable`
  for a `.name` step or a second index step and for a non-`Float64` real leaf,
  and `:vector_tap` for a non-`Real` leaf. `_tap_violation` (262–266) builds
  each as a `TapResolution`, thrown at resolution. "Any other seeded address is
  rejected at resolution as a `TapResolution`" is therefore true. No finding.
- **Fixer departures.**
  - P2-11: R15's "Flight.jl's Cessna 172 model" stays, and only the repeated
    (`c172.jl`) goes. Sound.
  - P2-20 in §14.8: sound. In §14.10, see finding 3.
  - P2-26: "When trims span the flight envelope" keeps the claim and avoids
    *sweep*. Sound.
  - P2-30: the gloss "worlds holding only the aircraft and its environment"
    agrees with `design_world`'s composition and with D-364's thin rig, which
    holds its environment as a root input or a constant source. It sits at
    §14.9's first use. Sound.
- **P1-37.** §14.5 is the home of the raw write → sweep → read cycles
  (unit B). The §14.5 pointer moves to "The iterations are untouched", and "at
  the seeded activation, over the continuous chain and `x_deriv` alone" stays
  uncited, as §14.5 does not state it. Sound.
- **P1-38.** §14.10 now uses the shared gloss, "the `Model`'s state at a frame
  top as one value". Sound, apart from finding 3.

## Other checks

- **Owners.** I checked the clauses the fixer added against the Flight.jl
  source. P2-17: `c172.jl` 934–939 warns with `@warn`, then calls `assign!`.
  P2-31: `FlightPhysics/src/world.jl` 49 defines
  `Modeling.f_init!(world::Model{<:SimpleWorld}, …)`, and FlightCore's
  `modeling.jl` exports `Model` and `f_init!`. P2-41: FlightPhysics'
  `linearization.jl` holds `LinearizedSS`.
- **Code.**
  - B12: `_saturated` (`src/trim.jl` 588–596) compares each decision only
    with its own bounds.
  - B16: the empty problem takes one evaluation and no backend call.
  - B18: `_linearize` runs `assert_total` on the `about` plan.
  - B14: `LinearizeDual` is a named const (`src/linearize.jl` 64).
  - P2-29: `at(prefix, node)` returns `Scoped` (`src/conditions.jl` 94).
- **Bold.** F, G and H hold 20, 19 and 17 bold spans before and after the
  edits. Every span has a D-citation later in its sentence.
- **Glossary links.** No term is linked twice in §14.7 to §14.10, §14.8
  across F and G included. Every added link (`probe-value`, `unattended-run`,
  `phase`) and every moved one (`checkpoint` in §14.8 and §14.10, `Model` and
  `root-input` in §14.10) sits at its first use with its gloss. Finding 4 is
  about the one removed link.
- **Reserved words.** The edits add no bare *entry*, *kind*, *door* or
  *class*. Finding 5 is the only lowercase *model* they add.
- **Wrap.** No prose line in F, G or H runs past 80 rendered columns. No
  edited paragraph leaves a ragged line, except where the next token is a long
  code span.

## Findings

1. **Unit G, line 154 (§14.8; from P2-13 in unit F).** P2-13 removed the
   misaimed `#g-probe` link, which left §14.8 with no `probe` link. "Makes the
   Dual probe fail" and "puts the probe in CI" (154, 156) use the glossary's
   *probe*. The frozen spec links "the first `Dual` [probe](#g-probe)" (spec
   2549). Fix: "makes the Dual [probe](#g-probe) (the build's single
   evaluation of a user function) fail".
2. **Unit G, lines 229–230 (§14.9; P2-29).** "**A read set carries its mount
   chain as data** ([D-277][d-277]). A read set is a `Reads` value.
   `at(prefix, read_set)` prepends the prefix to that chain…". The added
   sentence comes between "its mount chain" and "that chain". Fix: put "A read
   set is a `Reads` value." before the bold, or write "to the read set's mount
   chain".
3. **Unit H, lines 69–72 (§14.10; P2-20 and P1-38, the fixer's
   departure).** "A checkpoint is the `Model`'s state at a frame top as one
   value. It is `checkpoint(sim)` on a simulation and `checkpoint(model)` on a
   `Model`, each restored into the scratch world with no boundary zero". The
   new gloss sentence makes "It" any checkpoint, so "each restored into the
   scratch world" now reads as true of every checkpoint, not of the default
   operating point. Fix: begin the third sentence "The default point is
   `checkpoint(sim)` on a simulation…".
4. **Unit H, line 76 (§14.10; B18).** "…linearizes anywhere else without
   touching the sim**, its coverage checked as [§14.6][s14-6] requires". The
   nearest noun to "its" is "the sim", but the coverage is the condition's.
   Fix: "the condition's coverage checked as [§14.6][s14-6] requires".
5. **Unit H, lines 216–217 (§14.10; P2-42).** "an FMU (a Functional Mock-up
   Unit, a packaged external model)" adds a lowercase *model*, which is a
   reserved word. Fix: "(a Functional Mock-up Unit, a packaged external
   simulation unit)".
6. **Unit F, lines 121–123 (§14.7; P2-4).** "gives the [value-level
   constructor](#g-value-level-constructor) that builds such a handle, a plain
   exported function of the component and its input values." The appositive
   follows "such a handle", so it can read as glossing the handle. Fix:
   "[§8.2][s8-2] gives the [value-level constructor](#g-value-level-constructor),
   a plain exported function of the component and its input values, that
   builds such a handle."

## Re-check

I replayed `final_fixes_2.md`'s six entries on `bfcf024`'s F, G and H. Each
old block occurs once, at the line its heading names, and the result matches
the current `new.md` byte for byte. By `diff -U0` that is 5 hunks: F 1, G 2
and H 2. A word diff of each entry shows only the change its finding asked for.
The rest is rewrap.

1. G 151–156: "the Dual [probe](#g-probe) (the build's single evaluation of a
   user function)". The gloss is the glossary's first clause, and §14.8 now has
   one `#g-probe` link. "Puts the probe in CI" follows it. Fixed.
2. G 228–229: "prepends the prefix to the read set's mount chain". The `Reads`
   sentence stays where it was, and nothing now points back across it. Fixed.
3. H 70–71: "The default point is `checkpoint(sim)`…". "Each restored" now
   applies to the default point only. The citations are unchanged. Fixed.
4. H 76–77: "the condition's coverage checked as [§14.6][s14-6] requires". The
   bold and D-272 are unchanged. Fixed.
5. H 216–217: "(a Functional Mock-up Unit, a packaged simulation unit)". It has
   no reserved word, and "both say so" still has its two subjects. Fixed.
6. F 122–123: the appositive now follows "constructor". The link stays at its
   place, and the §14.1 sentence is unchanged. Fixed.

No neighbouring claim, antecedent, link or citation broke. No term is linked
twice in §14.7 to §14.10. All 56 bold spans keep a D-citation in their
sentence, and no prose line runs past 80 rendered columns. Each new span is in
its unit's `claims.md`. `build_inventory.py` prints `checks failed: 0` for F, G
and H. I skipped A and B, which another agent is fixing. Re-check findings: 0.
