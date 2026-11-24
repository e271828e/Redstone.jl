using Redstone, StaticArrays
import Redstone: AbstractComponent, x_init, s_init, m_init, ws_init, u_types, y_types, y_state,
    y_direct, x_deriv, s_update, x_projection, state_events, StateEvent, local_wires, input_wires,
    output_wires, sample_times, transparent_container, stop_reason, Group, Relative, Absolute, Pinned,
    resolve, resolve_terminal, input_faces, output_faces, input_passthrough, output_passthrough,
    DiagnosticError, diagnostics, CONTINUOUS, DISCRETE
const R = Redstone

function kinds(f)
    try
        f(); return :ok
    catch e
        e isa DiagnosticError || return (:other, typeof(e), first(split(sprint(showerror, e), '\n')))
        ds = e.carried isa Vector ? e.carried : [e.carried]
        return [(nameof(typeof(d)), hasproperty(d, :reason) ? d.reason : nothing) for d in ds]
    end
end
P(label, v) = println(label, " => ", v)

# ---- fixtures -------------------------------------------------------------
struct Gn <: AbstractComponent; k::Float64; end
x_init(::Gn) = nothing
u_types(::Gn) = (u = Float64,)
y_types(::Gn) = (y = Float64,)
y_direct(c::Gn, (; u)) = (y = c.k * u.u,)

struct BareI <: AbstractComponent end
x_init(::BareI) = 0.0
u_types(::BareI) = Float64
y_types(::BareI) = Float64
y_state(::BareI, (; x)) = x
x_deriv(::BareI, (; u)) = u

struct Ctr <: AbstractComponent end
s_init(::Ctr) = (n = 0,)
y_types(::Ctr) = (n = Int,)
y_state(::Ctr, (; s)) = (n = s.n,)
s_update(::Ctr, (; s)) = (n = s.n + 1,)

struct Src <: AbstractComponent end   # no inputs, one output
x_init(::Src) = nothing
y_types(::Src) = (y = Float64,)
y_direct(::Src, ::Any) = (y = 1.0,)

struct NoDecl <: AbstractComponent end
struct HoldsKid <: AbstractComponent; k::Gn; end
struct Mx <: AbstractComponent end
local_wires(::Mx) = ()
x_init(::Mx) = nothing
module Bad
using Redstone: AbstractComponent
struct B <: AbstractComponent end
x_init(::B) = nothing
end

