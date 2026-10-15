"""Apply agent 1's log edits (B41-B75) to decisions.md by exact old text.

Reads the file, asserts every old text matches exactly once before writing,
applies the edits in order, and writes the replay log section.
Usage: python3 -I log_edits.py <decisions.md> <log_out.md>
"""
import sys

E = []  # (label, item, old, new)


def spec(label, item, old, new):
    E.append((label, item, old, new))


def annot(label, item, anchor, text):
    """Insert an annotation paragraph after `anchor` (which ends in a newline)."""
    E.append((label, item, anchor, anchor + "\n" + text.strip("\n") + "\n"))


# ---- B41: Spec fields --------------------------------------------------
spec("D-021 Spec", "B41",
     "**Spec.** [§10.7][s10-7]\n",
     "**Spec.** [§10.7][s10-7], §12.1, §12.2\n")
spec("D-022 Spec", "B41",
     "**Spec.** [§2][s2], [§11.1][s11-1]\n",
     "**Spec.** [§2][s2], [§11.1][s11-1], §12.1, §12.3\n")
spec("D-045 Spec", "B41",
     "**Spec.** [§4.3][s4-3], [§11.4][s11-4], [§11.6][s11-6], [§11.7][s11-7]\n",
     "**Spec.** [§4.3][s4-3], [§11.4][s11-4], [§11.6][s11-6], [§11.7][s11-7], §12.5\n")
spec("D-060 Spec", "B41",
     "**Spec.** [§9.3][s9-3], [§13.5][s13-5], [§14.4][s14-4]\n",
     "**Spec.** [§9.3][s9-3], §12.4, §12.5, [§13.5][s13-5], [§14.4][s14-4]\n")
spec("D-108 Spec", "B41",
     "**Spec.** [§11.3][s11-3], [§13.6][s13-6], [§14][s14]\n",
     "**Spec.** [§11.3][s11-3], §12.6, §12.7, [§13.6][s13-6], [§14][s14]\n")
spec("D-228 Spec", "B41",
     "**Spec.** [§11.8][s11-8], [Appendix C][sC]\n",
     "**Spec.** [§11.8][s11-8], §12.4, [Appendix C][sC]\n")
spec("D-366 Spec", "B41",
     "each with a no-op default.\n\n**Spec.** [§11.6][s11-6]\n",
     "each with a no-op default.\n\n**Spec.** [§11.6][s11-6], §12.4\n")
spec("D-372 Spec", "B41",
     "The obligation is taught ([§11.6][s11-6], [Appendix A][sA]).\n\n**Spec.** [§11.6][s11-6]\n",
     "The obligation is taught ([§11.6][s11-6], [Appendix A][sA]).\n\n**Spec.** [§11.6][s11-6], §12.4\n")
spec("D-373 Spec", "B41",
     "(`DeviceJoinTimeout`, a stale heartbeat), never forced.\n\n**Spec.** [§11.6][s11-6]\n",
     "(`DeviceJoinTimeout`, a stale heartbeat), never forced.\n\n**Spec.** [§11.6][s11-6], §12.4\n")
spec("D-374 Spec", "B41",
     "**Spec.** [§11.3][s11-3], [§11.4][s11-4], [§11.6][s11-6]\n",
     "**Spec.** [§11.3][s11-3], [§11.4][s11-4], [§11.6][s11-6], §12.2, §12.4\n")
spec("D-381 Spec", "B41",
     "**Spec.** [§11.6][s11-6], [§D.6][sD-6]\n",
     "**Spec.** [§11.6][s11-6], §12.4, [§D.6][sD-6]\n")

