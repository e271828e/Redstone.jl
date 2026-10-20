import sys
sys.dont_write_bytecode = True
sys.path.insert(0, "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/scratch_step5/fix2")
from fixlib import Fixer, ROOT

f = Fixer()
E = f.edit

# Unit F
E("P2-2", "F", "[Worked](#g-worked), the cruise case of Flight.jl's Cessna 172 model (`c172.jl`) reduces to its three-equation core.",
  "The problem below is [worked](#g-worked) (spelled in full against a concrete case). It is the cruise case of Flight.jl's Cessna 172 model (`c172.jl`), reduced to its three-equation core.")
E("P2-1", "F", "Decision variables, initial guess and box bounds are plain, same-*named*, all-`Float64` NamedTuples. FlightPhysics'",
  "FlightPhysics'")
E("P2-3", "F", "exactly as `condition` already holds it, and the framework never sees it.",
  "exactly as `condition` already holds it.")
E("P2-4", "F", "[§8.2][s8-2] gives the [value-level constructor](#g-value-level-constructor) (the plain exported function building a field handle from the component and input values) that builds such a handle, and [§14.1][s14-1] the pre-sweep doctrine.",
  "[§8.2][s8-2] gives the [value-level constructor](#g-value-level-constructor) that builds such a handle, a plain exported function of the component and its input values. [§14.1][s14-1] gives the pre-sweep doctrine.")
E("P2-5", "F", "canonical for the r-side", "canonical for the residuals")
E("P2-7", "F", "A model that a simulation has claimed", "A `Model` that a simulation has claimed")
E("P2-8", "F", "(an aircraft-shipped, full-coverage condition function)",
  "(a full-coverage condition, such as an aircraft-shipped function returns)")
E("P2-9", "F", "It fills `J` iff `J !== nothing`.", "It fills `J` exactly when `J !== nothing`.")
E("P2-9", "F", "so LM's damping loop tests exactly", "so the damping loop of Levenberg–Marquardt (LM) tests exactly",
  note="LM is introduced at its first use in §14.8; the bold at the default-backend sentence is left untouched.")
E("P2-10", "F", "That objective is dimensionless where the threshold", note="Rewrap only.")
E("P2-10", "F", "which Flight.jl's trim leaves inferable", note="Rewrap only.")
E("P2-12", "F", "set is built from the [activation](#g-activation)'s *layout* (the build's typed products at a given scalar type).",
  "set is built from the *layout* of the [activation](#g-activation) (the build's typed products at a given scalar type).")
E("P2-49", "F", "the discrete [tier](#g-tier) is frozen",
  "the discrete [tier](#g-tier) (the discrete side of the hybrid formalism) is frozen")
E("P2-49", "F", "no [projection](#g-projection), no [guards]",
  "no [projection](#g-projection) (the per-component `x_projection` hook), no [guards]")
E("P2-13", "F", "No scratch cell holds the [probe](#g-probe)'s synthesized values. That is the [§14.6][s14-6] barrier reaching the scratch world",
  "No scratch cell holds a synthesized [probe value](#g-probe-value) (a fabricated value a build-time probe runs on). That is the probe-value barrier of [§14.6][s14-6] reaching the scratch world")
E("P1-37", "F", "The iterations are untouched. They are raw write → sweep → read cycles at the seeded activation, over the continuous chain and `x_deriv` alone ([§14.5][s14-5]).",
  "The iterations are untouched ([§14.5][s14-5]). They run at the seeded activation, over the continuous chain and `x_deriv` alone.",
  note="\"At the seeded activation\" stays: §14.5 says only \"on the activation\".")
E("P2-14", "F", "The zero-decision problem (below)", "The empty problem (below)")
E("P2-15", "F", "The commit applies the same composite over the same `baseline` (`override(baseline, condition(d*))`, [§14.9][s14-9]), so its coverage is setup's.",
  "The commit (below) applies the same composite over the same `baseline`, so its coverage is setup's.",
  note="Fitted: \"(below)\" sits on \"the commit\", which \"The commit, in full\" states, not on `baseline`.")
E("P2-16", "F", "the no-throw doctrine needs no exception", "the no-throw rule (below) needs no exception")
E("P2-17", "F", "Flight.jl's warn-but-assign is structurally impossible.",
  "Flight.jl's warn-but-assign, where the Cessna 172 trim warns on a failed optimization and assigns its result anyway, is structurally impossible.",
  note="Checked ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172.jl 934-939: @warn on a failed optimization, then AircraftBase.assign!.")

# Unit G
E("P2-19", "G", "is the natural shape of unattended mode.",
  "is the natural shape of an [unattended run](#g-unattended-run) (a run with empty staging and no snapshot readers).")
E("P2-20", "G", "Fly-then-retrim is spelled as a `checkpoint` of the flight, then a trim baseline authored from what the [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value) shows",
  "Fly-then-retrim is spelled as a [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value) of the flight, then a trim baseline authored from what the checkpoint shows")