# stores
mk(name, body) = nothing
struct E1 <: AbstractComponent end; x_init(::E1) = (;)
struct E2 <: AbstractComponent end; s_init(::E2) = (;)
struct E3 <: AbstractComponent end; x_init(::E3) = nothing; m_init(::E3) = (;); y_types(::E3) = (y = Float64,)
struct L1 <: AbstractComponent end; x_init(::L1) = (a = 1,);          x_deriv(::L1, ::Any) = (a = 1,); y_types(::L1) = (y = Float64,)
struct L2 <: AbstractComponent end; x_init(::L2) = (a = 1.0f0,);      x_deriv(::L2, ::Any) = (a = 1,); y_types(::L2) = (y = Float64,)
struct L3 <: AbstractComponent end; x_init(::L3) = (a = SVector(1, 2),); x_deriv(::L3, ::Any) = (a = 1,); y_types(::L3) = (y = Float64,)
struct L4 <: AbstractComponent end; x_init(::L4) = (a = SVector(1f0),); x_deriv(::L4, ::Any) = (a = 1,); y_types(::L4) = (y = Float64,)
struct L5 <: AbstractComponent end; x_init(::L5) = (a = (b = 1.0,),); x_deriv(::L5, ::Any) = (a = 1,); y_types(::L5) = (y = Float64,)
struct L6 <: AbstractComponent end; x_init(::L6) = (a = [1.0],);      x_deriv(::L6, ::Any) = (a = 1,); y_types(::L6) = (y = Float64,)
struct L7 <: AbstractComponent end; x_init(::L7) = 1;                 x_deriv(::L7, ::Any) = 1; y_types(::L7) = (y = Float64,)
struct L8 <: AbstractComponent end; x_init(::L8) = (a = true,);       x_deriv(::L8, ::Any) = (a = 1,); y_types(::L8) = (y = Float64,)
struct F1 <: AbstractComponent end; s_init(::F1) = (a = "x",); s_update(::F1, ::Any) = (a = "x",); y_types(::F1) = (y = Int,)
struct F2 <: AbstractComponent end; x_init(::F2) = nothing; m_init(::F2) = (a = [1],); y_types(::F2) = (y = Float64,)
struct W1 <: AbstractComponent end; x_init(::W1) = (a = 0.0,); y_types(::W1) = (y = Float64,)
struct W2 <: AbstractComponent end; s_init(::W2) = (n = 0,); y_types(::W2) = (y = Int,)
struct W3 <: AbstractComponent end; x_init(::W3) = (a = 0.0,); s_init(::W3) = (n = 0,); y_types(::W3) = (y = Int,)
struct T1 <: AbstractComponent end; u_types(::T1) = (u = Float64,); y_types(::T1) = (y = Float64,); y_direct(::T1, ::Any) = (y = 1.0,)
struct T2 <: AbstractComponent end; x_init(::T2) = nothing; s_init(::T2) = nothing; y_types(::T2) = (y = Float64,)
struct T3 <: AbstractComponent end; s_init(::T3) = nothing; m_init(::T3) = (a = 1,); y_types(::T3) = (y = Float64,)
struct T4 <: AbstractComponent end; s_init(::T4) = nothing; state_events(::T4) = (e = StateEvent(1, 2),); y_types(::T4) = (y = Float64,)
struct T5 <: AbstractComponent end; s_init(::T5) = nothing; u_types(::T5) = (u = Pinned{Float64},); y_types(::T5) = (y = Float64,)
struct T6 <: AbstractComponent end; x_init(::T6) = (a = 0.0,); x_deriv(::T6, ::Any) = (a = 1.0,); s_update(::T6, ::Any) = (n = 1,); y_types(::T6) = (y = Float64,)
struct T7 <: AbstractComponent end; s_init(::T7) = (n = 0,); s_update(::T7, ::Any) = (n = 1,); x_init(::T7) = (a = 0.0,); y_types(::T7) = (y = Int,)
struct T8 <: AbstractComponent end; s_init(::T8) = (n = 0,); x_deriv(::T8, ::Any) = (n = 1,); y_types(::T8) = (y = Int,)
struct T9 <: AbstractComponent end; x_init(::T9) = nothing; u_types(::T9) = (u = Pinned{Float64},); y_types(::T9) = (y = Pinned{Float64},); y_direct(::T9, ::Any) = (y = 1.0,)
struct S1 <: AbstractComponent end; x_init(::S1) = nothing; y_types(::S1) = (y = (Float64, Float64),); u_types(::S1) = (u = 3,)
struct S2 <: AbstractComponent end; x_init(::S2) = nothing; y_types(::S2) = nothing
struct S3 <: AbstractComponent end; x_init(::S3) = nothing; y_types(::S3) = (y = SVector{2,Pinned{Float64}},)
struct S4 <: AbstractComponent end; s_init(::S4) = nothing; y_types(::S4) = (y = SVector{2,Pinned{Float64}},)
struct S5 <: AbstractComponent end; x_init(::S5) = nothing; u_types(::S5) = NamedTuple{(Symbol(""),)}((Float64,)); y_types(::S5) = (y = Float64,)
struct S6 <: AbstractComponent end; x_init(::S6) = nothing; u_types(::S6) = (); y_types(::S6) = (y = Float64,)
struct S7 <: AbstractComponent end; x_init(::S7) = nothing; y_types(::S7) = (y = Float64,)  # declared, no stage
struct PT <: AbstractComponent end; x_init(::PT) = nothing; y_types(::PT) = (y = Float64,); y_direct(::PT, ::Any) = (y = 1.0,); transparent_container(::PT) = :nope

# wires
asm(; loc = (), inw = (), outw = (), kids = (; a = Gn(1.0), s = Src()), st = (;)) =
    Group(kids; local_wires = loc, input_wires = inw, output_wires = outw, sample_times = st)
struct NA{C} <: AbstractComponent; kids::C; w; i; o; end
local_wires(a::NA) = a.w
input_wires(a::NA) = a.i
output_wires(a::NA) = a.o
transparent_container(::NA) = :kids