# ---- B43: D-030 Spec field and annotation --------------------------------
spec("D-030 Spec and annotation", "B43",
     "`should_close` path; loop failure runs the same protocol from the catch path.\n"
     "\n**Rationale.** Recorded only through the rejections below.\n",
     "`should_close` path; loop failure runs the same protocol from the catch path.\n"
     "\n**Spec.** §12.4, §13.6\n"
     "\n**Rationale.** Recorded only through the rejections below.\n"
     "\nAnnotation (2026-10-15): since D-373 `should_close` dissolves into the loop\n"
     "body returning, a voluntary exit. A crashing device task is caught by the\n"
     "framework wrapper (D-102) and follows the same path, and it requests a sim\n"
     "stop only if the device's `should_abort` is set (§12.4).\n")

# ---- B44: D-031 ----------------------------------------------------------
annot("D-031 annotation", "B44",
      "**Spec.** [§11.3][s11-3], [§12.5][s12-5], [§14][s14]\n\n"
      "**Rationale.** Recorded only through the rejections below.\n",
      'Annotation (2026-10-15): the "slot" of "manual events = slot + guard" is a\n'
      "root input since D-206.\n")

# ---- B47: D-088 ----------------------------------------------------------
annot("D-088 annotation", "B47",
      "*actually* advanced; `t_end`/`stop_on` re-bindable per run at `run!` ([D-091][d-091]);\n"
      "`errored` terminal ([D-059][d-059]).\n",
      "Annotation (2026-10-15): `UninitializedSlots` is `UninitializedInputs` since\n"
      "D-206. Since D-255 `init!` allocates a fresh trace and log rather than\n"
      "clearing them, and D-255 supersedes D-091: `t_end` and `stop_on` are\n"
      "keywords of `run!` and `replay!`, validated per call. `stop_on` is\n"
      "`ignore_stop_requests` since D-316.\n")

# ---- B50: D-097 ----------------------------------------------------------
annot("D-097 annotation", "B50",
      "separation already treats the crash path as its own species.\n",
      "Annotation (2026-10-15): amended by D-228. A rate-limited diagnostic kind\n"
      "names its subjects in the payload and never its writer, and `DeviceCrash`\n"
      "is written to the crashing device's own cell, so its payload is the\n"
      "exception as `cause` and whether `should_abort` was set, with no device id\n"
      "(Appendix C).\n")

# ---- B51: D-101 ----------------------------------------------------------
annot("D-101 annotation", "B51",
      "parametric difference = the what-if replay (determinism promised,\n"
      "reproduction only against the identical build).\n",
      "Annotation (2026-10-15): amended by D-174, D-176, D-255 and D-274. Since\n"
      "D-274 the header is the checkpoint `init!` takes at the end of boundary\n"
      "zero, and replay restores it and feeds the batches, so the two\n"
      "substitutions become one, the drain fed by the recording: `init!` is the\n"
      "only door that runs boundary zero. The interactive writer is the harness\n"
      "writer since D-174. Since D-176 every writer's drained batch is\n"
      "sparse-converted at the drain, so the trace has one record format and\n"
      "replay one inverse-conversion path, and since D-255 the schemas are a list\n"
      "on the trace, not in its header. `ReplayHeaderMismatch` is\n"
      "`CheckpointMismatch` (Appendix C).\n")

# ---- B53: D-110 ----------------------------------------------------------
annot("D-110 annotation", "B53",
      "guards-at-commit, `t0` anchoring, and the [§12.6][s12-6] three-item clear (trace, log,\n"
      "staged batches).\n",
      "Annotation (2026-10-15): amended by D-273. `capture` no longer produces a\n"
      "condition, and a resume is a checkpoint and a restore, so resume-at-time is\n"
      "no longer spelled through `capture`'s returned `t` passed as `t0`.\n")

# ---- B54: D-114 ----------------------------------------------------------
annot("D-114 annotation", "B54",
      "**Spec.** [§10.4][s10-4], [§12.3][s12-3], [§13.4][s13-4]\n\n"
      "**Rationale.** Recorded only through the rejections below.\n",
      "Annotation (2026-10-15): amended by D-230. A snapshot carries the\n"
      "trajectory's published-boundary ordinal, and the wait counter is a\n"
      "separate, monotone count that is never reset, so the loop state the wait\n"
      "predicate tests no longer mirrors the snapshot's index.\n")

