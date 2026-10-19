C("The per-iteration ledger for trim has four terms.", tag="M", note="M3: moved up after the internal-API sentence")
C("They are the user fragment math (the domain computations unchanged from today, plus the tree's few boxes, §14.2), the leaf stores, the folded shape check, and the sweep.",
  new="They are the user fragment math, the leaf stores, the folded shape check and the sweep (one pass through the execution order against the current state). The fragment math is the domain computations, unchanged from Flight.jl's, plus building the tree, which with literal prefixes allocates nothing (§14.2).",
  tag="R", ruling="R35",
  note="verify: C-078, R35 adds 'with literal prefixes' as §14.2 scopes it; M3 move; F9(c) 'plus building the tree, which allocates nothing'; R12 'today' becomes Flight.jl's (the domain math of Flight.jl's FlightPhysics and FlightApps models); sweep linked and glossed at its first true use (#g-sweep)")
C("The sweep dominates, exactly as `f_ode!` does today.",
  new="The sweep dominates, exactly as `f_ode!` does in FlightCore, where it is the continuous-dynamics function a model extends.",
  tag="R", ruling="R12",
  note="M3 move; owner checked: ~/.julia/dev/Flight.jl/lib/FlightCore/src/modeling.jl 208-211, '#continuous dynamics, to be extended by Models'")
