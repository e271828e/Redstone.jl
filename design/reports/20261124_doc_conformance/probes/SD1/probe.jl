using Redstone, StaticArrays
import Redstone: AbstractComponent, x_init, s_init, m_init, ws_init, u_types, y_types, y_state,
    y_direct, x_deriv, s_update, state_events, StateEvent, local_wires, input_wires, output_wires,
    transparent_container, Group, build, Model, init!, set, at,
    DiagnosticError, StepError, diagnostics, diagnostic, message, port, Structure, ProbeDual,
    resolve_condition, combine

report(label, f) = try
    r = f(); println(label, " => ", r)
catch err
    if err isa DiagnosticError{Vector{Redstone.Diagnostic}}
        println(label, " => THROW ", [(typeof(d).name.name, hasproperty(d, :reason) ? d.reason : nothing) for d in diagnostics(err)])
        for d in diagnostics(err); println("     ", message(d)); end
    elseif err isa DiagnosticError
        d = diagnostic(err); println(label, " => THROW1 ", typeof(d).name.name, " ", hasproperty(d, :reason) ? d.reason : nothing); println("     ", message(d))
    elseif err isa StepError
        c = err.cause; println(label, " => STEPERR host=", err.host, " cause=", typeof(c).name.name)
        c isa Redstone.Diagnostic && println("     ", message(c))
    else
        println(label, " => OTHER ", sprint(showerror, err))
    end
end
import Redstone.Library: Constant, UnitDelay, SumJunction
paths(b) = [e.path for e in b.structure.components]

struct Gain <: AbstractComponent; k::Float64; end
x_init(::Gain) = nothing
u_types(::Gain) = (u = Float64,)
y_types(::Gain) = (y = Float64,)
y_direct(c::Gain, (; u)) = (y = c.k * u.u,)

struct Integ <: AbstractComponent end
x_init(::Integ) = (x = 0.0,)
u_types(::Integ) = (u = Float64,)
y_types(::Integ) = (y = Float64,)
y_state(::Integ, (; x)) = (y = x.x,)
x_deriv(::Integ, (; u)) = (x = u.u,)

# --- class (§8.5) ---
struct Empty <: AbstractComponent end
struct Mix <: AbstractComponent end
local_wires(::Mix) = ()
x_init(::Mix) = nothing
report("class/unreadable", () -> build(Group((; e = Empty()))))   # line ~
report("class/mixed", () -> build(Group((; m = Mix()))))
struct Both <: AbstractComponent end
x_init(::Both) = (x = 0.0,); s_init(::Both) = (n = 0,)
x_deriv(::Both, b) = (x = 0.0,)
report("tier/both", () -> build(Group((; m = Both()))))
struct DM <: AbstractComponent end
s_init(::DM) = (n = 0,); s_update(::DM, (; s)) = s; m_init(::DM) = (a = 1,)
y_types(::DM) = (y = Int,); y_state(::DM, (; s)) = (y = s.n,)
report("discrete/m_init", () -> build(Group((; m = DM()))))

# --- container children (§8.5) ---
struct Bank <: AbstractComponent
    units::Tuple{Gain,Gain}
    named::NamedTuple{(:p, :q),Tuple{Gain,Gain}}
    tag::Float64
end
local_wires(::Bank) = ("units/1/y" => "named/p/u",)
input_wires(::Bank) = ("in" => "units/1/u", "in2" => ("units/2/u", "named/q/u"))
output_wires(::Bank) = ("named/p/y" => "o1", "units/2/y" => "o2", "named/q/y" => "o3")
bank = Bank((Gain(1.0), Gain(2.0)), (p = Gain(3.0), q = Gain(4.0)), 1.0)
report("container/paths", () -> paths(build(Group((; b = bank); input_wires = ("in" => "b/in", "in2" => "b/in2")))))
struct BankT <: AbstractComponent
    units::Tuple{Gain,Gain}
    named::NamedTuple{(:p, :q),Tuple{Gain,Gain}}
end
local_wires(::BankT) = ("units/1/y" => "p/u",)
input_wires(::BankT) = ("in" => "units/1/u", "in2" => ("units/2/u", "q/u"))
transparent_container(::BankT) = :named
report("container/transparent", () -> paths(build(Group((; b = BankT((Gain(1.0), Gain(2.0)), (p = Gain(3.0), q = Gain(4.0)))); input_wires = ("in" => "b/in", "in2" => "b/in2")))))
report("container/assembly-not", () -> (Redstone.classify("", bank), Redstone.children("", bank) .|> first))