# ---- B55: D-127 ----------------------------------------------------------
annot("D-127 annotation", "B55",
      "no policy, so the `t_end`/`stop_on` pair is not recorded ([D-255][d-255]). The\n"
      "terminating advance's policy is in the termination record.\n",
      "Annotation (2026-10-15): `n` is `N_base` since D-234, and `event_budget` is\n"
      "`localization_budget` since D-181. `ReplayHeaderMismatch` is\n"
      "`CheckpointMismatch` (Appendix C).\n")

# ---- B56: D-128 ----------------------------------------------------------
spec("D-128 Spec", "B56",
     "**Spec.** [§10.4][s10-4], [§12.6][s12-6], [§12.7][s12-7], [§13.4][s13-4], [Appendix C][sC]\n",
     "**Spec.** [§10.4][s10-4], §12.3, [§12.6][s12-6], [§12.7][s12-7], [§13.4][s13-4], [Appendix C][sC]\n")
annot("D-128 annotation", "B56",
      "**Rationale.** The boundary counter stays the reporting index ([§10.4][s10-4]'s\n"
      "counter/frame-ordinal separation intact).\n",
      "Annotation (2026-10-15): amended by D-230. The index a snapshot reports is\n"
      "the trajectory's published-boundary ordinal, and the boundary counter is\n"
      "the wait's separate, monotone count, its absolute value nowhere normative.\n")

# ---- B57: D-132 (E1 clause left) -----------------------------------------
annot("D-132 annotation", "B57",
      "discrimination stands on the Position, an operator interrupt being a\n"
      "control-plane stop, not a failure.\n",
      "Annotation (2026-10-15): since D-310 no device runs on the calling task, so\n"
      '§12.4(5) has no asymmetry left, and the clause on "(5)\'s honest asymmetry"\n'
      "above is historical. `stop_on` is `ignore_stop_requests` since D-316: a\n"
      "model's stop request ends the run unless the advance ignores it.\n")

# ---- B58: D-133 ----------------------------------------------------------
annot("D-133 annotation", "B58",
      "algorithm, `event_budget` is `localization_budget`, and `firing_budget` joins\n"
      "them as a third recorded parameter.\n",
      "Annotation (2026-10-15): amended by D-198 and D-316. The join timeout is\n"
      "`join_timeout`, a keyword defaulting to 5 s (D-198). `stop_on` is\n"
      "`ignore_stop_requests` since D-316: a model's stop request ends the run at\n"
      "the first publication where it holds, unless the advance ignores it.\n")

# ---- B60: D-138 ----------------------------------------------------------
annot("D-138 annotation", "B60",
      "task is spawned and the record shows it; nothing else marks a device dead\n"
      "([D-160][d-160]'s annotation).\n",
      "Annotation (2026-10-15): the bracket runs at the top of a run, and a run\n"
      "need not start at boundary zero, so the Rationale's boundary-zero clauses\n"
      "read at the run's start (§12.4). A failed device is dead from the run's\n"
      "first frame top. Its orphaned root inputs, the slots of the Rationale since\n"
      "D-206, hold the values the run started with, well-defined by root-input\n"
      "totality (§14.6). With `should_abort` clear the device is absent from the\n"
      "run's first frame. With it set the stop is pending at the run's first\n"
      "frame top, which the loop reads before any frame, so the run advances no\n"
      "frame and ends `stopped` where it started, its terminal snapshot the one\n"
      "it started from. `DeviceCrash`'s payload names no device id since D-228.\n"
      "The cell it is written to names the device.\n")

