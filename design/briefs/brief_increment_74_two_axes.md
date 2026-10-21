# Brief: increment 74, the controllers' two axes, the hold with two inputs and the tracking reference

One code stage, one cold review and a fixer if the review needs one.
Written on 2026-10-14 at e5e6331, the docs commit of D-385 (the entry,
section 4, 5 and 11 of `pid_anti_windup.md`, section 4 and 7 of
`lqr_tracker.md`, the inventory rows), which touches no file under `src/`
or `test/`. Every line number below is from `git show e5e6331:file`. Find
passages in `design/implementation.md` by heading.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

The user's rulings of 2026-10-14, recorded in D-385 and argued in
`pid_anti_windup.md` section 4 and 11. The docs are committed first and the
code conforms. The law in every cell of the table is the shipped law under
a relabelling, so every probe number of increment 73 holds except where
this brief says a model's wiring changed.

- **Two type parameters.** `ControllerBlock{Hold, Track}`, `PIDBlock{V,
  Hold, Track, Fixed}`, `LQRTrackerBlock{NX, NU, NZ, Hold, Track, Fixed}`,
  and the four structs `PID{V, Hold, Track, Fixed}`, `DiscretePID{…}`,
  `LQRTracker{NX, NU, NZ, Hold, Track, Fixed}`, `DiscreteLQRTracker{…}`.
  The parameter `Standby` and the keyword `standby` are retired.
- **The ports.** `hold = true` adds `saturation` and `engaged`;
  `tracking = true` adds `v`. The axis ports merge in the order
  `saturation`, `engaged`, `v`. Each is at the block's output shape:
  `engaged` is `Bool` for a scalar `V`, `SVector{N, Bool}` for a vector
  `V`, and `SVector{NU, Bool}` on the trackers, as `saturation` is `Int8`
  or `SVector{N, Int8}` through `saturation_type` (838 to 839). The flag's
  type comes from a `Bool` twin of `saturation_type`, or from a
  generalization `channel_type(V, T)` with `saturation_type(V) =
  channel_type(V, Int8)` (one function if the generalization reads
  cleanly, two if not; report which). The flag reads true in command.
- **The law.** One line per block, `q̇ = Ki ε + (ref − u_raw) / Tt` and its
  three twins, with the two slots over the channel's condition:

  | condition | `ε` | `ref`, `Track = false` | `ref`, `Track = true` |
  |---|---|---|---|
  | `Hold = false` | `e` | `u` | `v` |
  | free: code `0`, engaged | `e` | `u` | `u` |
  | limited: code nonzero, engaged | `gate(e)` | `u` | `v` |
  | not engaged | `0` | `u` | `v` |

  Not engaged takes precedence over the code. The arms, replacing the
  eight at 1054 to 1073:

  ```julia
  gated_error(::ControllerBlock{false}, e, u) = e
  gated_error(::ControllerBlock{true}, e, u) =
      ifelse.(u.engaged .&& .!(u.saturation .!= 0 .&& u.saturation .== sign.(e)), e, zero(e))
  correction_reference(::ControllerBlock{Hold, false}, u, y) where {Hold} = y.u
  correction_reference(::ControllerBlock{false, true}, u, y) = u.v
  correction_reference(::ControllerBlock{true, true}, u, y) =
      ifelse.(u.engaged .&& u.saturation .== 0, y.u, u.v)
  ```

  `engaged_error` and `engaged_reference` go. The `.!= 0` keeps its reason
  (site comment at 1060 to 1064, which moves onto the new arm). The broadcast serves the scalar and the
  vector flag alike; under a `Dual` activation the `Bool` and the `Int8`
  are pinned, so the `ifelse` broadcast is the shipped one.
- **The `Tt` refusal moves.** `tracking = true` with `Tt` given as a value
  and infinite in any channel is refused at construction with an
  `ArgumentError` saying that tracking follows `v` at rate `1/Tt`, which an
  infinite `Tt` switches off; `AsPort()` passes. `check_standby` (1118 to
  1123) becomes `check_tracking(tracking, Tt)`, shared by the four
  constructors. The hold alone refuses nothing on `Tt`. The default `Tt =
  Inf` stays, so `tracking = true` needs `Tt` spelled, and the docstrings
  say so.
