# K11b_v probe: inbound periphery walkthrough claims, run against W at f14dbc1d.
include(joinpath(pwd(), "test", "RedstoneTests.jl"))
using .RedstoneTests
const RT = RedstoneTests
using Redstone
const R = Redstone

P(label, x) = println(rpad(label, 34), " => ", x)
function caught(f)
    try
        f(); "no throw"
    catch e
        string(typeof(e))
    end
end

# four root faces as in the walkthrough: throttle, elevator, flaps, brake
aircraft() = R.Group((; s1 = RT.Sum(sa = 1.0, sb = 1.0), s2 = RT.Sum(sa = 1.0, sb = 1.0));
                     input_wires = ("throttle" => "s1/a", "elevator" => "s1/b",
                                    "flaps" => "s2/a", "brake" => "s2/b"))
newsim() = R.Simulation(aircraft(); Δt_frame = 1//10)
cond() = RT.set(u = (throttle = 0.62, elevator = -0.03, flaps = 0.0, brake = 0.0))

# K11b-023: RosterEntry fields
P("K023 RosterEntry fields", fieldnames(R.RosterEntry))
P("K023 fieldtypes", fieldtypes(R.RosterEntry))
# K11b-056: StagingCell
P("K056 StagingCell pending type", fieldtype(R.StagingCell{Int}, :pending))
P("K056 Batch ismutable", ismutabletype(R.Batch))
# K11b-113: OutOfClaimEntry payload
P("K113 OutOfClaimEntry fields", fieldnames(R.OutOfClaimEntry))
P("K113 ClaimedFaceEntry fields", fieldnames(R.ClaimedFaceEntry))
# K11b-087: header vs schemas
P("K087 Trace fields", fieldnames(R.Trace))
P("K087 Checkpoint fields", fieldnames(R.Checkpoint))

# K11b-033: a bare NamedTuple as a binding
sim = newsim()
nt = (stick_y = (face = "elevator", expo = 0.6), throttle = (face = "throttle",))
P("K033 NamedTuple <: AbstractBinding", nt isa R.AbstractBinding)
P("K033 attach! with NamedTuple", caught(() -> R.attach!(sim, RT.Pad("joy"), nt)))
jb = R.TableBinding(stick_y = (face = "elevator", expo = 0.6), throttle = (face = "throttle",))
P("K033 claims(TableBinding)", R.claims(jb))

# K11b-063/064: map_input result and schema positions
mi = R.map_input((throttle = 0.70, stick_y = -0.05), jb)
P("K063 map_input type", typeof(mi))
P("K063 map_input value", mi)
joy = RT.Pad("joy")
hj = R.attach!(sim, joy, jb)
P("K064 joystick schema", hj.writer.faces)
R.stage!(hj, mi...)
pend = (@atomic hj.writer.cell.pending)[]
P("K064 staged values/mask", (pend.staged, pend.mask))
P("K023a entry id / who", (sim.plane.roster[1].id, R._who(sim.plane.roster[1])))

# K11b-027: order of identity vs face-name validation
sim2 = newsim()
d1 = RT.Pad("d1")
R.attach!(sim2, d1, RT.Enumerated("throttle"))
P("K027 same dev, unknown face", caught(() -> R.attach!(sim2, d1, RT.Enumerated("nosuch"))))
P("K027 new dev, unknown face", caught(() -> R.attach!(sim2, RT.Pad("d2"), RT.Enumerated("nosuch"))))
P("K025 same dev, overlapping", caught(() -> R.attach!(sim2, d1, RT.Enumerated("throttle"))))

# K11b-132: harness batch staged while stopped, renormalized at attach
sim3 = newsim()
R.stage!(sim3, "flaps" => 0.5, "brake" => 0.25)
P("K132 harness faces before", sim3.plane.harness.faces)
R.attach!(sim3, RT.Pad("udp"), RT.Enumerated("brake"))
P("K132 harness faces after", sim3.plane.harness.faces)
hp = (@atomic sim3.plane.harness.cell.pending)[]
P("K132 harness pending after", (hp.staged, hp.mask))
P("K132 harness diag", [(typeof(d), d.face, hasproperty(d, :site) ? d.site : nothing)
                        for d in (@atomic sim3.plane.harness_diag.batch).ring])
# K11b-112: harness write to an unknown face
R.stage!(sim3, "nosuch" => 1.0)
P("K112 harness unknown face kind", typeof(last((@atomic sim3.plane.harness_diag.batch).ring)))

# K11b-155/137/138/089/144: the worked frame
sim4 = newsim()
hjoy = R.attach!(sim4, RT.Pad("joy"), jb)
hgui = R.attach!(sim4, RT.Pad("gui"), RT.Greedy())
P("K155 GUI computed claim", hgui.writer.faces)
P("K108 harness surface", sim4.plane.harness.faces)
R.init!(sim4, cond())
P("K138 thunk before step", sim4.plane.roster[1].drain)
R.stage!(hjoy, R.map_input((throttle = 0.70, stick_y = -0.05), jb)...)
R.stage!(hgui, "flaps" => 1.0)
R.step!(sim4; frames = 1)
P("K144 root inputs after drain", [R.port(sim4, "", f) for f in (:throttle, :elevator, :flaps, :brake)])
tr = R.trace(sim4)
P("K089 trace schemas", tr.schemas)
P("K089 trace batches", [(b.frame, b.writer, b.entries) for b in tr.batches])
P("K137 run!/port_views", (isdefined(R, :port_views), [m.module for m in methods(R.port_views)]))
