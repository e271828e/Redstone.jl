# Unit B2: cold verification

Phase 1 split 121 items into 80 sub-assertions (appended to `verify_phase1.md`).

## Counts

Inventory 183 claims (F 68, M 67, R 33, C 15). MATCH 182, DRIFT 1, LOST 0.
Every `homes.md` span was found and checked in context. The seven R7 drops
(C-018, 038, 039, 098, 099, 119, 166) land on the corrected home. ADDED
assertions: 8 (V58, V59, V100, V101, V102, V103b, V104, V105). 1 claims more than
its source. Signature findings 2. Citation findings 3. Bold 0. Inbound 0.
Link findings 2.

## DRIFT

- C-041 (V38), scope. Old: "Nonlinear least squares … against the problem's
  own `tolerances`." New: "By default, nonlinear least squares … against the
  problem's own `tolerances` (§14.7)." "By default" now also covers the
  tolerances, but the service's box test applies to every backend (§14.8,
  D-150). Fix: "By default, nonlinear least squares on the packed residuals
  with exact Dual Jacobians; convergence is judged against the problem's own
  `tolerances`", or move the tolerances clause to `trim!`'s second sentence.

## ADDED, over-claiming

- V103b, "`logged` returns them oldest first (§11.2)". §11.2 never says
  "oldest" (no hit in the frozen spec). Only the `src/sim.jl:2255` docstring
  says it. Fix: drop "oldest first", or say in `rulings.md` that it rests on
  the docstring alone.

V58/V59 (§14.4, 11760–11763), V100/V101 (§13.5 10770–10776, D-203 Position,
`src/sim.jl:367`), and V104/V105 (§11.2 7131, D-407's first bullet,
`src/readers.jl:299`) hold.

## Signatures

- `trim!` shows `t0 = 0.0`. `src/sim.jl:812` spells `t0::Real = 0.0`, and B2
  spells `init!`'s `t0::Real`. This is not ruled. Fix: `t0::Real = 0.0`.
- `linearize` shows `width = 8`. `src/sim.jl:835` spells
  `width::Int = LINEARIZE_WIDTH`. Only C-082's note covers the value, not
  `rulings.md`. Fix: record it in `rulings.md`.

Every other signature, keyword and default matches `src/`, or is ruled
(`step!` `frames = 1`; `series`/`trace` return names).

## Citations

- Every old citation survives with its claim or moved with it.
- The added and replaced citations hold. I checked each one in the frozen
  spec or log. In the log, D-260's Position carries the stop-policy build and
  the `Float64` t₀. D-274's Position carries the checkpoint contents. D-268's
  Rationale (log 11498) spells `stop!(sim)` beside `stop!(handle)`. D-203's
  Position carries the typed sources. D-407's first bullet carries the read
  set. D-429's Position carries `overlay!`.
- V112: D-261 now ends the sentence "Replay is the state-trajectory inspector
  and the `StepError` reproduction tool". It carries nothing of that claim. It
  carries the recording keywords, which are now in the signature. Fix: accept
  it as the bullet's citation, or move it to the Recording sentence.
- V6: §14.2 joins the lift sentence but carries only "stores, never applies".
  This is acceptable at bullet scope.
- In `rulings.md`, two frozen line numbers are off by one: 5383 should be 5384
  (the measurement seam), and 9489 should be 9490 (`t_plus`).

## Bold and labels

No bold. The three `####` labels are Condition algebra, Stopped-sim services
and Running.

## Inbound

Frozen 7037, 7048, 7056, 7810, 7845, 8733 and 9369 all still find what they
cite B for: the tables, the signatures, the Recording sentence, and the
checkpoint entry's t₀ and deployment.

## Links (R12)

- `rulings.md` leaves "stop request" to B1. B1's old text uses the term only
  inside the keyword `ignore_stop_requests` and never in prose. B2 should link
  `#g-stop-request` at "no honoured stop request" (`run!` entry).
- "drain", "batches" and "staging cells" in `mode`'s entry have anchors
  (`#g-drain`, `#g-batch`, `#g-staging-cell`). B1's old text never uses them.
  They are unlinked and not listed in `rulings.md`.
- C-111's note says `StopPolicy` stays unlinked. That is stale: C-110 and
  coordinator ruling 5 link it.

## Reader-cold names

- `LevenbergMarquardt`: new in B through R7. It has no entry in B and is
  defined only in §14.8.
- `StopFlag`: linking stop request fixes it.
- `TrimReport`, `Linearization`, `UnboundedRun`, `StepError` and the
  `Simulation(world)` "world": carried from old B. They are defined in their
  sections or in Appendix C.
