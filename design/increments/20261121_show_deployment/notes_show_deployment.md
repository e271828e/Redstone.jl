# Notes: `show(::Deployment)` in the notation

The record of part four of the core work ahead of the inspector's
increment 10, run on 2026-11-20 and 2026-11-21 by one session and one
high-tier reviewer. The user ruled the printed form and then left for the
night, so the code landed while the user was away. It is not an increment:
a docs commit, a docs fix, and one code commit. No brief was written. This
file holds what the spec, the log and `pending.md` do not carry: the
rulings, the session's own decisions, the findings, what was verified, and
what is left open for the user.

## 1. The commits

- `8a488dc`: the spec's §9.2 and D-471, with an annotation under D-257 and
  one line of `tools/coinage_inventory.md`.
- `1cbb4c9`: three wording fixes to §9.2 and D-471 that the review found
  (decision 3.9).
- The commit that adds this file: `src/show.jl`, `test/test_show.jl`, the
  parity client of `test/test_descriptor.jl`, the `show.jl` entry of
  `code_map.md` and `pending.md`.

Nothing is pushed. The session `descriptor-handover` closed part three on
the same working tree during this work, at `81d6b76`, `fb4c3dc` and
`105747e`. The two sessions ordered their commits by message and neither
held a hunk in a file the other was committing.

## 2. The user's rulings

All of 2026-11-21, on a probe's output, and all stated in D-471.

1. `show(::Deployment)` prints a block of its own under `schedule:`, and
   `show(::Schedule)` stays as it is.
2. `Δt` and `τ` print exact, as `D·Δt_base` and `Φ·Δt_base`.
3. The anchor table has `Δtₖ`, `τₖ`, `Dₖ` and `Φₖ`, without the scope and
   the key, and its `A₀` row prints `Δt_base` by its value.
4. The component table prints no rate chain.
5. The chart spans the joint period.
6. The guard is 100 columns of that span.
7. A row is `●` where due, `·` at a base tick where it is not, and blank
   at a column that is no base tick. The frame tops are a first row
   labelled `frame tops`, `│` at each top.
8. The frame tops' row prints always. The session had proposed omitting it
   where every column is a frame top, and the user overruled that.

The user then asked the session to work autonomously and to record its
findings and decisions for review.

## 3. The session's decisions while the user was away

Each is open to the user's review.

1. **The code landed without the user's diff approval.** The repo's rule
   is that a code change is proposed before it is made. The user's
   instruction to work autonomously was read as covering it. The commit is
   local and unpushed.
2. **The chart's two heading forms.** Drawn:
   `chart, 10 columns of 1//500 s over 10 base ticks and 2 frames:`.
   Omitted: `chart omitted: 150 columns of 1//1500 s over 150 base ticks
   and 150 frames`. The spec asks for the span's length and "chart
   omitted", and fixes no wording. The `Schedule`'s own form puts the
   words the other way round, `hyperperiod: 150 base ticks, chart
   omitted`. The ruler counts columns.
3. **The block's heading shares the `Schedule`'s counts**, `schedule: 3
   rows, 1 rate scope, hyperperiod 10 base ticks`, through one helper.
4. **A rate scope with no discrete member prints the anchor table and the
   scope's row, and no chart.** With no row and no scope the block is its
   heading alone, `schedule: no rows`.
5. **Two helpers were extracted from `show(::Schedule)`'s code**,
   `_schedule_counts` and `_chart_ruler`, and `_count` now takes any
   `Integer`, since the chart's span is a `BigInt`. `show(::Schedule)`
   prints as before, which its unchanged tests pin.
6. **The descriptor's format is unchanged.** Every printed fact follows
   from `schedule.anchors`, the nodes' and the scopes' `timing`, `dt_base`
   and `dt_frame`. The parity client derives the whole block, the chart
   included.
7. **The parity client finds a scope's `(m, c)` by its path and key.** The
   schema states the order of `schedule.anchors` and `schedule.rows` and
   not of `schedule.scopes`, so a client cannot pair the two scope lists
   by position. The alternative is one clause in `src/descriptor.json`,
   which section 6 leaves to the user.
8. **A cold review ran**, although the work is not an increment. It found
   no defect and six surviving mutants. Section 5 has the detail.
9. **The docs took a second commit after the review.** The rate-scope
   table has the same columns "after its key". The frame tops' row stands
   "in every chart, also where every column is one", where the first text
   said "in every deployment". A deployment with no discrete component
   prints no chart, which the first text did not say. D-471's Rationale
   names the scopes' `(m, c)` beside the nodes'.
10. **`pending.md`'s first bullet stays**, reworded to say that all four
    parts have landed. It still holds the arc's state, which waits for the
    user's diff-verify and the push.
11. **The question D-466 left to this rewrite is not ruled.** It went to
    `pending.md` as its own item, and section 6 has it.
12. **The joint period is a coinage of two uses**, with an inline gloss
    and a line in the inventory's bucket D, and no glossary entry.

## 4. Findings

- **`D·Δt_base` can leave `Int`.** With `D = 2^40 + 15` and
  `Δt_base = (2^31 − 1)//2^31` the period is
  `2361183240367523233777//2147483648` seconds. `_seconds_label` takes the
  product in `Int128`, and a test pins that deployment.
- **The unit's two counts are coprime.** The unit is the gcd of the two
  periods, so `lcm(hyperperiod·base, frame)` equals
  `base·lcm(hyperperiod, frame)`. The reviewer noted it.
