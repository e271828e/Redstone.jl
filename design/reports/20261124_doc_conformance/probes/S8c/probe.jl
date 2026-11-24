# S8c probes: spec.md §8.2 (Function arguments..Completeness), §8.3, §8.4, §8.5.
import Redstone
import Redstone: AbstractComponent, x_init, s_init, m_init, u_types, y_types, y_state, y_direct,
    x_deriv, s_update, x_projection, state_events, StateEvent, local_wires, input_wires,
    output_wires, sample_times, transparent_container, Group, build, Simulation, init!, set,
    DiagnosticError, diagnostics, port, input_passthrough, Pinned, bundle_names,
    has_stage, CONTINUOUS, DISCRETE, Relative, message

dl(err) = err.carried isa Vector ? err.carried : [err.carried]
function kinds(f)
    try
        f(); "OK"
    catch err
        err isa DiagnosticError ? join(string.(nameof.(typeof.(dl(err)))), ",") :
            "EXC " * string(typeof(err))
    end
end
function msgs(f)
    try f(); "OK"
    catch err
        err isa DiagnosticError ? join(message.(dl(err)), "\n    ") : first(sprint(showerror, err), 300)
    end
end
show1(label, x) = println(rpad(label, 34), " => ", x)

# a driver wrapper: root assembly holding one leaf under root input/outputs
paths(s) = [e.path for e in s.components]
struct One{C} <: AbstractComponent
    c::C
end
local_wires(::One) = ()
struct Drive{C} <: AbstractComponent
    src::Any
    c::C
end
local_wires(::Drive) = ("src/out" => "c/e",)

struct Src <: AbstractComponent end
x_init(::Src) = nothing
y_types(::Src) = (out = Float64,)
y_direct(::Src, _) = (out = 1.0,)

struct DriveU{C} <: AbstractComponent
    c::C
end
local_wires(::DriveU) = ()
input_wires(::DriveU) = ("in" => "c/e",)
output_wires(::DriveU) = ("c/out" => "y",)
# ---- P1: StoreWithoutUpdate ------------------------------------------------
struct XNoDeriv <: AbstractComponent end
x_init(::XNoDeriv) = (x = 0.0,)
y_types(::XNoDeriv) = (y = Float64,)
y_state(::XNoDeriv, (; x)) = (y = x.x,)
struct SNoUpdate <: AbstractComponent end
s_init(::SNoUpdate) = (n = 0,)
y_types(::SNoUpdate) = (y = Int,)
y_state(::SNoUpdate, (; s)) = (y = s.n,)
struct XWithSUpdate <: AbstractComponent end   # x_init store, only s_update
x_init(::XWithSUpdate) = (x = 0.0,)
y_types(::XWithSUpdate) = (y = Float64,)
y_state(::XWithSUpdate, (; x)) = (y = x.x,)
s_update(::XWithSUpdate, (; s)) = (n = 1,)
struct SWithXDeriv <: AbstractComponent end
s_init(::SWithXDeriv) = (n = 0,)
y_types(::SWithXDeriv) = (y = Int,)
y_state(::SWithXDeriv, (; s)) = (y = s.n,)
x_deriv(::SWithXDeriv, _) = (x = 1.0,)
show1("P1 x_init no x_deriv", kinds(() -> build(One(XNoDeriv()))))
show1("P1 s_init no s_update", kinds(() -> build(One(SNoUpdate()))))
show1("P1 x_init + s_update only", kinds(() -> build(One(XWithSUpdate()))))
show1("P1 s_init + x_deriv only", kinds(() -> build(One(SWithXDeriv()))))

