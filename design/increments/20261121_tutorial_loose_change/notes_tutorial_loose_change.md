# Notes: the tutorial's loose change

The second bullet of `pending.md`'s work order, owed before the tutorial's
increment 3 by L12 and L23 of
`../20261119_tutorial_pages/notes_tutorial_pages.md` and by item 10 of that
file's section 6. It began as a loose change in three parts and grew in the
design session of 2026-11-21, so it runs as one small increment with no
brief. This file is its record. Today it holds the state, the rulings, what
the probes found, the friction, the prototype's charge and what is open.
The shape built, the measurements, the pins with their mutants, the
bookkeeping and the cold review's charter join it when the prototype
settles.

The three parts keep their numbers from the session:

1. compact `show` methods for `Simulation`, `Series`, `TrimReport` and,
   by T9, `Linearization`;
2. a `Series` that forwards its columns as properties;
3. labelled access to a `Linearization`'s matrices.

## 1. The state on 2026-11-21

- The design is settled except for the printed layouts, which the user
  has yet to judge on the output of section 8.
- The increment has landed on the real tree, unpushed: the docs as
  `d382b00`, the code as `23458b8`, the patch beside this file applied
  unchanged, and the cold review's fixes as `7410031`. Two small commits
  stand beside them, `623dbc5` for this file and one that renames a
  testset. The gate reads 10870 of 10870 at `7410031`, and the examples'
  runner 179 of 179 at `23458b8`. The cold review has closed, with its
  record in sections 11 and 12.
- What waits for the user: the four printed forms of section 8, the
  session's own decisions S1 to S13 in section 7, the wording of D-474,
  D-475 and the two spec passages, the open points of section 12, the
  diff-verify and the push.
- The peer finished at `505dd28` and released the tree. Both patches pass
  `git apply --check` there.
- **The peer.** The session `group-promotion` works on the same tree. Its
  tip is `108e26a`, which makes `Group` the core's assembly form (D-472,
  D-473). Three commits are still to come there, each with a gate on the
  real tree: A, the move of `Group` to the core; B, a copy constructor
  `Group(g; ...)`; C, wire keywords that take a function of the `Group`.
  A cold review and a possible fix commit follow. It messages this
  session with the hash of its last commit.
- **What the two sessions agreed**, by message:
  - This session edits no tracked file and runs no Julia against the real
    tree until the peer's last commit is in. This folder is untracked and
    was cleared with the peer.
  - The one shared file is `examples/test/test_longitudinal.jl`. The peer
    edits one `Group(...)` call in the chapter 6 testset, near line 399.
    This increment stays clear of that testset.
  - In `design/code_map.md` the peer edits the entries of `src/assembly.jl`
    and `src/library.jl`, and this increment the entries of `src/sim.jl`,
    `src/linearize.jl`, `src/show.jl` and the new `ext/` folder.
  - This increment takes D-474 and D-475.
  - From commit A on, `Group` is imported from `Redstone`, and
    `Redstone.Library` no longer defines it. The pages, tests and probes
    of this increment follow.
  - This session warns the peer before any agent of its own runs a gate,
    since a worktree's gate shares the machine's cores with the peer's.
- **The worktree** is
  `/Users/miguel/.julia/dev/Redstone.jl-worktrees/tutorial_loose_change`,
  detached at `336a79e`, the peer's commit A, by the user's ruling. The
  root `Manifest.toml` is copied in. The prototyper was launched there on
  2026-11-21, and the peer was told first. Its launch prompt is
  `tutorial_loose_change_prompt.md` beside the worktree, and its own notes
  are `tutorial_loose_change_notes.md` there.
- **The probes** are
  `/Users/miguel/.julia/dev/Redstone.jl-worktrees/tutorial_loose_change_probes/`,
  each script with its output beside it. Section 3 reads them.
- The coordinator stood at 175k tokens when the rulings closed.
- **The delegation.** The user read this file on 2026-11-21, found it
  good, and left with the instruction to work autonomously and to record
  findings and decisions for a later review. Section 7 takes the
  session's own decisions from that point on. Nothing is pushed.

## 2. The rulings

The user's, of 2026-11-21, unless marked. Each alternative under
"Rejected" was weighed in the session.

**T1. One small increment, delegated by stage and not by part.** One
prototyper, one cold reviewer and one fixer, by `rules/increment_rules.md`.
Rejected: parts 1 and 2 as loose fixes and part 3 as an increment. Part 1
takes rulings on its layouts, and two of its methods print what parts 2
and 3 build. Parts 2 and 3 sweep the same pages and the same test file.
Three landings pay three gates.

**T2. The code lands as one commit after one docs commit.** The
coordinator's default, which the user did not change. One commit per part
stays possible if the prototyper commits in that order in its worktree.

### Part 2

**T3. A `Series` forwards its columns as properties**, by L23. The four
fields stay, and `propertynames` lists them before the labels:

```julia
function Base.getproperty(s::Series, name::Symbol)
    name in (:t, :frame, :boundary, :columns) && return getfield(s, name)
    getfield(getfield(s, :columns), name)
end
Base.propertynames(s::Series) = (:t, :frame, :boundary, :columns, keys(getfield(s, :columns))...)
```

**T4. A reserved label is refused as a `ReadSetMisuse` with a new
reason**, `:reserved_label` unless Appendix C suggests a better name. The
refusal sits in `series` and not in `reads`, since trim's read set may
label an entry `t`. Rejected: a diagnostic kind of its own.

