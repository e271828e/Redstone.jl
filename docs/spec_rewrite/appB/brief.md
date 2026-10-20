# Appendix B: the rewrite brief

Appendix B thinned to an index, as `../appendices.md` plans ("Appendix B:
thin it, don't polish it"). Two units, B1 and B2, each rewritten by one
agent and verified blind by another. The chapter recipe's standing part,
`../checks/brief_common.md`, applies with the deviations below.

## Base and files

- Base commit `e6a4fcb`. Frozen copies, read these and never the working
  tree, which another session edits: `<S>/frozen/spec.md`,
  `<S>/frozen/decisions.md`, the outline `<S>/frozen/spec_outline.txt`, and
  the repository at that commit in `<S>/frozen_tree/` (its `src/` is the
  code B lists). `<S>` is the scratchpad directory the launch prompt names.
- `units/B1/old.md` is frozen spec lines 13371 to 13641: the heading, the
  lead paragraph, Authoring, the bundle table, Build, and the old
  "Deployment" group through the panel kit. `units/B2/old.md` is lines
  13642 to 13846: the condition algebra, the stopped-sim services, Running,
  and the closing `---` rule. Each `new.md` replaces exactly its span; B2's
  keeps the rule.
- `homes.md` is the frozen spec with Appendix B cut out and the one move of
  R6 applied. It is where every claim B drops is found.
- The survey is `survey/R1.tsv` to `survey/R4.tsv`: one row per sentence or
  clause of old B, classed 1 (name), 2 (duplicate of a home), 2d (drifted
  duplicate), 3 (stated nowhere else) or X (framing), with the home's
  frozen line. R1 and R2 cover B1, R3 and R4 cover B2. Their line numbers
  are frozen-spec numbers. In `homes.md` a frozen line after 8733 sits one
  line later, and one after 13846 sits 475 lines earlier. `survey/signatures.tsv` checks
  every signature against `src/`. The survey is evidence, not a ruling:
  where a row is wrong, say so in `rulings.md`.
- Tools, run from `docs/spec_rewrite`: `python3 checks/check_unit.py appB
  show-old B1`, and `python3 checks/build_inventory.py appB B1`.

## The thin shape

**R1. Every entry is a signature, a gloss and its citations.** The
signature is spelled as `src/` spells it, with every keyword and its
default. The gloss is one sentence, two at most, of at most 30 words, that
says what the entry is for. The citations name the owning section, and the
ruling entry wherever the section does not carry the gloss. Everything
else a class 2 row holds is dropped: its `claims.md` block is tag `M`,
`where: homes.md`, and `new:` the home's own span, verbatim from the
normalized home. Find the span from the survey's `home_line`; when the
survey's home does not hold the claim, find the one that does or keep the
claim and report it.

**R2. Keyword tables stay**, as `| keyword | default | meaning | owning
section |`, since readers look keywords up and the spec's own sentences
point here for the defaults. The meaning cell is a gloss of at most twelve
words; the rest is `M` to its home. These spec sentences cite B for
something B must keep: frozen 5626 (`Model` construction binds the
algorithm), 6043 (the `Deployment` keywords), 7037 (`log_every`), 7048
(`init!`'s and `run!`'s defaults), 7056 (the four recording keywords on
`init!` with their defaults), 7810 (the header's `Deployment` and `t₀`),
7845 (`init!`'s `trace` keyword), 8733 (`pace` and `margin` defaults), 8969
(`join_timeout`'s default), 9369 (the doors' recording keywords), 14108
(the constructors' keywords validate under `ArgumentInvalid`), 14870 (the
`Model` block lists the model's entry points).

**R3. The bundle table stays verbatim.** Its footnote paragraph collapses
to one or two sentences: each field is present only if it exists for the
component, by §5.2's bundle law, and the returns follow §5.2's three rules,
the handler's `(; x, m)` under the return law. Cite §5.2, §7.1 and D-090
(the return law's entry; the old bold had no citation). The bold goes.

**R4. Labels.** The bold group lead-ins become `####` topic labels:
Authoring, Build, Deployment and the model, The simulation and its devices
(from `Simulation(model; …)` through the panel kit), Condition algebra,
Stopped-sim services, Running. "Sides are declared" and every other bold in
B goes: B states no ruling, and each is bold in its owning section. B1
writes the first four labels, B2 the last three. No `####` anchor of B is
linked from anywhere; the only inbound link is `[sB]`.

**R5. The `Model` block is B's by design.** Appendix D's `Model` entry
says the model's entry points "are listed in the `Model` block of
Appendix B" (frozen 14870), and D-319's Rationale places `apply!` by B's
sentence. So the block's class 3 rows stay in B, thin, each citing the
entry that rules it (D-317, D-318, D-319; the survey names which): `init!`
on the model and its hooks, `frame!` with `FrameHooks`, `frame_top!`,
`settled!` and `NoHooks()`, the reads `port`, `state` and `modes`,
`warnings` on the model, `checkpoint(model)` off the grid, the stepping
primitives and `apply!` outside the API, the `:claimed` and `:not_built`
reasons, and the convenience forms' keywords. Two corrections ride:
"framework internals the spec names only as mechanisms" is false, since no
spec sentence names the five, so say "framework internals" (D-318); and
the `MethodError` sentence goes, since the typed signature
`Simulation(model::Model{Float64}; …)` and §9.2's "the constraint sits as
a type on the one constructor" carry it.

**R6. The other class 3 rows.**

- R1-04, "Every name here is public by being here": it is about B, so it
  stays in the lead, cited to D-226 (its Position states it).
- R3-21, "`t0` is any real": the signature spells `t0::Real`; keep "held
  as a `Float64` origin" with D-260.
- R3-78, `linearize`'s `t0` "(default `0.0`)": open for the owner. Keep
  the default in the signature as `src/` has it, and the claim as it
  stands, and list it under Open questions.
- R4-13, the harness-and-CI sentence: moved to §12.1, already applied in
  `homes.md` (after "`margin` to 2 ms"). Tag `M`.
- R4-50 and R4-52, `stop!(sim)` and `stop!(handle)`: names, so they stay,
  cited to D-268.
- R4-73, "on-disk persistence is deferred, `pending.md`": dropped, `M` with
  `where: docs/design/pending.md` and its span "The in-memory artifacts are
  settled (§11.2, §11.5) and nothing on-disk is."

## Corrections

**R7. Every 2d row is corrected to its home's version**, or dropped as `M`
when the thin shape no longer needs it. Tag `R`, ruling R7. The rows:
R1-49 (`Structure` holds no faces), R1-84 (`log_max` bounds the log, not
the session), R2-55 (four doors take the recording keywords, `overlay!`
included), R2-95 (only `loop` is mandatory; `init!`, `shutdown!` and
`unblock!` are optional hooks, D-366), R3-18 (the baselines are separately
named condition functions, not `condition` methods, and the package ships
none, so B names none), R3-36 and R3-37 (`log`, `log_every` and `log_max`
are the view policies replay neither records nor compares; `trace` is the
primary record's switch), R3-38 (`backend = LevenbergMarquardt()`, on both
`trim!` rows), R3-39 (least squares with exact Jacobians is the default),
R4-05 (any of the four doors opens the run, not only `init!`), R4-06 (with
identical input traces), R4-19 (`UnboundedRun` fires in `:live` only), R4-22
(`step!` never waits on the pacer; it blocks while paused), R4-41 (the
§9.8 measurement seam, homed in §9.7), R4-62 (the trace is on by default),
R4-69 (the halt leaves the simulation `initialized`).

**R8. Signatures follow `src/`** (`survey/signatures.tsv`). `Deployment`
lists `h` and `N_base` with no default: `h` is required (refused as
`DeploymentInvalid` when absent) and `N_base` is 1 when `Δt_base` is absent
and derived otherwise; its table says so. `step!`'s `frames` stays
`frames = 1`, its meaning in `src/`. `attach!`'s third argument is
`new_binding`, as §11.6 spells it; show its return if `src/`'s docstring
gives one. `orphaned(record)` and `stale(record; now)` are functions on the
record `incumbent_status` returns, not fields. Check `init!`, `overlay!`
and `linearize`'s optional arguments against `src/` and spell them as it
does. Any other mismatch you find goes in `rulings.md`; fix it only if the
spec's owning section agrees with `src/`.

**R9. The carried fixes.** The `Model` rows' "door" becomes "entry point"
(*door* is reserved for an entry point that builds a run, and a model's
`init!` builds none); "writing door" becomes "an entry point that writes".
"Requester roster" takes its link, `#g-requester-roster`. The handler
return law cites D-090 (R3).

## Additions

**R10. Names B omits**, each one entry in the thin shape under the group
it belongs to, each with an `added:` block in `claims.md` naming the spec
sentence or `src/` docstring it rests on. A gloss claims nothing its
source does not state.

- `AbstractComponent`, the one root type (Authoring; §8.1, D-039).
- `Relative` and `Absolute`, the `sample_times` entries, with `Hz` and
  `Period` (Authoring; §8.6 and §9.2; grep `Absolute(Hz`).
- `get_deriv`, beside `get_state`, `get_input`, `get_output` and
  `get_face`, as the selector family (B2's `taps` entry or a selector line;
  §14.4, grep `get_deriv(path`).
- `reads(; selectors...)`, the read set `series` takes and `at` mounts
  (B2; §11.2 at frozen 7131, D-407). Note in `rulings.md` that `reads` is
  also the binding trait `reads(b)`: one name, two senses, for the audit.
- `logged(sim)`, the retained snapshots (B2's post-run entry; §11.2 and its
  `src/` docstring; the spec spells no accessor, so say so in
  `rulings.md`).
- `termination(sim)`, the termination record, with `EndTimeReached` and
  `ModelRequestedStop` among its sources (B2; §12.6 and §13.5, frozen
  10773 to 10778, and the `src/` docstring).
- `port(snapshot, path, name)` beside `port(model, path, name)`, and the
  `Simulation` forms of `port`, `state` and `modes` (B1; `src/dataplane.jl`
  and `src/sim.jl` docstrings; the spec spells none of them, so say so).
- `stop!(handle)` on the handle's capability list (B1; §11.6, D-268).
- `RK4` and `Heun`, the shipped algorithms (B1, the `algorithm` row;
  §10.2, frozen 5613).

Listing a name is this rewrite's; exporting or renaming it is the
exported-name audit's.

## Length and links

**R11. Length.** Old B1 is 2,331 words and B2 1,898. Aim at half, after
the additions. A gloss that cannot fit is a sign the claim is a home's.

**R12. Glossary links.** B is one section: each term takes one link, at
its first use in B. B1 links the first uses in its half. B2 links a term
only if `units/B1/old.md` never uses it; list in `rulings.md` each term
you left unlinked for that reason. Link only anchors Appendix D declares
(`grep -n 'id="g-' <S>/frozen/spec.md`).

## What you produce

As `brief_common.md` says: `units/<U>/new.md`, `units/<U>/claims.md` run
to `checks failed: 0`, and `units/<U>/rulings.md`. Reply in under 150
words with the checker's last line, the counts of claims by tag and of
additions, the new word count, and every open question.