# containers
struct Cont{C} <: AbstractComponent; units::C; end
local_wires(::Cont) = ()
struct ContT{C} <: AbstractComponent; units::C; end
local_wires(::ContT) = ()
transparent_container(::ContT) = :units
struct ContBad{C} <: AbstractComponent; units::C; end
local_wires(::ContBad) = ()
transparent_container(::ContBad) = :nope
struct ContMix <: AbstractComponent; units; end
local_wires(::ContMix) = ()
struct Sib{C,D} <: AbstractComponent; units::C; other::D; end
local_wires(::Sib) = ()
transparent_container(::Sib) = :units
struct SelfN{C} <: AbstractComponent; units::C; end
local_wires(::SelfN) = ()
transparent_container(::SelfN) = :units

println("== class")
P("p20 ClassUnreadable plain",  kinds(() -> R.build(NoDecl())))
P("p21 ClassUnreadable holds",  kinds(() -> R.build(HoldsKid(Gn(1.0)))))
P("p22 ClassMixed",             kinds(() -> R.build(Mx())))
P("p23 DeclarationShadowed",    kinds(() -> R.build(Bad.B())))
try R.build(NoDecl()); catch e; d = e.carried; P("p24 ClassUnreadable payload", (d.found, d.assembly_family, d.leaf_family, d.holds_components)); end
try R.build(HoldsKid(Gn(1.0))); catch e; d = e.carried; P("p25 holds_components", d.holds_components); end
try R.build(Mx()); catch e; d = e.carried; P("p26 ClassMixed decls", d.declarations); end
P("p27 declarations_found", R.declarations_found(Gn(1.0)))
P("p28 leaf_declarations Ctr", R.leaf_declarations(Ctr()))
P("p29 stop_reason default", stop_reason(Gn(1.0)))
P("p29b transparent default", transparent_container(Gn(1.0)))
P("p29c sample_times default", sample_times(NoDecl()))
P("p29d input_wires default", (input_wires(Gn(1.0)), output_wires(Gn(1.0))))

println("== stores")
P("p30 EmptyStore x",  kinds(() -> R.build(E1())))
P("p31 EmptyStore s",  kinds(() -> R.build(E2())))
P("p32 EmptyStore m",  kinds(() -> R.build(E3())))
for T in (L1, L2, L3, L4, L5, L6, L7, L8)
    try R.build(T()); P("p33 $T", :ok)
    catch e; ds = e.carried isa Vector ? e.carried : [e.carried]; P("p33 $T", [(nameof(typeof(d)), d.reason, d.name) for d in ds]); end
end
for T in (F1, F2)
    try R.build(T()); P("p34 $T", :ok)
    catch e; ds = e.carried isa Vector ? e.carried : [e.carried]; P("p34 $T", [(nameof(typeof(d)), d.store, d.name) for d in ds]); end
end
P("p35 StoreWithoutUpdate x",   kinds(() -> R.build(W1())))
P("p36 StoreWithoutUpdate s",   kinds(() -> R.build(W2())))
P("p37 both stores no update",  kinds(() -> R.build(W3())))
P("p38 TierUnreadable",         kinds(() -> R.build(T1())))
P("p39 x_init+s_init nothing",  kinds(() -> R.build(T2())))
P("p40 m_init on discrete",     kinds(() -> R.build(T3())))
P("p41 state_events on discrete", kinds(() -> R.build(T4())))
P("p42 Pinned on discrete",     kinds(() -> R.build(T5())))
P("p43 x_deriv+s_update",       kinds(() -> R.build(T6())))
P("p44 s_init+s_update+x_init", kinds(() -> R.build(T7())))
P("p45 s_init + x_deriv",       kinds(() -> R.build(T8())))
P("p46 Pinned entry on continuous ok", kinds(() -> R.build(T9())))
P("p47 not_a_type tuple/number", kinds(() -> R.build(S1())))
P("p48 y_types nothing",        kinds(() -> R.build(S2())))
P("p49 nested marker cont",     kinds(() -> R.build(S3())))
P("p50 nested marker disc",     kinds(() -> R.build(S4())))
P("p51 empty u_types name",     kinds(() -> R.build(S5())))
P("p52 u_types = ()",           kinds(() -> R.build(S6())))
struct SO <: AbstractComponent end; x_init(::SO) = nothing
P("p53 StatelessWithoutOutputs", kinds(() -> R.build(SO())))