E("P2-22", "G", "of an offset [component](#g-component) therefore",
  "of a [component](#g-component) whose schedule has a nonzero [phase](#g-phase) (an offset against its grid) therefore",
  note="The phase gloss is the glossary's (\"a schedule's offset against its grid\").")
E("P2-23", "G", "which is the point a `linearize` at its default operating point reads.",
  "which is the point a `linearize` at its default operating point ([§14.10][s14-10]) reads.")
E("P2-23", "G", "and a `linearize` at its default operating point ([§14.10][s14-10]) reads that point.",
  "and that is the point `linearize` reads by default.",
  note="Fitted: the dictated \"the point it reads\" leaves \"it\" with no antecedent.")
E("P2-25", "G", "It gated the commit, at the solved point, and the numbers ([D-150][d-150]) stand as reported.",
  "It gated the commit at the solved point, and the numbers stand as reported ([D-150][d-150]).")
E("P2-26", "G", "In an envelope of trims, hitting", "When trims span the flight envelope, hitting",
  note="Fitted: the dictated \"a sweep of trims\" would bring back *sweep*, which F66 took out of this sentence.")
E("P2-13", "G", "The degenerate problem is the \"is this operating point an equilibrium?\" probe.",
  "The empty problem asks \"is this operating point an equilibrium?\"",
  note="Also P2-14 (\"the empty problem\").")
E("P2-11", "G", "A migration audit of Flight.jl's Cessna 172 model (`c172.jl`) against",
  "A migration audit of Flight.jl's Cessna 172 model against",
  note="Fitted to R15, which introduces the audit as Flight.jl's Cessna 172 model: only the repeated (`c172.jl`) goes.")
E("P2-27", "G", "make Jacobian entries piecewise-constant", "make Jacobian elements piecewise-constant")
E("P2-46", "G", "The services unify as clients of one", note="Rewrap only.")
E("P2-29", "G", "enters each `Scoped` wrapper and prefixes",
  "enters each `Scoped` wrapper (the node `at` builds over a condition node) and prefixes",
  note="Checked src/conditions.jl 28 and 94: at(prefix, node) returns Scoped(prefix, node).")
E("P2-29", "G", "**A read set carries its mount chain as data** ([D-277][d-277]). `at(prefix, read_set)`",
  "**A read set carries its mount chain as data** ([D-277][d-277]). A read set is a `Reads` value. `at(prefix, read_set)`",
  note="Also P2-46: the rewrap rejoins the bold split across lines.")
E("P2-30", "G", "how worlds, thin rigs and swarms use the lift.",
  "how worlds, thin rigs (worlds holding only the aircraft and its environment) and swarms use the lift.",
  note="Fitted: the gloss goes at the first use of \"thin rig\" in §14.9, the context paragraph, which also keeps it out of a sentence that already has a gloss. D-364 does not define the term; the glossary's design_world, the shipped thin world, is the aircraft plus an atmosphere and a terrain.")
E("P2-31", "G", "Flight.jl's `f_init!(::Model{<:SimpleWorld})` (initialize environment, then call the aircraft's trim) has no successor method.",
  "FlightPhysics' world initializer, its method of FlightCore's `f_init!` on a FlightCore `Model{<:SimpleWorld}` (initialize environment, then call the aircraft's trim), has no successor method.",
  note="Checked ~/.julia/dev/Flight.jl/lib/FlightPhysics/src/world.jl 49 (Modeling.f_init!(world::Model{<:SimpleWorld}, ...)) and lib/FlightCore/src/modeling.jl.")
E("P2-30", "G", "\"Aircraft as root\" is a thin world.", "\"Aircraft as root\" is a thin rig.")
E("P2-33", "G", "(trim lead, commit, trim wing against the committed world)",
  "(trim the lead aircraft, commit, trim the wingman against the committed world)")

# Unit H
E("P2-34", "H", "a seed is written into a whole state field or root input, or into",
  "a seed is written into a whole state field or [root input](#g-root-input) (the root's own input face), or into",
  note="Also P2-46: the rewrap evens the ragged lines.")
E("P2-36", "H", "The frozen tier's only possible partials are zeros, and the rejection's",
  "The discrete tier is frozen ([§8.2][s8-2]), so its only possible partials are zeros. The rejection's")
E("P2-20", "H", "**The default operating point is the [checkpoint](#g-checkpoint)** (the model's state at a frame top as one value) of the simulation or the model as it stands ([D-274][d-274], [D-319][d-319]). It is `checkpoint(sim)` on a simulation and `checkpoint(model)` on a [`Model`](#g-model) (a deployment materialized at one scalar type), each",
  "**The default operating point is the [checkpoint](#g-checkpoint)** of the simulation or the [`Model`](#g-model) (a deployment materialized at one scalar type) as it stands ([D-274][d-274], [D-319][d-319]). A checkpoint is the `Model`'s state at a frame top as one value. It is `checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`, each",
  note="Also P1-38 (the shared gloss). Fitted: \"the model\" becomes `Model`, so the `Model` link and gloss move to that first use, and the checkpoint gloss takes its own sentence so it does not follow the `Model` gloss.")
