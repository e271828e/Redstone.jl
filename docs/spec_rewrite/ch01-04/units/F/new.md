#### What a port may hold

**Stage returns are NamedTuples of port values, period** ([D-036][d-036]). **A custom struct is
a first-class port value** ([D-036][d-036]). It is one field of the returned tuple, one
declared port, one cell (`pose = KinPose{T}`, where `KinPose` is an illustrative
struct). Nested fields get no cells of their own. A reader reaches a nested
field through the port's [leaf address](#g-leaf-address), as in `"pose.q_eb"` ([§14.4][s14-4], [D-276][d-276]). A wired
consumer takes the bundle (the struct-valued port) whole. Bare-struct returns
are rejected ([D-036][d-036]).

A port value's leaves are what the [leaf walk](#g-leaf-walk) (the framework's
derivation of per-activation types) reaches through `Real`s, static arrays and
isbits structs ([D-237][d-237]). An enum is one leaf, pinned ([§8.2][s8-2],
[D-316][d-316]). `StopFlag` is the one enum with a framework meaning. An
output port of that type is a [stop request](#g-stop-request) (a port that ends the run when it
reads `STOP_REQUESTED`), and a `StopFlag` nested in a port of another type or
declared as a root input is refused (`IllegalPortType`, [§13.5][s13-5],
[D-316][d-316]).

**The walk stops at an immutable type that is not isbits and treats it as one
opaque leaf** ([D-237][d-237]). The table stores an opaque leaf whole,
references included. A [field handle](#g-field-handle) (an immutable query
object a consumer evaluates at arguments of its own choosing, [§4.4][s4-4]) is
such a leaf. **A `Symbol` is an opaque leaf too** ([D-243][d-243]). Julia
classifies it mutable, but it is interned, immutable and never freed, the
grounds on which [§7.3][s7-3] admits it in a store. So a `Symbol` mode
publishes like any other. **A mutable type anywhere in a port value is
refused, and so is an opaque leaf surfacing as a root input**, which has no
synthesis (`IllegalPortType`, [D-237][d-237]).

#### Granularity, read side

**Wiring is port-granular** ([D-276][d-276]). There are no sub-field
connections. A consumer that wants less than a bundle takes the bundle and
destructures it, or asks the producer for a loose port ([D-276][d-276]). It
destructures the bundle in its own stage or through an unbundling component.
An unbundling component is a `y_direct` leaf that takes the bundle and
publishes its fields. It is a candidate for the standard library of [§13.7][s13-7].

A field-projection connector is a [guarded addition](#g-guarded-addition) (a capability the design
admits but does not build), and its shape is obvious ([D-036][d-036]).

Under the granularity guideline, **authors should bundle what shares a stage
*and* is consumed together** ([D-036][d-036]). The first criterion is trivially
enforced, because each port has exactly one producing function. Bundling
across dependency footprints is the classic mistake. A kinematics bundle
mixing pose, which is stage 1 ([§5.2][s5-2]), with velocity-derived
quantities, which are stage 2, must split.

Fan-out is free, so publishing both a bundle and a hot loose field (`pose`
*and* `q_eb`) is legitimate. It costs one extra isbits cell.

The sketch below shows the bundle, the loose hot field and a face aliasing an
interior port, in declaration form. `Kinematics` and `Vehicle` are illustrative
names. An `output_wires` entry sources a face from an immediate child's face
([§6.1][s6-1]). `RQuat` is FlightPhysics' rotation quaternion. `RQuat{Float64}` is the
spec's form of it, since FlightPhysics' `RQuat` takes no type parameter.

```julia
#a continuous leaf: one bundle port and the hot field published loose — two cells
y_types(::Kinematics) = (pose = KinPose{Float64}, q_eb = RQuat{Float64})

#the enclosing assembly: each face aliases an interior port, creating no endpoint
output_wires(::Vehicle) = ("kin/pose" => "pose", "kin/q_eb" => "q_eb")
```

#### Granularity, write side

Under the write-side rule, **data written by different external writers, or
at different cadences, must not share a port** ([D-045][d-045]). In short,
bundle what is written together.

Pilot commands are the case in point. They are scalar faces under a namespace
prefix. The convenient bundle is assembled *downstream*, inside the graph, by
an ordinary component. Assembling it there is legal by the read-side
guideline, since the bundle has a single producer and is consumed together.

The granularity guideline and the write-side rule compose into one principle.
The finest-grained party owning either end sets a port's granularity. That
party is a producer on the read side and an external writer on the write side.
Field-addressed staging (a lens into struct slots) stays a recorded guarded
addition, unbuilt.
