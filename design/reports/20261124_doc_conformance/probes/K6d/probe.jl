using Test, StaticArrays, LinearAlgebra, ForwardDiff, Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/utils.jl"))
println("probe:start")
# ---------- P1: the algebra
const rn = let st = UInt64(12345); () -> (st = st * 6364136223846793005 + 1442695040888963407; (Int(st >> 40) / 2^23) - 1) end
randn(a...) = [rn() for _ in CartesianIndices(a)]
randn(n::Int) = [rn() for _ in 1:n]
nx, nu, nz = 3, 2, 2
A = -2I + 0.5 * randn(nx, nx); B = randn(nx, nu); C = randn(nz, nx)
for D in (zeros(nz, nu), 0.3 * randn(nz, nu)), ni in (1, 2)
    S = D - C * inv(A) * B
    M = [A B; C D]
    sol = M \ [zeros(nx); [1.0, -0.7]]
    dz = [1.0, -0.7]
    M22 = inv(S); M12 = -inv(A) * B * M22
    println("probe:30 eq: ", norm(sol[nx+1:end] - M22 * dz), " ", norm(sol[1:nx] - M12 * dz))
    Minv = inv(M)
    println("probe:31 blocks: ", norm(Minv[nx+1:end, nx+1:end] - M22), " ", norm(Minv[1:nx, nx+1:end] - M12))
    function lqrK(A, B, Q, R)
        n = size(A, 1)
        H = [A -B * inv(R) * B'; -Q -A']
        F = eigen(H)
        idx = findall(real.(F.values) .< 0)
        X = F.vectors[:, idx]
        P = real(X[n+1:end, :] / X[1:n, :])
        inv(R) * B' * P
    end
    K = lqrK(A, B, I(nx), I(nu))
    println("probe:36 stable: ", maximum(real(eigvals(A - B * K))))
    Kfwd = M22 + K * M12
    # steady state with Du: Δu = Kfwd dz - K Δx ; 0 = AΔx+BΔu
    Δx = (A - B * K) \ (-B * Kfwd * dz)
    Δu = Kfwd * dz - K * Δx
    println("probe:40 steady z err: ", norm(C * Δx + D * Δu - dz), " x* err ", norm(Δx - M12 * dz), " u* err ", norm(Δu - M22 * dz))
    # moving reference term: d/dt x̃ = Ax + B u - M12 zdot, u=Kfwd dz - K x
    x = randn(nx); zdot = randn(nz)
    xt = x - M12 * dz
    lhs = A * x + B * (Kfwd * dz - K * x) - M12 * zdot
    rhs = (A - B * K) * xt - M12 * zdot
    println("probe:47 moving ref: ", norm(lhs - rhs))
    # integral action on z_1 only
    Ci = C[1:ni, :]; Di = D[1:ni, :]
    Aa = [A zeros(nx, ni); Ci zeros(ni, ni)]; Ba = [B; Di]
    Ka = lqrK(Aa, Ba, I(nx + ni), I(nu))
    Kx, Kξ = Ka[:, 1:nx], Ka[:, nx+1:end]
    Kint = [Kξ zeros(nu, nz - ni)]
    # tracker closed loop in (x,q), about trim, dz* = 0 reference, w disturbance
    # u = Kfwd*dz* - Kx x + q ; z = Cx + D u ; q̇ = Kint (dz* - z)
    function closed(dzs)
        # unknown (x,q); build linear map with D feedthrough
        # u = -Kx x + q (+ ff); z = C x + D u
        Au = [-Kx I(nu)]               # u = Au*[x;q] + ff
        ff = Kfwd * dzs
        Zm = [C zeros(nz, nu)] + D * Au; zff = D * ff
        Acl = [A zeros(nx, nu); zeros(nu, nx + nu)] + [B; zeros(nu, nu)] * Au
        Acl[nx+1:end, :] -= Kint * Zm
        Acl, ff, zff
    end
    Acl, ff, zff = closed(dz)
    ev1 = sort(real(eigvals(Acl))); ev2 = sort(real(eigvals(Aa - Ba * Ka)))
    println("probe:60 ni=$ni eig(x,q) vs eig(aug) (extra eig of q for unintegrated channel): ", ev1, " | ", ev2)
    # steady state with constant disturbance G w
    G = randn(nx); w = 0.4
    s = Acl \ -[B * ff + G * w; Kint * (dz - zff)]
    z = [C zeros(nz, nu)] * s + D * ([-Kx I(nu)] * s + ff)
    println("probe:68 ni=$ni integrated errs w/ disturbance: ", (z - dz)[1:ni], " ; not integrated: ", (z - dz)[ni+1:end])
