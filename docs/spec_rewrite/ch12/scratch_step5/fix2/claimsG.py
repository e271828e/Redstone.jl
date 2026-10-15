p='/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch12/units/G/claims.md'
s=open(p).read()
R=[
("added: This section specifies replay, re-running the ordinary loop on a recorded input trace.\n",
 "added: This section specifies replay, re-running the ordinary loop on a recorded input trace, so that a recorded session can be inspected, its errors reproduced and its run continued live.\n"),
("new: `replay!` is the entry point the §11.5 trace exists for:\ntag: X\nnote: framing sentence; it now names `replay!` as its subject\n",
 "new: `replay!` is the entry point the trace exists for (§11.5):\ntag: X\nnote: framing sentence; it now names `replay!` as its subject; the section number left the adjective slot (step 5, P2-22)\n"),
("new: Its drain reads the trace, and under the default form the loop starts from a restored state.\ntag: R\nruling: R9\nnote: the units section's two-forms rule; the restore is the default form's\n",
 "new: The substitution is the drain, which reads the trace. Under the default form, `replay!(sim2, trc)` above, the loop also starts from a restored state.\ntag: R\nruling: R9\nnote: the units section's two-forms rule; the restore is the default form's; the drain is the one substitution (D-274 bullet 4), and the default form is named by its call above (step 5, P2-24)\n"),
("new: It restores the trace's checkpoint (the `Model`'s state at a frame top as one value), the state the recording opened from.\n",
 "new: It restores the trace's checkpoint (the `Model`'s state at a frame top, beside the run's frame index and boundary ordinal), the state the recording opened from.\n"),
("old: There is no condition resolution, and the totality (§14.6) held when the recording's `init!` ran.\ntag: F\n",
 "old: There is no condition resolution, and the totality (§14.6) held when the recording's `init!` ran.\nnew: There is no condition resolution, and the root-input totality (every root input must hold a value) (§14.6) held when the recording's `init!` ran.\ntag: F\nnote: the term named and glossed as half 1 does (step 5, P2-25)\n"),
("new: The write-surface rule (§11.3) ran at recording time.\ntag: F\n",
 "new: The write-surface rule (the bound on the faces a writer's batch entries may reach) (§11.3) ran at recording time,\ntag: F\nnote: the write-surface and face glosses moved off the middle of the old sentence (step 5, P2-26)\n"),
("added: A write surface is the set of faces a writer's batch entries may reach, and a face is the name a port wears on its component's boundary.\n",
 "added: A face is the name a port wears on its component's boundary.\n"),
("new: Claims (the set of faces a device may write) are a live-roster fact of the recorded session that replay does not reconstruct.\n",
 "new: and claims (the set of faces a device may write) are a live-roster fact of the recorded session that replay does not reconstruct.\n"),
("old: That workflow halts at the frame top the error names, then `step!`s the failing frame on its recorded inputs.\ntag: F\n",
 "old: That workflow halts at the frame top the error names, then `step!`s the failing frame on its recorded inputs.\nnew: then `step!`s the failing frame on its recorded inputs\ntag: M\nnote: merged into the error-reproduction sentence of the halting block, whose frame-entry boundary `k` the error names is that frame top (F54) (step 5, P2-35)\n"),
("new: Either keyword names a frame from the one the feed starts from through the recording's last.\n",
 "new: Either keyword names a frame from the one the feed starts from through the recording's last\n"),
("new: Anything else is refused (`ArgumentInvalid`).\ntag: R\nruling: R10\nnote: F68\n",
 "new: and anything else is refused (`ArgumentInvalid`).\ntag: R\nruling: R10\nnote: F68; joined to the range sentence so \"else\" reads against the range (step 5, P2-28)\n"),
("new: A localized `t` boundary inside the frame (the crossing instant bracketed by root-finding over trial sweeps) is reproduced but not stoppable-at (D-128).\n",
 "new: A localized `t` boundary (the crossing instant bracketed by root-finding over trial sweeps) inside the frame is reproduced but not stoppable-at (D-128).\n"),
("new: A termination the recorded session hit through a stop request reproduces itself anyway, deterministically (D-127).\n",
 "new: A termination the recorded session hit through a stop request (an output port of the framework enum `StopFlag`) reproduces itself anyway, deterministically (D-127).\n"),
("old: Validation is the other keywords'.\ntag: F\n",
 "old: Validation is the other keywords'.\nnew: `to_time` is validated as the other keywords are.\ntag: F\n"),
("old: The flip above is automatic, and it happens only at the recording's end.\ntag: F\n",
 "old: The flip above is automatic, and it happens only at the recording's end.\nnew: The flip above is automatic.\ntag: F\nnote: \"only at the recording's end\" is stated by \"The halt flips the mode only at the recording's end\" above (step 5, P2-34)\n"),
("new: The trace `sim2` leaves behind is a complete recording of itself, the replayed prefix out to t = 100 and then the frames flown live after it.\ntag: F\nnote: mid-sentence colon removed\n",
 "new: The trace `sim2` leaves behind is a complete recording of itself, the replayed prefix out to t = 100 and then the frames flown live after it, since replay re-records (below).\ntag: F\nnote: mid-sentence colon removed; the pointer at \"Replay re-records\", which M56/M57 placed later (step 5, P2-36)\n"),
("new: Error reproduction replays to the frame-entry boundary `k` the error names, then `step!`s the failing frame under instrumentation (§13.4).\n",
 "new: Error reproduction replays to the frame-entry boundary `k` the error names, then `step!`s the failing frame on its recorded inputs, under instrumentation (§13.4).\n"),
("added: The control plane is the separate atomic surface carrying pause, pace and the stop word.\n",
 "added: The control plane is the separate atomic surface carrying pause, pace and stop.\n"),
("old: Replaying against the same structure with changed parameters is the what-if replay, the deterministic re-driving of the recorded inputs through a modified model.\ntag: M\nnote: block 5; bold term dropped\n",
 "old: Replaying against the same structure with changed parameters is the what-if replay, the deterministic re-driving of the recorded inputs through a modified model.\nnew: Replaying against the same structure with changed parameters is the what-if replay.\ntag: M\nnote: block 5; bold term dropped; the gloss is stated once, in the context paragraph, and \"deterministic\" by \"What-if replay promises determinism\" (step 5, P2-23)\n"),
("added: Under `restore = false` the simulation's own clock runs, its origin must equal the recording's, and the new trace's header is the simulation's own checkpoint.\n",
 "added: Under `restore = false` the simulation's own clock runs, and its origin must equal the recording's.\n"),
]
for o,n in R:
    assert s.count(o)==1,(o[:70],s.count(o))
    s=s.replace(o,n)
open(p,'w').write(s)
print('ok')
