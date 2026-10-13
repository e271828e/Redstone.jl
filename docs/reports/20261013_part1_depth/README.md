# Part I depth pass: merged findings for ruling

The owner ruled on 2026-10-13 that Part I gets a general depth rule, read
strictly. This file merges three read-only audits run against `spec.md` at
`9fe8d89`. It is the list the owner rules on before any edit.

- `depth_ch05-07.md` checks chapters 5 to 7 against rules 1 to 5. Its
  entries are M1 to M44, with gaps G1 to G5.
- `laws_ch08-10.md` lists semantic laws in chapters 8 to 10 that Part I
  omits. Its entries are items 1 to 29.
- `laws_ch11-14.md` does the same for chapters 11 to 14. Its entries are
  L1 to L18.
- `depth_ch01-04.md` checks the roadmap and chapters 1 to 4, after their
  readability rewrite landed at `af4c13f`. Its entries are P1 to P24, with
  gaps PG1 to PG4.

## The rule

Part I says what a model computes. Parts II to IV say how it is written and
checked, how it runs, and how it fails. A reader who knows hybrid systems but
not the API reads Part I alone.

1. **Meaning, not spelling.** An API name serves only as a label for a
   concept Part I defines.
2. **Laws, not enforcement.** Checks, diagnostics and edge cases live where
   the check runs.
3. **Mechanisms by name only.** Algorithms are named and cited.
4. **Short rationale.** Case studies and arguments against alternatives
   leave a summary and a pointer.
5. **Pointers, not prerequisites.** A Part I sentence reads without its
   forward citations.
6. **Complete at its level, strictly.** Every semantic law the later parts
   mechanize is stated in Part I.

One filter applies to every addition under rule 6. A law states that a
parameter or method exists and what it does. Its default value and its
algorithm stay where they run. For example, Part I says a frame allows a
bounded number of localizations, and §10.4 says the bound is 8.

## Size

| | words |
|---|---|
| Part I today | about 15,200 |
| Moves out of chapters 5 to 7 | about 5,000 |
| Moves out of chapters 1 to 4 | about 1,100 |
| Laws added, merged and filtered | about 1,650 |
| Part I afterward | about 10,500 to 11,000 |

Of the 5,000 words leaving chapters 5 to 7, about 900 are pure duplicates.
The other 4,100 carry facts stated nowhere in Parts II to IV, so they land in
their destination before Part I loses them.

## Decisions for the owner

1. **Part I gets shorter.** The rule fixes uneven depth, not shortness.
   Chapters 5 and 7 lose about 40 percent.
2. **Chapter 2 becomes the formalism of a run.** Most added laws are about
   time and runs, and Part I has no home for them today. Recommendation:
   chapter 2 gains subsections for the system class, time and boundaries,
   events, and what a run is, with the exclusions last. Only §2.x numbers
   change, so the renumbering stays local.
3. **Trim and linearization.** L16 and L17 define what the services compute.
   They describe questions asked of a model rather than values the model
   produces. Recommendation: one sentence each in §7.2, the mechanics staying
   in §14.
4. **Material with no current home.** §7.3's idioms (M42) and §7.4's
   lineage (M43) exist nowhere else in the spec. Recommendation: the idioms go
   to §8.2 as authoring guidance. The lineage narrative, its MTK and FMI
   comparison and its "thirteen connections" figure go to a companion. The
   log already holds each step.
5. **Sequencing.** The rewrite of chapters 1 to 4 has landed, so nothing
   blocks the edits. Recommendation: a few reviewed commits, in order. First
   the landings in Parts II to IV, then the cuts and repointed citations,
   then chapter 2, then the other additions.

## Moves out of chapters 1 to 4

Details are in `depth_ch01-04.md`. It confirms most suspected passages and
corrects one.

- **§2.1's predicate definition stays.** The Bool and sign forms and the
  convention that holding means `σ ≥ 0` define the predicate, and §10.4,
  §10.6 and the glossary cite §2.1 for them. What moves is the rule that
  the guard's return type declares the policy, which §8.2 and §10.4 already
  state, and the naming note on `state_events`. Part I keeps the law that the
  predicate's form fixes its policy (P2).
- **§3.4's integrate-and-dump case moves (P9).** Several of its facts exist
  only there, so they land first in §8.6 or a companion. Part I keeps that an
  update writes only its own `s` and that handlers are the only writers of
  `x`, which §5.3 cites.
- **§4.4's value-level constructor moves (P23).** No section outside §4.4
  owns it. It lands in §8.2 or §14.1, with about six citations repointed.
- **Smaller moves.** The per-step hook's FlightCore examples (P6), the
  staging-cell bullet (P10), the StopFlag refusal (P16), the refusals and
  logger rule in §4.3 and §4.4 (P18, P21, P22) and pre-sampling (P24).
- **The roadmap (P1).** "cites them for spellings only" becomes a statement
  of rule 5, and the roadmap's §2 summary follows decision 2.