end

# ---------- P2: component facts
using Redstone.Library
gains = (K_fbk = [1.0 0; 0 1], K_fwd = [1.0 -1; 2 4], K_int = [0.5 0; 0 0.25], x_trim = [0.1, -0.2],
         u_trim = [0.3, 0.4], z_trim = [0.5, 0.6], Tt = 1.0, u_min = -1.0, u_max = 1.0)
println("probe:80 u_types hold+track: ", u_types(LQRTracker(; gains..., hold = true, tracking = true)))
println("probe:81 y_types disc: ", y_types(DiscreteLQRTracker(; gains...)), " cont: ", y_types(LQRTracker(; gains...)))
println("probe:82 supertype: ", supertype(LQRTracker{2,2,2,false,false,Nothing}), " / ", supertype(DiscreteLQRTracker{2,2,2,false,false,Nothing}))
println("probe:83 Tt=0 cont: ", failure(() -> LQRTracker(; gains..., Tt = 0.0)) |> typeof, " disc ok: ", DiscreteLQRTracker(; gains..., Tt = 0.0) isa DiscreteLQRTracker)
println("probe:84 Tt=Inf tracking: ", failure(() -> LQRTracker(; gains..., Tt = Inf, tracking = true)) |> typeof)
println("probe:85 scalar broadcast: ", LQRTracker(; gains...).fixed.u_max, LQRTracker(; gains...).fixed.Tt)
println("probe:86 AsPort all nine: ", keys(u_types(LQRTracker{3,2,2}(; K_fbk = AsPort(), K_fwd = AsPort(), K_int = AsPort(), x_trim = AsPort(), u_trim = AsPort(), z_trim = AsPort(), Tt = AsPort(), u_min = AsPort(), u_max = AsPort()))))
println("probe:87 NU=1 port types: ", u_types(LQRTracker(K_fbk = [1.0 0.0], K_fwd = hcat(1.0), hold = true, tracking = true, Tt = 1.0)))

