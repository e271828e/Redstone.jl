# K9a verifier probes. Run from W with --project=examples/test.
using Redstone, RedstoneExamples, LinearAlgebra
import Redstone: Simulation, init!, run!, trim!, linearize, state, port, set, at, combine, build,
    input_wires, local_wires, Group, DiagnosticError, diagnostics, AlgebraicCycle
import RedstoneExamples: Longitudinal, aircraft, level_flight, longitudinal_taps, autopilot, piloted, closed_loop, lqr_gains

p(tag, x) = println(tag, " => ", x)

# K9a-039 x_init; K9a-030 α = θ − γ
plant = Longitudinal()
p("K9a-039 x_init", Redstone.x_init(plant))
p("K9a-039 u_types", Redstone.u_types(plant))
p("K9a-030 y_state α", Redstone.y_state(plant, (; x = (V = 50.0, γ = 0.1, θ = 0.3, q = 0.0, h = 1000.0))))

# K9a-048 level_flight(; V, h)
p("K9a-048 methods", methods(level_flight))
p("K9a-048 kwargs", Base.kwarg_decl(first(methods(level_flight))))
sim = Simulation(aircraft(); Δt_frame = 1//100)
report = trim!(sim, level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5)))
p("K9a-048 trim status", (report.status, report.solution))
sim2 = Simulation(aircraft(); Δt_frame = 1//100)
r2 = trim!(sim2, level_flight(V = 50.0, h = 2000.0); baseline = set(u = (δe = 0.0, δt = 0.5)))
p("K9a-048 trim at h=2000", (r2.status, state(sim2, "plant").h))

# K9a-078 eigenvalues
lin = linearize(sim, longitudinal_taps())
p("K9a-078 eigvals", eigvals(lin.A))

# K9a-057 autopilot root inputs and children
solution = report.solution
ap = autopilot(solution)
p("K9a-057 autopilot kwargs", Base.kwarg_decl(first(methods(autopilot))))
p("K9a-057 input_wires", input_wires(ap))
p("K9a-057 children", keys(ap.children))

# K9a-067 closed_loop signature and children
gains = lqr_gains(lin)
p("K9a-067 closed_loop kwargs", Base.kwarg_decl(first(methods(closed_loop))))
cl = closed_loop(solution, gains; noise_σ = 0.3)
p("K9a-067 children", keys(cl.children))

# K9a-087 piloted without delays
model = piloted(solution)
undelayed = map(local_wires(model)) do wire
    wire.first == "selection/δe_prev" ? ("selection/δe" => wire.second) :
    wire.first == "selection/δt_prev" ? ("selection/δt" => wire.second) : wire
end
err = try build(Group(model; local_wires = undelayed)); nothing catch e; e end
p("K9a-087 refusal type", typeof(err))
for d in diagnostics(err)
    p("K9a-087 cycle", (typeof(d), d.classification, d.members))
end

# K9a-017 installed dirs read-only, and the two develop routes
sa = Base.pkgdir(Redstone.StaticArrays)
f = joinpath(sa, "Project.toml")
p("K9a-017 installed file mode", (f, string(filemode(f), base = 8)))
push!(LOAD_PATH, "@stdlib"); using Pkg
Pkg.offline(true)
W = pkgdir(Redstone)
Pkg.activate(temp = true)
Pkg.develop(PackageSpec(path = joinpath(W, "examples")))
p("K9a-017 examples alone: direct deps", keys(Pkg.project().dependencies))
p("K9a-017 examples alone: identify Redstone", Base.identify_package("Redstone"))
p("K9a-017 examples alone: identify RedstoneExamples", Base.identify_package("RedstoneExamples"))
p("K9a-017 examples alone: Redstone in manifest", any(d -> d.name == "Redstone", values(Pkg.dependencies())))
Pkg.activate(temp = true)
Pkg.develop([PackageSpec(path = W), PackageSpec(path = joinpath(W, "examples"))])
p("K9a-017 both: identify Redstone", Base.identify_package("Redstone"))
p("K9a-017 both: identify RedstoneExamples", Base.identify_package("RedstoneExamples"))
