# Introduction

The tutorial builds one model from scratch, a light aircraft in its plane of
symmetry, and grows it chapter by chapter. Each page shows its code whole,
beside the output the build of this site produced. The physics is stated,
not derived, and each result is checked against a hand calculation.

Every chapter ends at a function of the examples package,
`RedstoneExamples`, so you can start any chapter from the one before
without writing it. The package lives in the `examples` folder of the
repository. Add it beside Redstone:

```julia
using Pkg
Pkg.add(url = "https://github.com/e271828e/Redstone.jl")
Pkg.add(url = "https://github.com/e271828e/Redstone.jl", subdir = "examples")
Pkg.add("CairoMakie")
```

In a clone of the repository you need none of this. Start Julia there with
`julia --project=docs`, the environment that holds Redstone, the examples
and CairoMakie, and run `using Pkg; Pkg.instantiate()` once.

1. [The aircraft](@ref): the aircraft as a component, run off trim.
2. [Trim](@ref): the controls that hold level flight.
3. [Linearize](@ref): the aircraft's modes and the integration step.