# ---- P2: events ------------------------------------------------------------
struct EvA <: AbstractComponent end
x_init(::EvA) = (x = 0.0,)
x_deriv(::EvA, _) = (x = 1.0,)
y_types(::EvA) = (y = Float64,)
y_state(::EvA, (; x)) = (y = x.x,)
ev_guard(::AbstractComponent, (; x)) = x.x - 1.0
ev_guardb(::AbstractComponent, (; x)) = x.x > 1.0
ev_handler(::AbstractComponent, _) = (x = (x = 0.0,),)
function ev_nohandler end
state_events(::EvA) = (a = StateEvent(ev_guard, ev_handler),)
struct EvB <: AbstractComponent end
x_init(::EvB) = (x = 0.0,)
x_deriv(::EvB, _) = (x = 1.0,)
y_types(::EvB) = (y = Float64,)
y_state(::EvB, (; x)) = (y = x.x,)
state_events(::EvB) = (a = StateEvent(ev_guard, ev_nohandler),)
struct EvC <: AbstractComponent end
x_init(::EvC) = (x = 0.0,)
x_deriv(::EvC, _) = (x = 1.0,)
y_types(::EvC) = (y = Float64,)
y_state(::EvC, (; x)) = (y = x.x,)
state_events(::EvC) = (a = (ev_guard, ev_handler),)
struct EvD <: AbstractComponent end
x_init(::EvD) = (x = 0.0,)
x_deriv(::EvD, _) = (x = 1.0,)
y_types(::EvD) = (y = Float64,)
y_state(::EvD, (; x)) = (y = x.x,)
state_events(::EvD) = (a = StateEvent(ev_guardb, ev_handler),)
show1("P2 ok event", kinds(() -> build(One(EvA()))))
show1("P2 handler missing", kinds(() -> build(One(EvB()))))
show1("P2 not a StateEvent", kinds(() -> build(One(EvC()))))
bd = build(One(EvD()))
show1("P2 policies Bool guard", string(bd.events.components[1].policies))
bd = build(One(EvA()))
show1("P2 policies Float64 guard", string(bd.events.components[1].policies))

# ---- P3: wrong tier --------------------------------------------------------
struct BothUpd <: AbstractComponent end
x_init(::BothUpd) = (x = 0.0,)
x_deriv(::BothUpd, _) = (x = 1.0,)
s_update(::BothUpd, _) = (n = 1,)
y_types(::BothUpd) = (y = Float64,)
y_state(::BothUpd, (; x)) = (y = x.x,)
struct PinnedDisc <: AbstractComponent end
s_init(::PinnedDisc) = nothing
y_types(::PinnedDisc) = (y = Pinned{Float64},)
y_direct(::PinnedDisc, _) = (y = 1.0,)
struct BothInit <: AbstractComponent end
x_init(::BothInit) = (x = 0.0,)
s_init(::BothInit) = (n = 0,)
x_deriv(::BothInit, _) = (x = 1.0,)
y_types(::BothInit) = (y = Float64,)
y_state(::BothInit, (; x)) = (y = x.x,)
struct DiscProj <: AbstractComponent end
s_init(::DiscProj) = (n = 0,)
s_update(::DiscProj, _) = (n = 1,)
y_types(::DiscProj) = (y = Int,)
y_state(::DiscProj, (; s)) = (y = s.n,)
x_projection(::DiscProj, x) = x
struct DiscModes <: AbstractComponent end
s_init(::DiscModes) = (n = 0,)
s_update(::DiscModes, _) = (n = 1,)
m_init(::DiscModes) = (k = 1,)
y_types(::DiscModes) = (y = Int,)
y_state(::DiscModes, (; s)) = (y = s.n,)
struct DiscEvents <: AbstractComponent end
s_init(::DiscEvents) = (n = 0,)
s_update(::DiscEvents, _) = (n = 1,)
y_types(::DiscEvents) = (y = Int,)
y_state(::DiscEvents, (; s)) = (y = s.n,)
state_events(::DiscEvents) = (a = StateEvent(ev_guard, ev_handler),)
show1("P3 x_deriv+s_update", kinds(() -> build(One(BothUpd()))))
show1("P3 Pinned on discrete", kinds(() -> build(One(PinnedDisc()))))
show1("P3 both inits", kinds(() -> build(One(BothInit()))))
show1("P3 x_projection on discrete", kinds(() -> build(One(DiscProj()))))
show1("P3 m_init on discrete", kinds(() -> build(One(DiscModes()))))
show1("P3 state_events on discrete", kinds(() -> build(One(DiscEvents()))))
show1("P3 msg", msgs(() -> build(One(BothUpd()))))
# does the x_projection error come from the structure step or the nominal step?
try build(One(DiscProj())) catch err
    show1("P3 x_projection carries structure", string(err.structure === nothing ? "no (raised past structure step)" : "yes"))