# gate / reference semantics, channelwise, via x_deriv at Tt=1, K_int = I, no own limits
let
    kw = (K_fbk = zeros(2, 2), K_fwd = zeros(2, 2), K_int = [1.0 0; 0 1], Tt = 1.0)
    e = SVector(1.0, 1.0)  # z_ref - z
    function xd(c; sat, eng, v, uraw = SVector(0.0, 0.0), uc = SVector(0.0, 0.0))
        u = (x = zeros(SVector{2}), z = -e, z_ref = zero(SVector{2, Float64}), saturation = sat, engaged = eng, v = v)
        u = filter(p -> haskey(u_types(c), p.first) , pairs(u)) |> NamedTuple
        y = (u = uc, u_raw = uraw)
        x_deriv(c, (; x = zero(SVector{2}), u, y))
    end
    c = LQRTracker(; kw..., hold = true, tracking = true)
    v = SVector(5.0, 5.0)
    println("probe:100 limited ch1 (code +1 agrees with e>0 -> gated), ch2 free; v used only in limited: ",
            xd(c; sat = SVector{2,Int8}(1, 0), eng = SVector(true, true), v = v, uraw = SVector(0.0, 0.0), uc = SVector(0.0, 0.0)))
    println("probe:101 ch1 code -1 opposite sign -> not gated, v ref: ",
            xd(c; sat = SVector{2,Int8}(-1, 0), eng = SVector(true, true), v = v))
    println("probe:102 not engaged ch2, code 0: e zeroed, ref v: ",
            xd(c; sat = SVector{2,Int8}(0, 0), eng = SVector(true, false), v = v))
    ct = LQRTracker(; kw..., tracking = true)
    println("probe:103 tracking without hold: v always: ", xd(ct; sat = SVector{2,Int8}(0, 0), eng = SVector(true, true), v = v))
    ch = LQRTracker(; kw..., hold = true)
    println("probe:104 hold, not engaged ch2, no v: ", xd(ch; sat = SVector{2,Int8}(0, 0), eng = SVector(true, false), v = v, uraw = SVector(0.0, 0.0), uc = SVector(0.0, 0.0)))
    # discrete: Tt=0 -> beta = 1
    d0 = DiscreteLQRTracker(; kw..., Tt = 0.0, hold = true, tracking = true)
    s = (q = zero(SVector{2, Float64}), saturated = zero(SVector{2, Int8}))
    u = (x = zeros(SVector{2}), z = -e, z_ref = zero(SVector{2, Float64}), saturation = SVector{2,Int8}(0, 0), engaged = SVector(true, false), v = v)
    y = y_direct(d0, (; s, u))
    sn = s_update(d0, (; s, u, y, Δt = 0.01))
    u2 = u
    y2 = y_direct(d0, (; s = sn, u = u2))
    println("probe:110 Tt=0 standby follows v exactly after one tick (ch2): u_raw2 = ", y2.u_raw, " v = ", v, " ; ch1 engaged: ", y2.u_raw[1])
    dI = DiscreteLQRTracker(; kw..., Tt = Inf, u_min = -1.0, u_max = 1.0)
    println("probe:112 Tt=Inf disc beta: ", -expm1.(-0.01 ./ dI.fixed.Tt))
    # discrete update equation q+ = q + dt gate + beta (ref - u_raw)
    d1 = DiscreteLQRTracker(; kw..., Tt = 0.5, u_min = -1.0, u_max = 1.0, K_fwd = [3.0 0; 0 0])
    u = (x = zeros(SVector{2}), z = -e, z_ref = SVector(1.0, 0.0))
    y = y_direct(d1, (; s, u))
    sn = s_update(d1, (; s, u, y, Δt = 0.02))
    println("probe:115 disc q+ = ", sn.q, " expect ", 0.02 .* [1.0, 1.0] .+ (1 - exp(-0.02 / 0.5)) .* ([1.0, 0.0] .- [3.0, 0.0]), " saturated ", sn.saturated, " y.u ", y.u, " u_raw ", y.u_raw)
end

# ---------- P3: loops
tracker_plant() = StateSpace(A = [0 1; -2 -3], B = [1 0; 0 1], C = [1 0; 0 1])
function tracker_loop(controller; disturbance = SVector(0.0, 0.0), stepped = true)
    wires = Pair{String, String}[
        "plant/y" => "controller/x", "plant/y" => "controller/z", "controller/u" => "sum/in1",
        "disturbance/y" => "sum/in2", "sum/y" => "plant/u"]
    stepped && push!(wires, "reference/y" => "controller/z_ref")
    kids = (controller = controller, disturbance = Constant(disturbance),
              sum = SumJunction{SVector{2, Float64}, 2}(), plant = tracker_plant())
    Group(merge(kids, stepped ? (reference = Step(t_step = 0.5, before = SVector(0.0, 0.0), after = SVector(1.0, 0.5)),) : (;));
          input_wires = stepped ? () : ("z_ref" => "controller/z_ref",), local_wires = Tuple(wires))
