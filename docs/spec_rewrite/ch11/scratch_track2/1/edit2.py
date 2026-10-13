import re, sys, textwrap, json
P = "/Users/miguel/.julia/dev/Redstone.jl/docs/design/decisions.md"
OUT = "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch11/scratch_track2/1/edit2_pairs.json"
D = "Annotation (2026-10-13): "
SP = "since D-310 every rostered device, the GUI included, runs on a spawned task, so "
A174 = ("amended by D-174. The derived interactive surface is retired; the GUI is "
        "an ordinary enumerated writer, and the harness writer is the one derived surface.")
# (item, entry, text, mode)
anns = [
 ("B-36", 268, "since D-310 no device runs on the calling task, and the wrapper records no release. The repeat arises in `run!`'s interrupt arm, which releases directly each device it never spawned and advances a cursor after each `shutdown!` returns; an interrupt between a return and the cursor's advance repeats that call (§11.6).", "rej"),
 ("B-37", 160, "no `mark_dead!` exists. A device's death is marked nowhere beyond its record: the task has ended, `task_state` says so at the next publication, and the heartbeat goes stale (§11.6, §12.2, D-138, D-193).", "rej"),
 ("B-38", 138, "since D-310, `needs_calling_task` and `gui = true` are withdrawn and no GUI ships, so the topology clause and the shipped GUI's `should_abort = true` are historical. \"Marks it dead\" in the Position means no task is spawned and the record shows it; nothing else marks a device dead (D-160's annotation).", "rej"),
 ("B-39", 102, SP + "the inline clause is historical, and claims stay to run end (D-106).", "rej"),
 ("B-39", 93, SP + "the GUI-without-task clause and the movable loop are historical.", "rej"),
 ("B-39", 132, SP + "the topology clause is historical; the wrapper's discrimination stands on the Position, an operator interrupt being a control-plane stop, not a failure.", "rej"),
 ("B-39", 25, SP + "main-thread affinity is gone, and widgets that read, modify and write remain the GUI's one peculiarity.", "rej"),
 ("B-40", 44, A174, "rej"),
 ("B-40", 106, A174, "rej"),
 ("B-40", 104, A174 + " The carrier is values-plus-mask since D-202.", "rej"),
 ("B-41", 134, "§11.6 no longer detects sides by method presence. D-177 declares them, and D-174 replaced the `interactive(b)` marker with `is_greedy`.", "rej"),
 ("B-42", 45, "since D-174 the GUI is an enumerated writer, so \"slot unclaimed\" reads \"slot inside the GUI's own claim\"; a face outside it is `OutOfClaimEntry` (D-044).", "rej"),
 ("B-43", 26, "resolution is baked at run start, when the GUI's loop body builds its port views after the roster freeze (D-270), not at build.", "rej"),
 ("B-44", 96, "`stage!` runs on any task (D-200) and writes the harness writer's cell (D-174). The harness cell still drains last, now as plain convention; the stated reason is objectless once surfaces are disjoint (D-174).", "rej"),
 ("B-45", 136, "amended by D-200 (the harness writer's cell), D-317 (the `Model`'s cell, folded into the loop's account), D-240 (the heartbeat is read at publication) and D-241 (one small vector of records per publication). The zero-allocation invariant is scoped to the stepping loop (D-305).", "rej"),
 ("B-46", 24, "amended by D-104, whose one policy, CAS merge, holds for every writer, so no writer overwrites. The harness writer's cell takes several staging tasks at once, so its retry is not bounded by drain interception alone (D-200).", "rej"),
 ("B-46", 38, "no private cells remain to include or filter (D-165, D-194), and the full-state capture is the checkpoint's, which the trace header now is (D-274).", "rej"),
 ("B-46", 83, "no local cells remain (D-165, D-194), so the clause on local cells and presentation filters is historical.", "rej"),
 ("B-46", 98, "D-252 removed auto-publication, so the remedy is to return the field from `output_state`.", "rej"),
 ("B-46", 105, "the rate limit is the diagnostic cell's bound, and 25 is a renderer's number (D-136).", "rej"),
 ("B-46", 137, "`log_max` is a keyword of `init!`, `restore!` and `replay!`, the doors that build a run, not of `Simulation` (D-261). A finite `log_max` is the log's `sizehint!` (§11.2), not a hint for the expected duration.", "rej"),
 ("B-46", 176, "the schema list left the header for the trace itself (D-255), so records convert against the trace's schema list.", "rej"),
 ("B-46", 203, "the effective policy no longer lives in the run metadata. The deployment holds no policy, and the termination record carries the terminating advance's (§11.5, D-255). The `t_end` rejection's ground, one home for the fact, stands.", "rej"),
 ("B-46", 103, "amended by D-177, which declares a binding's sides by Bool traits in place of method presence, and by D-146, which renames `faces` and `selectors` to `claims` and `reads`. The Rationale stands.", "rej"),
 ("B-46", 107, "superseded in part by D-176, whose one sparse record format replaces this entry's density rule: every writer's batch is sparse-converted at the drain.", "rej"),
 ("B-46", 127, "the trace header holds the `Deployment` and `t₀` and no policy, so the `t_end`/`stop_on` pair is not recorded (D-255). The terminating advance's policy is in the termination record.", "rej"),
 ("B-47", 252, "the dev-mode note is §11.2's.", "rej"),
 ("B-47", 274, "the persistence deferral is `pending.md`'s (Log and trace persistence) and Appendix B's, not §11.5's.", "rej"),
 ("B-47", 177, "§11.6 names the three rejections in one sentence citing this entry; the answer lives here.", "rej"),
 ("B-47", 216, "Appendix C's `DeploymentInvalid` row names deployment parameters alone; the run-shaping keywords left it. `log`, `log_every` and `log_max` are keywords of the doors (D-261), `t_end` of `run!` and `replay!` (D-255), and `join_timeout` stays a `Simulation` keyword (D-261). Appendix C validates the `Simulation` constructor's keywords under `ArgumentInvalid`, whose call list also names `init!`, `restore!`, `run!` and `replay!`.", "rej"),
 ("B-50", 217, "the length is the frame ordinal of the last drain (D-260), which under `init!` equals the number of drains since the header; a trace that `restore!` opens starts at the checkpoint's frame (D-274).", "rej"),
 ("B-50", 255, "the length is the frame ordinal of the last drain (D-260), which under `init!` equals the number of drains since the header; a trace that `restore!` opens starts at the checkpoint's frame (D-274).", "end"),
]
def wrap(s):
    return "\n".join(textwrap.wrap(s, 78, break_long_words=False, break_on_hyphens=False))
