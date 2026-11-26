const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/frozen_init/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(W, "imports.jl")); include(joinpath(W, "fixtures.jl")); include(joinpath(W, "utils.jl"))
import Redstone: set, at, combine, _scratch
say(t, x) = println(rpad(t, 50), " => ", x)

# --- 1. scratch count: instrument `_scratch` -------------------------------------
const SCRATCH_CALLS = Ref(0)
@eval Redstone _scratch(model::Model, ::Type{T}) where {T} =
    ($(SCRATCH_CALLS)[] += 1; Model(model.deployment, T; chunk_size = model.exec.chunk_size))
cont = Model(fed(BareAccumulator()), D8; Δt_frame = 1//10)
SCRATCH_CALLS[] = 0; init!(cont, set(u = (in = 2.0,)))
say("continuous-only D8: scratches built", SCRATCH_CALLS[])
say("continuous-only D8: status", cont.status)
f64 = Model(Group((; zoh = ZOH(), lag = BareAccumulator()); local_wires = ("zoh/out" => "lag/u",),
                  input_wires = ("r" => "zoh/in",)); Δt_frame = 1//10)
SCRATCH_CALLS[] = 0; init!(f64, set(u = (r = 2.0,)))
say("pair Float64: scratches built", SCRATCH_CALLS[])
pair = Model(Group((; zoh = ZOH(), lag = BareAccumulator()); local_wires = ("zoh/out" => "lag/u",),
                   input_wires = ("r" => "zoh/in",)), D8; Δt_frame = 1//10)
SCRATCH_CALLS[] = 0; init!(pair, set(u = (r = 2.0,)))
say("pair D8: scratches built", SCRATCH_CALLS[])
say("pair D8: zoh.out", port(pair, "zoh", :out))

# --- 2. Dual-carrying condition --------------------------------------------------
P = ForwardDiff.Partials(ntuple(i -> Float64(i), 8))
chain = Group((; lag = BareAccumulator(), hold = ZOH(), neg = Negator(), echo = ZOH());
              local_wires = ("lag/y" => "hold/in", "neg/y" => "echo/in"),
              input_wires = ("r" => "lag/u", "e" => "neg/u"))
m = Model(chain, D8; Δt_frame = 1//10)
init!(m, combine(at("lag", set(x = D8(3.0, P))), set(u = (r = D8(2.0, P), e = D8(5.0, P)))))
say("dual cond: hold.out (lag.x value)", repr(port(m, "hold", :out)))
say("dual cond: echo.out (-5.0 expected)", repr(port(m, "echo", :out)))
say("dual cond: lag.x partials kept", ForwardDiff.partials(state(m, "lag")))

# convert mutant: what would a plain copy into Float64 do?
say("convert(Float64, Dual nonzero partials)", try convert(Float64, D8(2.0, P)) catch e; typeof(e) end)
say("convert(Float64, Dual zero partials)", try convert(Float64, D8(2.0)) catch e; typeof(e) end)

# --- 3. StepError from the nominal round ----------------------------------------
struct Fuse <: AbstractComponent end
x_init(::Fuse) = nothing
u_types(::Fuse) = (u = Float64,)
y_types(::Fuse) = (y = Float64,)
y_direct(::Fuse, (; u)) = u.u > 1 ? throw(Exploded()) : (y = u.u,)
fused() = Group((; zoh = ZOH(), fuse = Fuse()); local_wires = ("zoh/out" => "fuse/u",),
                input_wires = ("r" => "zoh/in",))
for T in (Float64, D8)
    mm = Model(fused(), T; Δt_frame = 1//10)
    err = failure(() -> init!(mm, set(u = (r = 2.0,)); t0 = 1//4))
    say("[$T] StepError?", err isa StepError)
    err isa StepError && say("[$T] host, boundary, t, cursor", (err.host, err.boundary, err.t, err.cursor))
    say("[$T] status", mm.status)
end

# --- 4. nested Dual ---------------------------------------------------------------
DD = ForwardDiff.Dual{:outer,ForwardDiff.Dual{:inner,Float64,1},1}
nm = Model(Group((; zoh = ZOH(), lag = BareAccumulator()); local_wires = ("zoh/out" => "lag/u",),
                 input_wires = ("r" => "zoh/in",)), DD; Δt_frame = 1//10)
init!(nm, set(u = (r = 2.0,)))
say("nested Dual: zoh.out", repr(port(nm, "zoh", :out)))

# --- 5. a composite root input (SVector) feeding a discrete consumer --------------
struct VecHold <: AbstractComponent end
x_init(::VecHold) = nothing
u_types(::VecHold) = (v = SVector{2,Float64},)
y_types(::VecHold) = (n = Float64,)
y_direct(::VecHold, (; u)) = (n = u.v[1] + 10u.v[2],)
vm = Model(Group((; h = VecHold(), z = ZOH()); local_wires = ("h/n" => "z/in",), input_wires = ("v" => "h/v",)), D8; Δt_frame = 1//10)
init!(vm, set(u = (v = SVector(D8(1.0, P), D8(2.0, P)),)))
say("SVector root: z.out (21 expected)", repr(port(vm, "z", :out)))

# --- 6. clock and s, m copies -------------------------------------------------------
struct Stamp <: AbstractComponent end
s_init(::Stamp) = nothing
y_types(::Stamp) = (stamp = Float64,)
y_state(::Stamp, (; t)) = (stamp = t,)
sm = Model(Group((; st = Stamp())), D8; Δt_frame = 1//10)
init!(sm; t0 = 1//4)
say("clock: stamp (0.25 expected)", repr(port(sm, "st", :stamp)))
lp = Model(sampled_loop(), D8; Δt_frame = 1//50)
init!(lp, combine(at("ctl", set(s = (acc = 2.0,))), set(u = (ref = 0.0,))))
say("s: ctl.u (2.0 expected)", repr(port(lp, "ctl", :u)))
gm = Model(Group((; gm = GearMode(), hold = ZOH()); local_wires = ("gm/y" => "hold/in",)), D8; Δt_frame = 1//10)
init!(gm, at("gm", set(m = (gear = down,))))
say("m: hold.out (1.0 expected)", repr(port(gm, "hold", :out)))
