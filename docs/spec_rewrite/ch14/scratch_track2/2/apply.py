"""Agent 2's track 2 edits: D-415 to D-426 into the log, their citations into
chapter 14. Every old text must occur exactly once; all are checked before any
file is written. Prints each edit for the log."""
import sys

ROOT = "/Users/miguel/.julia/dev/Redstone.jl/docs/design/"
HERE = "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/scratch_track2/2/"
MARK = "<!-- citation link definitions"

# (label, old, new) in chapter order
SPEC = [
 ("G1 D-415, §14 lead",
  "payload is the operation, the current status and the legal statuses. It is the",
  "payload is the operation, the current status and the legal statuses (D-415). It is the"),
 ("G13 D-425, §14 lead",
  "`init!`, `restore!`, `trim!` and `linearize` with an explicit `about` are legal\nat any status. A model",
  "`init!`, `restore!`, `trim!` and `linearize` with an explicit `about` are legal\nat any status (D-425). A model"),
 ("G2 D-416, §14.1",
  "**\"Caller-computable\" reaches past closed-form knowledge to environment queries**\n([D-139][d-139]).",
  "**\"Caller-computable\" reaches past closed-form knowledge to environment queries**\n([D-139][d-139], D-416)."),
 ("G5 D-277, §14.2",
  "`ConditionResolution` with reason `:internally_wired`. Unexported stays",
  "`ConditionResolution` with reason `:internally_wired` (D-277). Unexported stays"),
 ("G10 D-423, §14.4",
  "`ConditionShapeDrift` ([Appendix C][sC]), reason `:tree_type` or `:prefix`, a",
  "`ConditionShapeDrift` ([Appendix C][sC], D-423), reason `:tree_type` or `:prefix`, a"),
 ("G4 D-418, §14.4",
  "the head is matched\nrather than parsed. The head is",
  "the head is matched\nrather than parsed (D-418). The head is"),
 ("G8 D-421, §14.8",
  "The tolerance translation is the service's too, per backend family ([D-150][d-150]). In",
  "The tolerance translation is the service's too, per backend family ([D-150][d-150], D-421). In"),
 ("G9 D-422, §14.8 (1)",
  "- A box with `lower` above `upper`.\n",
  "- A box with `lower` above `upper` (D-422).\n"),
 ("G9 D-422, §14.8 (2)",
  "- A tolerance or check tolerance that is not finite and positive.\n",
  "- A tolerance or check tolerance that is not finite and positive (D-422).\n"),
 ("G5 D-277, §14.9",
  "`ReadResolution` for\na `get_input`. The service compiles",
  "`ReadResolution` for\na `get_input` (D-277). The service compiles"),
 ("G3 D-417, §14.9",
  "**A problem never authors the environment** ([D-139][d-139]).",
  "**A problem never authors the environment** ([D-139][d-139], D-417)."),
 ("G11 D-424, §14.10",
  "rejected at resolution as a\n`TapResolution`. A `y` tap",
  "rejected at resolution as a\n`TapResolution` (D-424). A `y` tap"),
 ("G6 D-419, §14.10 (1)",
  "seed there would overwrite the first ([D-272][d-272]).",
  "seed there would overwrite the first ([D-272][d-272], D-419)."),
 ("G7 D-420, §14.10",
  "passed without `about` is an `ArgumentInvalid`.",
  "passed without `about` is an `ArgumentInvalid` (D-420)."),
 ("G6 D-419, §14.10 (2)",
  "continuous cell that consumer drives, or the recorded step map below ([D-272][d-272]).",
  "continuous cell that consumer drives, or the recorded step map below ([D-272][d-272], D-419)."),
 ("G14 D-426, §14.10",
  "declared\nnon-participation. One piece",
  "declared\nnon-participation (D-426). One piece"),
]

def main():
    spec = open(ROOT + "spec.md").read()
    log = open(ROOT + "decisions.md").read()
    entries = open(HERE + "entries_new.md").read()
    ok = True
    for label, old, new in SPEC:
        n = spec.count(old)
        if n != 1:
            print("NO MATCH x%d: %s" % (n, label)); ok = False
    if log.count(MARK) != 1 or "### D-415 " in log:
        print("log marker or D-415 check failed"); ok = False
    if not ok:
        sys.exit(1)
    for label, old, new in SPEC:
        spec = spec.replace(old, new)
    i = log.index(MARK)
    log = log[:i] + entries + log[i:]
    open(ROOT + "spec.md", "w").write(spec)
    open(ROOT + "decisions.md", "w").write(log)
    for k, (label, old, new) in enumerate(SPEC, 1):
        print("## %d. %s\n\nOld:\n\n```markdown\n%s\n```\n\nNew:\n\n```markdown\n%s\n```\n"
              % (k, label, old.rstrip("\n"), new.rstrip("\n")))

main()