end

# ---- P4: stateless ---------------------------------------------------------
struct StlC <: AbstractComponent end
x_init(::StlC) = nothing
y_types(::StlC) = (out = Float64,)
u_types(::StlC) = (e = Float64,)
y_direct(::StlC, (; u)) = (out = u.e,)
struct StlD <: AbstractComponent end
s_init(::StlD) = nothing
y_types(::StlD) = (out = Float64,)
u_types(::StlD) = (e = Float64,)
y_direct(::StlD, (; u)) = (out = u.e,)
struct StlNoY <: AbstractComponent end
x_init(::StlNoY) = nothing
u_types(::StlNoY) = (e = Float64,)
struct NoStoreNoY <: AbstractComponent end
y_types(::NoStoreNoY) = (out = Float64,)
y_direct(::NoStoreNoY, _) = (out = 1.0,)
show1("P4 stateless continuous", kinds(() -> build(Drive(Src(), StlC()))))
show1("P4 stateless discrete", kinds(() -> build(Drive(Src(), StlD()))))
show1("P4 stateless no y_types", kinds(() -> build(Drive(Src(), StlNoY()))))
show1("P4 no store at all", kinds(() -> build(One(NoStoreNoY()))))
b = build(Drive(Src(), StlC())); show1("P4 tier C", string(b.structure.components[2].tier))
b = build(Drive(Src(), StlD())); show1("P4 tier D", string(b.structure.components[2].tier))
show1("P4 bundle names StlC y_direct", string(bundle_names(y_direct, StlC(), CONTINUOUS, ())))
show1("P4 bundle names StlD y_direct", string(bundle_names(y_direct, StlD(), DISCRETE, ())))
show1("P4 bundle names XNoDeriv y_state", string(bundle_names(y_state, XNoDeriv(), CONTINUOUS, ())))

# ---- P5: stage 1/2 completeness, visibility --------------------------------
struct Undecl <: AbstractComponent end
x_init(::Undecl) = nothing
y_types(::Undecl) = (P_shaft = Float64,)
y_direct(::Undecl, _) = (P_shft = 1.0,)
struct NotProd <: AbstractComponent end
x_init(::NotProd) = (x = 0.0,)
x_deriv(::NotProd, _) = (x = 1.0,)
y_types(::NotProd) = (a = Float64, b = Float64)
y_state(::NotProd, (; x)) = (a = x.x,)
struct Twice <: AbstractComponent end
x_init(::Twice) = (x = 0.0,)
x_deriv(::Twice, _) = (x = 1.0,)
y_types(::Twice) = (a = Float64,)
y_state(::Twice, (; x)) = (a = x.x,)
y_direct(::Twice, _) = (a = 1.0,)
struct Branchy <: AbstractComponent end
x_init(::Branchy) = nothing
u_types(::Branchy) = (e = Float64,)
y_types(::Branchy) = (out = Float64, P = Float64)
y_direct(::Branchy, (; u)) = u.e < 0 ? (out = 1.0,) : (out = 1.0, P = 2.0)
struct BranchyTaken <: AbstractComponent end
x_init(::BranchyTaken) = nothing
u_types(::BranchyTaken) = (e = Float64,)
y_types(::BranchyTaken) = (out = Float64, P = Float64)
y_direct(::BranchyTaken, (; u)) = u.e >= 0 ? (out = 1.0,) : (out = 1.0, P = 2.0)
struct NoOut <: AbstractComponent end   # stateful, no y_types
x_init(::NoOut) = (x = 0.0,)
x_deriv(::NoOut, _) = (x = 1.0,)
struct OneNoOut{C} <: AbstractComponent
    c::C