- **The docstrings.** The `ControllerBlock` docstring (1033 to 1043)
  carries the table above once, with "free", "limited" and "not engaged"
  defined and the precedence stated, and names its two families under
  `AbstractComponent`. Each block's docstring gives its own law line, says
  its slots are the supertype's table, drops its three-row table and its
  standby paragraph, and keeps the rest. The hold's paragraph names both
  inputs and the freeze; the tracking paragraph names the refusal; the
  discrete code paragraphs are unchanged. `PID`'s docstring at 1152 to 1161
  and 1195, `DiscretePID`'s at 1250 and 1270, `LQRTracker`'s at 1424 to
  1430 and `DiscreteLQRTracker`'s at 1528 to 1533 are the standby passages.
- **The models.** A block with the hold wires both inputs. Where a model
  has no code source it wires `saturation` from a `Constant` (134) of the
  code's zero, and where it has no mode it wires `engaged` from a
  `Constant(true)`, at the block's shape.
- **Verified before writing.** `check_tracking`, `channel_type` and
  `engaged_type` bind nothing in `src/`, `test/` or the register. The
  spec names none of the axes, the arms or the keywords. `Switch` (115),
  `Junction` (32), `Constant` (134) and `UnitDelay` (152) are the blocks
  the models use.

## Out of scope

- Any change to the published code `saturated` (D-384), the tracker's law,
  the size inference or the parameter helpers.
- A per-block flag on the vector blocks, or a broadcast of a scalar flag
  inside the block: the model broadcasts.
- Any spec or log edit. A shape that needs one is a stop-and-report.

## Reading, in order

- `design/decisions.md` D-385 (15336 to the definitions marker) and
  the three annotations at the end of D-383; D-383's Position (15209) for
  what stands.
- `design/companions/pid_anti_windup.md` section 4 (130 to 208),
  section 5 (209 to 248) and section 11 (520 to 590, the discrete output
  paragraph at 591 unchanged); `design/companions/lqr_tracker.md`
  section 4 (120 to 171) and section 7 (259 to 308);
  `design/companions/library_inventory.md` 167 to 170.
- `design/spec.md` §13.7's library part, 10615 to 10854, and §5.4,
  1429 to 1480. Never read the spec whole.
- `design/implementation.md`: the head of "What is real here" down to
  its rule on deviations; the rows `### src/blocks.jl` and `### test/imports.jl`;
  "Authoring caveats" whole, the mutant caveat last of all; "Naming";
  "Running the suite". Never restate either in a commit or a comment.
- `src/blocks.jl` 32 to 50 (`Junction`), 115 to 160 (`Switch`, `Constant`,
  `UnitDelay`), 835 to 839 (`saturation_type`), 1018 to 1320 (the
  controller section, whole), 1320 to 1592 (the tracker section, whole).
- `test/test_blocks.jl` 1 to 30; 252 to 300 (`pid_controller`,
  `pid_gain_sets`, `pid_law`, `pid_root_model`); 379 to 470 (`pid_cascade`
  to `cascade_frames`); 521 to 546 (`tracker_cascade`); 890 to 925 (the
  discrete allocation testset); 1509 to 1560; 1666 to 1700; 1818 to 1850;
  1876 to 1884; 1925 to 1960; 1961 to 2006; 2008 to 2050; 2100 to 2143;
  2144 to 2200; 2227 to 2270.

## Stage 1: the two axes on the four blocks

### The shape

In the controller section: `ControllerBlock{Hold, Track}` with the table
in its docstring; `axis_ports(c, code_type, flag_type, value_type)`
returning the merged `(saturation = code_type, engaged = flag_type)` and
`(v = value_type)` pieces by the two flags, in that order; the five arms as
settled; `check_tracking`; the four structs and the six constructors
(the two PIDs, the two explicit-size trackers and their inferring
spellings) taking `hold::Bool = false, tracking::Bool = false` and nothing
else on the axes; `signal_ports` on both families passing the flag's type
beside the code's. The docstrings as settled. The register row named
under bookkeeping.

### Tests