# ---- B61: D-198 ----------------------------------------------------------
annot("D-198 annotation", "B61",
      "and stays replay-blind, the `log_max` disposition ([§11.2][s11-2]). One value for the\n"
      "whole tail: the join loop has one patience.\n",
      "Annotation (2026-10-15): amended by D-256 and D-317. D-256 moves\n"
      "`join_timeout` into `Control`, and D-317 makes it a keyword of\n"
      "`Simulation(model::Model{Float64}; join_timeout = 5.0)`. The Rationale's\n"
      '"Deployment contexts" are contexts of use, not the `Deployment`. §12.4 says\n'
      '"usage contexts".\n')

# ---- B62: D-217 ----------------------------------------------------------
annot("D-217 annotation", "B62",
      "trace that `restore!` opens starts at the checkpoint's frame ([D-274][d-274]).\n"
      "\n**Rejected.**\n- *A mutable termination slot in the header, rewritten at every advance:* one\n",
      "")  # placeholder, replaced below
E.pop()
E.append(("D-217 annotation", "B62",
          "trace that `restore!` opens starts at the checkpoint's frame ([D-274][d-274]).\n"
          "\n**Rejected.**\n- *A mutable termination slot in the header, rewritten at every advance:* one\n",
          "trace that `restore!` opens starts at the checkpoint's frame ([D-274][d-274]).\n"
          "\nAnnotation (2026-10-15): `ReplayHeaderMismatch` is `CheckpointMismatch`\n"
          "(Appendix C).\n"
          "\n**Rejected.**\n- *A mutable termination slot in the header, rewritten at every advance:* one\n"))

# ---- B63: D-218 ----------------------------------------------------------
annot("D-218 annotation", "B63",
      "and keeps going, so every frame of a session is either record-driven or live,\n"
      "and which one it was is readable before it runs.\n",
      "Annotation (2026-10-15): since D-274 replay restores the header and runs no\n"
      "boundary zero, so D-101's two substitutions are one, the drain fed by the\n"
      "recording.\n")

# ---- B65: D-223 ----------------------------------------------------------
annot("D-223 annotation", "B65",
      "that threw left a warm simulation reporting `initialized` with the clock reset\n"
      "and the stores half-transitioned, and `step!` advanced on them.\n",
      "Annotation (2026-10-15): since D-274 `init!` is the only door that runs\n"
      "boundary zero, so a throw inside boundary zero comes under `init!` alone.\n")

# ---- B66: D-230 ----------------------------------------------------------
annot("D-230 annotation", "B66",
      "boundary index, a frame count that can name no `t*` boundary; [§10.4][s10-4] and\n"
      "[§12.3][s12-3] had called it the counter and now name it as what it is. The cost is\n"
      "one field beside the clock, reset with it and stamped at publication.\n",
      "Annotation (2026-10-15): amended by D-274. A `restore!` of a checkpoint\n"
      "opens a fresh run, but the boundary ordinal continues, being the\n"
      "trajectory's (§12.3).\n")

# ---- B67: D-249 ----------------------------------------------------------
annot("D-249 annotation", "B67",
      "member set; a `Pinned` entry on a discrete leaf joins it ([D-263][d-263]).\n",
      "Annotation (2026-10-15): the fourth bullet is historical. D-316 retires the\n"
      "`stop_on` keyword and `StopFaceInvalid`.\n")

# ---- B69: D-255 ----------------------------------------------------------
E.append(("D-255 annotation", "B69",
          "trace that `restore!` opens starts at the checkpoint's frame ([D-274][d-274]).\n"
          "\n\n### D-256 — ",
          "trace that `restore!` opens starts at the checkpoint's frame ([D-274][d-274]).\n"
          "\nAnnotation (2026-10-15): D-260 supersedes the first bullet's `Run`, and\n"
          "with D-261 the placeholder. `t₀` and the mode are not run fields, and the\n"
          "placeholder run is an empty log and no trace. D-317 supersedes the clause\n"
          "keeping the lifecycle on `Control`. `Control` holds a running flag, and\n"
          "`lifecycle(sim)` derives the state.\n"
          "\n\n### D-256 — "))

