using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(W * "imports.jl"); include(W * "fixtures.jl"); include(W * "utils.jl")
const L = Redstone.Library
two_state_system(; kw...) = StateSpace(A = [-1 0.5; 0 -2], B = [1 0.5; 0 1], C = [1 2; 0 1]; kw...)
linear_root_model(system) = Group((; c = system); input_wires = ("in" => "c/u",), output_wires = ("c/y" => "out",))
fed_by(src, c; sample_times = (;)) = Group((; k = src, c = c); local_wires = ("k/y" => "c/u",), sample_times = sample_times)
feedback_loop(plant) = Group((; r = Constant(1.0), e = Junction{Float64, Float64, 2}(-), p = plant);
          local_wires = ("r/y" => "e/in1", "p/y" => "e/in2", "e/y" => "p/u"))
sslag(D) = StateSpace(A = [-1.0;;], B = [1.0;;], C = [1.0;;], D = [D;;])
lag_form() = TransferFunction(num = (1,), den = (0.5, 1))
lead_lag() = TransferFunction(num = (1, 2), den = (1, 5))
second_order() = TransferFunction(num = (4,), den = (1, 1.2, 4))
P(tag, x) = println("PROBE[", tag, "] ", x)
dlist(e) = e.carried isa Vector ? e.carried : [e.carried]
errkind(f) = try f(); "builds" catch e; e isa DiagnosticError ? join([string(typeof(d), " ", hasproperty(d,:classification) ? d.classification : "") for d in dlist(e)], "; ") : string(typeof(e)) end

# 1 realizations
for (n, tf) in (("lag", lag_form()), ("leadlag", lead_lag()), ("so", second_order()))
    r = L.realization(tf); P("real_" * n, (Matrix(r.A), Matrix(r.B), Matrix(r.C), Matrix(r.D), typeof(tf)))