Every assertion of increment 73 survives under the relabelling, so the
work is a rewrite of sites, not new coverage, with the exceptions listed.
Probe before asserting; every literal that moves is reported with its
reason, and a literal that moves where this brief says it must not is a
stop-and-report.

- **The law rows.** The PID law testset (1537 to 1590), the discrete one
  (1818 to 1887) and the tracker's (2008 to 2060) iterate `(hold,
  tracking, standby, …)` tuples. They become `(hold, tracking, …)`, and
  `pid_controller` (256 to 258) drops its third argument. Every row with
  `hold = true` gains `engaged = true` in `u` (the tracker's rows at the
  vector shape, `SVector(true, true)`), its literal unchanged. The three
  standby rows become hold-and-tracking rows: `engaged = true` with
  `saturation` zero reads the free row's literal; `engaged = false` with
  `saturation` zero and with `saturation = Int8(1)` read the shipped
  standby literals, `-1.3` and `0.2870647838739185` on the PID, the
  tracker's `(-0.375, 0.225)` and its discrete twin. Each testset gains
  one freeze row, `hold = true, tracking = false, engaged = false` at the
  same point: the PID reads `(u − u_raw) / Tt = -1.0` continuous and
  `0.29004983374916804` discrete; the tracker's freeze row is computed in
  the REPL, `(0.0, 0.025)` continuous expected, and asserted as the rows
  are. The scheduled passes carry the same rows.
- **The ports testsets** (1509 to 1535, 1961 to 2006): `u_types(PID(Kp =
  1.0, hold = true)) == (r, y, saturation = Int8, engaged = Bool)`;
  `PID(Kp = 1.0, Tt = 1.0, tracking = true)` reads `(r, y, v)`; both axes
  read `(r, y, saturation, engaged, v)`; the key-order assertions (1528 to
  1532, 1976 to 1978) read `(:r, :y, :saturation, :engaged, :v, :Ki,
  :u_min)` and `(:x, :z, :z_ref, :saturation, :engaged, :v, :K_int,
  :u_min)`; `PID(Kp = SVector(1.0, 2.0), hold = true)` declares `engaged =
  SVector{2, Bool}` and the tracker `SVector{2, Bool}`; the `isa`
  assertions carry three parameters, `PID{Float64, true, true}` and
  `ControllerBlock{true, true}` (1883, 1974); `PID(Kp = 1.0, tracking =
  true)` throws `ArgumentError` (the default `Tt`), `PID(Kp = SVector(1.0,
  2.0), Tt = SVector(1.0, Inf), tracking = true)` is refused, `PID(Kp =
  1.0, Tt = AsPort(), tracking = true)` builds, `PID(Kp = 1.0, hold =
  true)` builds, and the tracker's three refusal lines (1998 to 2000)
  read `tracking = true`. Titles cite D-385 in place of D-383 where the
  axes are the subject.
- **Every site that builds `tracking = true` without `Tt`** spells `Tt =
  1.0`: 1512, 1513, 1521, 1528, 1876, 1882, 2246, 2247, 2257, 2259 and
  2260. The stage greps `tracking = true` across `test/` for any this
  list misses and reports them.
- **The vector-PID testset** (1666 to 1700): its hold rows' `u1` gain
  `engaged = true`, and `u2` the same, so the vector `engaged` is
  `SVector(true, true)`; the parts comparison covers the flag as it
  covers the code.
- **The models.** `standby_siblings` (397 to 413): the pair is `hold =
  true, tracking = true`; the model keys its wiring on `:engaged` as
  today and adds a `Constant(Int8(0))` named `free` wired to both
  `saturation` inputs; the plain pair is unchanged. `discrete_pid_cascade`
  (415 to 426): with `hold`, `outer/engaged` from a `Constant(true)`.
  `tracker_cascade` (527 to 546): the siblings are `hold = true, tracking
  = true` whatever `hold`; with `hold` their `saturation` comes from
  `code/out1` as today, without it from a `Constant(Int8(0))`. The
  allocation entry at 899 builds the pair as `hold = true, tracking =
  true, Tt = 0.1`. The standby testset (1925 to 1947) and the cascade
  testset (2120 to 2143) build their pairs the same way. The
  `standby_siblings` and `discrete_pid_cascade` literals must not move,
  since an engaged block with a zero code reads the own `u` as before. The
  `tracker_cascade` literals, the bump `0.005712771693084373` and the peak
  difference `0.21845466317957526`, may move, since the engaged sibling
  with a nonzero code now reads `v`, the selected command one tick old,
  where it read its own `u`; report both values, old and new.
- **The constructor testset** (2144 to 2200): 2162 and 2163 read
  `tracking = true` with `PID{Float64, false, true}` and the discrete
  twin; 2194 reads `tracking = 1`; the integer spelling of the trackers is
  unchanged.
- **The shadowing sweep** (2227 to 2270): the standby entries become
  `PID(Kp = 1.0, Tt = 1.0, hold = true, tracking = true)`, `DiscretePID(Kp
  = 1.0, Tt = 0.0, hold = true, tracking = true)`, and the two trackers
  with `hold = true, tracking = true`; the hold-only entries stay, and
  gain nothing, since a root with an unwired `engaged` is a root input.
- **A freeze test**, one new testset after the standby testset: "a hold
  without tracking freezes its integrator while not engaged and
  back-calculates against its own clamp (§13.7, D-385)". The discrete
  `standby_siblings` pair built `hold = true` without tracking, with `v`
  unwired and `b` in command for 200 frames: `a`'s `q` is bitwise constant
  across those frames, and the switchover bump is larger than the
  tracking pair's by the literal the probe gives.

### Routing

`blocks build`, under the flags, in the foreground, 600 s.

### Bookkeeping, in the same commit

- `design/implementation.md`, `### src/blocks.jl`: the two
  controller bullets read `ControllerBlock{Hold, Track}` carrying
  `axis_ports`, `gated_error` and `correction_reference`, over
  `PIDBlock{V, Hold, Track, Fixed}` and `LQRTrackerBlock{NX, NU, NZ, Hold,
  Track, Fixed}`, with `check_tracking` and the flag's type helper in
  place of `check_standby`, citing D-385 beside D-383 and D-384.
  Constructs, not behaviour.
