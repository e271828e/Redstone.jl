import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from fixlib import para_containing, rewrap_block

UNITS = '/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch12/units'
# (finding, unit, paragraph locator, [(old, new), ...]); empty list = rewrap only
E = [
 ('P2-1', 'F', 'This section settles what the', [
   ("eliminates `user_callback!`,", "eliminates FlightCore's per-step hook `user_callback!`,")]),
 ('P2-40', 'F', 'A sim-time script becomes a', []),
 ('P2-2', 'F', 'Inputs arrive fresh from the same', []),
 ('P2-3', 'F', 'In a scenario configuration the script', [
   ("renders the corresponding GUI widgets read-only with its source shown. The port-resolution rule resolves FlightCore's demo-vs-GUI dead-slider fight ([§11.7][s11-7]).",
    "renders the corresponding GUI widgets read-only, each showing its source. Its port-resolution rule resolves FlightCore's demo-vs-GUI dead-slider fight.")]),
 ('P2-5', 'F', 'Mid-run re-initialization is not built', [
   ("Initialization and trim are stopped-sim workflows (first-class services, [§14][s14]).",
    "Initialization and trim are stopped-sim workflows, first-class services of [§14][s14].")]),
 ('P2-6', 'F', 'Mid-run re-initialization is not built', [
   ("so that no consumer ever observes un-decoded state.",
    "so that no consumer ever observes un-decoded state. A sweep is one pass through the execution order against the current state.")]),
 ('P2-7', 'F', 'This section specifies what a `Simulation`', [
   ("how it advances and restarts, and what it keeps of its [devices](#g-device) (any attached participants in the periphery) across runs.",
    "how it advances and restarts, what it keeps of its [devices](#g-device) (any attached participants in the periphery) across runs, and the stop policy each advance declares.")]),
 ('P2-8', 'F', 'This section specifies what a `Simulation`', [
   (" In `:live` they come from the [staging cells](#g-staging-cell) (where each device's pending batch waits between drains), and in `:replay` from the attached recording.", "")]),
 ('P2-8', 'F', 'Four fields evolve during the run.', [
   ("`feed` is the recording `replay!` attached, or `nothing`.", "`feed` is described above.")]),
 ('P2-8', 'F', 'Beside the state, the run carries', [
   ("the staging cells or the attached recording ([§12.7]",
    "the [staging cells](#g-staging-cell) (where each device's pending batch waits between drains) or the attached recording ([§12.7]")]),
 ('P2-9', 'F', 'is what one run owns', [
   ("which is `nothing` under the trace switch.", "which is `nothing` under `trace = false`.")]),
 ('P2-10', 'F', 'Four fields evolve during the run.', [
   ("`restore!` and `replay!` to the checkpoint's, and the loop",
    "`restore!` and `replay!` to those of the [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top, beside the run's frame index and boundary ordinal), and the loop")]),
 ('P2-10', 'F', 'is not a run field', [
   ("A [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value) carries it", "A checkpoint carries it")]),
 ('P2-11', 'F', 'is not a run field', [
   ("The executor's clock holds it beside `t`.",
    "The clock of the [executor](#g-executor) (the compiled form of the stage execution order) holds it beside `t`.")]),
 ('P2-11', 'F', 'is a mutable struct of four fields', [
   ("the [executor](#g-executor), its status", "the executor, its status"),
   ("The executor is the compiled form of the stage execution order, and a diagnostic cell is a writer's own holding place for runtime diagnostics.",
    "A diagnostic cell is a writer's own holding place for runtime diagnostics.")]),
 ('P2-12', 'F', 'is not a run field', [
   ("the initialization boundary ([§14.5][s14-5])",
    "the initialization boundary run as the ordinary macro-sequence with an empty integrate ([§14.5][s14-5])")]),
 ('P2-12', 'F', 'moves through five states', [
   ("has completed boundary zero, the initialization boundary run as the ordinary macro-sequence with an empty integrate ([§14.5][s14-5]), or",
    "has completed boundary zero ([§14.5][s14-5]), or")]),
 ('P2-13', 'F', 'is a mutable struct of four fields', [
   ("the data plane and the control plane ([D-317][d-317])", "the data plane ([§11][s11]) and the control plane ([D-317][d-317])")]),
 ('P2-13', 'F', 'Every other value belongs to one of the four', [
   ("its account and the published holder are the plane's,",
    "its account and the published-snapshot holder ([§11.2][s11-2]) are the data plane's,")]),
 ('P2-40', 'F', 'Deviceless, `run!` is fully synchronous', []),
 ('P2-16', 'F', 'The frame-top drain still runs', [
   ("(the always-present staging cell of the harness writer). The harness write path is `stage!(sim, \"face\" => value, …)`, and [§11.3][s11-3] specifies that [harness writer](#g-harness-writer).",
    "(the always-present staging cell of the [harness writer](#g-harness-writer)). The harness write path is `stage!(sim, \"face\" => value, …)`, and [§11.3][s11-3] specifies the writer.")]),
 ('P2-17', 'F', 'Termination policy is honored', [
   ("Termination policy is honored throughout,", "The stop policy is honoured throughout,")]),
 ('P2-18', 'F', 'The stop policy is honoured throughout', [
   ("[holding](#g-edge-semantics) at frame 3", "[holding](#g-edge-semantics) (publishing `STOP_REQUESTED`) at frame 3")]),
 ('P2-40', 'F', 'The stop policy is declared per advance', []),
 # unit G
 ('P2-22', 'G', 'This section specifies [replay](#g-replay)', [
   ("on a recorded input [trace](#g-trace). A trace is",
    "on a recorded input [trace](#g-trace), so that a recorded session can be inspected, its errors reproduced and its run continued live. A trace is"),
   ("`replay!` is the entry point the [§11.5][s11-5] trace exists for:",
    "`replay!` is the entry point the trace exists for ([§11.5][s11-5]):")]),
 ('P2-10', 'G', 'The default form restores from the header.', [
   ("[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value)",
    "[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top, beside the run's frame index and boundary ordinal)")]),
 ('P2-24', 'G', 'is the ordinary loop with exactly one substitution', [
   ("Its drain reads the trace, and under the default form the loop starts from a restored state.",
    "The substitution is the drain, which reads the trace. Under the default form, `replay!(sim2, trc)` above, the loop also starts from a restored state.")]),
 ('P2-25', 'G', 'The default form restores from the header.', [
   ("and the totality ([§14.6][s14-6]) held",
    "and the [root-input totality](#g-root-input-totality) (every root input must hold a value) ([§14.6][s14-6]) held")]),
 ('P2-26', 'G', 'Each frame top applies the recording', [
   ("The [write-surface](#g-write-surface) rule ([§11.3][s11-3]) ran at recording time. A write surface is the set of [faces](#g-face) a writer's batch entries may reach, and a face is the name a port wears on its component's boundary. [Claims](#g-claim) (the set of faces a device may write) are a live-roster fact of the recorded session that replay does not reconstruct.",
    "The [write-surface](#g-write-surface) rule (the bound on the [faces](#g-face) a writer's batch entries may reach) ([§11.3][s11-3]) ran at recording time, and [claims](#g-claim) (the set of faces a device may write) are a live-roster fact of the recorded session that replay does not reconstruct. A face is the name a port wears on its component's boundary.")]),
 ('P2-35', 'G', 'A mode that outlives the call', [
   ("with no replay-only spelling of `step!`. That workflow halts at the frame top the error names, then `step!`s the failing frame on its recorded inputs.",
    "with no replay-only spelling of `step!`.")]),
 ('P2-28', 'G', 'the recording is the bound', [
   ("through the recording's last. The feed starts from the header's frame under the default form, and from the simulation's own under `restore = false` (below). Anything else is refused (`ArgumentInvalid`).",
    "through the recording's last, and anything else is refused (`ArgumentInvalid`). The feed starts from the header's frame under the default form, and from the simulation's own under `restore = false` (below).")]),
 ('P2-30', 'G', 'takes the frame-entry boundary index', [
   ("`t*` boundary inside the frame (the crossing instant bracketed by root-finding over trial sweeps) is",
    "`t*` boundary (the crossing instant bracketed by root-finding over trial sweeps) inside the frame is")]),
 ('P2-31', 'G', 'Replay may also end earlier still', [
   ("hit through a stop request reproduces",
    "hit through a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`) reproduces")]),
 ('P2-33', 'G', "Validation is the other keywords'.", [
   ("Validation is the other keywords'.", "`to_time` is validated as the other keywords are.")]),
 ('P2-34', 'G', 'is the one call that moves the mode alone', [
   ("The flip above is automatic, and it happens only at the recording's end.", "The flip above is automatic.")]),
 ('P2-36', 'G', 'leaves behind is a complete recording', [
   ("the frames flown live after it.", "the frames flown live after it, since replay re-records (below).")]),
 ('P2-35', 'G', "A replay's halt leaves the simulation", [
   ("then `step!`s the failing frame under instrumentation",
    "then `step!`s the failing frame on its recorded inputs, under instrumentation")]),
 ('P2-37', 'G', 'are unchanged', [
   ("carrying pause, pace and the stop word.", "carrying pause, pace and stop.")]),
 ('P2-40', 'G', 'Validation is loud and up front', []),
 ('P2-38', 'G', 'Under the default form the clock is', [
   ("Under `restore = false` the simulation's own clock runs, its origin must equal the recording's, and the new trace's header is the simulation's own checkpoint.",
    "Under `restore = false` the simulation's own clock runs, and its origin must equal the recording's.")]),
 ('P2-23', 'G', 'Replaying against the same structure', [
   ("is the what-if replay, the deterministic re-driving of the recorded inputs through a modified model.", "is the what-if replay.")]),
 ('P2-39', 'G', 'attaches the feed to the simulation as it stands and restores nothing', []),
]

def main():
    log = ['# Chapter 12, step 5: editorial fixes, half 2', '',
           'Fixer fix2 applied these edits to `units/F/new.md` and `units/G/new.md`, in',
           'order, on top of `69a3191`. Each entry replaces its old text, verbatim and',
           'found exactly once in the unit\'s file at that point of the sequence, with its',
           'new text. Each edited paragraph is rewrapped to 80 rendered columns.', '']
    for k, (fid, u, loc, reps) in enumerate(E, 1):
        p = f'{UNITS}/{u}/new.md'
        src = open(p).read()
        a, b = para_containing(src, loc)
        old = src[a:b]
        new = rewrap_block(old, reps)
        assert new != old or not reps, fid
        if new == old:
            print('no change', fid, loc); continue
        assert src.count(old) == 1
        src = src[:a] + new + src[b:]
        open(p, 'w').write(src)
        what = 'rewrap only' if not reps else 'edit and rewrap'
        log += [f'## {k}. {fid}, unit {u} ({what})', '', 'Old:', '', '````text', old, '````', '',
                'New:', '', '````text', new, '````', '']
    open(sys.argv[1], 'w').write('\n'.join(log))

main()
