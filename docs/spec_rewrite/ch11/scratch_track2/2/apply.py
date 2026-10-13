"""Insert D-367..D-376 before the link block and add their chapter 11 citations.
Every old text must match exactly once; nothing is written unless all match."""
import sys

ROOT = "/Users/miguel/.julia/dev/Redstone.jl/docs/design/"
HERE = "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch11/scratch_track2/2/"

# (old, new) pairs in spec.md, in chapter order
SPEC = [
    ("**Spawn-inside-`run!` is the start gate** ([D-093][d-093])",
     "**Spawn-inside-`run!` is the start gate** ([D-093][d-093], D-367)"),
    ("default is 65536 (2¹⁶), with `Inf` the explicit opt-out ([D-137][d-137])",
     "default is 65536 (2¹⁶), with `Inf` the explicit opt-out ([D-137][d-137], D-368)"),
    ("**The bound is a count, not a memory budget** ([D-137][d-137])",
     "**The bound is a count, not a memory budget** ([D-137][d-137], D-368)"),
    ("**The default is finite unconditionally** ([D-137][d-137])",
     "**The default is finite unconditionally** ([D-137][d-137], D-368)"),
    ("so coverage stays global\n([D-137][d-137]). A rolling",
     "so coverage stays global\n([D-137][d-137], D-368). A rolling"),
    ("**The guarantees are normative, not the mechanism** ([D-137][d-137])",
     "**The guarantees are normative, not the mechanism** ([D-137][d-137], D-368)"),
    ("retained unconditionally** ([D-137][d-137])",
     "retained unconditionally** ([D-137][d-137], D-368)"),
    ("policy, not a trajectory-determining one** ([D-137][d-137])",
     "policy, not a trajectory-determining one** ([D-137][d-137], D-368)"),
    ("rather than claimed ([D-174][d-174]). It is the unclaimed",
     "rather than claimed ([D-174][d-174], D-370). It is the unclaimed"),
    ("naming the incumbent, [D-174][d-174]). A rostered greedy",
     "naming the incumbent, [D-174][d-174], D-370). A rostered greedy"),
    ("**The init/trim services own root-input initial values** ([D-047][d-047])",
     "**The init/trim services own root-input initial values** ([D-047][d-047], D-376)"),
    ("Identity is the device instance. The same object",
     "Identity is the device instance (D-375). The same object"),
    ("Admission is a two-part check at the attach point, in order:",
     "Admission is a two-part check at the attach point, in order (D-375):"),
    ("**Device death does not detach** ([D-106][d-106])",
     "**Device death does not detach** ([D-106][d-106], D-374)"),
    ("move no writer's surface ([D-106][d-106])",
     "move no writer's surface ([D-106][d-106], D-374)"),
    ("The harness cell gets the same treatment ([D-174][d-174])",
     "The harness cell gets the same treatment ([D-174][d-174], D-370)"),
    ("naming the incumbent device\n([D-174][d-174])",
     "naming the incumbent device\n([D-174][d-174], D-370)"),
    ("the drain is pure application ([D-106][d-106])",
     "the drain is pure application ([D-106][d-106], D-044)"),
    ("the drain is fully compilable\n([D-106][d-106])",
     "the drain is fully compilable\n([D-106][d-106], D-374)"),
    ("freedom the freeze creates, not an obligation ([D-106][d-106])",
     "freedom the freeze creates, not an obligation ([D-106][d-106], D-374)"),
    ("last drain on the live trace ([D-217][d-217])",
     "last drain on the live trace ([D-217][d-217], D-260)"),
    ("**`shutdown!` must tolerate a partially initialized device** ([D-138][d-138])",
     "**`shutdown!` must tolerate a partially initialized device** ([D-138][d-138], D-372)"),
    ("never force ([Appendix A][sA], [D-102][d-102])",
     "never force ([Appendix A][sA], [D-102][d-102], D-373)"),
    ("**`should_close` dissolves** ([D-102][d-102])",
     "**`should_close` dissolves** ([D-102][d-102], D-373)"),
    ("to run end (the freeze, [§11.3][s11-3], [D-106][d-106])",
     "to run end (the freeze, [§11.3][s11-3], [D-106][d-106], D-374)"),
    ("**Sides are declared, and the obligations they create are enforced both ways**\n([D-177][d-177])",
     "**Sides are declared, and the obligations they create are enforced both ways**\n([D-177][d-177], D-371)"),
    ("**A second greedy attach stakes the empty remainder** ([D-174][d-174])",
     "**A second greedy attach stakes the empty remainder** ([D-174][d-174], D-370)"),
    ("**Several interactive front ends may be rostered at once** ([D-174][d-174])",
     "**Several interactive front ends may be rostered at once** ([D-174][d-174], D-370)"),
    ("a device that may write nothing\n([D-177][d-177])",
     "a device that may write nothing\n([D-177][d-177], D-371)"),
    ("root input lies inside the GUI's own claim ([D-174][d-174])",
     "root input lies inside the GUI's own claim ([D-174][d-174], D-370)"),
    ("**The ring's bound *is* the rate limit** ([D-136][d-136])",
     "**The ring's bound *is* the rate limit** ([D-136][d-136], D-369)"),
    ("**The diagnostic cells are taken at the same drain [§11.4][s11-4] specifies** ([D-136][d-136])",
     "**The diagnostic cells are taken at the same drain [§11.4][s11-4] specifies** ([D-136][d-136], D-369)"),
    ("**The published framework status is a concrete frozen value** ([D-136][d-136])",
     "**The published framework status is a concrete frozen value** ([D-136][d-136], D-369)"),
    ("channel policy** ([D-136][d-136])",
     "channel policy** ([D-136][d-136], D-369)"),
    ("[§13.5][s13-5], [D-136][d-136]). An [unattended run]",
     "[§13.5][s13-5], [D-136][d-136], D-369). An [unattended run]"),
    ("**On a quiet frame nothing allocated scales with diagnostic activity** ([D-241][d-241])",
     "**On a quiet frame nothing allocated scales with diagnostic activity** ([D-241][d-241], D-369)"),
    ("never a `Dict`**\n([D-136][d-136])",
     "never a `Dict`**\n([D-136][d-136], D-369)"),
]

LINKS = "<!-- citation link definitions"


def main():
    spec = open(ROOT + "spec.md").read()
    dec = open(ROOT + "decisions.md").read()
    entries = open(HERE + "entries.md").read()
    bad = [(o, spec.count(o)) for o, _ in SPEC if spec.count(o) != 1]
    if bad:
        for o, n in bad:
            print(f"MATCH {n}: {o!r}")
        sys.exit(1)
    if dec.count(LINKS) != 1 or "### D-367 " in dec:
        sys.exit("decisions.md: link marker or D-367 check failed")
    # chapter 11 bounds: every old text must sit inside it
    lo, hi = spec.index("\n## 11. "), spec.index("\n## 12. ")
    for o, _ in SPEC:
        assert lo < spec.index(o) < hi, o
    for o, n in SPEC:
        spec = spec.replace(o, n)
    i = dec.index(LINKS)
    dec = dec[:i] + entries.rstrip("\n") + "\n\n" + dec[i:]
    open(ROOT + "spec.md", "w").write(spec)
    open(ROOT + "decisions.md", "w").write(dec)
    print(f"applied {len(SPEC)} spec edits and inserted entries")


main()
