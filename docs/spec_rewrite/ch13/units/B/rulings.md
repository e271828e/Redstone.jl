# Unit B (§13.3, §13.4): rulings

Line numbers are old spec lines at `1fee0fc`; log lines are lines of the
frozen `scratch_survey/h1/decisions.md`.

## Corrections proposed

1. **"Three kinds of client share one primitive"** (10203). After F3 the
   public `resolve` is one level and the generic-holding duty is the service
   walk's (`resolve_authored`, `src/assembly.jl` 1494–1534), so the clients
   do not share one primitive. Wiring calls `resolve_terminal` and
   `_one_level`, services walk `resolve_authored`, and inspection reads the
   address table. Ruled R17 and applied: "Three kinds of client share
   one resolution, and each gets the rule its promises require." §13.3's
   internal-fact sentence (10244) already licenses several functions.
2. **"a broken binding fails at attach, at its own site, harming only the
   observer"** (10232–10233). The sentence argues the inspection client's
   leniency with a binding as its example. Under R2 a device read binding is
   a service client, strict past a generic seam (D-406, `src/readers.jl`
   505–506), so the example now names the wrong client. Kept as written.
   Proposed: "It addresses one build's instances, and a broken inspection
   read fails at its own site, harming only the observer." The paragraph
   cites D-130, which R5 says to cite only for clauses R2 leaves standing.
   Ruled R18 and applied, "at attach" dropped with the binding.
3. **"no declared condition will catch them"** (10412). *Condition* is
   §14's datum (`#g-condition`, "A guard defines a *predicate*"). Here it
   means an event predicate. Ruled R19 and applied: "so no declared
   guard will catch them".
4. **`Outputs`'s gloss, "the port classes"** (10269). The glossary's
   `Outputs` holds "per component the output port names each stage
   produces, and the execution order". "The port classes" reads as the same
   fact in older words (which stage produces a port). Kept as written,
   as R19 confirms.

## Citations added or replaced

- **D-061** at "All three are normative in the forms given here" (10173),
  bold. Position: "`resolve(asm, path)` walks declared field types …;
  `input_faces`/`output_faces` return declaration-ordered face-name strings;
  the wiring resolver splits a terminal path's final segment".
- **D-207** at the one-level rule (10188). Position: "every endpoint in the
  three wiring declarations addresses an immediate child (container
  elements included) and one of its faces". Plain; §6.1 bolds it.
- **D-130** at "Which rule applies depends on who is resolving" (10200),
  bold, and at the internal-fact sentence (10244). Position:
  "`resolve`/`resolve_terminal`'s generic-boundary duty is client-scoped —
  D-083's line carried into resolution …; which of the three a client falls
  under is internal, never user-facing API".
- **D-406** in the service row (R2). Position: "Attach resolves a binding's
  `reads` through the read-selector family's one collecting resolver, the
  resolver trim and linearization already use".
- **D-310** in the inspection row (R2). Position: "The built-in Julia GUI is
  parked". **§11.7 removed** from that row (R16).
- **§13.3 removed** from the moved attach sentence (F24).
- **§14.4 replaces §14.10** in F2's replacement paragraph, as R6 dictates.
- **D-317** on the bold at the `frame!` sentence (F16). Bullet 8: "The
  model's `frame!` and `init!` host the catch and build the `StepError`
  through the one constructor." Also at the interrupt's topic sentence:
  "An `InterruptException` is never wrapped and writes no status inside a
  frame."
- **D-059** on the bold at "`frame!` never wraps per stage or per
  component" (it was cited there), at the cursor sentence and at the
  terminal status. Position: "Runtime failures are caught at one site,
  around the boundary macro-sequence, against an execution cursor — schedule
  index, function kind, boundary phase, one plain store per dispatch";
  bullet 4: "Status goes terminal `stopped`/`errored`, and synchronous runs
  rethrow after the tail".
- **D-261 replaces D-253** at the cursor's component index (F13). D-261:
  "the execution order beside the rows as component indices"; its
  Supersedes line takes D-253's clause keeping the `Dataflow` name.
- **§10.4** at ITP or Brent root-finding (R10).
- **D-128** on the bold "The frame-entry boundary index is the replay
  pointer" and at the halt. Position: "`StepError`'s replay pointer is
  respelled the frame-entry boundary index — the frame-top boundary (grid or
  boundary zero) at which the failing frame began — …
  `replay!(to_boundary = k)` halts precisely there".
- **D-235** at the conformance failure's catch site. Bullet 2: "A
  non-conformant one generates a throw of `ConformanceFailure`, a
  `StepError` species at runtime".
- **D-221** on the species-rule bold. Position: "The catch site unwraps it,
  and the `StepError` it constructs carries that diagnostic as `cause`."
- **D-225** on "The cause's type is the carrier's parameter". Position:
  "`StepError{C}` carries the type of its `cause`".
- **D-132** at the routing to the stop path (Rationale; below).
- **D-294** at the unmask points (F19). Bullet 1: "The wait is an unmask
  point, beside the frame top and the pause block".