**T5. L23's measurement is the prototype's first probe.** It times what
the forwarding method costs to compile per label set, through the real
entry point in a fresh process, and checks that `flight.V` infers inside
a function. The prototyper stops and reports if the figure is bad.

### Part 3

**T6. Labelled access comes from a ComponentArrays extension.** The
package is a weak dependency, and `Project.toml` gains its first
`[weakdeps]` and `[extensions]`. Rejected:

- *A small label-carrying matrix type in the core.* It reinvents a part of
  ComponentArrays and loses its labels at the first broadcast.
- *A type of our own with algebra that checks agreement.* It is the only
  version that would fix T12's finding, and it is most of a labelled-array
  package, kept in the core for a convenience.
- *ComponentArrays as a hard dependency.* Every user loads it, and a 0.x
  package's type sits in the return of a public function.
- *An extension that changes what `linearize` returns.* The return type
  would depend on what else the session has loaded.
- *AxisKeys*, which refuses disagreeing labels. Its lookup by label uses
  round brackets, and the user knows ComponentArrays. Section 3 has the
  comparison.

**T7. The converter is `labeled(linearization)`.** The core declares the
function with no methods and the extension adds one. It returns a
`Linearization`, so one value carries the operating point, the labels and
the matrices in both forms. The spelling is the repo's: "labeled" stands
12 times in the spec and 26 in `src/`. A participle fits none of §8.1's
four shapes, which is the exported-name audit's to weigh. Rejected: a
NamedTuple of the four matrices, which drops the operating point and
prints through no method of ours.

**T8. Without ComponentArrays loaded, `labeled` answers with an error
hint** that names the package. Rejected: a fallback method in the core,
which the extension would have to overwrite.

**T9. A `Linearization` holds plain arrays in the plain form and component
arrays in the labelled form.** The four operating-point fields become
`AbstractVector{Float64}` and the four matrices `AbstractMatrix{Float64}`.
The three label tuples stay in both forms.

```julia
struct Linearization
    ẋ₀::AbstractVector{Float64}
    x₀::AbstractVector{Float64}
    u₀::AbstractVector{Float64}
    y₀::AbstractVector{Float64}
    A::AbstractMatrix{Float64}
    B::AbstractMatrix{Float64}
    C::AbstractMatrix{Float64}
    D::AbstractMatrix{Float64}
    x_labels::Tuple{Vararg{Symbol}}
    u_labels::Tuple{Vararg{Symbol}}
    y_labels::Tuple{Vararg{Symbol}}
end

# ext/RedstoneComponentArraysExt.jl
function Redstone.labeled(l::Linearization)
    x, u, y = Axis(l.x_labels), Axis(l.u_labels), Axis(l.y_labels)
    Linearization(ComponentVector(l.ẋ₀, x), ComponentVector(l.x₀, x),
                  ComponentVector(l.u₀, u), ComponentVector(l.y₀, y),
                  ComponentMatrix(l.A, x, x), ComponentMatrix(l.B, x, u),
                  ComponentMatrix(l.C, y, x), ComponentMatrix(l.D, y, u),
                  l.x_labels, l.u_labels, l.y_labels)
end
```

This supersedes D-272's bullet on the return, which holds the four
vectors as NamedTuples. D-272 gives no reason for them and does not weigh
plain vectors. The reasons for the change:

- Today's value is mixed. The vectors carry labels and cannot do
  arithmetic, and the matrices do arithmetic and carry no labels.
- The plain form does the affine model, `ẋ₀ + A * (x - x₀)`, with no
  `collect`.
- In the labelled form all eight arrays stand on the same axes, so
  operands the framework hands over always agree.

The cost, accepted: the plain form loses reading by name, so
`linearization.ẋ₀.θ` becomes `linearization.ẋ₀[1]`. About 15 lines of
`test/test_linearize.jl` change to positional comparisons, with the label
tuples pinned beside them. The core tests do not load the extension.

Rejected:

- *Type parameters for the matrices.* A `ComponentMatrix` holds its axes
  in its type, so `A`, `B`, `C` and `D` are four concrete types and need
  four parameters. Every method taking a `Linearization` would then
  compile per label set. With abstract fields a parameter buys only
  concrete inference of `linearization.A`, which design code that runs
  once does not need.
- *NamedTuples in the plain form beside component vectors in the labelled
  one*, under a `Union` field type. It keeps the mixed value.

**T10. A `y` tap on a leaf that is not a `Float64` converts.** The `x` and
`u` taps are `Float64` already, and `ẋ₀` follows. The `y` list admits any
`Real` leaf, so a `Bool` or an `Int` sits in `y₀` today with its own type.
It becomes `Float64(value)`. That tap's rows of `C` and `D` are zeros
already, and `y₀` enters the affine model as a float. A test of such a tap
is added, since none was found. Rejected: refusing the tap, which removes
a readout that works.

**T11. No `subsystem` function is added.** The labelled form slices by
label, `A[(:V, :γ), (:V, :γ)]`.

**T12. ComponentArrays computes by position, and the log entry says so.**
It does not check that two operands' labels agree. Section 3 has the
evidence. The user expected a check, and a reader will too.

**T13. The tutorial uses the labelled form from chapter 3 on**, the
finite-difference block included. The docs environment gains
ComponentArrays. Where the labelled form first appears, the page says in
one sentence that the arithmetic goes by position. Rejected: staying
positional, as `V, γ, θ, q, h = 1:5` does today.

### Part 1