Chapter 3's letter paragraph (P7) turned out to be mostly law and stays.

## Moves out of chapters 5 to 7

Details are in `depth_ch05-07.md`. The largest moves, all carrying unique
content:

| Passage | Words | Destination |
|---|---|---|
| §5.6 feedthrough tracing (M18) | 900 | a new "Cycle diagnosis" subsection under §9.1 |
| §7.5 allocation policy (M44) | 570 | §9.7 "The measurement seam", with logging and unrecorded firings in §11.2 |
| §7.3 workspace spelling and idioms (M40 to M42) | 530 | §8.2, see decision 4 |
| §6.1 "Type-checking a wire" (M23) | 420 | §8.2 "Input contracts" |
| §7.4 lineage (M43) | 380 | a companion, see decision 4 |
| §6.2 `Junction` code (M25) | 250 | §13.7 |

§1 cites §7.5, and §1 is locked until the rewrite lands. Removing §7.5 also
means repointing about 19 citations in Parts II to IV.

Borderline items, with recommendations:

- **Keep in Part I.** M1's de-spelled sentence that each function receives a
  defined set of named views. M7's "modes are state for the feedthrough
  split". M18's two-sentence verdict defining a real and an artificial loop.
  M20's "a container's elements count as immediate children". M23(b), that a
  re-emitted frozen handle pins its output. M31, why the leaf vocabulary is
  closed. M33's "the flat vector still exists".
- **Move.** M10, M11, M13, M21, M26, M27, M34 and M44's unrecorded firings.

## Laws Part I gains

The two law sweeps overlap. Each law below cites its sources.

### Chapter 2, time and runs