# ---- B70: D-260 ----------------------------------------------------------
annot("D-260 annotation", "B70",
      "A `Float64` origin also lets `init!` take `t0 = 0.25` on a `Dual`\n"
      "simulation, which a `T`-typed keyword refused.\n",
      "Annotation (2026-10-15): D-317 supersedes the first bullet's four-field\n"
      "`Run`. The frame index and the boundary ordinal are the run's counters.\n")

# ---- B71: D-261 ----------------------------------------------------------
annot("D-261 annotation", "B71",
      "one entry per requester, in place of the faces' compiled addresses, and a\n"
      "`t*` stop hit is a requester or `nothing`.\n",
      "Annotation (2026-10-15): D-317 supersedes the clause keeping `chunk_size`\n"
      "on `Simulation(deployment, T)`. `chunk_size` is a keyword of\n"
      "`Model(deployment, T = Float64; chunk_size = 16)`.\n")

# ---- B72: D-268 ----------------------------------------------------------
annot("D-268 annotation", "B72",
      "after each `shutdown!` returns; an interrupt between a return and the cursor's\n"
      "advance repeats that call ([§11.6][s11-6]).\n",
      "Annotation (2026-10-15): the stop faces of the second bullet and the\n"
      "Rationale are stop requests since D-316. Since D-274 `restore!` copies a\n"
      "checkpoint's state back, and replay is a restore followed by the feed, so\n"
      "the stores of the second 2026-09-26 annotation may hold mid-boundary values\n"
      "until the next `init!`, `restore!` or `replay!` (§12.4).\n")

# ---- B74: D-274 ----------------------------------------------------------
spec("D-274 Spec", "B74",
     "[§12.6][s12-6], [§12.7][s12-7], [§13.7][s13-7], [§14.8][s14-8], [§14.10][s14-10], [Appendix B][sB]\n",
     "[§12.6][s12-6], [§12.7][s12-7], §14, [§14.8][s14-8], [§14.10][s14-10], [Appendix B][sB]\n")
annot("D-274 annotation", "B74",
      "Annotation (2026-10-13): the persistence deferral is `pending.md`'s (Log and\n"
      "trace persistence) and [Appendix B][sB]'s, not [§11.5][s11-5]'s.\n",
      "Annotation (2026-10-15): the stopped-sim services are §14, so the second\n"
      "bullet's §13.7 reads §14.\n")

# ---- B75: D-319 ----------------------------------------------------------
spec("D-319 Spec", "B75",
     "**Spec.** [§9.2][s9-2], [§11.5][s11-5], [§12.6][s12-6], [§14][s14], [§14.5][s14-5], [§14.8][s14-8], [§14.10][s14-10], [Appendix B][sB], [Appendix C][sC]\n",
     "**Spec.** [§9.2][s9-2], [§11.5][s11-5], §12.4, [§12.6][s12-6], §12.7, [§14][s14], [§14.5][s14-5], [§14.8][s14-8], [§14.10][s14-10],\n"
     "[Appendix B][sB], [Appendix C][sC]\n")


def main(path, logpath):
    text = open(path, encoding="utf-8").read()
    bad = [(l, text.count(o)) for (l, _, o, _) in E if text.count(o) != 1]
    if bad:
        for l, c in bad:
            print(f"MISMATCH {l}: {c} matches")
        sys.exit(1)
    for (_, _, o, n) in E:
        assert text.count(o) == 1
        text = text.replace(o, n, 1)
    open(path, "w", encoding="utf-8").write(text)
    with open(logpath, "w", encoding="utf-8") as g:
        for i, (l, item, o, n) in enumerate(E, 1):
            g.write(f"### L{i}. {item}: {l}\n\nOld:\n\n```\n{o}```\n\nNew:\n\n```\n{n}```\n\n")
    print(f"applied {len(E)} edits")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