- **The rows and the scopes cannot misalign.** `bind_schedule` builds the
  rows with the same filter over `structure.components` that `show` uses,
  and the scopes in `structure.scopes`' order. The reviewer read this, and
  two mutants pin it.
- **A rate scope with no discrete member deploys**, as the structure
  trial's notes already say. The `Schedule` then prints `no rows, 1 rate
  scope`, and the lattice's `base` is 0.
- **`hyperperiod 1 base ticks`.** The `Schedule`'s heading and compact
  form write the plural at a hyperperiod of 1. The wording predates this
  work, and the deployment's block now shares it. The chart's own heading
  writes `1 base tick`.
- **§13.9's parity sentence lists what a client computes**: the routes,
  the feedthrough edges, the hyperperiod and the steps per frame. A client
  now also computes each row's seconds and the chart's joint period. The
  sentence was left as it is.
- **The float wart leaves `show(::Deployment)`.** `pending.md`'s item on a
  schedule row's `Δt` now names `show(::Schedule)` alone as its printer.
- **The suite's total** was 10657 at `105747e` and is 10724 with this
  commit, 67 assertions more.

## 5. What was verified, and what was not

- **The gate**, the full suite under the sandbox flags: green on the
  prototype at `8a488dc` and again at `105747e`, 10711 of 10711 each, and
  green on the real tree with the final patch, 10724 of 10724.
  `src/show.jl` did not change between the second run and the third. The
  tests the review asked for did.
- **Twenty mutants of `src/show.jl`**, each killed by `show descriptor`:
  - the session's fourteen: the guard at `≥ 100`; the span as the
    hyperperiod alone; the frame tops marked on base ticks; no blank off
    the base grid; the seconds as a float; an anchor's counts swapped; `τ`
    from `D`; the gate without the phase; the base ticks counted in units;
    the frames counted in units; a scope row reading a component's timing;
    `A₀` printed symbolic; the frame tops' row dropped where every column
    is one; the unit printed as the base tick;
  - the reviewer's six, which survived the first tests and die on the
    added ones: the scope rows paired in reverse; the seconds in `Int`;
    the chart's label width fixed at the frame tops'; the root's label
    bare on the chart; the root's path bare in the table; the guard on
    base ticks.
- **The reviewer's two further mutants** died on the first tests: the
  anchors reversed, and the component rows paired without the tier filter.
- **The reviewer's probes** rendered ten edge shapes with no defect: a
  root primitive, a long label, a label in CJK characters, an `Absolute`
  scope over continuous members, two scopes, `BS3` with `h_min`, a derived
  base tick, seconds and a hyperperiod past `Int`, and a sparse chart.
- **The docs battery**: green at both docs commits and at the code commit.
- **Not verified:** the examples' runner, since no name the examples
  import changed; the Documenter build; and `show` on a terminal narrower
  than its widest line, which no `show` here adapts to. The reviewer did
  not read the tests added after its report or the docs fix. The session
  ran its six mutants against them itself.
- **One test robustness limit.** The parity test splits a chart line at
  the character index of the ruler's zero. That holds while every label
  character is one column wide, as the fixtures' are. `show` itself pads
  by `textwidth`.

## 6. Open for the user

1. **Whether `show(::Deployment)` prints its `Δt_base` against the
   coarsest admissible one.** D-466 left it to this rewrite. The
   inspector's page shows the comparison on a deployment. A candidate is
   one line under the block's heading, such as `Δt_base: 1//500, the
   coarsest admissible 1//50 over 10`, with no line for a structure with
   no anchors. The anchors' `Dₖ` and `Φₖ` already let a reader see a
   common factor, so the line would state what the table implies. The
   session leans to printing it, weakly. It is an item of `pending.md`.
2. **The diff-verify of this part**, then the push of the arc.
3. **The frame tops' wording and glyphs in real use.** Rulings 7 and 8
   were made on a probe's output. The tests pin them, so a change is one
   edit and its literals.
4. **`hyperperiod 1 base ticks`**, a one-line fix that changes
   `show(::Schedule)`'s text at a hyperperiod of 1.
5. **Whether the schema states the order of `schedule.scopes`**, as it
   does for the anchors and the rows. The writer already keeps the
   structure's order.
6. **Whether §13.9's parity sentence should name the seconds and the
   joint period** among what a client computes.
7. **The chart-omitted line's wording**, decision 3.2, against the
   `Schedule`'s.

## 7. Where things are

- The prototype's worktree: `Redstone.jl-worktrees/show_deployment`, at
  `105747e` with the patch applied.
- Its probes, logs, mutant script and the patch:
  `Redstone.jl-worktrees/show_deployment_probes/`. `probe_render.jl` and
  `probe_literals.jl` print the block on every lattice shape the tests
  pin.
- The reviewer's worktree and probes:
  `Redstone.jl-worktrees/show_deployment_review` and
  `Redstone.jl-worktrees/show_deployment_review_probes/`.
- All four can be removed once the user has verified the diff.

## 8. The user's answers to section 6, 2026-11-21

1. **Item 1: `show(::Deployment)` prints its `Δt_base` against the coarsest
   admissible one.** Its form waits for the user's word on a rendered
   candidate, `probe_admissible.jl` among the probes.
2. **Item 4: fixed.** `hyperperiod 1 base tick` takes the singular in the
   `Schedule`'s two forms, on its chart's heading and on the deployment's
   block, in the commit that adds this section.
3. **Item 5: the user asked for a recommendation** on stating the order of
   `schedule.scopes`.
4. **Item 6: fixed** in `121da1a`. §13.9's parity sentence names each
   schedule row's exact seconds and the deployment's chart over the joint
   period, with an annotation on D-467.
