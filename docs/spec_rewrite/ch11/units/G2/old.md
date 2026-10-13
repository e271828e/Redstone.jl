#### The binding: framework-legible by enumeration, opaque in its mappings

A binding is a value subtyping `AbstractBinding`, the second mandatory root.
Its type declares which sides it has and enumerates what each side touches.
The legible half is explicit methods returning data, called once at attach
on the [calling task](#g-calling-task) (the task that invoked `run!`). The
opaque half is called per datum on the [device](#g-device) task by the
author's own loop:

```julia
struct T16000MBinding <: AbstractBinding    # the roots are mandatory: attach! dispatches
    table::NamedTuple                       # on ::AbstractDevice, ::AbstractBinding
end

is_input(::T16000MBinding)  = true     # sides are *declared*, never inferred; the root
is_output(::T16000MBinding) = false    # carries the false defaults, so silence = absent
is_greedy(::T16000MBinding) = false    # the claim source within the input side (§11.3)

claims(b::T16000MBinding)   = ...      # input side:  the enumerated face set → the claim
map_input(datum, b)                    #              datum → face ⇒ value pairs — user code
reads(b)                               # output side: labeled §14.4 selectors → one compiled gather
map_output(nt, b)                      #              the gather's NamedTuple → wire datum
```

The root carries `is_greedy(::AbstractBinding) = false` beside the two side
defaults, so silence is not greediness. The computed claim source is
declared or absent.

The framework needs no [contract](#g-contract) on the datum's shape. The
datum travels only between `loop` and `map_input`, written by the same
author, and the framework's structural knowledge comes entirely from the
declared traits and the enumeration methods. Everything enumerable validates
at attach. Everything opaque is bounded at its runtime enforcement point.
`map_input` is bounded by the staging checks ([§11.4][s11-4]). `map_output`
receives exactly the compiled gather's NamedTuple, and what it puts on the
wire is the peer's business. `map_input`/`map_output` are, precisely,
**conventions of the author-owned loop idiom**. The framework never calls
them, so they are taught ([Appendix A][sA]) and never checked. A binding
whose loop calls something else by another name is simply a binding with a
different private helper.

**Rule.** `reads(b)` returns a labeled NamedTuple of [selectors](#g-selector)
(the closed family of deferred reads, [§14.4][s14-4]), for example
`(; alt = get_output(…), pose = get_face(…))`. The labels are the binding's
own naming, carried through compilation in declaration order, so the
NamedTuple `map_output` receives is keyed by exactly the names `reads`
declared. One returned value thereby fixes names, order and reads together,
under the same attach-time validation as `claims` ([D-199][d-199]).

**Sides are declared, and the obligations they create are enforced both
ways.** `claims` and `reads` have **error-throwing fallbacks on the root**,
so a declared side whose method was never written fails loudly at the attach
point rather than degrading into silence. The attach runs a
**bidirectional conformance check** over the pair (trait, method):

- `is_input && !is_greedy` ⇒ `claims(b)` is called once and its
  [faces](#g-face) staked. The fallback firing here means "you declared an
  input side and wrote no enumeration".
- `is_input && is_greedy` ⇒ the [claim](#g-claim) is computed
  ([§11.3][s11-3]), and a `claims` method defined for this binding is an
  error. The two sources are alternatives, not layers.
- `is_output` ⇒ `reads(b)` is called and the gather compiled.
- Neither side declared ⇒ attach-time error naming both traits. A binding
  that touches nothing is a configuration mistake, not a degenerate.
- `is_greedy` without `is_input` ⇒ error. Greediness is a *source* within a
  side, and a source without its side is meaningless.
- A **specific** method of `claims` or `reads` defined for the binding type
  while its trait reads false ⇒ error, the converse direction of the same
  fact. A method written and never reached is exactly the drift the check
  exists to catch. Detecting it is one `which` against the fallback method.
  That is the reflection class ([§8.1][s8-1]), where the shadowing check is
  an `isdefined`/`!==` pair. The `which` detection runs once at a stopped-sim
  service point, not inside any frame.

Every violation in that list reports `BindingContractMismatch`
([Appendix C][sC]). The report names the binding type, the trait, the method
at fault and the direction (declared-but-missing, or defined-but-undeclared).

**This is what closes the shadowing hole.** Under the rejected alternative,
detection by method presence ([D-177][d-177]), a bidirectional binding whose
`claims` was written without extending the framework's generic presented as
output-only and degraded *silently*. That omission is the
`using`-without-`import` trap ([§8.1][s8-1]), one level down. With the side
declared, the absent method has something to contradict.

Greediness stays orthogonal to `reads`. A greedy front end may also drive a
compiled output gather. That combination is legal and currently
uninstantiated. Its plausible customer is a narrow-wire interactive surface,
a motorized control board whose detents must be driven back out. The binding
stays an `attach!` argument, never a device field. The same `T16000M` binds
differently per aircraft, and narrowing the binding narrows the claim
([§11.3][s11-3]).

**Why the [periphery](#g-periphery) gets roots where
[components](#g-component) have one.** [§8.5][s8-5] refuses a class supertype
for two reasons, and neither reaches here. First, a component's
single-inheritance slot is *already spoken for* by the domain hierarchies
(`AbstractAircraft`, engine families), while a device's and a binding's are
vacant. Nothing else wants them. Second, a component's class is
implementation detail behind its contract ([§8.5][s8-5]), while a binding's
**sidedness is its public contract**, the one thing every consumer of it
must know.

Rejected, correspondingly ([D-177][d-177]): an abstract binding-type
*taxonomy* encoding the sides, optional roots left unenforced, and a declared
`sides(b)` trait returning the side set. The last of the three is **answered
rather than repeated** by the design above, since redundancy *with a
cross-check* is drift detection. That is what the bidirectional check turns
the traits into. The same fact is stated twice, in two forms, with the
framework paid to compare them.

**`is_greedy` is a claim source, not a device class.** What the declaration
buys is one computation at the attach point. After it the binding holds an
ordinary claim set, and every mechanism downstream is blind to where the set
came from: exclusivity and storage ([§11.3][s11-3]); shape, shim, merge,
scatter and [drain](#g-drain) ([§11.4][s11-4]); [trace](#g-trace)
([§11.5][s11-5]); detach's release. There is no derived surface shared among
the writers that elected it, and no device class hanging off the marker. The
standing rejection is untouched. Opportunistic writing to unclaimed faces
"for any device" stays dead ([D-044][d-044]). Autonomous devices still
enumerate, and a maximal surface is what exactly one line of a binding asks
for, in the open, checked like any other claim.

**A second greedy attach stakes the empty remainder.** The complement is
computed against the [roster](#g-roster) as it stands. A greedy binding
attached after another has already swallowed everything therefore gets the
empty claim. That claim is legal, being the honest may-write-nothing
degenerate below, and it is useless, which is worth saying out loud. The
attach succeeds and records `EmptyGreedyClaim` ([Appendix C][sC], a warning
naming the device and its binding) in the roster entry's diagnostic cell.
`attach!` mutates the roster, so the warning lives in that state's status and
surfaces through the status record ([§11.8][s11-8], [D-250][d-250]). The log line
at return is presentation. That is the one honest reading of "you asked for
what is left and nothing was left".

**Several interactive front ends may be rostered at once.** A web console
can claim the autopilot faces beside a local GUI claiming the stick faces.
With explicit claims they are simply two enumerated devices, partitioning
the surface rather than sharing it.

**The shipped GUI binding is a greedy one.** It declares `is_input` and
`is_greedy`, stakes the computed claim (everything unclaimed at the moment
it attaches), and defines no `claims` of its own. It declares no `reads`
either, because its read path is the handle's primitive read. Paced by its
own clock, it reads `latest` afresh at each tick ([§12.3][s12-3]), with an
ad-hoc read set over the whole [snapshot](#g-snapshot). That is the
shape of an inspection read ([§11.2][s11-2]). The compiled output gather
therefore has nothing to do for it. The same GUI device type is equally
attachable under a binding that returns explicit claims. Greediness is the
binding's declaration, not the device's nature. Every other interactive
front end anyone might want (a web console, a remote panel) has both
spellings available. It can attach with the greedy binding where the GUI
would have been, or with explicit claims beside other front ends.

**The empty enumeration is not a back door.** `is_input(b) = true` with
`claims(b) = ()` stays an honest degenerate, a device that may write nothing.
Its writes are still binding-bounded, so drift onto any face is
`OutOfClaimEntry`. There is no privileged class for it to promote into
either. `claims` bodies are ordinary code (the idiom, [§8.5][s8-5];
comprehensions included), and an enumeration that came back empty by
accident stays inert, exactly as written. The maximal surface is reachable
only through the explicit `is_greedy(b) = true` declaration. The most
privileged claim is the hardest to acquire by accident, and a declared trait
is deliberate authorship. For the same reason, `claims` never returns
`nothing` or a sentinel to mean "compute it for me". The enumeration
contract has one meaning and the trait carries the other. A dual-meaning
return would be exactly the ambiguity the declaration vocabulary is built to
refuse.

#### One shipped binding type; conditioning has an owner

`TableBinding` is *data-driven*. The framework writes its `map_input` once,
and a table value (axis/button entry → [face](#g-face), deadzone/expo
parameters) is constructed per [device](#g-device) × aircraft pairing, where
configurations are made:

```julia
TableBinding(stick_y  = (face = "elevator", deadzone = 0.05, expo = 0.6),
             throttle = (face = "throttle",),
             trigger  = (face = "brake_count",))       # levels doctrine: a counter
```

Its generic `map_input` *is* the shared pure conditioning helper
([§11.4][s11-4]), and its owner. The entry tuple rides in the type, so the
mapping specializes per table with no dynamic dispatch. A *code-driven*
binding looks identical to the framework. A JSON telecommand peer whose
`claims` returns the vocabulary and whose `map_input` parses bytes is one.
One purity note is taught in [Appendix A][sA]. Cross-datum state, such as
press counters and edge detection, lives in the device struct, maintained by
the loop, and arrives *inside* the datum. `map_input` stays pure.