end
ω, ζ = 3.0, 0.4
r = L.realization(TransferFunction(num = (ω^2,), den = (1, 2ζ*ω, ω^2))); P("so_general", (Matrix(r.A), Matrix(r.B), Matrix(r.C), Matrix(r.D)))
r = L.realization(TransferFunction(num = (1, 2, 3), den = (2, 4, 6, 8))); P("real_n3", (Matrix(r.A), Matrix(r.B), Matrix(r.C), Matrix(r.D)))
r = L.realization(TransferFunction(num = (2, 1, 3), den = (4, 2, 7))); P("real_equal_deg", (Matrix(r.A), Matrix(r.C), Matrix(r.D)))
# leading zero numerator
P("leadzero", typeof(TransferFunction(num = (0, 1), den = (1, 5))))
# 2 loops
P("loop_D0", errkind(() -> build(feedback_loop(sslag(0.0)))))
P("loop_D1", errkind(() -> build(feedback_loop(sslag(1.0)))))
P("loop_tf_strict", errkind(() -> build(feedback_loop(lag_form()))))
P("loop_tf_leadlag", errkind(() -> build(feedback_loop(lead_lag()))))
# has_stage
P("has_stage", (has_stage(y_direct, lag_form()), has_stage(y_state, lag_form()), has_stage(y_direct, lead_lag()), has_stage(y_state, lead_lag()), has_stage(y_state, sslag(0.0)), has_stage(y_direct, sslag(0.0))))
P("supertypes", (supertype(typeof(lag_form())), supertype(typeof(sslag(0.0))), L.AbstractLinearSystem <: AbstractComponent, L.AbstractDiscreteLinearSystem <: AbstractComponent, hasmethod(L.x_deriv, Tuple{TransferFunction, Any})))
P("x_deriv_methods", [m.sig for m in methods(L.x_deriv) if m.module === L && occursin("Linear", string(m.sig))])
# 3 ports and storage
P("ports", (u_types(sslag(0.0)), u_types(two_state_system()), y_types(two_state_system()), u_types(lag_form()), y_types(lag_form()), u_types(StateSpace(A=[-1 0.5; 0 -2], B=[1 0.5; 0 1], C=[1 2]))))
P("fields", (fieldtypes(typeof(sslag(0.0))), fieldtypes(typeof(lag_form()))))
P("x_init", (x_init(sslag(0.0)), x_init(second_order())))
P("concrete", (isconcretetype(typeof(sslag(0.0))), isconcretetype(typeof(two_state_system())), isconcretetype(typeof(lag_form())), isconcretetype(typeof(second_order()))))
P("tf_has_x0kw", try TransferFunction(num=(1,),den=(1,1),x0=1.0); "accepted" catch e; typeof(e) end)
P("tf_u0", (Matrix(L.realization(TransferFunction(num = (1,), den = (0.5, 1), u0 = 3)).x0'), x_init(TransferFunction(num = (1,), den = (0.5, 1), u0 = 3))))
# DC gain
g = TransferFunction(num=(2,1), den=(1,3,2), u0=2.0); r = L.realization(g)
P("dcgain", (r.x0, (r.D - r.C*inv(r.A)*r.B)[1]*2, r.C*r.x0 + r.D*[2.0], "G0*u0=", (1/2)*2*2 ))
# refusals
P("ref_origin_u0", errkind(() -> TransferFunction(num = (1,), den = (1, 0), u0 = 1.0)))
P("ref_origin_u0_0", typeof(TransferFunction(num = (1,), den = (1, 0), u0 = 0.0)))
P("ref_longer", errkind(() -> TransferFunction(num = (1, 1, 1), den = (1, 1))))
P("ref_dbl_origin", errkind(() -> TransferFunction(num = (1,), den = (1, 0, 0), u0 = 1.0)))
P("static_singular", (SMatrix{1,1}(0.0) \ SVector(1.0), SMatrix{2,2}(0.0,0.0,1.0,0.0) \ SVector(0.0,1.0)))
P("A_inv_singular_dbl", let r = L.realization(TransferFunction(num = (1,), den = (1, 0, 0))); try r.A \ SVector(0.0,1.0) catch e; e end end)
P("ref_x0_len", errkind(() -> StateSpace(A=[-1.0;;],B=[1.0;;],C=[1.0;;], x0=[1.0,2.0])))
# positional 4-arg
P("positional4", try StateSpace([-1.0;;],[1.0;;],[1.0;;],[0.0;;]); "ok" catch e; typeof(e) end)
# lag vs FirstOrderLag
m = Group((; k = Constant(1.0), tf = lag_form(), l = FirstOrderLag(τ = 0.5)); local_wires = ("k/y" => "tf/u", "k/y" => "l/u"))
sim = Simulation(m; Δt_frame = 1//100); init!(sim, set()); step!(sim; t_plus = 1.0)
P("lagmatch", (port(sim, "tf"), port(sim, "l"), state(sim, "tf"), state(sim, "l"), port(sim,"tf")==port(sim,"l")))
# x0=1
m = Group((; k = Constant(0.0), tf = TransferFunction(num=(1,),den=(0.5,1)), l = FirstOrderLag(τ = 0.5, x0 = 1.0), s=StateSpace(A=[-2.0;;],B=[1.0;;],C=[2.0;;], x0=1.0)); local_wires = ("k/y" => "tf/u", "k/y" => "l/u","k/y"=>"s/u"))
sim = Simulation(m; Δt_frame = 1//100); init!(sim, set())
P("x0_lag", (port(sim,"l"), port(sim,"tf"), port(sim,"s"), state(sim,"s")))
# u0 start
sim = Simulation(linear_root_model(TransferFunction(num = (1,), den = (0.5, 1), u0 = 3.0)); Δt_frame = 1//100)
init!(sim, set(u = (in = 3.0,))); a = port(sim, "c"); step!(sim; t_plus = 1.0); P("u0start", (a, port(sim, "c")))
# linearization
sim = Simulation(linear_root_model(lead_lag()); Δt_frame = 1//100); init!(sim, set(u = (in = 0.0,)))
P("lin_leadlag", linearize(sim, taps(x = (q = get_state("c", "[1]"),), u = (in = get_input(:in),), y = (out = get_face(:out),))))
P("lin_leadlag_q", errkind(() -> linearize(sim, taps(x = (q = get_state("c", :q),), u = (in = get_input(:in),), y = (out = get_face(:out),)))))
P("lin_leadlag_x", errkind(() -> linearize(sim, taps(x = (q = get_state("c", :x),), u = (in = get_input(:in),), y = (out = get_face(:out),)))))
P("lin_leadlag_bare", errkind(() -> linearize(sim, taps(x = (q = get_state("c"),), u = (in = get_input(:in),), y = (out = get_face(:out),)))))
sim2 = Simulation(linear_root_model(second_order()); Δt_frame = 1//100); init!(sim2, set(u = (in = 0.0,)))
lz = linearize(sim2, taps(x = (q1 = get_state("c", "[1]"), q2 = get_state("c", "[2]")), u = (in = get_input(:in),), y = (out = get_face(:out),)))
P("lin_so_err", maximum(abs(((lz.C * ((s*I - lz.A) \ lz.B) + lz.D)[1]) - 4/(s^2+1.2s+4)) for s in (0, im, 2im, 1+3im)))
# two-state SS linearize at t=0.3 
A=[-1 0.5; 0 -2]; B=[1 0.5; 0 1]; C=[1 2; 0 1]
m = linear_root_model(two_state_system(D=[1 0.5; 0.25 2]))
sim3 = Simulation(m; Δt_frame = 1//100); init!(sim3, set(u = (in = SVector(0.0,0.0),)))
step!(sim3; t_plus = 0.3)
lz3 = linearize(sim3, taps(x = (a = get_state("c","[1]"), b = get_state("c","[2]")), u = (i1 = get_input("in[1]"), i2 = get_input("in[2]")), y = (o1 = get_face("out[1]"), o2 = get_face("out[2]"))))
P("lin_ss", (lz3.A ≈ A, lz3.B ≈ B, lz3.C ≈ C, lz3.D ≈ [1 0.5; 0.25 2]))
P("dual_build", (build(fed_by(Constant(1.0), sslag(0.0)); activations = (Float64, LinearizeDual)) isa Build, build(linear_root_model(two_state_system()); activations = (Float64, LinearizeDual)) isa Build))
# allocations
function alloc(model)
    sim = Simulation(model; Δt_frame = 1//100); init!(sim, set()); step!(sim; t_plus = 0.5)
    t = 0.5
    best = typemax(Int)
    for i in 1:3
        t += 0.1; b = @allocated step!(sim; t_plus = t); best = min(best, b)
    end
    best
end
P("alloc_lag", alloc(fed_by(Constant(1.0), FirstOrderLag(τ = 0.5))))
P("alloc_vlag", alloc(Group((; k = Constant(SVector(1.0, -2.0)), c = FirstOrderLag(τ = SVector(0.5, 0.25))); local_wires = ("k/y" => "c/u",))))
P("alloc_tf", alloc(fed_by(Constant(1.0), lag_form())))
P("alloc_leadlag", alloc(fed_by(Constant(1.0), lead_lag())))
P("alloc_ss_scalar", alloc(fed_by(Constant(1.0), sslag(0.0))))
P("alloc_ss_2x2", alloc(fed_by(Constant(SVector(1.0,-1.0)), two_state_system())))
# order-of-FT comparisons
# generic forwarding probe
struct FwdTF <: AbstractComponent; sys::StateSpace; end
x_init(c::FwdTF) = x_init(c.sys); u_types(c::FwdTF) = u_types(c.sys); y_types(c::FwdTF) = y_types(c.sys)
x_deriv(c::FwdTF, b) = x_deriv(c.sys, b)
y_state(c::FwdTF, b) = y_state(c.sys, b)
y_direct(c::FwdTF, b) = y_direct(c.sys, b)
P("fwd_generic", errkind(() -> build(fed_by(Constant(1.0), FwdTF(sslag(0.0))))))
P("fwd_generic_D1", errkind(() -> build(fed_by(Constant(1.0), FwdTF(sslag(1.0))))))
struct FwdTF2 <: AbstractComponent; sys::StateSpace; end
x_init(c::FwdTF2) = x_init(c.sys); u_types(c::FwdTF2) = u_types(c.sys); y_types(c::FwdTF2) = y_types(c.sys)
x_deriv(c::FwdTF2, b) = x_deriv(c.sys, b)
y_state(c::FwdTF2, b) = y_state(c.sys, b)
y_direct(c::FwdTF2, (; x, u)) = 0.0 * u
P("fwd_twostage", errkind(() -> build(fed_by(Constant(1.0), FwdTF2(sslag(0.0))))))
let e = try build(fed_by(Constant(1.0), FwdTF(sslag(0.0)))) catch e e end
    P("fwd_generic_diag", e isa DiagnosticError ? [(typeof(d), hasproperty(d,:cause) ? typeof(d.cause) : nothing) for d in dlist(e)] : e) end
let e = try build(fed_by(Constant(1.0), FwdTF2(sslag(0.0)))) catch e e end
    P("fwd_two_diag", e isa DiagnosticError ? [(typeof(d), hasproperty(d,:port) ? d.port : nothing) for d in dlist(e)] : e) end
# only y_direct producer for D=0
struct FwdTF3 <: AbstractComponent; sys::StateSpace; end
x_init(c::FwdTF3) = x_init(c.sys); u_types(c::FwdTF3) = u_types(c.sys); y_types(c::FwdTF3) = y_types(c.sys)
x_deriv(c::FwdTF3, b) = x_deriv(c.sys, b)
y_direct(c::FwdTF3, (; x, u)) = (c.sys.C * x)[1]
P("fwd_only_direct_alone", errkind(() -> build(fed_by(Constant(1.0), FwdTF3(sslag(0.0))))))
P("fwd_only_direct_loop", errkind(() -> build(feedback_loop(FwdTF3(sslag(0.0))))))
# Library exports
P("exports", names(Redstone.Library))
P("jver", VERSION)
# discrete
P("dtf_sum", errkind(() -> DiscreteTransferFunction(num=(1,), den=(1,-0.7,-0.3), u0=1.0)))
P("dtf_sum_val", sum([1,-0.7,-0.3]))
dtf = DiscreteTransferFunction(num=(0.5,), den=(1,-0.5), u0=2.0)
P("dtf_u0", (L.held(dtf).s0, typeof(dtf)))
P("dtf_realize_eq", L.held(DiscreteTransferFunction(num=(1,2), den=(1,5))).A == L.realization(lead_lag()).A)
P("dss_fields", (fieldnames(DiscreteStateSpace), L.held(DiscreteStateSpace(A=[0.5;;],B=[1.0;;],C=[1.0;;])) isa DiscreteStateSpace))
P("dss_FT", (typeof(DiscreteStateSpace(A=[0.5;;],B=[1.0;;],C=[1.0;;],D=[1.0;;])), typeof(DiscreteStateSpace(A=[0.5;;],B=[1.0;;],C=[1.0;;]))))
P("ds_s0kw", errkind(() -> DiscreteStateSpace(A=[0.5;;],B=[1.0;;],C=[1.0;;],x0=1.0)))
P("dtf_abstract", (supertype(DiscreteTransferFunction{1,false,1,2,1}), L.AbstractDiscreteLinearSystem, supertype(typeof(DiscretizedTransferFunction(num=(1,),den=(1,1))))))
# discretized
dt = DiscretizedTransferFunction(num=(1,), den=(0.5,1))
P("dtfz_types", (typeof(dt), fieldtypes(typeof(dt)), typeof(L.held(dt)), L.held(dt).x0))
# zoh check
Δt = 0.01; τ = 0.5; a = exp(-Δt/τ)
r = L.realization(dt, Δt); P("zoh_lag", (r.A, r.B, r.C, r.D, a, 1-a))
# exact vs formula for 2x2
ss = DiscretizedStateSpace(A=[-1 0.5; 0 -2], B=[1 0.5; 0 1], C=[1 2; 0 1]); rr = L.realization(ss, 0.1)
Ad = exp([-1 0.5; 0 -2]*0.1); Bd = (Ad - I) / [-1 0.5; 0 -2] * [1 0.5; 0 1]
P("zoh_2", (rr.A ≈ Ad, rr.B ≈ Bd, rr.C == ss.continuous.C, rr.D == ss.continuous.D))
P("dss_u0_kw", errkind(() -> DiscretizedStateSpace(A=[-1.0;;],B=[1.0;;],C=[1.0;;],u0=1.0)))
# discretized u0: y starts at G(0)u0
sim = Simulation(fed_by(Constant(3.0), DiscretizedTransferFunction(num=(1,),den=(0.5,1),u0=3.0)); Δt_frame=1//100, )
P("dtfz_run", try init!(sim, set()); (port(sim,"c"), state(sim,"c")) catch e; sprint(showerror, e)[1:200] end)
P("dtfz_pole0", errkind(() -> DiscretizedTransferFunction(num=(1,),den=(1,0),u0=1.0)))
# allocs of exp
for n in (2,3,4,5)
    M = SMatrix{n,n}(randn(n,n)*0.1); f(M) = exp(M); f(M)
    P("exp_alloc_$n", (@allocated(f(M)), minimum(@elapsed(for _ in 1:1000; f(M); end)/1000 for _ in 1:5)))
end
let A = SMatrix{3,3}(randn(3,3)), B = SMatrix{3,2}(randn(3,2)), Z1 = zeros(SMatrix{2,3,Float64}), Z2 = zeros(SMatrix{2,2,Float64})
    f1(A,B,Z1,Z2) = vcat(hcat(A,B), hcat(Z1,Z2)); f2(A,B,Z1,Z2) = [A B; Z1 Z2]
    f1(A,B,Z1,Z2); f2(A,B,Z1,Z2)
    P("concat_alloc", (@allocated(f1(A,B,Z1,Z2)), @allocated(f2(A,B,Z1,Z2))))
end
let ss = DiscretizedStateSpace(A=[-1 0.5 0; 0 -2 1; 0 0 -3], B=[1 0.5; 0 1; 1 1], C=[1 2 0; 0 1 1]); L.realization(ss, 0.1); P("realization_alloc", @allocated L.realization(ss, 0.1)) end
# Tustin lag algebra check
τ=0.5; Δt=0.1; a=exp(-Δt/τ)
zz = 1.3+0.4im
tus = 1/(τ*(2/Δt)*(zz-1)/(zz+1)+1); form = (Δt/(2τ+Δt))*(zz+1)/(zz-(2τ-Δt)/(2τ+Δt))
P("tustin", abs(tus-form))
# discrete steady claims: continuous formula: q0=-A^-1 B u0
A = [-1 0.5; 0 -2]; B=[1;1.0]; Ad = exp(A*0.1); Bd = (Ad-I)/A*B
P("dss_steady", ((I-Ad)\Bd) ≈ -(A\B))
# import resolution
module M1; export Foo; Foo() = 1; end
module M2; Foo() = 2; end
module T1; import ..M2: Foo; using ..M1; r() = Foo(); end
module T2; using ..M1; import ..M2: Foo; r() = Foo(); end
module T3; using ..M1; r0 = Foo(); import ..M2: Foo; r() = Foo(); end
P("import_res", (T1.r(), T2.r(), (try T3.r() catch e; typeof(e) end)))
P("dtf_leadlag_FT", (typeof(DiscreteTransferFunction(num=(1,-0.9),den=(1,-0.5))), typeof(DiscretizedTransferFunction(num=(1,2),den=(1,5)))))
P("Discrete_names", (isdefined(L, :DiscreteIntegrator), isdefined(L, :Discretized), isdefined(L, :c2d)))

P("sing_int", let r = L.realization(TransferFunction(num=(1,),den=(1,0))); (Matrix(r.A), r.A \ SVector(1.0), -(r.A \ SVector(1.0))) end)
P("sing_dbl_neg", let r = L.realization(TransferFunction(num=(1,),den=(1,0,0))); (r.A \ SVector(0.0, 1.0)) end)
for (nx, nu) in ((1,1),(2,1),(2,2),(4,1))
    A = rand(SMatrix{nx,nx}); B = rand(SMatrix{nx,nu}); Z1 = zeros(SMatrix{nu,nx,Float64}); Z2 = zeros(SMatrix{nu,nu,Float64})
    f1(A,B,Z1,Z2) = vcat(hcat(A,B), hcat(Z1,Z2)); f2(A,B,Z1,Z2) = [A B; Z1 Z2]
    f1(A,B,Z1,Z2); f2(A,B,Z1,Z2)
    P("concat_$(nx)_$(nu)", (@allocated(f1(A,B,Z1,Z2)), @allocated(f2(A,B,Z1,Z2))))
end
P("ts_scoped", has_stage(y_state, FwdTF2(sslag(0.0))))
