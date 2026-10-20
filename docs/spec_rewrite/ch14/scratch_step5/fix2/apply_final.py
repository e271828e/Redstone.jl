import sys
sys.dont_write_bytecode = True
sys.path.insert(0, "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/scratch_step5/fix2")
from fixlib import Fixer, ROOT
f = Fixer(); E = f.edit
E("1", "G", "makes the Dual probe fail", "makes the Dual [probe](#g-probe) (the build's single evaluation of a user function) fail",
  note="The gloss is the glossary's #g-probe.")
E("2", "G", "`at(prefix, read_set)` prepends the prefix to that chain and joins nothing.",
  "`at(prefix, read_set)` prepends the prefix to the read set's mount chain and joins nothing.")
E("3", "H", "It is `checkpoint(sim)` on a simulation", "The default point is `checkpoint(sim)` on a simulation")
E("4", "H", "without touching the sim**, its coverage checked", "without touching the sim**, the condition's coverage checked")
E("5", "H", "(a Functional Mock-up Unit, a packaged external model)", "(a Functional Mock-up Unit, a packaged simulation unit)",
  note="Worded as the coordinator asked: lowercase *model* is reserved.")
E("6", "F", "gives the [value-level constructor](#g-value-level-constructor) that builds such a handle, a plain exported function of the component and its input values.",
  "gives the [value-level constructor](#g-value-level-constructor), a plain exported function of the component and its input values, that builds such a handle.")
HEADER = """# Chapter 14, step 6b: the final fixes, half 2 (units F, G and H)

Each entry gives the finding of `final_verify_2.md`, the unit, and the old and
new text of the edited paragraph, verbatim. Replay them in order on commit
`bfcf024`. Every edited paragraph is rewrapped to 80 rendered columns (link
markup collapsed), so the old and new blocks are whole paragraphs.
"""
f.save(f"{ROOT}/final_fixes_2.md", HEADER)
print("applied", len(f.log))
