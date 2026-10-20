import sys; sys.path.insert(0, "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/scratch_step5/fix2")
from claimlib import Claims
c = Claims("F")
c.set(97, new="§8.2 gives the value-level constructor, a plain exported function of the component and its input values, that builds such a handle. §14.1 gives the pre-sweep doctrine.",
      note="step 6b finding 6: the appositive moves next to the constructor, so it no longer reads as glossing the handle")
c.save()
c = Claims("G")
c.set(73, new="A pinned intermediate (a value held at `Float64` inside authored continuous math) makes the Dual probe (the build's single evaluation of a user function) fail with a culprit-naming `MethodError` or `InexactError` (D-307). `build(world; activations)` puts the probe in CI (D-280).",
      note="step 6b finding 1: probe linked at its first use in §14.8 with the glossary's gloss")
c.set(106, new="`at(prefix, read_set)` prepends the prefix to the read set's mount chain and joins nothing.",
      note="step 6b finding 2: 'that chain' named, the added Reads sentence standing between it and its antecedent")
c.save()
c = Claims("H")
c.set(27, new="The default point is `checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`, each restored into the scratch world with no boundary zero (§12.6, D-274, D-319).",
      note="step 6b finding 3: the subject named, since 'It' would now take the checkpoint gloss sentence as antecedent")
c.set(30, new="`about = <condition>`, with `t0` beside it, linearizes anywhere else without touching the sim, the condition's coverage checked as §14.6 requires (D-272). `t0` is admitted only there, and a `t0` passed without `about` is an `ArgumentInvalid`.",
      note="step 6b finding 4: 'its' named as the condition's")
c.set(109, new="An opaque wrapper, such as an FMU (a Functional Mock-up Unit, a packaged simulation unit) or a C aerodynamic table, and a deliberately severed coupling can therefore both say so in the schema, instead of showing up in Jacobians as unexplained zero rows.",
      note="step 6b finding 5: the gloss avoids lowercase *model*, a reserved word")
c.save()