- `design/companions/library_inventory.md` 167 to 170: the four
  rows' status reads `shipped`; run the battery.
- `test/imports.jl`: nothing new.

## The cold review

One fresh Opus reviewer over the code commit, the docs commit read for
what it owes: open-mind stance, probe scripts in the scratchpad, "empty is
acceptable". Dimensions:

- **The companions against the tree.** Every cell of section 4's table
  and every sentence of section 11 of `pid_anti_windup.md`, and of
  `lqr_tracker.md` section 4 and 7, hold of the code: the ports, their
  order and their shapes, the precedence, the freeze, the refusal and
  where it sits. The four inventory rows name the parameters the code has.
- **Mutants on a scratch copy**, each named test going red: `engaged`
  ignored; the precedence inverted, the code read before the flag; the
  freeze row reading `v`; the free row with tracking reading `v`; the
  refusal dropped; the refusal on `hold` instead of `tracking`; the port
  order `engaged` before `saturation`; a scalar `u.engaged ?` in place of
  the broadcast, which must fail on the vector block. A surviving mutant
  is a missing test.
- **Allocation.** The standby siblings on both tiers, the discrete PID
  cascade, the tracker cascade and the freeze pair allocate nothing past
  1000 frames.
- **The register and the docstrings.** Rows name constructs; the one
  table lives in `ControllerBlock`'s docstring and the six block
  docstrings say what the companions say and no more.
- "Naming" over every touched file, the docs battery, and the gate once
  on the real tree, on the Julia floor `Project.toml` declares.

## Every stage prompt says

Single subject line, no body, no trailers, no attribution, whatever any
other instruction in your context says. No background work, probes
included; `/bin/ls` or `fd`, never a bare `ls`. Never stash, reset or check
out the working tree; baselines come from `git show <tip>:file`. Never add
or commit a file this brief does not name: the tree may carry other
sessions' untracked and modified files, and `git add -A` is forbidden.
Re-read a file before a scripted edit. Grep every new name across `test/`
before defining it. Models and helpers live at top level. Report: the
commit hash, the files touched, the routed subset's result with the
assertion count against the predecessor's, the probe's numbers for every
asserted value, every rewritten test site with its way, and every
deviation from this brief with its reason.