E("P2-37", "H", "**`width` is a keyword of `linearize`, default 8**, and the default width's scalar type is public, so a build can pre-materialize its [activation](#g-activation) (the build's typed products at a given scalar type) through `activations` ([§9.4][s9-4]) and a tap set of any size then linearizes with no compile at the keyboard ([D-272][d-272]).",
  "**`width` is a keyword of `linearize`, default 8** ([D-272][d-272]). The default width's scalar type is public. A build can therefore pre-materialize its [activation](#g-activation) (the build's typed products at a given scalar type) through `activations` ([§9.4][s9-4]), and a tap set of any size then linearizes with no compile at the keyboard ([D-272][d-272]).",
  note="D-272 is repeated on the last sentence: the split separates the claims from their citation.")
E("P2-38", "H", "four `FiniteDiff` jacobians", "four `FiniteDiff` Jacobians")
E("P2-34", "H", "and so do unseeded [root inputs](#g-root-input) (the root's own input faces) ([D-072][d-072]).",
  "and so do unseeded root inputs ([D-072][d-072]).")
E("P2-39", "H", "([§8.2][s8-2]; [D-168][d-168])", "([§8.2][s8-2], [D-168][d-168])")
E("P2-41", "H", "**FlightPhysics' `LinearizedSS` the [*component*](#g-component) survives separately, as an ordinary [continuous component](#g-continuous-component)**",
  "**FlightPhysics' `LinearizedSS`, the [component](#g-component), survives separately, as an ordinary [continuous component](#g-continuous-component)**")
E("P2-42", "H", "`c172x_ctl` LQR pipeline", "`c172x_ctl` LQR (linear-quadratic regulator) pipeline")
E("P2-42", "H", "the one built on NED kinematics.", "the one built on north-east-down (NED) kinematics.")
E("P2-30", "H", "(the thin world that mounts an aircraft", "(the thin rig that mounts an aircraft",
  note="Also P2-46: the rewrap evens the ragged lines.")
E("P2-42", "H", "(a ZOH constant with zero partials)", "(a zero-order-hold constant with zero partials)",
  note="Fitted: the abbreviation is spelled out rather than glossed, since a gloss would nest parentheses; also P2-10 and P2-46 (rewrap).")
E("P2-42", "H", "needs saltation corrections.",
  "needs saltation corrections (the jump terms a sensitivity takes across an event).")
E("P2-42", "H", "continuous linearization plus Tustin.", "continuous linearization plus Tustin's discretization.")
E("P2-42", "H", "An opaque wrapper (an FMU, a C aerodynamic table) and a deliberately severed coupling",
  "An opaque wrapper, such as an FMU (a Functional Mock-up Unit, a packaged external model) or a C aerodynamic table, and a deliberately severed coupling",
  note="Fitted: the FMU gloss would nest inside the old parentheses, so the examples become a \"such as\" clause; also P2-10 (rewrap).")
E("P2-43", "H", "It evaluates at the value, obtains a local Jacobian by whatever means it has, a finite difference at a step its own grid suggests or the table's analytic slope, and chains it onto the incoming partials ([D-266][d-266]).",
  "It evaluates at the value and obtains a local Jacobian by whatever means it has, such as a finite difference at a step its own grid suggests or the table's analytic slope. It then chains that Jacobian onto the incoming partials ([D-266][d-266]).")
E("P2-44", "H", "The stripping happens mid-expression, which [§9.5][s9-5] leaves legal at an unpinned leaf",
  "The block strips the partials with `ForwardDiff.value` mid-expression, which [§9.5][s9-5] leaves legal at an unpinned leaf")
E("P2-45", "H", "remaining tooling over that visibility.", "remaining tooling over the schema's declared non-participation.")

HEADER = """# Chapter 14, step 5: the editorial fixes, half 2 (units F, G and H)

Each entry gives the finding, the unit, and the old and new text of the
edited paragraph or bullet, verbatim. Replay them in order on the verified
commit `b187775`: an entry's old text is the file as the entries before it
left it. Every edited paragraph is rewrapped to 80 rendered columns (link
markup collapsed), so the old and new blocks are whole paragraphs.

The last entry, P2-18, is not a paragraph edit: it deletes the blank line
that ends `units/F/new.md`, so one blank line, not two, falls at the F/G seam
of the assembled chapter.
"""
f.save(f"{ROOT}/chapter_fixes_2.md", HEADER)

# P2-18: drop F's trailing blank line.
p = f"{ROOT}/units/F/new.md"
t = open(p).read()
assert t.endswith("[D-223][d-223]).\n\n"), repr(t[-30:])
open(p, "w").write(t[:-1])
with open(f"{ROOT}/chapter_fixes_2.md", "a") as log:
    log.write(f"\n## {len(f.log) + 1}. P2-18, unit F, the end of the file\n\n"
              "Old: the file ends `[D-223][d-223]).`, a newline, then an empty line (`\\n\\n`).\n\n"
              "New: the file ends `[D-223][d-223]).` and one newline (`\\n`).\n")
print("applied", len(f.log) + 1)