println("== wires")
P("p60 bare Pair local",   kinds(() -> R.build(NA((a = Gn(1.0), s = Src()), "s/y" => "a/u", (), ()))))
P("p61 string input",      kinds(() -> R.build(NA((a = Gn(1.0), s = Src()), (), "x", ()))))
P("p62 not_a_pair",        kinds(() -> R.build(NA((a = Gn(1.0), s = Src()), (3,), (), ()))))
P("p63 good",              kinds(() -> R.build(NA((a = Gn(1.0), s = Src()), ("s/y" => "a/u",), (), ()))))
P("p64 face with slash",   kinds(() -> R.build(NA((a = Gn(1.0),), (), ("x/y" => "a/u",), ()))))
P("p65 face collision",    kinds(() -> R.build(NA((a = Gn(1.0),), (), ("x" => "a/u",), ("a/y" => "x",)))))
P("p66 empty tuple paths", kinds(() -> R.build(NA((a = Gn(1.0),), (), ("x" => (),), ()))))
P("p67 input endpoint resolves to output", kinds(() -> R.build(NA((a = Gn(1.0),), (), ("x" => "a/y",), ()))))
P("p68 output source an input",           kinds(() -> R.build(NA((a = Gn(1.0),), (), (), ("a/u" => "y",)))))
P("p69 reversed local",    kinds(() -> R.build(NA((a = Gn(1.0), s = Src()), ("a/u" => "s/y",), (), ()))))
P("p70 two producers",     kinds(() -> R.build(NA((a = Gn(1.0), s = Src(), t = Src()), ("s/y" => "a/u", "t/y" => "a/u"), (), ()))))
P("p71 fan out",           kinds(() -> R.build(NA((a = Gn(1.0), b = Gn(2.0)), (), ("x" => ("a/u", "b/u"),), ()))))
P("p72 empty face name",   kinds(() -> R.build(NA((a = Gn(1.0),), (), ("" => "a/u",), ()))))
P("p73 deep endpoint",     kinds(() -> R.build(NA((a = Gn(1.0), s = Src()), (), ("x" => "a/b/u",), ()))))
P("p74 unknown child",     kinds(() -> R.build(NA((a = Gn(1.0),), (), ("x" => "zz/u",), ()))))
P("p75 child alone",       kinds(() -> R.build(NA((a = Gn(1.0),), (), ("x" => "a",), ()))))
P("p76 empty last segment", kinds(() -> R.build(NA((a = Gn(1.0),), (), ("x" => "a/",), ()))))

println("== containers")
struct ContW{C} <: AbstractComponent; units::C; end
local_wires(::ContW) = ()
input_wires(::ContW) = ("x" => "units/1/u",)
P("p80 tuple container wires", kinds(() -> R.build(ContW((Gn(1.0), Gn(2.0))))))
P("p80b paths", kinds(() -> R.build(Group((; c = Cont((Src(), Src()))); input_wires = ("x" => "c/units/1/u",)))))
P("p81 transparent container paths", [e.path for e in R.build(ContT((a = Src(), b = Src()))).structure.components])
P("p82 TransparentContainerUnknown", kinds(() -> R.build(ContBad((a = Src(),)))))
try R.build(ContBad((a = Src(),))); catch e; d = e.carried isa Vector ? e.carried[1] : e.carried; P("p82b payload", (d.field, d.component, d.candidates, d.path)); end
P("p83 primitive transparent_container never read", kinds(() -> R.build(PT())))
P("p84 ContainerMixed",  kinds(() -> R.build(ContMix((Src(), 3)))))
P("p85 ContainerNested", kinds(() -> R.build(ContMix(((Src(),), 3)))))
struct Colide{C} <: AbstractComponent; a::Src; kids::C; end
local_wires(::Colide) = ()
transparent_container(::Colide) = :kids
P("p87 bare key = sibling child name", kinds(() -> R.build(Colide(Src(), (a = Src(),)))))
P("p88 bare key = own field name (sugar)", kinds(() -> R.build(SelfN((units = Src(),)))))
P("p89 bare key = sibling container field", kinds(() -> R.build(Sib((a = Src(),), (a = Src(),)))))
P("p89b bare key = sibling container field name", kinds(() -> R.build(Sib((other = Src(),), (z = Src(),)))))
P("p89c empty sibling container no collision", kinds(() -> R.build(Sib((other = Src(),), (;)))))
P("p89d empty transparent container", kinds(() -> R.build(ContT((;)))))