t = open(P, encoding="utf-8").read()
pairs = []
# B-35 Spec fields
pairs.append(("B-35 D-136",
 "**Spec.** [§9.8][s9-8], [§10.7][s10-7], [§11.1][s11-1], [§11.2][s11-2], [§11.4][s11-4], [§11.6][s11-6], [§11.8][s11-8], [§12.2][s12-2], [§12.4][s12-4], [§13.2][s13-2], [§13.5][s13-5],\nAppendices C/D",
 "**Spec.** §9.8, §10.7, §11.2, §11.6, §11.8, §12.2, §12.4, §13.2, §13.5, Appendices C/D"))
pairs.append(("B-35 D-168",
 "**Spec.** [§6.1][s6-1], [§11.3][s11-3], [§8.2][s8-2], [§14.10][s14-10]",
 "**Spec.** §6.1, §8.2, §14.10"))
heads = [(m.start(), int(m.group(1))) for m in re.finditer(r'(?m)^### D-(\d{3}) — ', t)]
def entry(n):
    for i,(s,k) in enumerate(heads):
        if k == n:
            e = heads[i+1][0] if i+1 < len(heads) else t.find("\n<!-- citation link definitions")
            return t[s:e]
    sys.exit(f"no entry {n}")
for item, n, text, mode in anns:
    body = entry(n)
    ann = wrap(D + text)
    if mode == "rej":
        k = body.find("\n\n**Rejected.**\n")
        if k < 0 or body.count("\n\n**Rejected.**\n") != 1: sys.exit(f"{n}: rejected")
        p = body.rfind("\n\n", 0, k) + 2
        first = body[k+2:].split("\n")[1]
        old = body[p:k] + "\n\n**Rejected.**\n" + first
        new = body[p:k] + "\n\n" + ann + "\n\n**Rejected.**\n" + first
    else:
        tail = body.rstrip("\n")
        p = tail.rfind("\n\n") + 2
        nxt = t[t.find(body)+len(body):].split("\n")[0]
        gap = body[len(tail):]
        old = tail[p:] + gap + nxt
        new = tail[p:] + "\n\n" + ann + gap + nxt
    pairs.append((f"{item} D-{n:03d}", old, new))
for tag, old, new in pairs:
    c = t.count(old)
    if c != 1: sys.exit(f"{tag}: matches {c}")
for tag, old, new in pairs:
    t = t.replace(old, new, 1)
open(P, "w", encoding="utf-8").write(t)
json.dump(pairs, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print(len(pairs), "edits")