- **T1. The time grid.** Time advances in frames of fixed step on the grid
  `t₀ + k·h`. Boundaries fall at every grid point, at every localized event
  time and once at `t₀`. A localized event never shifts the grid. Time is
  not state. (8–10 #9, L10)
- **T2. Integration.** A fixed-step one-step method, chosen at deployment,
  advances the continuous state from each published boundary. (#10)
- **T3. Inputs.** Root inputs change only at frame tops and hold until
  written again, the newest staged value winning. They are the only outside
  influence on values. Control commands decide when steps run and where the
  run ends, never what a step computes. (#13, L1, L2)
- **T4. What a run consists of.** A run starts from each store's declared
  initial value, overridden leaf by leaf by the applied condition, which sets
  `x`, `s`, `m` and root inputs only. Root inputs have no defaults. A run
  starts only when every root input has a value. (#1, #5, L6, L7)
- **T5. What a run publishes.** Every completed boundary publishes one
  immutable snapshot of the settled table with its time, `t₀` and `t*`
  included. Intermediate values from integration stages, trial evaluations
  and non-final event rounds are never published. (#12, L5)
- **T6. Termination.** An end time stops the run at the first grid boundary
  at or after it, and the last step is never shortened. A stop request is
  read at every published boundary, and the first one honored ends the run
  there with no rollback. An external stop takes effect at the next frame
  top, so the trajectory is a prefix of the unstopped one. (L11 to L13, #29)
- **T7. What fixes a trajectory.** The model, the initial condition, the
  input trace and the deployment parameters fix it: step, base tick, method,
  localization tolerance and budget, firing budget. Pacing, wall clock,
  caching, logging, readers and splitting a run into advances never change
  it. Bit-identical replay holds under the same compiled code. (#8, #20, L3,
  L4)

### §2.1, events

- **E1.** An even number of crossings within one step fires nothing, under
  either policy. (#19)
- **E2.** A localized event triggers when its prior was not holding and its
  predicate holds at the step's end. Its time is the earliest instant, within
  a tolerance, at which the predicate holds, strictly after the step's start.
  A crossing exactly at the grid point is the ordinary grid boundary. (#15)
- **E3.** The state at `t*` is the step's continuous extension there.
  Projection applies at the `t*` boundary, and a projection that moves the
  state back across the guard cancels the firing. (#16)
- **E4.** When several localized events trigger in one step, the earliest
  becomes a boundary with the full event iteration and a fresh firing budget,
  no ticks and no input change. Integration then resumes to the same grid
  point, and later crossings are localized on the remainder. Past a bounded
  number per frame, crossings fall back to boundary detection. (#17, #18)
- **E5.** An edge caused by an input change at a frame top has no crossing
  to find. It fires at the frame's end boundary. (#14)

### Chapter 3, ticks and rates

- **K1.** A stateless discrete leaf still computes only at its ticks and
  holds between them. Tier changes the values of a stateless leaf. (#4)
- **K2.** Every discrete period is an integer multiple of a base tick, itself
  a whole number of steps, so ticks fall only at frame tops. (#21)
- **K3.** A component ticks at its phase plus multiples of its period on the
  base-tick index, and at no other boundary. No tick is due at a `t*`
  boundary. (#22)
- **K4.** Rates are declared in the enclosing assembly. The relative form
  ticks every K-th tick of its scope from a phase, the absolute form gives a
  period and offset in seconds and leaves the scope. Relative entries compose
  down the tree. (#23, target §3.3)
- **K5.** A tick's update is the outgoing transition. (L9)

### Chapter 5

- **PG2.** A tick's new state stays invisible until the owner's next tick,
  so a tick never triggers an event. Part I states this only inside §3.4's
  argument, so it joins B4 or K5 before that argument is trimmed.
- **R1.** A handler's mode return merges, and its state return replaces.
  (#7, §5.2)
- **R2.** A returned port value carries exactly its declared type at the
  nominal scalar, pairs with its port by name, and has one shape on every
  branch. (G2, §5.2)
- **R3.** A discrete component's `Δt` is its own period, the same in every
  stage, and its phase never changes it. (#24, §5.2)
- **B1. Boundary zero.** Initialization runs one ordinary boundary at `t₀`
  with no integration. Every output stage publishes from the initial state,
  and only components at phase zero update. Every prior starts not holding,
  so an event whose predicate already holds fires at `t₀`. Restoring a
  checkpoint keeps the priors. (#25, L8, L9, §5.3)
- **B2. The firing rule.** In each round an event fires if and only if its
  predicate holds now, its last observed sample was not holding, and its
  budget at this boundary is not spent. A blocked event keeps its edge. The
  final quiescent sample becomes the next prior. (#26, §5.3)
- **B3.** Once an event spends its budget at a boundary, its further edges
  there are dropped, and the run continues. (#27, G3, §5.3)
- **B4. The full boundary sequence.** Due discrete output stages run in
  every round against their unchanged `s`. After quiescence every due update
  runs, reading the settled table, and then the boundary publishes. A model
  with no continuous state runs the same sequence with an empty integration.
  This replaces §5.3's abbreviated sequence. (#28, #11)

### Chapter 7

- **S1.** The full state of a run is `x`, `s`, `m`, the signal table with its
  root-input levels and held discrete outputs, the guard priors and the
  clock. Restoring it and continuing gives the trajectory of never stopping.
  (L15, §7 intro)
- **D1.** At a non-nominal scalar, partials enter only from the seeded
  directions. Declared values enter as zero-partial constants. (#2, §7.2)
- **D2.** A pinned leaf carries no partials, so it is an exact zero coupling
  in every Jacobian. A plain value where the activation scalar is expected
  embeds as an exact zero-partial constant. (#3, G1, L18, §7.2)
- **D3.** At a non-nominal scalar only the continuous dynamics run. Discrete
  cells hold their nominal values and no guard or handler runs. (#6, §7.2)
- **D4, subject to decision 3.** Trim searches initial conditions for one
  whose residuals hold within tolerance, each evaluation a sweep with modes
  and the discrete tier held. Linearization gives the Jacobians of the
  continuous map from `(x, u)` to `(ẋ, y)` with everything else held. (L16,
  L17)

The chapters 1 to 4 audit found T1, T2, T3, T5, T6, T7, E2, K4 and K5
partly stated in the rewritten text. When T3 lands, §2's bullet that the
runtime injects inputs "asynchronously" needs rewording to match. Its
borderline gaps PG1, PG3 and PG4 are in `depth_ch01-04.md`.

## A finding outside the depth pass

§14.9 says a thin rig holds its environment as "a handle-valued root
input", following D-139. The later D-237 refuses a root input whose type is
an opaque leaf, which a bulk-data handle is. The two agree only for isbits
handles, such as the parametric atmosphere. §14.9 does not say so. This
needs a ruling, not a move.

Left out as not semantic or as already stated: see the closing sections of
`laws_ch08-10.md` and `laws_ch11-14.md`. L14, that a failed boundary is
discarded, stays in Part IV.

## Outcome

Applied on 2026-10-13 from `3685f92`, uncommitted until the owner's review.
`brief.md` drove three stages: chapters 1 to 4, chapters 5 to 7, then
chapter 2 and the laws. Two cold reviewers followed, one checking for lost
content and one checking the laws. `fixes.md` records their findings as
ruled, and a fixer applied them. The orchestrator swept the citations
outside the rostered docs (`sweep_notes.md`). The full suite and the battery
pass.

| chapter | words at `3685f92` | words after |
|---|---|---|
| 1 | 602 | 602 |
| 2 | 880 | 2,853 |
| 3 | 1,418 | 1,301 |
| 4 | 2,365 | 1,859 |
| 5 | 5,734 | 4,268 |
| 6 | 2,714 | 1,859 |
| 7 | 4,011 | 2,523 |

Open for the owner: §10.4 and D-290 claim boundary detection is exact for a
guard reading only `u` and `m`. That holds for root inputs and held discrete
outputs, not for inputs wired from continuous producers.