**T14. `show(::Linearization)` joins the three methods of L12.** It prints
each matrix as a table under the row and column labels, read from the
label tuples by integer index, so one method serves both forms. It needs
neither the extension nor T9. ComponentArrays prints its own matrices with
bare rows.

**T15. The four layouts are ruled on the prototype's real output**, the
tutorial's own calls run through the methods. The coordinator's leans,
which the user accepted as starting points:

- a `Simulation`'s REPL form shows its deployment's one-line form, since
  every page opens with `sim = Simulation(...)` and the full block would
  repeat on each;
- a `Series` prints each label with its element type and no summary of
  values, since a column holds any leaf type.

## 3. What the probes found

All on Julia 1.13.3, in scratch environments that do not load Redstone,
the last one excepted.

**ComponentArrays 0.15.50 on the tutorial's call sites**
(`componentarrays/probe1_call_sites.jl`). It has 10 direct dependencies,
and a fresh environment's manifest holds 28 packages.

| Call | Result |
|---|---|
| `A[:h, :γ]` | the scalar |
| `A[:, :h]`, `B[:, :δe]`, `A[:θ, :]` | labelled vectors |
| `A[(:V, :γ), (:V, :γ)]`, and the same with vectors of labels | a labelled 2×2 |
| `round.(A; digits = 1)`, `A * B`, `[A B]` | labelled |
| `eigvals(A)`, `inv(A)`, `A == A0`, `isapprox(A, A0)` | work, the first two plain |
| `[A B; B' zeros(2, 2)]` | a plain `Matrix` |
| `show` | the axes in a header, the rows bare |

**Its load time.** The session reported 1.49 s. That was the first load
after the install, with a startup file. A later run with
`--startup-file=no` reads 0.11 s. The load times of the five other
packages below are first loads too, so they compare among themselves and
are not steady figures.

**Label agreement** (`componentarrays/probe3_label_agreement.jl`). `A` is
a `ComponentMatrix` labelled `(V, γ, θ, q, h)` on both sides, with the
diagonal 1 to 5.

| Call | Result |
|---|---|
| `A * q`, `q` labelled `(h, V, γ, θ, q)` | `(V = 20.0, γ = 10.0, θ = 0.15, q = 0.2, h = 1.0)` |
| `A * other`, `other` labelled `(a, b, c, d, e)` | `(V = 1.0, γ = 2.0, θ = 3.0, q = 4.0, h = 5.0)` |
| `A \ q`, `q' * A * q` | no error |
| `q + r`, `r` in the taps' order | a plain `Vector`, by position |
| `r + r` | labelled |

A product goes by position and takes its labels from `A`. Between two
vectors whose axes differ, the result drops its labels and is still
computed by position. Nothing refuses.

**An axis from the label tuple**
(`componentarrays/probe4_axis_from_labels.jl`).

- `Axis(x_labels)` builds the axis from the tuple.
- `ComponentVector(w, Axis(x_labels))` labels a plain vector by position.
  With the taps reordered, the same data takes the new names.
- A vector one element short throws a `BoundsError`. One element long is
  accepted silently.
- `ComponentVector(x₀, Axis(x_labels))` with a NamedTuple `x₀` is a
  `MethodError`.
- `q[x_labels]` reorders a vector written by name. A missing label throws
  and names it. An extra label is dropped silently.

**Five other packages** (`labelled_arrays/`), on the same matrix and
vectors.

| Package | Disagreeing labels in `A * q` and `q + r` | Entry by label | Rows labelled in `show` |
|---|---|---|---|
| AxisKeys 0.2.17 | refuses, naming both key vectors | `A(:h, :γ)` | yes |
| DimensionalData 0.30.3 | refuses | `A[At(:h), At(:γ)]` | yes |
| NamedArrays 0.10.5 | by position, with one warning | `A[:h, :γ]` | yes |
| AxisArrays 0.4.8 | by position, silently | `A[:h, :γ]` | no |
| LabelledArrays 1.20.5 | does not apply: it labels single elements | none | no |

DimensionalData also fails `eigvals(A)` with a `MethodError`. Not checked
for AxisKeys: whether `ss` and `lqr` of ControlSystemsBase take its
matrices, whether `A * B` checks the inner labels, block matrices with
different labels, and its upkeep.

