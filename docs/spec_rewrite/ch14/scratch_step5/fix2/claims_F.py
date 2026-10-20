import sys; sys.path.insert(0, "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/scratch_step5/fix2")
from claimlib import Claims
c = Claims("F")
c.set(16, new="The problem below is worked (spelled in full against a concrete case). It is the cruise case of Flight.jl's Cessna 172 model (`c172.jl`), reduced to its three-equation core.",
      note="step 5 P2-2: recast for grammar, worked glossed after the glossary's #g-worked")
c.set(20, new="`guess`, `lower` and `upper` are same-named all-`Float64` NamedTuples (D-069).", tag="M",
      note="step 5 P2-1: the sentence doubled the field-list bullet and is dropped; the bullet carries it, and the decisions themselves are the decision NamedTuple of 'Residuals and checks', guess-shaped")
c.set(51, new="The order is `tolerances`' field order, the declared side again, canonical for the residuals.", note="step 5 P2-5: 'r-side' becomes 'residuals'")
c.set(101, new="The order is `tolerances`' field order, the declared side again, canonical for the residuals.", note="step 5 P2-5")
c.set(95, new="`TrimParameters` stays behind the closure, exactly as `condition` already holds it.",
      note="step 5 P2-3: 'and the framework never sees it' dropped as the double of the bold in 'Decisions and parameters' (TrimParameters stays a plain user struct the framework never sees)")
c.set(97, new="§8.2 gives the value-level constructor that builds such a handle, a plain exported function of the component and its input values. §14.1 gives the pre-sweep doctrine.",
      note="step 5 P2-4: the gloss becomes an appositive after 'such a handle'")
c.set(126, new="It fills `J` exactly when `J !== nothing`.", note="step 5 P2-9: 'iff' in plain words")
c.set(148, new="They feed the per-residual test directly, so the damping loop of Levenberg–Marquardt (LM) tests exactly what the service will re-test.",
      note="step 5 P2-9: LM introduced at its first use in §14.8")
c.set(171, new="The set is built from the layout of the activation (the build's typed products at a given scalar type).", note="step 5 P2-12: the gloss now follows activation")
c.set(186, new="At the seeded activation the discrete tier (the discrete side of the hybrid formalism) is frozen (§9.4).", note="step 5 P2-49: tier glossed after the glossary's #g-tier")
c.set(190, new="That round is boundary zero's sweep with every discrete output stage admitted, due or not (D-205), with no projection (the per-component `x_projection` hook), no guards and no `s_update`.",
      note="step 5 P2-49: projection glossed after the glossary's #g-projection")
c.set(195, new="No scratch cell holds a synthesized probe value (a fabricated value a build-time probe runs on).",
      note="step 5 P2-13: the link moves from #g-probe to #g-probe-value, glossed after the glossary")
c.set(196, new="That is the probe-value barrier of §14.6 reaching the scratch world, as D-205 made it reach the published one.",
      note="step 5 P2-13: named as §14.6 names it")
c.set(197, new="The iterations are untouched (§14.5).", note="step 5 P1-37: the pointer to the home of the raw iterations (R6)")
c.set(198, new="They run at the seeded activation, over the continuous chain and `x_deriv` alone.", tag="M",
      note="step 5 P1-37: 'raw write → sweep → read cycles' is held at its home in §14.5 (units/B/new.md, 'Optimizer iterations are raw write → sweep → read cycles on the activation'); the §14.5 pointer sits on the sentence before; 'at the seeded activation' stays, since §14.5 does not say it")
c.set(199, new="The empty problem (below) is the nominal half alone (D-213).", note="step 5 P2-14: the name 'The report' gives it")
c.set(201, new="The commit (below) applies the same composite over the same `baseline`, so its coverage is setup's.", newcites="none",
      note="step 5 P2-15: the expression and its §14.9 pointer give way to 'below', where 'The commit, in full' (units/G/new.md) states the expression; §14.9 states it too")
c.set(204, new="`TrimReport` therefore carries no committed flag, and the no-throw rule (below) needs no exception.",
      note="step 5 P2-16: points to 'Non-convergence never throws' in 'The report'")
c.set(211, new="Flight.jl's warn-but-assign, where the Cessna 172 trim warns on a failed optimization and assigns its result anyway, is structurally impossible.",
      note="step 5 P2-17: the clause states what that code does, c172.jl 934-939")
c.replace("added: A model that a simulation has claimed is refused before any check, as `ArgumentInvalid` with reason `:claimed`, since the call commits (D-318, D-319).",
          "added: A `Model` that a simulation has claimed is refused before any check, as `ArgumentInvalid` with reason `:claimed`, since the call commits (D-318, D-319).")
c.replace("added: The `baseline` keyword takes a baseline (an aircraft-shipped, full-coverage condition function).",
          "added: The `baseline` keyword takes a baseline (a full-coverage condition, such as an aircraft-shipped function returns).")
c.save()
