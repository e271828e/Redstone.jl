import sys; sys.path.insert(0, "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/scratch_step5/fix2")
from claimlib import Claims
c = Claims("G")
c.set(7, new="A fresh recording that starts at its own anchor is the natural shape of an unattended run (a run with empty staging and no snapshot readers).",
      note="step 5 P2-19: the glossary's term, linked and glossed with its words")
c.set(10, new="Fly-then-retrim is spelled as a checkpoint (the `Model`'s state at a frame top as one value) of the flight, then a trim baseline authored from what the checkpoint shows (D-273).",
      note="step 5 P2-20: the checkpoint link and gloss move to the first use")
c.set(29, new="Every output stage publishes at boundary zero (D-205, §14.5). A residual reading the port (one declared name, one cell) of a component whose schedule has a nonzero phase (an offset against its grid) therefore reads a commit-refreshed cell like any other.",
      note="step 5 P2-22: 'an offset component' spelled out; phase linked with the glossary's gloss ('a schedule's offset against its grid')")
c.set(30, new="Those committed-state residuals are the numbers describing the state the simulation is actually in, which is the point a `linearize` at its default operating point (§14.10) reads.",
      newcites="§14.10", note="step 5 P2-23: the §14.10 pointer moves here, the first of the two mentions")
c.set(32, new="The committed stores then sit at the post-handler point, not the reported solution, and that is the point `linearize` reads by default.",
      newcites="none", note="step 5 P2-23: the second mention shortened; its §14.10 pointer now sits on the first, in the paragraph before")
c.set(37, new="It gated the commit at the solved point, and the numbers stand as reported (D-150).",
      note="step 5 P2-25: the citation leaves mid-phrase")
c.set(46, new="When trims span the flight envelope, hitting the infeasible edge is information.",
      note="step 5 P2-26: 'an envelope of trims' was reader-cold; *sweep* stays out (F66)")
c.set(64, new='The empty problem asks "is this operating point an equilibrium?"',
      note="step 5 P2-13 and P2-14: one name for the problem, and 'probe' no longer takes a third sense in §14.8")
c.set(75, new="A migration audit of Flight.jl's Cessna 172 model against this obligation took one afternoon.",
      note="step 5 P2-11: the second introduction in §14.8 drops (`c172.jl`); R15's 'Flight.jl's Cessna 172 model' stays")
c.set(79, new="Prefer cubic knots over linear where partials matter, though, since linear knots make Jacobian elements piecewise-constant.",
      note="step 5 P2-27: bare *entry* becomes 'elements'")
c.set(104, new="The flattening accumulator of §14.3 enters each `Scoped` wrapper (the node `at` builds over a condition node) and prefixes every condition entry below it.",
      note="step 5 P2-29: Scoped glossed; checked src/conditions.jl 28 and 94")
c.set(132, new="FlightPhysics' world initializer, its method of FlightCore's `f_init!` on a FlightCore `Model{<:SimpleWorld}` (initialize environment, then call the aircraft's trim), has no successor method.",
      note="step 5 P2-31: owners named per piece, world.jl 49 (FlightPhysics) and lib/FlightCore/src/modeling.jl (f_init!, Model)")
c.set(136, new='"Aircraft as root" is a thin rig.', note="step 5 P2-30: one name, D-364's 'thin rig'")
c.set(155, new="Sequential independent trims (trim the lead aircraft, commit, trim the wingman against the committed world) cover weak or one-way coupling.",
      note="step 5 P2-33: the lead named in full")
c.replace("added: The section says what a problem is, then how `at` lifts one, how a mounted read set and mounted input entries resolve, why a problem never authors the environment, and how worlds, thin rigs and swarms use the lift.",
          "added: The section says what a problem is, then how `at` lifts one, how a mounted read set and mounted input entries resolve, why a problem never authors the environment, and how worlds, thin rigs (worlds holding only the aircraft and its environment) and swarms use the lift.")
c.L.insert(c.L.index("added: (the prefixes it is mounted under, root first)") + 1, "")
c.L.insert(c.L.index("added: (the prefixes it is mounted under, root first)") + 2, "added: A read set is a `Reads` value.")
c.L.insert(c.L.index("added: A read set is a `Reads` value.") + 1, "# step 5 P2-29: introduces Reads, the type D-277's next ruling names")
c.save()
