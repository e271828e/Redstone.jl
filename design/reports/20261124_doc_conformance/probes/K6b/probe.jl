using Redstone, StaticArrays, LinearAlgebra
const Logging = Base.CoreLogging
using Redstone.Library
const L = Redstone.Library
function tryit(label, f)
    try
        r = f()
        println(label, " => ", r)
    catch e
        println(label, " THROWS ", typeof(e), ": ", first(split(sprint(showerror, e), '\n')))
    end
end
println("== P1 derivative TF s/(tau s+1)")
τ = 0.3
tf = L.TransferFunction(num = (1, 0), den = (τ, 1))
r = tf.realization
println(typeof(tf).parameters[2], " FT")
for w in (0.5, 2.0, 7.0)
    s = im * w
    G = (r.C * ((s * I - r.A) \ r.B) + r.D)[1]
    println(w, " ", abs(G - s / (τ * s + 1)))
end
println("== P2 lag vs TF u0=x0")
tfl = L.TransferFunction(num = (1,), den = (τ, 1), u0 = 2.0)
println("y0 = ", (tfl.realization.C * tfl.realization.x0)[1], " ; A=", tfl.realization.A, " B=", tfl.realization.B, " C=", tfl.realization.C)
println("== P3 Fields")
for V in (Float64, SVector{2, Float64}, Tuple{Int, Int}, NamedTuple{(), Tuple{}}, NamedTuple, NamedTuple{(:a, :b), Tuple{Int, Float64}}, Vector{Float64})
    tryit("Fields{$V}", () -> typeof(L.Fields{V}()))
end
println("== P4 Select")
@enum Leg1 CLIMB CRUISE
@enum Leg2 a select
abstract type Foo end
tryit("Select Leg1", () -> typeof(L.Select{Float64, Leg1}()))
tryit("Select Leg2", () -> typeof(L.Select{Float64, Leg2}()))
tryit("Select Enum", () -> typeof(L.Select{Float64, Enum}()))
s = L.Select{Float64, Leg1}()
println(Redstone.u_types(s))
println(Redstone.y_direct(s, (; u = (CLIMB = 1.0, CRUISE = 2.0, select = CRUISE))))
println("== P5 keywords")
tryit("Integrator x0=1", () -> L.Integrator(x0 = 1))
tryit("Integrator x0=Float32", () -> L.Integrator(x0 = 1.5f0))
tryit("Integrator x0=Vector", () -> typeof(L.Integrator(x0 = [1, 2])))
tryit("Integrator x0=MVector", () -> typeof(L.Integrator(x0 = MVector(1, 2))))
tryit("positional", () -> L.Integrator{Float64, false}(0.0))
tryit("Relay dimmismatch", () -> L.Relay(lower = SVector(0, 0), upper = SVector(1, 1, 1)))
println("STATIC_WARN_LENGTH = ", L.STATIC_WARN_LENGTH)
buf = IOBuffer()
Logging.with_logger(Base.CoreLogging.SimpleLogger(buf)) do
    L.Integrator(x0 = zeros(513)); L.Integrator(x0 = zeros(600)); L.Integrator(x0 = zeros(512))
end
println("warn count (expect 1) = ", count("Warn", String(take!(buf))))
tryit("PID Kp svec", () -> typeof(L.PID(Kp = @SVector fill(2.0, 3))))
tryit("PID Kp scalar Ki svec", () -> typeof(L.PID(Kp = 2.0, Ki = [1, 2, 3])))
tryit("PID AsPort Kp only", () -> typeof(L.PID(Kp = L.AsPort(), Ki = 0.5)))
tryit("PID all AsPort", () -> typeof(L.PID(Kp = L.AsPort())))
println("== P6 Delay taps")
d = L.Delay(K = 3, v0 = 0.0, taps = true)
global st = Redstone.s_init(d)
for k in 1:5
    out = Redstone.y_state(d, (; s = st))
    println(k, " y=", out.y, " taps=", out.taps, " y==taps[end] ", out.y == out.taps[end])
    global st = Redstone.s_update(d, (; s = st, u = Float64(k)))