**A `Bool` tap** (`probe_bool_tap.jl`, against the real tree before the
peer's commit A). A constant fills an integrator, and a comparator reports
whether the level is above 0.5.

| `x0` | `y₀` today | `C` | `y₀` under T10 |
|---|---|---|---|
| 0.2 | `(level = 0.2, above = false)` | `[1.0; 0.0;;]` | `[0.2, 0.0]` |
| 0.8 | `(level = 0.8, above = true)` | `[1.0; 0.0;;]` | `[0.8, 1.0]` |

**Read off the code**, with no probe:

- `src/linearize.jl` builds `x₀` and `u₀` from `site_values`, a
  `Float64[]`, and `ẋ₀` and `y₀` from `Vector{Any}` values that
  `_readback!` returns.
- `_check_seedable` refuses an `x` or `u` tap whose leaf is not `Float64`.
  `_seeded_tap(::Val{:y}, ...)` admits any `Real` leaf, "since a row is a
  read and not a seed".
- `src/` reads `.columns` nowhere. The uses are 11 in `test/test_log.jl`,
  6 in `examples/test/test_longitudinal.jl`, 2 in `examples/test/utils.jl`,
  5 in `docs/src/tutorial/aircraft.md` and 1 in
  `docs/src/tutorial/linearize.md`.
- The four vectors are read by name in `test/test_linearize.jl`, about 15
  lines, and through `keys(x₀)`, `collect(x₀)` and `u = u₀` in chapter 3's
  page and in the examples' chapter 3 testset.

## 4. Friction

By R17 of `../roadmap_tutorial.md`. One item, for chapter 9's increment,
the roadmap's increment 4.

1. `lqr_gains` takes its weights by position.
   `qx = 1 ./ [5.0, 0.05, 0.05, 0.2, 20.0] .^ 2` means V, γ, θ, q and h
   only through the order of `longitudinal_taps()`. A reordered tap set
   moves each weight to another state with no error. ComponentArrays does
   not catch it: `A * q` computes by position and labels the result as `A`
   does, by section 3. Candidate: the weights by name, ordered inside
   `lqr_gains` by `linearization.x_labels`, with a check that the two
   label sets are equal.

## 5. The prototype's charge

One high-tier agent in a scratch worktree under `../Redstone.jl-worktrees/`,
cut after the peer's commit A. In this order:

1. T5's measurement, with its stop.
2. Part 2: T3 and T4 with their tests, and the sweep of `.columns` in the
   pages and the examples' tests. `test/test_log.jl`'s reads may stay,
   since the field remains.
3. Part 3: T7 to T11, the extension, ComponentArrays in the test and docs
   environments at the version Pkg resolves in the worktree, the changed
   lines of `test/test_linearize.jl`, a testset that loads the extension,
   and chapter 3's page by T13.
4. Part 1: the four methods by T14 and T15, in `src/show.jl`'s
   conventions, with their tests.
5. The gate, the examples' runner and the docs build, the gate announced
   to the peer first.

Its report brings the four layouts as real output on the tutorial's
calls, and every reading on a seam these notes do not rule.

## 6. Open

- **The layouts**, by T15.
- **Not verified.** Whether a test pins a `y₀` that is not a `Float64`.
  Whether `x_deriv`'s bundle takes a `ComponentVector` as `u`, which
  chapter 3's block needs under T13. What `labeled` does on a value that is
  labelled already.
- **Owed with the docs commit**, since tracked files are frozen until the
  peer finishes: the spec's §11.2 and §14.10, D-474 and D-475, a line
  under increment 4 of `../roadmap_tutorial.md` that points at section 4,
  this file in the friction review's list in `pending.md`, and the stage
  on the bullet.
- **Scratch to delete** once the increment is pushed: the probes' folder,
  and then the worktree.

## 7. The session's decisions while the user was away

Each is the coordinator's, for the user to review. A decision the user
overturns changes the hunks named with it.

**S1. The session carries the pipeline as far as the peer allows.** It
launches the prototype after the peer's commit A, rules the readings
itself and records them here, and lands nothing on the real tree before
the peer's last commit is in. The layouts of T15 are the readings most
likely to be overturned, so the record shows each printed form whole.

**S2. The prototyper stops before its three costly runners**, the gate,
the examples' runner and the docs build, and the coordinator resumes it
to run them when no gate of the peer's is running. This carries out the
user's ruling that our gate waits for the peer's. The agent cannot see
the peer's runs, and a loop that waits on another process is the kind the
user's rules warn against. Routed subsets and probes run freely.

**S3. The prototyper's readings stand as built**, the one of S5 excepted.
Each is one line here, with the alternative it rejected.

1. *T4's reason* is `:reserved_label`. `series` refuses the first reserved
   label it meets, before the lifecycle gate, as it refuses a bare
   NamedTuple. Rejected: collecting every reserved label.
2. *The labelled testsets* close `test/test_linearize.jl`, which loads
   ComponentArrays at its head. The extension is therefore loaded for the
   whole suite, and no core testset calls `labeled`. Rejected: a new test
   file, which needs a row in `code_rules.md`'s routing table.
3. *T8's hint is tested in a child process* that loads Redstone alone, and
   its silence in the suite's own process. Rejected: a switch in the hint
   for the test's sake.
4. *`labeled` on a labelled value labels it again* over the same axes. The
   extension unwraps the data first, so the types do not nest. Rejected:
   returning the value as it is, which needs a branch.
5. *`x_deriv`'s bundle takes component vectors* for `x` and `u`, since a
   component reads both by property. Chapter 3's block runs on them and
   its gap is unchanged, 1.526e-10.
6. *No test pinned a `y₀` that is not a `Float64`.* The new testset uses
   the library's `Constant`, `Integrator` and `Comparator`. The typed
   field converts at construction, so the explicit conversion is redundant
   beside the typed buffer.
7. *`README.md` and the inspector read none of this.* `docs/src/api.md`
   gains `labeled`, which `Linearization`'s docstring links.
8. *`.columns` stays where two whole column sets are compared*, in chapter
   1's last block and in the examples' `plant_outputs`. A `Series` has no
   `==`. Rejected: comparing column by column.
9. *The examples' chapter 3 testset uses the plain form*, so the examples'
   test environment gains no dependency. Its numbers equal the page's.
   Rejected: ComponentArrays in `examples/test`.
10. *The compat bound* is `ComponentArrays = "0.15"` in the root project
    alone. Pkg resolved 0.15.50.
11. *The module's `__init__`* registers the hint and sits in
    `src/linearize.jl` beside `labeled`. Rejected: `src/Redstone.jl`,
    which holds includes only. The cold review weighs this one.
12. *`getproperty`'s parameter is `x`*, by the rule for a Base overload.

**S4. The four layouts stand as built, for the user to judge.** Section 8
shows each whole. The coordinator changed none, since a revision made on a
guess costs the prototyper's context twice. Its reservations, each a
change to `src/show.jl` and to the blocks `test/test_show.jl` pins:

- A `TrimReport`'s heading says "converged" twice in the common case,
  once for the verdict and once for the backend's status.
- Numbers stand left-aligned, as `show.jl`'s tables do, so a column with
  minus signs is ragged. Right alignment needs a second table helper.
- `A`'s table shows round-off as it is, `1.04807e-14` beside `20.4167`.

**S5. Chapter 3 displays the `Linearization` itself.** Under T13 the
page's `round.(linearization.A; digits = 4)` prints ComponentArrays' own
form, an axes header over bare rows, which reads worse than the page did
before. So the tap-set block ends on `linearization`, which prints T14's
table, and the two `round` blocks go. Chapter 2 keeps its NamedTuple
summaries. Whether it shows the report's new form is for the tutorial's
increment 3, since nothing there got worse.

**S6. The worktree moves to the peer's `4907ebb` before the costly
runners.** The patch passed `git apply --check` there. The peer's commits
B and C touch two of its files, `design/code_map.md` and
`examples/test/test_longitudinal.jl`, in other hunks. One gate on the
newer tip saves a second one later.

**S7. Whether the hint's print line takes a coverage marker is the cold
review's.** The line runs in a child process, so the coverage workflow
may count it as missed. `code_rules.md` allows a marker once the gate is
shown to run the line.

**S8. The docs commit is drafted in a scratch worktree of its own**,
`tutorial_loose_change_docs` beside the prototype's, since tracked files
on the real tree are frozen for the peer. The battery is green there and
`linkify` is a no-op on a second run. The patch is `docs_commit.patch` in
the probes' folder. It holds:

- §11.2, a paragraph on the properties and the refused labels;
- §14.10's "The returned value", rewritten for plain arrays and the
  labeled form, with FlightPhysics' slicing now said of the labeled form;
- Appendix B, a `labeled` entry and a sentence on `series`; Appendix C,
  the `:reserved_label` reason;
- D-474 and D-475, with annotations under D-407 and D-272;
- a row for the extension in `rules/code_rules.md`'s routing table;
- the pointer under increment 4 of `roadmap_tutorial.md`;
- `pending.md`: this change's bullet with its stage, this file in the
  friction review's list, and `labeled` as a sixth boundary case of the
  exported-name audit.

The wording of the two entries and the two spec passages is the
coordinator's, and the user has not read it.

**S9. The cold review runs on the worktree, before the landing.** The
rules land first and review after. The peer still holds the real tree,
with a review fix uncommitted there, so the order turns: the review reads
the same diff that will land, staged in the prototype's worktree with the
docs patch beside it, and the fixer's work is whatever stands unstaged
after it. The landing then takes three patches in the rules' order, the
docs, the code and the fixes. The reviewer does not run the full gate,
since the prototyper ran it on this exact diff and the user ruled that
ours wait for the peer's. It runs routed subsets and its own mutants.

**S10. The prototype's last round**, after S5 and S6:

- The worktree stands at `4907ebb`. `git checkout -m` refused the file
  added with `git add -N`, so the prototyper reset, checked out the tip
  and applied its saved patch, which applied whole.
- The gate reads 10863 of 10863 in 10 min 54 s, with no warning. The
  conventional entry point, `Pkg.test()` under the root project, reads
  the same 10863. The examples' runner reads 179 of 179. The docs build
  is green, its one warning the local "skipping deployment".
- The link to `labeled` resolves in the built reference. Chapter 3's page
  shows the `Linearization` block, its label lookups give
  `(50.0, 1.0, ...)`, its finite-difference gap is 1.526e-10, and the
  package's linearization equals the page's.
- In a `Simulation`'s heading, `live` is `mode(sim)`, the input mode. It
  reads `replay` while a recording is attached.
- The patch is `prototype_tutorial_loose_change.patch` beside this file,
  19 files, +592 −85, against `4907ebb`. `git apply --check` passes on
  the real tree at `c373acc`, and so does the docs patch.
- The prototyper ended at 366k tokens of its 450k stop.

**The cold review's charter.** One independent high-tier agent, with an
open mind and no brief beyond this file, the rules and the staged diff.
Probe scripts go outside the tree. An empty report is acceptable. It
reads the code against the rulings of section 2, the two spec passages
and D-474 and D-475 against the code, and the pages against their rules.
It runs the mutants of section 9 it doubts and its own, the hint's print
among them. Three points wait for it by name: where the module's
`__init__` sits (S3.11), whether the hint's print line takes a coverage
marker (S7), and whether the labelled testsets loading ComponentArrays
for the whole suite hides anything (S3.2).

**S11. The landing went back to the rules' order once the peer released
the tree**, which S9 had turned. The docs landed as `d382b00` and the
code as `23458b8`, the patch applied unchanged over the peer's `505dd28`.
Before the code commit, on the real tree: the gate read 10864 of 10864,
the examples' runner 179 of 179, and the docs build was green. The
manifest resolved ComponentArrays at 0.15.50. The cold review ran
meanwhile on the same diff in the worktree, and its fixes follow as a
third commit.

**S12. The record's claim that the core tests do not load the extension
was wrong, and the design stands.** T9 says "The core tests do not load
the extension", and S3.2 says no core testset calls `labeled`. As built,
`test/test_linearize.jl` loads ComponentArrays at its head, and the suite
includes every file before any test runs, so every test runs with the
extension loaded. `test/test_show.jl`'s `Linearization` testset also
calls `labeled`, to assert that both forms print alike. What holds is
narrower: the testsets of the plain form never call `labeled`. The
reviewer probed the cost and found none: loading ComponentArrays adds no
method on a type it does not own to Base, LinearAlgebra, StaticArrays,
ForwardDiff or Redstone, and Redstone's ambiguities stay at zero. The
alternative, for the user to weigh, moves the labelled testsets into a
child process, as the hint's test already is.

**S13. Three leftovers of the fix, ruled with the reviewer's view.**

- D-475's Rationale says the labeled form "puts all eight arrays on
  shared axes", and §14.10 says the arrays of one linearization agree
  because they share their axes. Both are loose where a tap list is
  empty. They stay: each is reasoning and no ruling, and agreement holds
  vacuously for an empty array.
- The `Series` testset of `test/test_show.jl` cited D-474, which rules no
  printed form. The citation went, in a commit of its own, with the
  `show` file green at 230. The `Linearization` testset keeps D-475,
  since it exercises the labeled form.
- The child process that runs the hint strips the coverage flag, so the
  coverage workflow never records the marked print line. The marker
  stands for that reason, as `src/precompile.jl`'s workload does.

## 8. The printed forms, as built

From `probe_layouts.jl` and `out_layouts.txt` in the probes' folder, on
the tutorial's own calls. Each REPL form is followed by its one-line form.

A `Simulation`, as built, after `init!` and after `run!`:

```
Simulation: built, live
  deployment: Deployment(Δt_frame = 1//100, Δt_base = 1//100, h_max = 1//100, RK4())
  log: no snapshots
  devices: none
  warnings: none

Simulation(built, live)
```

```
Simulation: initialized, live, frame 0 at t = 0.0
  deployment: Deployment(Δt_frame = 1//100, Δt_base = 1//100, h_max = 1//100, RK4())
  log: 1 snapshot
  devices: none
  warnings: none

Simulation(initialized, live, frame 0 at t = 0.0)
```

```
Simulation: stopped, live, frame 12000 at t = 120.0
  deployment: Deployment(Δt_frame = 1//100, Δt_base = 1//100, h_max = 1//100, RK4())
  termination: EndTimeReached at t = 120.0
  log: 12001 snapshots
  devices: none
  warnings: none

Simulation(stopped, live, frame 12000 at t = 120.0)
```

Other lines the suite's fixtures show: `termination: ModelRequestedStop at
t = 0.9, by stop/y, reason "three ticks counted"`, `log: off` under
`log = false`, and `devices: device 1 (TailProbe)`. A running loop prints
no log line, since `logged` refuses it.

Chapter 1's flight as a `Series`:

```
Series: 12001 snapshots, t = 0.0 to 120.0
  column  eltype
  V       Float64
  h       Float64

Series(12001 snapshots, t = 0.0 to 120.0; V, h)
```

Chapter 2's `trim!` report, converged, and stalled at 20 m/s:

```
TrimReport: converged, committed; status converged, 4 iterations, 5 evaluations
  decision  value
  θ         0.0199302
  δe        0.0250582
  δt        0.372337
  residual  value        tolerance  committed
  V̇         5.33191e-14  1.0e-9     5.33191e-14
  γ̇         4.59138e-12  1.0e-9     4.59138e-12
  q̇         2.62017e-13  1.0e-9     2.62017e-13

TrimReport(converged, committed, 4 iterations)
```

```
TrimReport: not converged, nothing committed; status stalled, 42 iterations, 85 evaluations
  decision  value
  θ         0.3        at the upper bound
  δe        -0.238337
  δt        0.373034
  residual  value     tolerance
  V̇         0.138292  1.0e-9
  γ̇         -0.12392  1.0e-9
  q̇         0.117614  1.0e-9

TrimReport(not converged, nothing committed, 42 iterations)
```

A report with fired events adds `fired events: c/touchdown`.

Chapter 3's `Linearization`. The plain and the labelled form print alike,
byte for byte, which the suite asserts:

```
Linearization: 5 states, 2 inputs, no outputs
  states:
       x₀         ẋ₀
    V  50.0       5.33191e-14
    γ  0.0        4.59138e-12
    θ  0.0199302  0.0
    q  0.0        2.62017e-13
    h  1000.0     0.0
  inputs:
        u₀
    δe  0.0250582
    δt  0.372337
  A:
       V            γ         θ         q       h
    V  -0.0372263   -4.89572  -4.91428  0.0     0.0
    γ  0.00783316   -2.46861  2.46861   0.0     0.0
    θ  0.0          0.0       0.0       1.0     0.0
    q  1.04807e-14  20.4167   -20.4167  -3.675  0.0
    h  0.0          50.0      0.0       0.0     0.0
  B:
       δe     δt
    V  0.0    2.4995
    γ  0.0    0.000996444
    θ  0.0    0.0
    q  -24.5  0.0
    h  0.0    0.0

Linearization(5 states, 2 inputs, no outputs)
```

With outputs tapped, an `outputs:` block with `y₀` follows the inputs, and
`C:` and `D:` follow `B:`. An empty tap list prints no block.

Values print as a REPL prints them inside a container, six significant
digits. The prototyper weighed full precision, which doubles the width of
`A`'s table, and a mark on the labelled form's heading, which would make
the two forms print differently against T14.

## 9. The shape built, the measurement and the pins

As the prototyper reported them at `336a79e`, before S5's hunk and S6's
move. The patch touches 19 files, +591 −80.

| File | Lines | What |
|---|---|---|
| `Project.toml` | +7 | `[weakdeps]`, `[extensions]`, the compat bound |
| `ext/RedstoneComponentArraysExt.jl` | 24, new | `labeled` by T9, unwrapping first |
| `src/sim.jl` | +26 −5 | `getproperty`, `propertynames`, T4's refusal, the docstrings |
| `src/diagnostics.jl` | +6 −2 | the `:reserved_label` reason and its message |
| `src/linearize.jl` | +57 −21 | the struct and its docstring, `labeled` declared, the hint, T10 |
| `src/show.jl` | +145 −1 | four types in two forms each |
| `test/Project.toml`, `docs/Project.toml` | +1 each | ComponentArrays |
| `test/imports.jl` | +3 −3 | `GetOutput`, `TrimReport`, `labeled` |
| `test/test_log.jl` | +24 | the properties and the refusal |
| `test/test_diagnostics.jl` | +6 | the sample and its text |
| `test/test_linearize.jl` | +86 −13 | positional reads, the plain types, T10's testset, two labelled testsets |
| `test/test_show.jl` | +131 | four testsets |
| `docs/src/api.md` | +1 | `labeled` |
| `docs/src/tutorial/aircraft.md` | +6 −5 | the sweep, one sentence on columns as properties |
| `docs/src/tutorial/linearize.md` | +16 −12 | T13 |
| `examples/test/utils.jl` | +2 −2 | the sweep |
| `examples/test/test_longitudinal.jl` | +12 −11 | the sweep, chapter 3's block in the plain form |
| `design/code_map.md` | +37 −5 | the entries of `ext/`, `linearize.jl`, `sim.jl`, `show.jl` |

**T5's measurement** (`probe_t5_compile.jl`): a fresh process, the
tutorial aircraft flown 10 s, eight distinct label sets of one to eight
labels after a warm-up set.

| What | Per new label set |
|---|---|
| `series(sim, reads(...))` | 5.3 to 7.7 ms |
| the first `flight.label`, all of it compilation | 3.0 to 3.6 ms |
| the old path, `getfield(flight, :columns)[label]` | 1.1 to 1.4 ms |
| a fresh `s -> s.V` | 0.9 to 1.0 ms |

`flight.V` and `flight.t` infer as `Vector{Float64}` inside a function.
The worst figure is under a twentieth of the stop's threshold.

**The routed subsets** read 6648 assertions green under the gate's flags.
Four files gained assertions: `log` 87 to 105, `linearize` 131 to 162,
`diagnostics` 1052 to 1057, `show` 201 to 227. The examples' longitudinal
file alone read 179.

**The pins and their mutants.** The prototyper ran twelve mutants
(`mutants.py`, `out_mutants.txt`) and each turned a test red.

| Testset | Mutant | Red |
|---|---|---|
| `test_log`, a column reads as a property | M1, every name forwarded | yes |
| the same | M2, the labels listed first | yes |
| the same | M3, no refusal | yes |
| `test_diagnostics`, the rendering | M4, the reason's branch falls through | yes |
| `test_linearize`, a `y` tap that is not a `Float64` | M5, abstract field, untyped buffer, no conversion | yes |
| `test_linearize`, the labelled form | M6, no unwrap | yes |
| the same | M7, `C`'s axes swapped | yes |
| `test_linearize`, the hint | M8, the hint ignores the extension | yes |
| `test_show`, `TrimReport` | M9, the bound's mark dropped | yes |
| `test_show`, `Linearization` | M10, an empty matrix prints its block | yes |
| `test_show`, `Simulation` | M11, the log read while the loop runs | yes |
| `test_show`, `Linearization` | M12, `C` under the wrong row labels | yes |

Not run: a mutant that drops the hint's print, which the child-process
check should catch. The conversion of T10 alone is an equivalent mutant,
since the typed field converts.

## 10. Findings

- **L23 reverses one point of D-407.** That entry rejected FlightCore's
  `TimeSeries` partly because overloading `getproperty` reserved the
  wrapper's own field names. The cost is now four reserved labels, refused
  at `series`. D-474 must say so. D-407's claim that `series` compiles
  nothing per label set stays true. The property access compiles once per
  label set, about 3 ms.
- **`==` checks labels where the arithmetic does not**
  (`probe_equality.jl`). Two component arrays with different labels are
  unequal. A `ComponentVector` against a plain `Vector` is `false`, and a
  `ComponentMatrix` against a `Matrix` compares values alone.
- **An empty tap list's vector stays plain** in the labelled form, since a
  `ComponentVector` over an empty axis collapses.
- **A `Simulation` inside a container still prints its type parameter**,
  as in `[sim]`. That is Julia printing the vector's element type.
- **The real tree's manifest.** The untracked root `Manifest.toml` needs
  `Pkg.resolve()` under `--project=test` before any runner there, since
  the root gained a weak dependency and two environments a dependency. The
  peer shares that file, so the resolve waits for its last commit.

## 11. The cold review

One independent high-tier agent, on the staged diff in the prototype's
worktree at `4907ebb`, by the charter that closes section 7. Its notes
are `tutorial_loose_change_review_notes.md` beside the worktree and its
probes `tutorial_loose_change_review_probes/` there. It ended at 275k
tokens.

**The verdict.** The code does what T3 to T14 say, and behaves correctly
in every edge case probed: empty tap lists, a `Series` with no columns or
no snapshots, `labeled` on odd inputs, the printed forms in every
lifecycle state and both input modes, a report in each status. Nothing
blocks the landing. One guard lacks a test, and several docs sentences
are slightly false.

**The findings and the coordinator's rulings.** The fixer's charge is
`tutorial_loose_change_fix_prompt.md` beside the worktree.

| | Finding | Ruling |
|---|---|---|
| F1 | The hint's `err.f === labeled` guard is unpinned: without it every `MethodError` in a session without ComponentArrays carries the hint | fix: the child also raises an unrelated `MethodError`, and the hint must occur once |
| F2 | The whole suite runs with the extension loaded, against T9's sentence | no fix; S12 corrects the record |
| F3 | "Eight arrays" is false for an empty tap list: the vector stays plain, and so does a matrix whose two lists are both empty | fix the six sentences, and pin the matrix's type |
| F4 | The routing row omits `show` and misplaces the load | fix |
| F5 | D-072's Position says the linearization returns labeled data, and has no annotation | annotate |
| F6 | `companions/linearization_walkthrough.md` and `companions/lqr_tracker.md` still describe NamedTuples | fix |
| F7 | Five facts of the printed forms and one of `series` are unpinned: `replay` in the heading, the residue clause, an empty column set, six significant digits, and the refusal standing before the lifecycle check | add a test for each; the last is pinned or its claim dropped |
| F8 | The `Series` table prints an element type directly, so its qualification depends on the printing module | add the site to `code_rules.md`'s caveat, no code change |
| F9 | The `show` methods cite D-474 and D-475, which rule no printed form | remove or redirect the citations; nothing enters the spec before the user judges the forms |
| F10 | D-475's Rejected item on a NamedTuple of matrices says it drops the labels | reword |
| F11 | §11.2's paragraph uses `flight` unintroduced, and two rulings stand unbolded | fix as the reviewer proposed |
| F12 | Chapter 1's last block compares `.columns`, a field the page no longer introduces | compare the columns themselves; S3.8 stands for the examples' tests only |
| F13 | `labeled`'s docstring lacks the glossary link and a warning that `==` between a component vector and a plain one is `false` | fix |

**The three named points.** The module's `__init__` stays in
`src/linearize.jl`, since a second one elsewhere fails loudly at
precompilation, and the code map's `src/Redstone.jl` entry gains a
clause. The hint's print line takes `# COV_EXCL_LINE`, since the child
test turns red when the print is dropped. Loading ComponentArrays for the
whole suite hides nothing in behavior, by S12.

**The reviewer's mutants.**

| Mutant | Result |
|---|---|
| R1, the hint's print dropped | red, by the child-process test |
| R2, the `err.f === labeled` guard dropped | survived: F1 |
| R3, the mode written as the literal `live` | survived: F7 |
| R4, the residue clause dropped | survived: F7 |
| R5, the empty-column guard dropped | survived: F7 |
| R6, the refusal moved after the lifecycle check | survived: F7 |
| R7, compact printing dropped | survived: F7 |

**Not checked by the reviewer.** The full gate, the examples' runner and
the docs build, which the prototyper and then the coordinator ran. The
docs battery, which the coordinator ran. Whether Codecov shows the print
line as missed. Accessors or ConstructionBase on a `Series`, whose
property names now differ from its field names. A hand-made
`Linearization` whose lengths disagree with its labels, which `labeled`
and `show` accept silently.

## 12. The fixes and the delta

One fixer landed `7410031`, 14 files, +94 −51, by the charge the
coordinator wrote from section 11. Its probes are
`tutorial_loose_change_fix_probes/` beside the worktree.

- Every finding ruled "fix" is fixed as charged. The reviewer's mutants R2
  to R7 each turn a test red now.
- F7's last item is pinned and its claim kept. In `test/test_log.jl`'s
  running-loop testset, `series` refuses a reserved label first, and the
  call after it still meets the lifecycle refusal, which shows the loop
  was running.
- The routed files read 1557 of 1557, the docs battery was green, the
  gate read 10870 of 10870 with no warning, six assertions above the
  landing, and the docs build was green.

The reviewer, resumed with its context, read the commit file by file and
found that every fix holds and widens nothing. It saw nothing new.

**Open, for the user.**

- **The printed forms** of section 8, with the reservations of S4.
- **S12.** The whole suite runs with the extension loaded. The
  alternative moves the labelled testsets into a child process.
- **Position bullets the spec states nowhere**, which the fixer listed
  and nobody acted on: that `propertynames` lists the four fields first
  (D-474); that the fields are typed abstractly with no type parameter,
  that ComponentArrays is a weak dependency and the core declares
  `labeled` with no method, that `labeled` on a labeled value labels it
  again, and that no `subsystem` is added (D-475). The spec's rule asks
  each ruling to be bold where a section states it, so either the spec
  gains these sentences or the entries' Positions shed them.
- **The printed forms have no home in the spec or the log.** §9.2 and
  §13.7 cover the artifacts, and these four values are none. A home waits
  for the user's judgment of the forms.
- **Not verified.** Whether Codecov shows the marked line as excluded.
  Accessors or ConstructionBase on a `Series`. The docs build on Linux.
- **Scratch to delete once the increment is pushed**, all under
  `/Users/miguel/.julia/dev/Redstone.jl-worktrees/`: the worktrees
  `tutorial_loose_change`, `tutorial_loose_change_docs` and
  `tutorial_loose_change_review`, the four `tutorial_loose_change_*probes`
  folders, the two prompts and the three agents' notes.