# --- branch shape (§8.3) ---
struct Br <: AbstractComponent end
x_init(::Br) = nothing
u_types(::Br) = (u = Float64,)
y_types(::Br) = (a = Float64, b = Float64)
y_direct(::Br, (; u)) = u.u <= 0 ? (a = u.u, b = 1.0) : (a = u.u,)
brg = Group((; c = Br()); input_wires = ("in" => "c/u",))
report("branch/build", () -> (build(brg); :built))
report("branch/untaken", () -> (m = Model(brg; Δt_frame = 1//10); init!(m, set(u = (in = 0.0,))); init!(m, set(u = (in = 1.0,))); :ran))
struct Br2 <: AbstractComponent end
x_init(::Br2) = nothing; u_types(::Br2) = (u = Float64,); y_types(::Br2) = (a = Float64, b = Float64)
y_direct(::Br2, (; u)) = u.u <= 0 ? (a = u.u, b = 1.0) : (a = u.u, b = 1)
report("branch/types", () -> (m = Model(Group((; c = Br2()); input_wires = ("in" => "c/u",)); Δt_frame = 1//10); init!(m, set(u = (in = 0.0,))); init!(m, set(u = (in = 1.0,))); :ran))

# --- unconnected, undeclared return ---
report("unconnected", () -> build(Group((; a = Gain(1.0)); output_wires = ("a/y" => "out",))))
struct Undecl <: AbstractComponent end
x_init(::Undecl) = nothing; y_types(::Undecl) = (y = Float64,); y_direct(::Undecl, b) = (y = 1.0, z = 2.0)
report("undeclared-return", () -> build(Group((; a = Undecl()))))

# --- algebraic loop (§5.5) ---
report("loop/real", () -> build(Group((; a = Gain(1.0), b = Gain(2.0)); local_wires = ("a/y" => "b/u", "b/y" => "a/u"))))
report("loop/delay", () -> paths(build(Group((; a = Gain(1.0), d = UnitDelay(0.0)); local_wires = ("a/y" => "d/u", "d/y" => "a/u")))))

# --- FSM: modes and events, no x ---
struct FSM <: AbstractComponent end
x_init(::FSM) = nothing; m_init(::FSM) = (on = false,); u_types(::FSM) = (u = Float64,)
y_types(::FSM) = (y = Bool,); y_state(::FSM, (; m)) = (y = m.on,)
fsm_guard(::FSM, (; u)) = u.u - 1.0
fsm_handler(::FSM, (; m)) = (m = (on = true,),)
state_events(::FSM) = (go = StateEvent(fsm_guard, fsm_handler),)
report("fsm", () -> (m = Model(Group((; f = FSM()); input_wires = ("in" => "f/u",)); Δt_frame = 1//10);
                     init!(m, set(u = (in = 0.0,))); (Redstone.frame!(m, 1)); Redstone.modes(m, "f")))

# --- abstract entries ---
abstract type AbsF end
struct ConcF <: AbsF; v::Float64; end
ConcF() = ConcF(0.0)
struct UseAbs <: AbstractComponent end
x_init(::UseAbs) = nothing; u_types(::UseAbs) = (f = AbsF,); y_types(::UseAbs) = (y = Float64,); y_direct(::UseAbs, (; u)) = (y = 1.0,)
struct UseConc <: AbstractComponent end
x_init(::UseConc) = nothing; u_types(::UseConc) = (f = ConcF,); y_types(::UseConc) = (y = Float64,); y_direct(::UseConc, (; u)) = (y = u.f.v,)
report("abstract/atroot", () -> build(Group((; c = UseAbs()); input_wires = ("f" => "c/f",))))
report("abstract/atroot+conc", () -> (build(Group((; a = UseAbs(), b = UseConc()); input_wires = ("f" => ("a/f", "b/f")))); :built))
report("abstract/stub", () -> (build(Group((; s = Constant(ConcF(1.0)), c = UseAbs()); local_wires = ("s/y" => "c/f",))); :built))
report("abstract/not-below", () -> build(Group((; s = Constant(3.0), c = UseAbs()); local_wires = ("s/y" => "c/f",))))
report("abstract/pinned-producer-activations", () -> (build(Group((; s = Constant(ConcF(1.0)), c = UseAbs()); local_wires = ("s/y" => "c/f",)); activations = (Float64, ProbeDual)); :built))

# --- opaque leaves ---
struct Hnd; r::Base.RefValue{Int}; end
struct UseH <: AbstractComponent end
x_init(::UseH) = nothing; u_types(::UseH) = (h = Hnd,); y_types(::UseH) = (y = Float64,); y_direct(::UseH, b) = (y = 1.0,)
report("opaque/handle-root", () -> build(Group((; c = UseH()); input_wires = ("h" => "c/h",))))
struct UseS <: AbstractComponent end
x_init(::UseS) = nothing; u_types(::UseS) = (s = Symbol,); y_types(::UseS) = (y = Float64,); y_direct(::UseS, b) = (y = 1.0,)
report("opaque/symbol-root", () -> build(Group((; c = UseS()); input_wires = ("s" => "c/s",))))
report("opaque/predicate", () -> (Redstone._opaque(Hnd), Redstone._opaque(Symbol), Redstone._opaque(ConcF)))

# --- workspace ---
const WSLOG = Any[]
struct WSD <: AbstractComponent end
s_init(::WSD) = (n = 0,); s_update(::WSD, (; s)) = s; y_types(::WSD) = (y = Int,); y_state(::WSD, (; s)) = (y = s.n,)
ws_init(::WSD, ::Type{T}) where {T} = (push!(WSLOG, (:disc, T)); (a = zeros(T, 1),))
struct WSC <: AbstractComponent end
x_init(::WSC) = (x = 0.0,); x_deriv(::WSC, (; x)) = (x = 0.0,); y_types(::WSC) = (y = Float64,); y_state(::WSC, (; x)) = (y = x.x,)
ws_init(::WSC, ::Type{T}) where {T} = (push!(WSLOG, (:cont, T)); (a = zeros(T, 1),))
report("ws", () -> (empty!(WSLOG); build(Group((; d = WSD(), c = WSC())); activations = (Float64, ProbeDual)); unique(WSLOG)))

# --- bundle ---
struct BU <: AbstractComponent end
x_init(::BU) = (x = 0.0,); u_types(::BU) = (u = Float64,); y_types(::BU) = (a = Float64, b = Float64)
y_state(::BU, (; x)) = (a = x.x,); y_direct(::BU, (; y_x, u)) = (b = y_x.a + u.u,); x_deriv(::BU, (; y, u)) = (x = y.b,)
report("bundle/handdown", () -> (m = Model(Group((; c = BU()); input_wires = ("in" => "c/u",)); Δt_frame = 1//10); init!(m, set(u = (in = 2.0,))); port(m, "c", :b)))
struct BU2 <: AbstractComponent end
x_init(::BU2) = (x = 0.0,); u_types(::BU2) = (u = Float64,); y_types(::BU2) = (a = Float64,)
y_state(::BU2, (; x, u)) = (a = x.x,); x_deriv(::BU2, (; u)) = (x = u.u,)
report("bundle/stage1-u", () -> build(Group((; c = BU2()); input_wires = ("in" => "c/u",))))
struct BU3 <: AbstractComponent end
x_init(::BU3) = (x = 0.0,); y_types(::BU3) = (a = Float64,)
y_state(::BU3, (; x)) = (a = x.x,); x_deriv(::BU3, (; x)) = (x = 0.0,)
report("bundle/xproj-undeclared-family", () -> Redstone.classify_bundle_field(:x_projection, Redstone.CONTINUOUS, :x))

# --- conditions: export chain, locality ---
nest = Group((; w = Group((; i = Integ(), j = Integ()); input_wires = ("in" => "i/u",), local_wires = ("i/y" => "j/u",))); input_wires = ("in" => "w/in",))
nb = build(nest)
report("cond/deep-path", () -> (resolve_condition(at("w/i", set(x = (x = 1.0,))), nb); :resolved))
report("cond/chain-input", () -> (resolve_condition(at("w/i", set(u = (u = 1.0,))), nb); :resolved))
report("cond/internally-wired", () -> resolve_condition(at("w/j", set(u = (u = 1.0,))), nb))
report("cond/unexported", () -> resolve_condition(set(u = (zzz = 1.0,)), nb))
report("cond/ws-target", () -> resolve_condition(at("w/i", set(ws = (a = 1.0,))), nb))

# --- library ---
report("sumjunction", () -> (m = Model(Group((; s = SumJunction{Float64,2}()); input_wires = ("a" => "s/in1", "b" => "s/in2")); Δt_frame = 1//10); init!(m, set(u = (a = 1.0, b = 2.0))); port(m, "s", :y)))
report("constant-ports", () -> (u_types(Constant(1.0)), y_types(Constant(1.0)), Redstone.classify("", Constant(1.0))))
report("frame/step", () -> (sim = Redstone.Simulation(Group((; i = Integ()); input_wires = ("in" => "i/u",)); Δt_frame = 1//10); init!(sim, set(u = (in = 1.0,))); Redstone.step!(sim; frames = 3); (Redstone.state(sim, "i"), Redstone.latest(sim) |> typeof)))
