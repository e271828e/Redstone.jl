import sys; sys.path.insert(0, "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/scratch_step5/fix2")
from claimlib import Claims
c = Claims("H")
c.set(19, new="The discrete tier is frozen (§8.2), so its only possible partials are zeros. The rejection's next-move guidance points at the recorded step-map extension below.",
      newcites="§8.2", note="step 5 P2-36: 'the frozen tier' was used before §14.10 says the discrete tier is frozen; §8.2 is the pointer the section already gives for that fact")
c.set(26, new="The default operating point is the checkpoint of the simulation or the `Model` (a deployment materialized at one scalar type) as it stands (D-274, D-319). A checkpoint is the `Model`'s state at a frame top as one value.",
      note="step 5 P2-20 and P1-38: the shared gloss (glossary #g-checkpoint) in its own sentence, so it no longer splits the bold noun phrase; bare 'model' becomes `Model`, which takes its link and gloss here at its new first use")
c.set(27, new="It is `checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`, each restored into the scratch world with no boundary zero (§12.6, D-274, D-319).",
      note="step 5 P2-20: the `Model` link and gloss moved to the sentence before")
c.set(34, new="`width` is a keyword of `linearize`, default 8 (D-272). The default width's scalar type is public. A build can therefore pre-materialize its activation (the build's typed products at a given scalar type) through `activations` (§9.4), and a tap set of any size then linearizes with no compile at the keyboard (D-272).",
      note="step 5 P2-37: split in three, 'so' kept as 'therefore'; D-272 repeated after the split, the bold keeping its own")
c.set(40, new="That seeded evaluation replaces Flight.jl's four `FiniteDiff` Jacobians, their step-size heuristics and ~4n perturbed evaluations.", note="step 5 P2-38: capital J")
c.set(42, new="Unseeded states sit constant at the operating point, and so do unseeded root inputs (D-072).",
      note="step 5 P2-34: the root-input link and gloss move to the first use, in 'The tap set'")
c.set(52, new="A root input is unseedable whenever any one of its consumers demands frozen, which is the fan-out meet (§8.2, D-168).", note="step 5 P2-39: comma, not semicolon")
c.set(63, new="Flight.jl's `c172x_ctl` LQR (linear-quadratic regulator) pipeline consumes it with cosmetic changes.", note="step 5 P2-42: LQR spelled out")
c.set(64, new="FlightPhysics' `LinearizedSS`, the component, survives separately, as an ordinary continuous component in the migrated library (D-072).",
      note="step 5 P2-41: 'the component' set off as an appositive; the bold's words unchanged")
c.set(70, new="This is why Flight.jl's C172X design code linearizes the aircraft's `{NED}` variant, the one built on north-east-down (NED) kinematics.", note="step 5 P2-42: NED spelled out")
c.set(71, new="`design_world(ac)` (the thin rig that mounts an aircraft for trim and linearization) rigs that variant, promoting implicit practice to stated rule.",
      note="step 5 P2-30: one name, 'thin rig', as §14.9 now writes")
c.set(75, new="Trim and linearization differentiate the continuous dynamics with the discrete state held, and for that a frozen discrete output (a zero-order-hold constant with zero partials) is the exact answer, as §7.2 states (D-072).",
      note="step 5 P2-42: ZOH spelled out, which avoids nested parentheses")
c.set(98, new="Exactness across a firing needs saltation corrections (the jump terms a sensitivity takes across an event).", note="step 5 P2-42: saltation glossed")
c.set(103, new="The second is exact discrete-time linearization of the full loop, which is digital design on the exact discretized plant instead of continuous linearization plus Tustin's discretization.",
      note="step 5 P2-42: Tustin named as a discretization")
c.set(109, new="An opaque wrapper, such as an FMU (a Functional Mock-up Unit, a packaged external model) or a C aerodynamic table, and a deliberately severed coupling can therefore both say so in the schema, instead of showing up in Jacobians as unexplained zero rows.",
      note="step 5 P2-42: FMU glossed; the examples become a 'such as' clause so the gloss does not nest")
c.set(122, new="It evaluates at the value and obtains a local Jacobian by whatever means it has, such as a finite difference at a step its own grid suggests or the table's analytic slope. It then chains that Jacobian onto the incoming partials (D-266)",
      note="step 5 P2-43: split in two, the list of means set off by 'such as'")
c.set(125, new="The block strips the partials with `ForwardDiff.value` mid-expression, which §9.5 leaves legal at an unpinned leaf, and the seeded pass sees the component as an ordinary differentiable one.",
      note="step 5 P2-44: 'the stripping' had lost its antecedent; the block's own `ForwardDiff.value` call names it")
c.set(130, new="What stays recorded is only the remaining tooling over the schema's declared non-participation.",
      note="step 5 P2-45: 'that visibility' named, its antecedent being 40 lines back")
c.replace("added: A seeded tap, in the `x` or `u` list, reaches its scalar through one index step at most and never a `.name` step, because a seed is written into a whole state field or root input, or into one array element of it.",
          "added: A seeded tap, in the `x` or `u` list, reaches its scalar through one index step at most and never a `.name` step, because a seed is written into a whole state field or root input (the root's own input face), or into one array element of it.")
c.save()
