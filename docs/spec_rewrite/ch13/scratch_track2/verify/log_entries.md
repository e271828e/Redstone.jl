### D-408 — Discard a failed boundary and promote the previous snapshot to final

**Status.** ratified

**Position.** A loop failure discards the failed boundary, promotes the
previous snapshot to final and rejoins the ordinary tail. No torn final
snapshot is published.

**Spec.** [§13.6][s13-6]

**Rationale.** This restates the ground of [D-030][d-030]'s rejection of a mid-frame
abort, "torn final snapshot; consumers observe un-swept state", which its
Position does not state. That Position says only that a loop failure runs
the same protocol from the catch path. The design text that ruled [D-030][d-030]
stated the discard and the promotion, since the boundary is all-or-nothing
outside the loop, and the log's entry did not carry them. The entry decides
nothing new.

**Rejected.** None beyond [D-030][d-030]'s list.

### D-409 — Keep service observation on the contract and let inspection see everything

**Status.** ratified

**Position.** Two rulings on observation by path.

- Observation by path is rejected. Service observation must speak the
  contract, while inspection observation sees everything, [§6.1][s6-1]'s knowledge
  rule applied to reads.
- The ignore list narrows the rejection. It reads no arbitrary cell. It
  addresses the `Build`'s requester roster, a build product like the
  root-input list, and it binds at an advance, a stopped-sim point where
  conditions already address state by path ([§14.1][s14-1]).

**Spec.** [§13.5][s13-5]

**Rationale.** The first bullet restates the ground of [D-060][d-060]'s rejection of
observation by path, which its Position does not state. The second restates
the paragraph of [D-316][d-316]'s Rationale on the narrowed rejection, which [D-060][d-060]'s
annotation of 2026-10-08 also records. [D-316][d-316]'s Position states neither.
[D-083][d-083]'s Position states the inspection half for output-device reads alone.
The entry decides nothing new.

**Rejected.** None beyond the source entries' lists.

### D-410 — Leave post-terminal dynamics to the model

**Status.** ratified

**Position.** Post-terminal dynamics are the model's job, and a model states
its own terminal dynamics.

**Spec.** [§13.5][s13-5]

**Rationale.** This restates the second ground of [D-060][d-060]'s rejection of
termination by exception, "models never state their terminal dynamics",
which its Position does not state. That Position makes termination model
state, never an exception. The entry decides nothing new.

**Rejected.** None beyond [D-060][d-060]'s list.

### D-411 — Spell the component test rig's stub as a `Constant` holding the test handle

**Status.** ratified

**Position.** `Constant` subsumes the rig stub. The concrete provider a rig
wires to an abstract face ([D-120][d-120]) is typically a `Constant` holding the test
handle, the block's first shipped instance. Bespoke stubs stay ordinary
components wherever the double must compute something.

**Spec.** [§13.7][s13-7]

**Rationale.** This restates the rig-stub clause of [D-143][d-143]'s Rationale, which
its Position does not state. That Position spells the block's other use, the
zero-contributor aggregate. The demonstrated-need charter the Rationale then
cites is retired ([D-313][d-313]), and the stub does not rest on it. The entry
decides nothing new.

**Rejected.** None beyond [D-143][d-143]'s list.

### D-412 — Pin a library block whose output depends on neither state nor a walking input

**Status.** ratified

**Position.** A library block whose output depends on neither its continuous
state nor a walking input, only on instance data and a mode, declares
`(out = Pinned{V},)`, as `Constant` does. `Step` and `Relay` are such
blocks. `UnitDelay` stays plain, because the discrete tier pins wholesale
([D-263][d-263]).

**Spec.** [§13.7][s13-7]

**Rationale.** This restates [D-312][d-312]'s annotation of 2026-10-06, which its
Position does not state. That Position pins `Constant` alone. The
annotation rests on the Rationale's ground for `Constant`. Such a block is
never seeded, carries zero partials under every activation, and its pinned
form is the more connectable one. The entry decides nothing new.

**Rejected.** None beyond [D-312][d-312]'s list.

### D-413 — Let the reason string, never the framework, tell a stop request's two uses apart

**Status.** ratified

**Position.** Validity breakdown and scenario completion share the
stop-request mechanism. The reason string is what tells a reader which, and
the framework never will.

**Spec.** [§13.5][s13-5]

**Rationale.** This restates a clause of [D-316][d-316]'s Rationale, which its
Position does not state. That Position makes `stop_reason` an optional
declaration whose string the requester roster carries. The clause before it,
that an ignored request is still a cell in every snapshot, follows from the
Position and is not restated. The entry decides nothing new.

**Rejected.** None beyond [D-316][d-316]'s list.

### D-414 — Check for an honoured request at an advance's entry, and bound `t_end` first

**Status.** ratified

**Position.** Two rulings on what every advance, `run!`, `replay!` and
`step!`, checks before its first frame.

- The advance reads the latest snapshot for an honoured stop request before
  its first frame. After `init!` that snapshot is boundary zero's, so an
  authored condition already terminal ends the run at `t₀` with that
  snapshot final, integrating nothing. An advance that starts later ends
  where it started, advancing no frame.
- A `t_end` that is not a non-negative real is refused as `ArgumentInvalid`,
  reason `:range`, before the ignore list is read.

**Spec.** [§13.5][s13-5]

**Rationale.** Both bullets record what the code does and [§13.5][s13-5] states.
`_advance!` in `src/sim.jl` calls `_stop_hit` on the latest snapshot before
its loop and returns `ModelRequestedStop` with no frame advanced.
`_bind_policy` calls `_t_bound`, which throws the `ArgumentInvalid`
fail-fast, before it validates the ignore list. [D-316][d-316]'s Position rules the
scan after every publication, not the entry read, and [D-255][d-255]'s says only that
`t_end` is validated per call. The entry decides nothing new.

**Rejected.** None beyond [D-255][d-255]'s and [D-316][d-316]'s lists.