end
println("Delay types ", Redstone.y_types(L.Delay(K = 2)), " ", Redstone.y_types(L.Delay(K = 2, taps = true)))
println("== P9 DiscretePID")
tryit("DPID Tt=0", () -> typeof(L.DiscretePID(Kp = 1.0, Tt = 0.0)))
tryit("PID Tt=0", () -> typeof(L.PID(Kp = 1.0, Tt = 0.0)))
tryit("DPID τd=0", () -> typeof(L.DiscretePID(Kp = 1.0, τd = 0.0)))
tryit("PID tracking Tt Inf", () -> typeof(L.PID(Kp = 1.0, tracking = true)))
tryit("PID tracking Tt AsPort", () -> typeof(L.PID(Kp = 1.0, tracking = true, Tt = L.AsPort())))
c = L.DiscretePID(Kp = 1.0, Tt = 0.0, u_min = -1.0, u_max = 1.0)
println("== PID u_types / y_types")
println(Redstone.u_types(L.PID(Kp = 1.0, Tt = 1.0, hold = true, tracking = true)))
println(Redstone.y_types(L.PID(Kp = 1.0)), Redstone.y_types(c))
println(Redstone.u_types(L.PID(Kp = 1.0)))
println("== P10 zero-pole")
tryit("pair", () -> typeof(L.TransferFunction(poles = (-1 + 1im, -1 - 1im))))
tryit("unpaired", () -> typeof(L.TransferFunction(poles = (-1 + 1im, -2))))
tryit("ten pairs z", () -> begin
    rs = [0.9exp(im * 2π * k / 21) for k in 1:10]
    typeof(L.DiscreteTransferFunction(poles = (rs..., conj.(rs)..., 0.1)))
end)
tryit("mixed", () -> typeof(L.TransferFunction(num = (1,), den = (1, 1), poles = (-1,))))
tryit("DiscretizedTF zp", () -> typeof(L.DiscretizedTransferFunction(poles = (-1,), gain = 2.0)))
println("== P11 misc")
println("names(Library) = ", names(L))
println("Comparator types ", Redstone.y_types(L.Comparator(threshold = 1.0)))
tryit("Comparator lower>upper", () -> L.Comparator(lower = 2.0, upper = 1.0))
tryit("Relay lower>upper", () -> L.Relay(lower = 2.0, upper = 1.0))
println("Relay events ", length(Redstone.state_events(L.Relay(lower = SVector(0.0, 0.0), upper = SVector(1.0, 1.0)))))
println("LI events ", length(Redstone.state_events(L.LimitedIntegrator(lower = SVector(0.0, 0.0), upper = SVector(1.0, 1.0)))),
        " reset ", length(Redstone.state_events(L.LimitedIntegrator(lower = SVector(0.0, 0.0), upper = SVector(1.0, 1.0), reset = true))))
println("LDI events ", length(Redstone.state_events(L.LimitedDoubleIntegrator(lower = SVector(0.0, 0.0), upper = SVector(1.0, 1.0)))))
println("LDI y ", Redstone.y_types(L.LimitedDoubleIntegrator(lower = 0, upper = 1)))
println("Constant types ", Redstone.y_types(L.Constant(1.0)), " Source ", Redstone.y_types(L.Source(sin)))
println("Fn ", Redstone.u_types(L.Fn{Float64}(identity)), Redstone.y_types(L.Fn{Float64, Int}(identity)))
println("Junction ", Redstone.u_types(L.SumJunction{Float64, 3}()), " Pack ", Redstone.y_types(L.Pack{Float64, 3}()))
println("Unpack ", Redstone.y_types(L.Unpack{Float64, 3}()))
println("Sequence handler ", L.advance_handler(L.Sequence(times = (1, 2, 3), values = (0, 1, 2, 3)), (; t = 2.5)))
println("DLI types ", Redstone.y_types(L.DiscreteLimitedIntegrator(lower = 0, upper = 1)))
println("Backlash/RateLimiter y ", Redstone.y_direct(L.Backlash(width = 2.0), (; s = 0.0, u = 3.0)), " ",
        Redstone.y_direct(L.RateLimiter(rising = 1.0), (; s = 0.0, u = 3.0, Δt = 0.5)))
println("DiscreteIntegrator reset ", Redstone.s_update(L.DiscreteIntegrator(s0 = 5.0, reset = true), (; s = 1.0, u = (u = 2.0, reset = true), Δt = 0.1)))
println("StopRequest ", Redstone.y_types(L.StopRequest(reason = "x")), Redstone.u_types(L.StopRequest()))
println("GWN ", Redstone.y_state(L.GaussianWhiteNoise(seed = 1, σ = 1.0), (; s = UInt64(3), Δt = 0.1)) ==
        Redstone.y_state(L.GaussianWhiteNoise(seed = 1, psd = 0.1), (; s = UInt64(3), Δt = 0.1)) * sqrt(0.1) / 1.0 * 1 )
let a = Redstone.y_state(L.GaussianWhiteNoise(seed = 1, σ = 1.0), (; s = UInt64(3), Δt = 0.1)),
    b = Redstone.y_state(L.GaussianWhiteNoise(seed = 1, psd = 1.0), (; s = UInt64(3), Δt = 0.25))
    println("psd sigma^2=psd/dt: ", b / a, " expect 2.0")
end
tryit("GWN neither", () -> L.GaussianWhiteNoise(seed = 1))
tryit("GWN both", () -> L.GaussianWhiteNoise(seed = 1, σ = 1.0, psd = 1.0))
println("LQR ", typeof(L.LQRTracker(K_fbk = ones(2, 3), K_fwd = ones(2, 1))))
println("LQR u_types ", Redstone.u_types(L.LQRTracker(K_fbk = ones(2, 3), K_fwd = ones(2, 1), Tt = 1.0, hold = true, tracking = true)))
println("DLQR y ", Redstone.y_types(L.DiscreteLQRTracker(K_fbk = ones(2, 3), K_fwd = ones(2, 1))))
tryit("LQR size missing", () -> L.LQRTracker(K_fbk = L.AsPort(), K_fwd = L.AsPort()))
println("TF FT eq degree ", typeof(L.TransferFunction(num = (1, 1), den = (1, 2))).parameters[2],
        " lower ", typeof(L.TransferFunction(num = (1,), den = (1, 2))).parameters[2])
println("Freeze refuse ", try L.Freeze{Int}(); "no" catch e; typeof(e) end)
