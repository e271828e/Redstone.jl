"""The verifier's eight fixes (track2_verify.md). Every old text must occur
exactly once; all are checked before any file is written. Prints the log."""
import sys

ROOT = "/Users/miguel/.julia/dev/Redstone.jl/docs/design/"
MARK = "<!-- citation link definitions"

D427 = """### D-427 — Refuse a condition entry naming an internally wired input at resolution, with its producer

**Status.** ratified

**Position.** Resolution refuses a condition entry naming an input face that a
component feeds, as `ConditionResolution` with reason `:internally_wired` and
the producer in hand.

**Spec.** §14.2, §14.9

**Rationale.** Section 16.2 of the design text at `2ee101a`, which settled
D-065, stated the ruling. Resolution "walks the export chain to the root slot
and errors if the face never surfaces — an internally-wired input has no slot
and writing it is meaningless (the first sweep overwrites)". No Position
carries it. D-277's second bullet states the refusal for a `get_input` and
points to §14.2 for the condition entry, and D-071's second bullet and D-139's
Rationale assert it by citing §14.9. The code raises it in `_root_input`
(`src/conditions.jl`), with the producer, and the landed §14.2 states it. This
entry records the refusal as that design text, §14.2 and the code state it,
and decides nothing new.

**Rejected.** None beyond D-065's list.

"""

LOG = [
 ("1. D-427 inserted before the link-definition marker", None, D427),
 ("2. D-071 annotation: condition entries point at D-427",
  """resolution refuses it with the producer named, as [D-277][d-277]
states for a face fed by a component. And""",
  """resolution refuses it with the producer named, as D-427
states for a condition entry and D-277 for a `get_input`. And"""),
 ("3. D-122 annotation: `init!` never took `baseline`",
  """Annotation (2026-10-20): only `trim!` takes the `baseline` keyword now. The
clause held when written, the spec at `8e2505c` reading "the `baseline` keyword
`init!`/`trim!` take", and `init!` lost the keyword later.""",
  """Annotation (2026-10-20): only `trim!` takes the `baseline` keyword. `init!`
took none when this entry was written (`4728a93` gives
`init!(sim, condition; t0)`)."""),
 ("4. D-098 annotation: D-406's own words",
  """No client
policy applies on top of the source rule, which is the resolver's, not a
client's ([D-406][d-406]).""",
  """D-406's
Position makes the source rule "the resolver's, not a client's", and its
Rationale says the family "splits by source and not by client"."""),
 ("5. D-409 annotation: the scoping clause dropped",
  """Annotation (2026-10-20): the service half bears on the reads a run acts on, as
[§13.5][s13-5] frames the rejection. Since [D-414][d-414] the locality law is authoring guidance,
not a framework check, and `get_face` remains the read for a consumer meant to
outlive the build.""",
  """Annotation (2026-10-20): since D-414 the locality law is authoring guidance,
not a framework check, and `get_face` remains the read for a consumer meant to
outlive the build."""),
 ("6. D-424 Rationale: D-276's store-selector bullet for the `x` half",
  """**Rationale.** No entry records the limits. The code checks them in
`_check_seedable` (`src/linearize.jl`), and the suite cites "[§14.10][s14-10], [D-036][d-036],
[D-276][d-276]" for them, though neither Position states them. A seed is a `Float64`""",
  """**Rationale.** The code checks the limits in `_check_seedable`
(`src/linearize.jl`), and the suite cites "§14.10, D-036, D-276" for them.
D-276's Position bullet "A store selector takes a field name with at most an
index step" already bounds the `x` list. No entry records the `u` list's step
limit, the exact-`Float64` leaf or the reason names. A seed is a `Float64`"""),
 ("6b. D-424 Rationale: the vector refusal is D-272's second bullet",
  """The refusal of a tap
resolving to a vector or a bundle is [D-272][d-272]'s annotation of 2026-09-30, and the
second bullet names its reason only.""",
  """The refusal of a tap
resolving to a vector or a bundle is D-272's second bullet, as its annotation
of 2026-09-30 spells it, and the second bullet here names its reason only."""),
 ("7. D-422 Rationale: where the reasons entered",
  """Both entered the code in
`415ed0b` and moved into `src/trim.jl` in `3408028`, and the landed [§14.8][s14-8]
lists both cases.""",
  """Both were named in the kind in
`415ed0b`, `src/trim.jl`'s checks have raised them since `3408028`, and the
landed §14.8 lists both cases."""),
 ("8. D-426 Rationale: `9ad74d5` as the two-piece form's source",
  """Two pieces remain recorded,
as [§14.10][s14-10] states.""",
  """Section 14.10 of the
spec text at `9ad74d5`, written when the marker came to exist, gave the
two-piece form the Position restates. It reads "What stays recorded is only
the remaining tooling over that visibility", names pinned-face validation by
the tap declaration and a feedthrough-graph lint, and closes "Additive when a
consumer shows up, no flag day". The landed §14.10 states it."""),
]

SPEC = [
 ("9. §14.2: D-427 in place of D-277",
  "`ConditionResolution` with reason `:internally_wired` ([D-277][d-277]). Unexported stays",
  "`ConditionResolution` with reason `:internally_wired` (D-427). Unexported stays"),
 ("10. §14.9: D-277 and D-427",
  "a `get_input` ([D-277][d-277]). The service compiles",
  "a `get_input` ([D-277][d-277], D-427). The service compiles"),
]

def main():
    log = open(ROOT + "decisions.md").read()
    spec = open(ROOT + "spec.md").read()
    ok = log.count(MARK) == 1 and "### D-427 " not in log
    for lab, old, new in LOG[1:]:
        if log.count(old) != 1: print("NO MATCH x%d: %s" % (log.count(old), lab)); ok = False
    for lab, old, new in SPEC:
        if spec.count(old) != 1: print("NO MATCH x%d: %s" % (spec.count(old), lab)); ok = False
    if not ok: sys.exit(1)
    for lab, old, new in LOG[1:]: log = log.replace(old, new)
    i = log.index(MARK); log = log[:i] + D427 + log[i:]
    for lab, old, new in SPEC: spec = spec.replace(old, new)
    open(ROOT + "decisions.md", "w").write(log)
    open(ROOT + "spec.md", "w").write(spec)

main()
