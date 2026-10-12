#### What a port may hold

**Stage returns are named tuples of port values, period.** A custom struct is a
first-class port *value*. It is one field of the returned tuple, one declared
port, one cell (`pose = KinPose{T}`). Nested fields get no cells of their own.
A reader reaches one through the port's [leaf address](#g-leaf-address) (the
field name with dotted and bracketed steps below it), `"pose.q_eb"`
([§14.4][s14-4], [D-276][d-276]), and a wired consumer takes the bundle whole. Bare-struct
returns are rejected ([D-036][d-036]).

A port value's leaves are what the leaf walk reaches through `Real`s, static
arrays and isbits structs. An enum is one leaf, pinned ([§8.2][s8-2]).
`StopFlag` is the one enum with a framework meaning. An output port of that
type is a [stop request](#g-stop-request) (a port that ends the run when it
reads `STOP_REQUESTED`), and a `StopFlag` nested in a port of another type or
declared as a root input is refused (`IllegalPortType`, [§13.5][s13-5], [D-316][d-316]). The walk
stops at an immutable type that is not isbits and treats it as one opaque leaf
(a leaf the table stores whole, references included). That leaf is the
[field handle](#g-field-handle) ([§4.4][s4-4]). A `Symbol` is an opaque leaf too. Julia classifies
it mutable, but it is interned, immutable and never freed, the same grounds
[§7.3][s7-3] admits it in a store on, so a `Symbol` mode publishes like any other
([D-243][d-243]). A mutable type anywhere in a port value is refused, and so is an
opaque leaf surfacing as a root input, which has no synthesis
(`IllegalPortType`, [D-237][d-237]).

#### Granularity, read side

**Rule.** Wiring is port-granular. There are no sub-field connections. A
consumer that wants less than a bundle takes the bundle and destructures it,
in its own stage or through an unbundling component (a `y_direct` leaf that
takes the bundle and publishes its fields, a candidate for the standard
library of [§13.7][s13-7]), or asks the producer for a loose port ([D-276][d-276]). A
field-projection connector is a [guarded
addition](#g-guarded-addition) (a capability the design admits but does not
build). Its shape is obvious, and it is not built.

**Granularity guideline.** Authors should bundle what *shares a stage* *and is
consumed together*. The first criterion is trivially enforced, because each port
has exactly one producing function. Bundling across dependency footprints is the
classic mistake. A kinematics bundle mixing pose, which is stage 1, with
velocity-derived quantities, which are stage 2, must split. Fan-out is free, so publishing both a bundle
and a hot loose field (`pose` *and* `q_eb`) is legitimate. It costs one extra
isbits cell.

**Example.** The sketch below shows the bundle, the loose hot field and a face
aliasing an interior port, in declaration form.

```julia
#a continuous leaf: one bundle port and the hot field published loose — two cells
y_types(::Kinematics) = (pose = KinPose{Float64}, q_eb = RQuat{Float64})

#the enclosing assembly: each face aliases an interior port, creating no endpoint
output_wires(::Vehicle) = ("kin/pose" => "pose", "kin/q_eb" => "q_eb")
```

#### Granularity, write side

**Write-side rule.** **Bundle what is written together.**

**Rule.** Data written by different external writers, or at different cadences,
must not share a port.

Pilot commands are the case in point. They are scalar faces under a namespace
prefix. The convenient bundle is assembled *downstream*, inside the graph, by an
ordinary component. That is legal by the read-side guideline, since the bundle
has a single producer and is consumed together.

The guideline and the rule compose into one principle. A port's granularity is
set by the finest-grained party owning either end, producers on the read side
and external writers on the write side. Field-addressed staging (a lens into
struct slots) stays a recorded guarded addition, unbuilt.