end
local_wires(::OneNoOut) = ()
show1("P5 typo'd return field", kinds(() -> build(One(Undecl()))))
show1("P5 typo msg", msgs(() -> build(One(Undecl()))))
show1("P5 declared not produced", kinds(() -> build(One(NotProd()))))
show1("P5 DNP msg", msgs(() -> build(One(NotProd()))))
show1("P5 produced twice", kinds(() -> build(One(Twice()))))
show1("P5 taken-branch missing P", kinds(() -> build(Drive(Src(), BranchyTaken()))))
show1("P5 stateful no y_types builds", kinds(() -> build(OneNoOut(NoOut()))))
show1("P5 untaken branch at first exec", (try; init!(Simulation(DriveU(Branchy()); Δt_frame = 1//10), set(u = (in = -1.0,))); "no error";
    catch err; err isa DiagnosticError ? join(string.(nameof.(typeof.(dl(err)))), ",") * " :: " * join(message.(dl(err)), " | ") : sprint(showerror, err); end))

# ---- P6: walkthroughs 1,2,4 ------------------------------------------------
struct TW <: AbstractComponent end
local_wires(::TW) = ("src/out" => "c/throtle",)
struct Thr <: AbstractComponent end
x_init(::Thr) = nothing
u_types(::Thr) = (throttle = Float64,)
y_types(::Thr) = (out = Float64,)
y_direct(::Thr, (; u)) = (out = u.throttle,)
struct W1 <: AbstractComponent
    src::Src
    c::Thr
end
local_wires(::W1) = ("src/out" => "c/throtle",)
struct W2 <: AbstractComponent
    c::Thr
end
local_wires(::W2) = ()
struct BoolIn <: AbstractComponent end
x_init(::BoolIn) = nothing
u_types(::BoolIn) = (flag = Bool,)
y_types(::BoolIn) = (out = Float64,)
y_direct(::BoolIn, _) = (out = 1.0,)
struct W4 <: AbstractComponent
    src::Src
    c::BoolIn
end
local_wires(::W4) = ("src/out" => "c/flag",)
show1("P6 w1 typo wire", kinds(() -> build(W1(Src(), Thr()))))
show1("P6 w1 msg", msgs(() -> build(W1(Src(), Thr()))))
show1("P6 w2 forgotten wire", kinds(() -> build(W2(Thr()))))
show1("P6 w4 type mismatch", kinds(() -> build(W4(Src(), BoolIn()))))
show1("P6 w4 msg", msgs(() -> build(W4(Src(), BoolIn()))))

# ---- P7: class by declaration shape ----------------------------------------
struct Neither <: AbstractComponent end
struct NeitherHolds <: AbstractComponent
    s::Src
end
struct Mixed <: AbstractComponent end
local_wires(::Mixed) = ()
x_init(::Mixed) = nothing
struct OnlyInput <: AbstractComponent end
input_wires(::OnlyInput) = ()
struct OnlyYT <: AbstractComponent end
y_types(::OnlyYT) = (y = Float64,)
x_init(::OnlyYT) = nothing
y_direct(::OnlyYT, _) = (y = 1.0,)
show1("P7 neither", kinds(() -> build(Neither())))
show1("P7 neither holds components", msgs(() -> build(NeitherHolds(Src()))))
show1("P7 neither msg", msgs(() -> build(Neither())))
show1("P7 mixed", kinds(() -> build(Mixed())))
show1("P7 only input_wires", kinds(() -> build(OnlyInput())))
show1("P7 supertypes", string(supertype(Group), " ", isdefined(Redstone, :AbstractAssembly)))

# ---- P8: transparent_container two names, Group, sample_times --------------
struct TwoTrans{K <: NamedTuple, U <: Tuple} <: AbstractComponent
    kids::K
    units::U
end
local_wires(::TwoTrans) = ()
transparent_container(::TwoTrans) = (:kids, :units)
show1("P8 two transparent containers", kinds(() -> build(TwoTrans((a = Src(),), (Src(),)))))
show1("P8 two transparent msg", msgs(() -> build(TwoTrans((a = Src(),), (Src(),)))))

# Group function for sample_times
show1("P8 sample_times function", kinds(() -> Group((; a = Src()); sample_times = g -> (; a = Relative(2)))))
# Group bare pair
gp = Group((; src = Src(), c = Thr()); local_wires = "src/out" => "c/throttle")
show1("P8 Group bare Pair entries", string(local_wires(gp)))
# bare Pair returned by named assembly
struct PairBody <: AbstractComponent
    src::Src
    c::Thr
end
local_wires(::PairBody) = "src/out" => "c/throttle"
show1("P8 named bare Pair", kinds(() -> build(PairBody(Src(), Thr()))))
# function wire keyword
inner = Group((; hold = Thr()); input_wires = "throttle" => "hold/throttle")
outer = Group((; inner); input_wires = g -> input_passthrough(g, "inner"; prefix = ""))
show1("P8 function wire", string(input_wires(outer)))
show1("P8 field holds function", string(typeof(outer.input_wires) <: Function))
# spec approach block, adapted
approach = Group((; vehicle = Thr(), gear = Thr());
    input_wires = g -> input_passthrough(g, "vehicle"; prefix = ""),
    local_wires = ("vehicle/out" => "gear/throttle",))
show1("P8 approach input_wires", string(input_wires(approach)))
# copy
rew = Group(approach; local_wires = ())
show1("P8 copy keeps fn", string(input_wires(rew)) * " lw=" * string(local_wires(rew)))
show1("P8 copy children", string(keys(rew.children)))
# a copy with other children computes entries from them
approach2 = Group(approach; children = (; vehicle = Thr(), gear = Thr(), extra = Thr()))
show1("P8 copy w/ children fn", string(input_wires(approach2)))
# spec first block adapted: world with Group
world = Group((; src = Src(), c = Thr()); local_wires = ("src/out" => "c/throttle",))
w = build(world)
show1("P8 Group build paths", string(paths(w.structure)))
# Group sample_times bare key
gs = Group((; src = Src(), c = Thr()); local_wires = ("src/out" => "c/throttle",), sample_times = (; c = Relative(2)))
show1("P8 Group bare key rates", msgs(() -> build(gs)))
show1("P8 Group field-name sugar", kinds(() -> build(Group((; src = Src(), c = Thr()); local_wires = ("src/out" => "c/throttle",), sample_times = (; children = Relative(2))))))
show1("P8 Group transparent", string(transparent_container(world)))
# Group is an AbstractComponent with type params carrying children
show1("P8 Group type", string(typeof(world)))
show1("P8 Group fieldnames", string(fieldnames(Group)))
# classify Group
show1("P8 Group class", string(Redstone.classify("", world)))
# empty container ok, abstract
struct EmptyRoster{U <: Tuple} <: AbstractComponent
    units::U
end
local_wires(::EmptyRoster) = ()
show1("P8 empty container", string(paths(build(EmptyRoster(())).structure)))
# Tuple naming
struct TupR{U <: Tuple} <: AbstractComponent
    units::U
end
local_wires(::TupR) = ()
show1("P8 tuple naming", string(paths(build(TupR((Src(), Src()))).structure)))
# Group rewired via copy of the keyword normalisation
show1("P8 Group(g) w/ bare Pair kw", string(local_wires(Group(world; local_wires = "src/out" => "c/throttle"))))
# stage discovery by method existence: positional spelling not discovered
struct Posl <: AbstractComponent end
y_direct(::Posl, x, u) = nothing
y_direct(::Posl; u = 1) = nothing
show1("P9 has_stage positional/kw", string(has_stage(y_direct, Posl())))
