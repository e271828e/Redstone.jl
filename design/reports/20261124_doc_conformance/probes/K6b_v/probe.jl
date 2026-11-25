# K6b verifier probes, read-only.
using Redstone, StaticArrays, ForwardDiff
const L = Redstone.Library
const R = Redstone
D = ForwardDiff.Dual{Nothing, Float64, 1}
p(tag, f) = try println(tag, " => ", f()) catch e println(tag, " THROWS ", typeof(e), ": ", sprint(showerror, e)[1:min(end, 200)]) end

# K6b-039: Constant keyword form
p("039 Constant(value=1.0)", () -> L.Constant(value = 1.0))
p("039 Constant(1.0)", () -> L.Constant(1.0))
# K6b-012: entries under a Dual activation
p("012 Constant y at Dual", () -> R.retype_entry(D, R.y_types(L.Constant(1.0))))
p("012 Comparator y at Dual", () -> R.retype_entry(D, R.y_types(L.Comparator(threshold = 1.0))))
p("012 Freeze y at Dual", () -> R.retype_entry(D, R.y_types(L.Freeze{Float64}())))
p("012 FirstOrderLag y at Dual", () -> R.retype_entry(D, R.y_types(L.FirstOrderLag(τ = 1.0))))
# K6b-022: port names on several-port sides
p("022 Switch u", () -> R.u_types(L.Switch{Float64}()))
p("022 PID u", () -> R.u_types(L.PID(Kp = 1.0)))
p("022 PID y", () -> R.y_types(L.PID(Kp = 1.0)))
p("022 LimitedIntegrator y", () -> R.y_types(L.LimitedIntegrator(lower = -1, upper = 1)))
p("022 Integrator reset u", () -> R.u_types(L.Integrator(reset = true)))
p("022 SumJunction u", () -> R.u_types(L.SumJunction{Float64, 3}()))
p("022 Unpack y", () -> R.y_types(L.Unpack{Float64, 3}()))
# K6b-038: retype touches parameters, not fields
struct Flat; a::Float64; end
struct Par{T}; a::T; end
p("038 retype Flat", () -> R.retype(D, Flat))
p("038 retype Par{Float64}", () -> R.retype(D, Par{Float64}))
# K6b-050: Switch events
p("050 Switch events", () -> R.state_events(L.Switch{Float64}()))
# K6b-060: Fields outputs
struct Pose{T}; pos::SVector{2, T}; heading::T; flag::Bool; end
p("060 Fields{Pose{Float64}} y", () -> R.y_types(L.Fields{Pose{Float64}}()))
p("060 Fields NT y", () -> R.y_types(L.Fields{NamedTuple{(:a, :b), Tuple{Float64, Int}}}()))
# K6b-070: Sequence guard
seq = L.Sequence(times = [1.0, 2.0], values = [0.0, 1.0, 2.0])
p("070 guard m=0 t=0.5", () -> L.advance_guard(seq, (; t = 0.5, m = 0)))
p("070 guard m=1 t=1.5", () -> L.advance_guard(seq, (; t = 1.5, m = 1)))
p("070 guard m=2 t=3", () -> L.advance_guard(seq, (; t = 3.0, m = 2)))
p("070 handler t=2.0", () -> L.advance_handler(seq, (; t = 2.0)))
# K6b-080: TransferFunction
tf = L.TransferFunction(num = (1.0,), den = (1.0, 2.0), u0 = 3.0)
p("080 realization", () -> typeof(L.realization(tf)))
p("080 x0 init", () -> R.x_init(tf))
p("080 ports", () -> (R.u_types(tf), R.y_types(tf)))
p("080 x0 keyword", () -> L.TransferFunction(num = (1.0,), den = (1.0, 2.0), x0 = 1.0))
# K6b-090: LimitedIntegrator reset
li = L.LimitedIntegrator(lower = -1.0, upper = 1.0, x0 = 2.0, reset = true)
p("090 events", () -> keys(R.state_events(li)))
p("090 reset handler", () -> L.reset_handler(li, nothing))
li2 = L.LimitedIntegrator(lower = -1.0, upper = 1.0, x0 = 0.5, reset = true)
p("090 reset handler inside", () -> L.reset_handler(li2, nothing))
# K6b-102: Comparator
p("102 threshold", () -> R.y_types(L.Comparator(threshold = 1.0)))
p("102 limits", () -> R.y_types(L.Comparator(lower = 0.0, upper = 1.0, localized = false)))
p("102 threshold+lower", () -> L.Comparator(threshold = 1.0, lower = 0.0))
# K6b-112: discrete pair
dss = L.DiscreteStateSpace(A = [0.5;;], B = [1.0;;], C = [1.0;;])
dtf = L.DiscreteTransferFunction(num = (1.0,), den = (1.0, -0.5))
p("112 supertypes", () -> (supertype(typeof(dss)), supertype(typeof(dtf))))
p("112 x_deriv methods", () -> hasmethod(R.x_deriv, Tuple{typeof(dss), Any}) ? which(R.x_deriv, Tuple{typeof(dss), Any}) : "none")
p("112 s_update", () -> which(R.s_update, Tuple{typeof(dtf), Any}))
# K6b-122 / 132: DiscretePID
dp = L.DiscretePID(Kp = 1.0, Ki = 1.0, u_max = 1.0)
p("122 supertypes", () -> (supertype(typeof(dp)), supertype(supertype(typeof(dp)))))
p("122 gated_error method", () -> which(L.gated_error, Tuple{typeof(L.DiscretePID(Kp = 1.0, hold = true)), Float64, Any}))
p("132 y_types", () -> R.y_types(dp))
p("132 y_state", () -> L.y_state(dp, (; s = (q = 0.0, yf = 0.0, saturated = Int8(1)))))
p("132 s_update saturated", () -> L.s_update(dp, (; s = R.s_init(dp), u = (r = 5.0, y = 0.0), y = (u = 1.0, u_raw = 5.0), Δt = 0.1)))
# K6b-100: zero-pole
p("100 unpaired", () -> L.TransferFunction(poles = (1.0im - 1,)))
p("100 pair", () -> L.TransferFunction(poles = (-1 + 1.0im, -1 - 1.0im)).den)
ring = [0.9 * cis(2π * (k + 0.5) / 20) for k in 0:19]
p("100 ring of 10 pairs", () -> L.DiscreteTransferFunction(poles = ring).den[end])
# a nearly-conjugate pair whose expansion's imaginary part is at rounding level
p("100 near pair 1e-9", () -> L.TransferFunction(poles = (-1 + 1.0im, -1 - 1.0im + 1e-9)).den)