end
function plant_at(model, t_end)
    sim = Simulation(model; Δt_frame = 1//100); init!(sim, set()); step!(sim; frames = round(Int, 100t_end)); state(sim, "plant")
end
function lin(controller, state_taps)
    sim = Simulation(tracker_loop(controller; stepped = false); Δt_frame = 1//100)
    init!(sim, set(u = (z_ref = SVector(0.0, 0.0),)))
    linearize(sim, taps(x = state_taps, u = (z_ref1 = get_input("z_ref[1]"), z_ref2 = get_input("z_ref[2]"))))
end
let
    # K_fwd = -A + K_fbk so feedforward alone holds z = z_ref (B = C = I, D = 0): M22 = (-C A^-1 B)^-1 = -A, M12 = -A^-1 B M22 = I; K_fwd = M22 + K M12 = -A + K
    Aplant = [0 1; -2 -3.0]; K = [1.0 0; 0 1]
    Kfwd = -Aplant + K
    plain = (K_fbk = K, K_fwd = Kfwd, K_int = zeros(2, 2), Tt = 1.0)
    println("probe:130 plain tracker steady (expect 1.0, 0.5): ", plant_at(tracker_loop(LQRTracker(; plain...)), 20))
    println("probe:131 disc plain steady: ", plant_at(tracker_loop(DiscreteLQRTracker(; plain...)), 20))
    pt = (x1 = get_state("plant", "[1]"), x2 = get_state("plant", "[2]"))
    l = lin(LQRTracker(; plain...), pt)
    println("probe:132 A = ", l.A, " vs A-BK = ", Aplant - K, " ; fields ", fieldnames(typeof(l)), " x0 ", l.x₀, " u0 ", l.u₀, " y0 ", l.y₀, " labels ", l.x_labels, l.u_labels, l.y_labels, " types ", typeof(l.x₀))
    # integral: K_int from augmented design for z1,z2 both integrated
    Aa = [Aplant zeros(2, 2); I(2) zeros(2, 2)]; Ba = [Matrix(I(2)); zeros(2,2)+I(2)*0 .+ [0 0; 0 0]]
    Ba = [1.0 0; 0 1; 0 0; 0 0]   # D_i = 0
    Q = I(4); R = I(2)
    H = [Aa -Ba * Ba'; -Q -Aa']
    F = eigen(H); idx = findall(real.(F.values) .< 0); X = F.vectors[:, idx]; P = real(X[5:8, :] / X[1:4, :]); Ka = Ba' * P
    Kx, Kxi = Ka[:, 1:2], Ka[:, 3:4]
    Kfw = -Aplant + Kx
    integ = (K_fbk = Kx, K_fwd = Kfw, K_int = Kxi, Tt = Inf)
    l2 = lin(LQRTracker(; integ...), merge(pt, (q1 = get_state("controller", "[1]"), q2 = get_state("controller", "[2]"))))
    println("probe:140 eig closed loop (x,q): ", sort(real(eigvals(l2.A))), " vs aug: ", sort(real(eigvals(Aa - Ba * Ka))))
    println("probe:141 integral loop z at t=200 disturb: ", plant_at(tracker_loop(LQRTracker(; integ...); disturbance = SVector(0.2, -0.1)), 200))
end

# ---------- P4: cycles
function sib_model(PIDT; delay = false, discrete = true)
    wires = Pair{String, String}["ref_a/y" => "a/r", "ref_b/y" => "b/r", "y/y" => "a/y", "y/y" => "b/y",
        "a/u" => "sel/in1", "b/u" => "sel/in2", "mode/y" => "sel/select"]
    cmd = delay ? "delay/y" : "sel/y"
    push!(wires, cmd => "a/v", cmd => "b/v")
    delay && push!(wires, "sel/y" => "delay/u")
    kids = (ref_a = Constant(1.0), ref_b = Constant(0.5), y = Constant(0.0), mode = Constant(true),
            a = PIDT(Kp = 0.5, Ki = 0.2, Tt = 0.1, tracking = true), b = PIDT(Kp = 0.5, Ki = 0.2, Tt = 0.1, tracking = true),
            sel = Switch{Float64}())
    Group(delay ? merge(kids, (delay = UnitDelay(0.0),)) : kids; local_wires = Tuple(wires))
end
for (nm, T) in (("DiscretePID", DiscretePID), ("PID", PID)), delay in (false, true)
    r = failure(() -> build(sib_model(T; delay)))
    d = r === nothing ? "builds" : (try only(diagnostics(r)) catch; r end)
    println("probe:200 ", nm, " delay=", delay, " -> ", d isa AlgebraicCycle ? ("AlgebraicCycle ", d.classification) : d)
end

# tracker under a PID cascade (outer u -> inner z_ref, inner u -> outer v) with and without the delay
function casc(PIDT, TrT; delay = false, hold = false)
    wires = Pair{String, String}["ref/y" => "outer/r", "m/out1" => "outer/y", "plant/y" => "m/u", "outer/u" => "pk/in1", "lvl/y" => "pk/in2",
        "pk/y" => "inner/z_ref", "plant/y" => "inner/x", "plant/y" => "inner/z", "inner/u" => "plant/u"]
    push!(wires, delay ? "iu/y" => "outer/v" : "m2/out1" => "outer/v")
    push!(wires, "inner/u" => (delay ? "iu/u" : "m2/u"))
    hold && append!(wires, ["inner/saturated" => "code/u", "code/out1" => "outer/saturation", "free/y" => "outer/engaged"])
    kids = (ref = Constant(1.0), m = Unpack{Float64, 2}(), m2 = Unpack{Float64, 2}(), outer = PIDT(Kp = 0.5, Ki = 0.2, Tt = 0.1, tracking = true, hold = hold),
            pk = Pack{Float64, 2}(), lvl = Constant(0.0), inner = TrT(; K_fbk = [1.0 0; 0 1], K_fwd = [1.0 -1; 2 4], K_int = zeros(2,2)), plant = tracker_plant())
    kids = delay ? merge(kids, (iu = Fn{SVector{2,Float64},Float64}(u -> u[1]),)) : kids
    hold && (kids = merge(kids, (code = Unpack{Int8, 2}(), free = Constant(true))))
    Group(kids; local_wires = Tuple(wires))
end
for (nm, P, T) in (("disc", DiscretePID, DiscreteLQRTracker), ("cont", PID, LQRTracker))
    r = failure(() -> build(casc(P, T)))
    d = r === nothing ? "builds" : (try only(diagnostics(r)) catch; r end)
    println("probe:210 cascade ", nm, " inner u -> outer v: ", d isa AlgebraicCycle ? ("AlgebraicCycle ", d.classification) : d)
end
r = failure(() -> build(casc(DiscretePID, DiscreteLQRTracker; hold = true)))
println("probe:215 disc cascade through saturated -> Unpack{Int8,2} -> outer saturation (v still from inner u -> cycle expected from v wiring): ", r === nothing ? "builds" : (try only(diagnostics(r)).classification catch; r end))

# FaceNameCollision
struct Clash <: Redstone.AbstractComponent end
Redstone.x_init(::Clash) = nothing
Redstone.u_types(::Clash) = (saturation = Int8,)
Redstone.y_types(::Clash) = (saturation = Int8,)
Redstone.y_direct(::Clash, (; u)) = (saturation = u.saturation,)
r = failure(() -> build(Clash()))
println("probe:220 same name in/out as root: ", r === nothing ? "builds" : (try only(diagnostics(r)) |> typeof catch; r end))
println("probe:221 tracker alone as root builds: ", failure(() -> build(DiscreteLQRTracker(; gains..., hold = true))) === nothing)
println("probe:222 Unpack{Int8,2} outs: ", y_types(Unpack{Int8, 2}()))

# cascade through the stage-1 code alone: outer hold, no v
function casc_code(PIDT, TrT)
    wires = Pair{String, String}["ref/y" => "outer/r", "m/out1" => "outer/y", "plant/y" => "m/u", "outer/u" => "pk/in1", "lvl/y" => "pk/in2",
        "pk/y" => "inner/z_ref", "plant/y" => "inner/x", "plant/y" => "inner/z", "inner/u" => "plant/u",
        "inner/saturated" => "code/u", "code/out1" => "outer/saturation", "free/y" => "outer/engaged"]
    kids = (ref = Constant(1.0), m = Unpack{Float64, 2}(), outer = PIDT(Kp = 0.5, Ki = 0.2, hold = true),
            pk = Pack{Float64, 2}(), lvl = Constant(0.0), inner = TrT(; K_fbk = [1.0 0; 0 1], K_fwd = [1.0 -1; 2 4], K_int = zeros(2,2), u_max = 1.0, u_min = -1.0), plant = tracker_plant(),
            code = Unpack{Int8, 2}(), free = Constant(true))
    Group(kids; local_wires = Tuple(wires))
end
r = failure(() -> build(casc_code(DiscretePID, DiscreteLQRTracker)))
println("probe:230 hold cascade via saturated, disc: ", r === nothing ? "builds" : (try only(diagnostics(r)).classification catch; r end))
println("probe:231 DiscretePID y_types: ", y_types(DiscretePID(Kp = 1.0)))