println("== sample_times")
st(x) = R.build(Group((; a = Ctr(), g = Src(), c = Group((; k = Ctr())), u = Cont((Ctr(), Ctr()))); sample_times = x))
tm(b) = [(e.path, e.timing) for e in b.structure.components]
P("p100 ok Relative on discrete+sub-assembly", kinds(() -> st((a = Relative(2), c = Relative(3, 1)))))
P("p101 non-NamedTuple",   kinds(() -> st(((:a, Relative(2)),))))
P("p102 bare number",      kinds(() -> st((a = 2,))))
P("p103 unknown key",      kinds(() -> st((zz = Relative(2),))))
P("p104 continuous child", kinds(() -> st((g = Relative(2),))))
P("p105 deep key",         kinds(() -> st((var"c/k" = Relative(2),))))
P("p106 container field name keys all", tm(st((u = Relative(2),))))
P("p107 unlisted default", tm(st((a = Relative(2),))))
P("p108 affine", tm(R.build(Group((; mid = Group((; c = Ctr()); sample_times = (c = Relative(3, 1),))); sample_times = (mid = Relative(2, 1),)))))
P("p109 Relative(0)",   kinds(() -> st((a = Relative(0),))))
P("p110 Relative(2,2)", kinds(() -> st((a = Relative(2, 2),))))
P("p111 Relative(1,1)", kinds(() -> st((a = Relative(1, 1),))))
P("p112 Absolute(0)",   kinds(() -> st((a = Absolute(0),))))
P("p113 Absolute(1//2,1)", kinds(() -> st((a = Absolute(1//2, 1),))))
P("p114 Absolute faster than scope ok", kinds(() -> st((a = Absolute(1//50),))))
P("p115 Absolute on continuous", kinds(() -> st((g = Absolute(1//50),))))
P("p116 Absolute on sub-assembly", tm(st((c = Absolute(1//10),))))

println("== rate constructors")
P("p120 Relative(1.0)", kinds(() -> Relative(1.0)))
P("p121 Relative(2,1.0)", kinds(() -> Relative(2, 1.0)))
P("p122 Relative(big(2)^80)", kinds(() -> Relative(big(2)^80)))
P("p123 Relative(3//1)", kinds(() -> Relative(3//1)))
P("p124 Relative fields", (Relative(2).D, Relative(2).Φ, Relative(Int8(3), UInt8(1))))
P("p125 Relative(2,big(2)^80)", kinds(() -> Relative(2, big(2)^80)))
P("p126 Relative(0), Relative(-1,5) construct", (Relative(0), Relative(-1, 5)))
P("p127 Absolute(0.5)", kinds(() -> Absolute(0.5)))
P("p128 Absolute(1//2, 0.1)", kinds(() -> Absolute(1//2, 0.1)))
P("p129 Absolute big", kinds(() -> Absolute(big(1)//big(2)^80)))
P("p130 Absolute(1//0)", kinds(() -> Absolute(1//0)))
P("p131 Absolute ok forms", (Absolute(50), Absolute(1//50, 1//500), Absolute(Int8(2), Int8(1))))
P("p132 Absolute(Inf)", kinds(() -> Absolute(Inf)))
P("p133 Relative(NaN)", kinds(() -> Relative(NaN)))
for (lab, f) in (("Relative(1.0)", () -> Relative(1.0)), ("Relative(2,1.5)", () -> Relative(2, 1.5)), ("Relative big", () -> Relative(big(2)^80)),
                 ("Absolute(0.5)", () -> Absolute(0.5)), ("Absolute(1//2,0.1)", () -> Absolute(1//2, 0.1)), ("Absolute big", () -> Absolute(big(1)//big(2)^80)))
    try f(); catch e; d = e.carried; P("p134 $lab", (d.call, d.reason, hasproperty(d, :argument) ? d.argument : nothing, d.value)); end
end

println("== faces and helpers")
cg = Group((; a = Gn(1.0), b = BareI(), n = Src(), u = Cont((Gn(1.0), Gn(2.0))), t = ContT((k = Gn(1.0),))))
P("p140 faces prim", (input_faces(Gn(1.0)), input_faces(BareI()), output_faces(BareI()), input_faces(Src())))
P("p141 faces assembly", (input_faces(Group((; a = Gn(1.0)); input_wires = ("x" => "a/u", "y" => "a/u"))), output_faces(Group((; a = Gn(1.0)); output_wires = ("a/y" => "o",)))))
let g = Group((; a = Gn(1.0)); input_wires = ("x" => "a/u",)); v = input_faces(g); push!(v, "zz"); P("p142 fresh vector", input_faces(g)); end
P("p143 input_faces on ClassUnreadable", kinds(() -> input_faces(NoDecl())))
P("p143b input_faces bare pair assembly", kinds(() -> input_faces(NA((a = Gn(1.0),), (), "x" => "a/u", ()))))
P("p144 resolve ok", (resolve(cg, "a") === cg.children.a, resolve(cg, "b") isa BareI))
P("p145 resolve container element", resolve(Cont((Gn(1.0), Gn(2.0))), "units/2"))
P("p146 resolve transparent", resolve(ContT((left = Gn(1.0),)), "left"))
P("p147 resolve empty", kinds(() -> resolve(cg, "")))
P("p148 resolve unknown", kinds(() -> resolve(cg, "zz")))
P("p149 resolve deep", kinds(() -> resolve(cg, "a/y")))
P("p150 resolve deep2", kinds(() -> resolve(cg, "a/y/q")))
P("p151 resolve_terminal", (resolve_terminal(cg, "a/u"), resolve_terminal(cg, "a"), resolve_terminal(Cont((Gn(1.0),)), "units/1/u"), resolve_terminal(Cont((Gn(1.0),)), "units/1")))
P("p152 resolve_terminal empty/trailing", (kinds(() -> resolve_terminal(cg, "")), kinds(() -> resolve_terminal(cg, "a/")), kinds(() -> resolve_terminal(cg, "a/b/c"))))
P("p153 resolve_terminal name type", typeof(resolve_terminal(cg, "a/u")))
P("p160 input_passthrough default", input_passthrough(cg, "a"))
P("p161 bare", (input_passthrough(cg, "b"), output_passthrough(cg, "b")))
P("p162 prefix empty bare", (input_passthrough(cg, "b"; prefix = ""), output_passthrough(cg, "b"; prefix = "")))
P("p163 container element", (input_passthrough(Cont((Gn(1.0),)), "units/1"), output_passthrough(Cont((Gn(1.0),)), "units/1"), input_passthrough(Cont((Gn(1.0),)), "units/1"; sep = "_")))
P("p164 transparent element", input_passthrough(ContT((k = Gn(1.0),)), "k"))
P("p165 sep prefix", input_passthrough(cg, "a"; sep = "_", prefix = "P"))
P("p166 prefix verbatim", input_passthrough(cg, "a"; prefix = "u/x"))
P("p167 multiple", kinds(() -> input_passthrough(cg, "a"; only = ("u",), except = ("u",))))
P("p168 unknown only", kinds(() -> input_passthrough(cg, "a"; only = ("zz",))))
P("p168b unknown except", kinds(() -> output_passthrough(cg, "a"; except = ("zz",))))
P("p169 deep path", kinds(() -> input_passthrough(cg, "a/u")))
P("p170 select", (input_passthrough(cg, "a"; select = n -> n == "u"), output_passthrough(cg, "a"; select = n -> false)))
P("p171 only/except", (input_passthrough(cg, "a"; only = ("u",)), input_passthrough(cg, "a"; except = ("u",))))
P("p172 faceless no selector", input_passthrough(cg, "n"))
P("p173 selector on faceless w/ unknown except", kinds(() -> input_passthrough(cg, "n"; except = ("u",))))
P("p173b select on faceless", input_passthrough(cg, "n"; select = n -> true))
P("p174 selector keeps nothing: value", input_passthrough(cg, "a"; select = n -> false))
P("p175 only=() no selector", input_passthrough(cg, "a"; only = ()))
P("p176 select receives String", input_passthrough(cg, "a"; select = n -> (n isa String)))
w = R.build(Group((; a = Gn(1.0), s = Src()); local_wires = "s/y" => "a/u", input_wires = g -> input_passthrough(g, "a"; select = n -> false)))
P("p177 EmptyFaceSelection on build", [(nameof(typeof(d)), d.selector, d.names, d.who, d.path) for d in w.warnings])
w = R.build(Group((; a = Gn(1.0), s = Src()); local_wires = "s/y" => "a/u", input_wires = g -> input_passthrough(g, "a"; except = ("u",))))
P("p177b except all", [(nameof(typeof(d)), d.selector, d.names) for d in w.warnings])
w = R.build(Group((; s = Src()); input_wires = g -> input_passthrough(g, "s")))
P("p177c faceless silent", length(w.warnings))
P("p179 Group bare Pair wires", kinds(() -> R.build(Group((; a = Gn(1.0), s = Src()); local_wires = "s/y" => "a/u"))))
P("p180 sample_times function", kinds(() -> Group((; a = Gn(1.0)); sample_times = g -> (;))))
P("p181 Group(Tuple children)", kinds(() -> Group((Gn(1.0),))))
P("p182 Group copy", let g = Group((; a = Gn(1.0), s = Src()); local_wires = "s/y" => "a/u", input_wires = g -> ()), h = Group(g; children = (; a = Gn(2.0), s = Src())); (h.children.a.k, h.local_wires, h.input_wires === g.input_wires, h.sample_times) end)
P("p183 Group fields", fieldnames(typeof(Group((;)))))
P("p184 Group child naming", [e.path for e in R.build(Group((; a = Src(), s = Src()))).structure.components])
P("p185 Group local_wires fn returning Pair", local_wires(Group((; a = Gn(1.0)); local_wires = g -> "s/y" => "a/u")))
P("p186 fn called each read", let n = Ref(0); g = Group((; a = Gn(1.0)); input_wires = g -> (n[] += 1; ())); input_wires(g); input_wires(g); n[] end)
P("p187 field-name sugar", tm(R.build(Group((; a = Ctr()); sample_times = (children = Relative(2),)))))
P("p188 bare key", tm(R.build(Group((; a = Ctr()); sample_times = (a = Relative(2),)))))

import Redstone.Library: UnitDelay
inner = Group((; hold = UnitDelay(0.0)); input_wires = "u" => "hold/u")
outer = Group((; inner); input_wires = g -> input_passthrough(g, "inner"; prefix = ""))
P("p190 doctest", input_wires(outer))

println("== bundle law and frame")
P("p200 bundle_names y_direct cont", R.bundle_names(y_direct, Gn(1.0), CONTINUOUS, ()))
P("p201 bundle_names x_deriv cont", R.bundle_names(x_deriv, BareI(), CONTINUOUS, (:y,)))
P("p202 bundle_names s_update disc", R.bundle_names(s_update, Ctr(), DISCRETE, (:n,)))
P("p203 bundle_names y_state disc", R.bundle_names(y_state, Ctr(), DISCRETE, ()))
P("p204 event_bundle_names", R.event_bundle_names(BareI()))
for (fam, tier, f) in ((:y_state, CONTINUOUS, :u), (:y_state, CONTINUOUS, :s), (:y_state, CONTINUOUS, :ws), (:y_state, CONTINUOUS, :foo), (:y_state, DISCRETE, :x), (:y_state, DISCRETE, :m), (:s_update, DISCRETE, :m), (:guard, CONTINUOUS, :Δt))
    P("p205 classify $fam $tier $f", R.classify_bundle_field(fam, tier, f))
end
struct Rd <: AbstractComponent end
x_init(::Rd) = (a = 0.0,); y_types(::Rd) = (y = Float64,); y_state(::Rd, (; x, u)) = (y = x.a,); x_deriv(::Rd, (; x)) = (a = 1.0,)
struct Rd2 <: AbstractComponent end
x_init(::Rd2) = (a = 0.0,); y_types(::Rd2) = (y = Float64,); y_state(::Rd2, (; x, ws)) = (y = x.a,); x_deriv(::Rd2, (; x)) = (a = 1.0,)
struct Rd3 <: AbstractComponent end
x_init(::Rd3) = (a = 0.0,); y_types(::Rd3) = (y = Float64,); y_state(::Rd3, (; x, s)) = (y = x.a,); x_deriv(::Rd3, (; x)) = (a = 1.0,)
struct Bm <: AbstractComponent end
x_init(::Bm) = (a = 0.0,); y_types(::Bm) = (y = Float64,); y_state(::Bm, (; x)) = error("boom"); x_deriv(::Bm, (; x)) = (a = 1.0,)
struct Bi <: AbstractComponent end
x_init(::Bi) = error("init boom"); y_types(::Bi) = (y = Float64,); y_direct(::Bi, ::Any) = (y = 1.0,)
for T in (Rd, Rd2, Rd3, Bm, Bi)
    try R.build(T()); P("p206 $T", :ok)
    catch e; ds = e.carried isa Vector ? e.carried : [e.carried]; P("p206 $T", [(nameof(typeof(d)), hasproperty(d, :reason) ? d.reason : nothing, hasproperty(d, :path) ? d.path : nothing, hasproperty(d, :fn) ? d.fn : nothing) for d in ds]); end
end
try R.build(Group((; b = Bi()))); catch e; d = e.carried isa Vector ? e.carried[1] : e.carried; P("p207 UserCodeFraming path in group", (nameof(typeof(d)), d.path, d.fn)); end
P("p208 foreign_declarations ok", R.foreign_declarations(Gn(1.0)))
P("p209 foreign_declarations Bad", R.foreign_declarations(Bad.B()))
P("p210 has_stage", (R.has_stage(y_direct, Gn(1.0)), R.has_stage(y_state, Gn(1.0)), R.has_stage(x_projection, Gn(1.0))))
P("p211 _declares", (R._declares(x_init, Gn(1.0)), R._declares(x_init, NoDecl()), R._declares(ws_init, Gn(1.0), Type{Float64})))
P("p212 contract_at methods", [m.sig for m in methods(R.contract_at)])
P("p213 DECLARATION_FAMILY", R.DECLARATION_FAMILY)
P("p214 probe_value", (R.probe_value(Float64), R.probe_value(Bool), R.probe_value(SVector{2,Float64}), R.probe_value(Int8)))

println("== ws_init scalar for a discrete component")
const WS = Any[]
struct DW <: AbstractComponent end
s_init(::DW) = (n = 0,); u_types(::DW) = (u = Float64,); y_types(::DW) = (y = Float64,)
ws_init(::DW, ::Type{T}) where {T} = (push!(WS, T); (;))
y_direct(::DW, (; u)) = (y = u.u,)
s_update(::DW, (; s)) = (n = s.n + 1,)
struct CW <: AbstractComponent end
x_init(::CW) = nothing; u_types(::CW) = (u = Float64,); y_types(::CW) = (y = Float64,)
y_direct(::CW, (; u)) = (y = u.u + 1.0,)
P("p220 cycle disc+cont", kinds(() -> R.build(Group((; d = DW(), c = CW()); local_wires = ("d/y" => "c/u", "c/y" => "d/u")))))
P("p221 ws_init scalars seen", unique(WS))
empty!(WS)
P("p222 build with activations", kinds(() -> R.build(Group((; d = DW()); input_wires = "x" => "d/u"); activations = (Float64, R.ProbeDual))))
P("p223 ws_init scalars", unique(WS))

struct ContR{C} <: AbstractComponent; units::C; end
local_wires(::ContR) = ()
sample_times(::ContR) = (units = Relative(2),)
P("p230 sugar keys all elements of container field", tm(R.build(ContR((Ctr(), Ctr())))))
struct StShape <: AbstractComponent; v; kid::Ctr; end
local_wires(::StShape) = ()
sample_times(c::StShape) = c.v
P("p231 sample_times Tuple", kinds(() -> R.build(StShape(((:kid, Relative(2)),), Ctr()))))
P("p232 sample_times NamedTuple with float", kinds(() -> R.build(StShape((kid = 2.0,), Ctr()))))
P("p233 sample_times nothing", kinds(() -> R.build(StShape(nothing, Ctr()))))
P("p234 bare container key in transparent: one entry all elements", tm(R.build(Group((; a = Ctr(), b = Ctr()); sample_times = (children = Relative(2),)))))

println("== late probes")
P("p240 transparent container with mixed element", kinds(() -> R.build(ContT((Src(), 3)))))
P("p241 transparent container naming a non-container field", kinds(() -> R.build(ContBad((a = Src(),)))))
struct Pair2{C} <: AbstractComponent; pair::C; end
local_wires(::Pair2) = ()
transparent_container(::Pair2) = :pair
sample_times(::Pair2) = (a = Relative(2, 0), b = Relative(2, 1))
P("p242 stagger", [(e.path, e.timing) for e in R.build(Pair2((a = Ctr(), b = Ctr()))).structure.components])