- **D-398 replaces D-268** at the forced throw (M7, survey part E). Bullet
  2: "Julia's forced throw after repeated SIGINTs reaches §13.4's defensive
  arm inside the mask." D-268 states it only in its 2026-09-26 annotation.
- **D-268** on the bold "`run!` and `replay!` discriminate the two by the
  roster". Bullet 5: "`run!` discriminates §13.4's two dispositions by the
  roster"; `replay!` from the annotation of 2026-09-26.
- **D-389** at "`step!` is deviceless by construction". Bullet 2: "A
  stepping session is deviceless by construction".
- **D-218** at the `:replay` halt. Bullet 1: "`replay!` attaches the
  recording and enters `:replay`. `step!` and `run!` consume it frame by
  frame from there".
- **D-223** on the boundary-zero bold, repeated because the paragraph is
  split in three. Position: "A throw inside boundary zero … is wrapped by
  the one `StepError` constructor with the cursor's frame, `t₀`, pointer `0`
  and the species rule, and the simulation returns to `built`".
- **D-274** on the bold "The reproduction of a boundary-zero failure is
  `init!` under the same condition" (it was cited there). Bullet 7: "Its
  reproduction is `init!` under the same condition."
- **D-157** on two bolds, the first act and `ẋ`. Position: "The
  nonfinite-`x` check is the boundary's first act …; `ẋ` does not
  participate, with the reason stated".
- **D-105** at "It fails in two classes". Position: "two failure classes,
  two fates". Plain; §11.6 bolds it.
- **§12.2** at the liveness heartbeat (F10's kept clause).
- **D-022** at the domains never mixing (F26). Position: "no shared mutable
  model".

## Rationale-only rulings

- **D-132**, Rationale (log 4341–4343): "§13.4's catch site never wraps an
  `InterruptException` in `StepError` (routes it to the stop path;
  unreachable in practice under masking, kept defensively)". It carries the
  routing to the stop path and "the branch is kept … defensively". D-317
  bullet 8 states "never wrapped" alone.
- **D-225**, Rationale (log 8805–8807): "for that throw the frame and the
  pointer are lost, and the lifecycle word does not move as it does on the
  framed path". It carries F30's added sentence.
- **D-225**, Rationale (log 8795–8799): the test spelling
  `@test_throws StepError{ConformanceFailure}` (10316).
- **D-223**, Rationale (log 8733–8734): the remedy for a condition that
  fails at `t₀` is a corrected condition (10378).
- **D-130**, Rationale (log 4258–4260) and Rejected: the principle
  paragraph (10228–10239).
- **D-061**, annotation of 2026-10-12 (log 1955–1961): the two duties
  (10187–10191).
- **D-059**, Rejected (log 1889–1890): "Framing information does not need to
  be caught into existence" (10262).

## Bold on the same entry elsewhere

No ruling of this unit is bold in two places. Other bolds in the frozen spec
cite the same entries for other rulings:

- D-059: §12.6 (9411) and §14 (11185) bold bullet 4, `errored` terminal.
  Here the Position's first sentence is bold, and bullet 4 is cited plain.
- D-317: §9.2 (4327) and §12.6 (9320, 9355, 9395) bold bullets 1, 2 and 7.
  Here bullet 8.
- D-128: §12.7 (9674) bolds the first Position sentence. Here the second.
- D-268: §11.6 (7910, 7920), §12.1 (8658, 8672) and §12.4 (9114–9199) bold
  other bullets and annotations. Here bullet 5.
- D-274: §11.5 (7728) and §12.7 (9622) bold bullet 4 and the Position. Here
  bullet 7.
- D-083: §11.2 (7105). The old §13.3 bold at 10200 cited it in the next
  sentence; that bold now cites D-130, and D-083 stays plain.

The sibling units' `new.md` files (A, F and G, as they stood when this unit
finished) hold no bold citing any entry this unit cites.

## Inbound citations affected

- spec 5085 (§9.5): "That site's frame holds the boundary time and the
  replay index". After F12 the time is the clock at the failure. A
  table-write conformance failure inside integration carries a stage time.
- spec 13617–13620 (Appendix C, `StepError`): "boundary time" and the four
  phases (F12, F14). Track 2, as the brief says.
- spec 14689–14693 (glossary, execution cursor): "an index into the
  `Outputs`'s execution order" (F13) and "without exception frames in the
  hot path" (R7's "exception handlers").
- spec 3410–3413 (§8.6) and 7108–7110 (§11.2): landing edits under R2.
- spec 12831–12833 (Appendix B): `resolve` "enforces the one-level rule for
  wiring and the generic-holding rule for deep reads, at the primitive". F3
  gives the second to the service walk.
- spec 5094–5096 (§9.5) and 6531–6532 (§10.6): "loop-level" and "loop-state
  field", landing edits under F20.
- spec 9164–9165 and 9201 (§12.4): hold. The catch-site clauses stay.
- The `resolve_terminal` paragraph (F2): no inbound row relies on the five
  clients or the one splitter.

## Open questions

None. The first two were ruled R16 to R18 after step 3 and are applied.
