# Chapter 11: serious findings for the owner

Each finding shows a defect or inconsistency in the design itself, not in its
prose. The rewrite carries the text as written. Lines are `spec.md` lines at
`f61b1af`; `log` marks `decisions.md` lines.

## From the survey (checkpoint 1)

- **E1. The fan-out mapping entry** (survey 1 F10; brief R8). §11.4
  7507–7510 says aircraft-semantic derivation such as `q_ref = q_sf · axis`
  lives in-model, "Alternatively it is accepted as a small per-aircraft×device
  mapping entry, an aircraft-design fork." D-045's Rejected list (log
  1448–1449) rejects "*Shaping as per-device mapping code:* aircraft semantics
  duplicated per device". `flight_case_studies.md` 264–269 says "semantics
  in-model". No Position settles which holds. Recommendation: delete the
  "Alternatively" sentence, since D-045 records the rejection and the case
  study agrees; if the exception is wanted, record it in a new entry that
  amends D-045.
- **E2. Who records the `shutdown!` release** (survey 2 F54; brief R15).
  §11.6 7790–7795 says the wrapper records the release just after
  `shutdown!` returns, so an interrupt between the two repeats the call.
  D-268's amendment (log 10950–10953) describes the withdrawn calling-task
  device. In `src` the wrapper records nothing (`src/devices.jl` 406–425);
  the repeat arises in `run!`'s interrupt arm, which advances a cursor after
  each return (`src/sim.jl` 1226–1227). The obligation, an idempotent
  `shutdown!`, stands either way. Recommendation: restate the case as the
  code has it, and annotate D-268 under D-310 in track 2.
- **E3. `mark_dead!`** (survey 2 F55; brief R15). §11.6's wrapper sketch
  (7775) and 7865, and §12.4's sketch (8788), mark a dead device with
  `mark_dead!`. D-160's Position (log 5686) names it. `src` has no such
  function: "Death is marked nowhere beyond the record" (`src/devices.jl`
  397–399), which D-138's Rationale (log 4557, "no dead-marking machinery of
  its own") and D-193 agree with. Recommendation: replace the sketch line
  with a comment that the task's end reads as `task_state = :done` at the next
  publication, and annotate D-160.
- **E4. Which device functions are mandatory** (survey 2 F62; brief R15).
  §11.6 says "four functions, one optional" (7748, 7760), so `init!` and
  `shutdown!` read as mandatory. `src` gives both no-op defaults
  (`src/devices.jl` 67–85) and makes `loop` "the one mandatory function",
  refused at `attach!` (`DeviceContractMismatch`, D-216). No entry gives the
  defaults. Recommendation: rule the spec to the code ("one mandatory
  function, three optional with no-op defaults") in a new entry naming the
  rejected alternative.
- **E5. The shipped GUI binding after D-310** (survey 2 F71, F69; brief
  R15). §11.6 8010–8017 describes "the shipped GUI binding" and its render
  loop reading `latest` "at each tick". D-310 parked the built-in Julia GUI
  in favour of a browser cockpit over the bridge, and `src` ships no GUI
  binding. The glossary's `should_abort` entry (14097–14099) says "The
  shipped GUI attaches with `true` (§11.6, §12.4)", from D-138's Rationale
  under the withdrawn `gui = true`. Recommendation: keep the binding's shape
  (greedy, no `claims`, no `reads`) as the standard front-end binding, drop
  the render-loop clause and the glossary's claim, and leave the cockpit's
  read path to its own design.
