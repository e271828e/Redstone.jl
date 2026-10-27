# The declaration layer (§8.1, §8.2): a plain-Julia trait layer. Declarations
# are ordinary functions of the *instance*, written at concrete `Float64`; the
# framework's activation walk (§7.2) retypes them. No macros, no stage tags.
#
# Both tiers live here, and so does the event declaration surface (§2.3, §8.2).

# --- the one root type (§8.5) -------------------------------------------------
# There is no `AbstractAssembly`: primitives and assemblies share one root, so a
# field declared `E <: AbstractEngine` accepts either, and class is read off
# declaration shape (`src/assembly.jl`).

# Design: §8.1, §8.5, D-039, D-117, D-246.
"""
    AbstractComponent

The abstract type every [component](@ref g-component) subtypes, primitive and
[assembly](@ref g-assembly) alike.

A component is a plain struct, `MyComp <: AbstractComponent`, whose fields are
inert parameters or child components. Its [class](@ref g-class) is read off
which declarations its type defines. Defining [`local_wires`](@ref) makes it an
assembly, whose component-typed fields are its children. Defining any primitive
declaration, such as [`x_init`](@ref), [`u_types`](@ref) or the stage
[`y_direct`](@ref), makes it a primitive. There is no separate assembly type, so
a field typed by a domain supertype accepts a primitive and an assembly alike.

A component's module extends the declarations it defines, importing each one by
name, as in `import Redstone: x_init, y_types, y_direct`, and defines them at
module top level.

The build refuses a type that defines neither family as `ClassUnreadable`, and
one that defines both as `ClassMixed`. A module that binds a declaration name
to a function of its own, the sign of a missing import, is refused as
`DeclarationShadowed`.
"""
abstract type AbstractComponent end

# --- what an author declares --------------------------------------------------

# Design: §7.1, §8.2, §8.5, D-263.
# The store is the tier marker, as `local_wires` is the class marker. The
# fallback serves the value readers; the classifier asks whether the method is
# declared.
"""
    x_init(c) -> NamedTuple

Return the [component](@ref g-component)'s initial continuous state, as a
`NamedTuple` of named values.

A continuous primitive declares its state by value, written with `Float64`
values, as in `x_init(::Engine) = (ω = 0.0,)`. The state's type is derived from
the value, and its real values follow the scalar of each
[activation](@ref g-activation). Each field is one `Float64` or one static array
of `Float64`. Integers, `Bool`s and enums belong in [`m_init`](@ref).

Every primitive defines exactly one of `x_init` and [`s_init`](@ref), and the
one it defines makes it continuous or discrete. A stateless continuous primitive
declares `x_init(::C) = (;)`. A non-empty state needs an [`x_deriv`](@ref)
method.

The build refuses a value that is not a `NamedTuple` as `StoreNotNamedTuple`,
and a field outside the state vocabulary as `IllegalStateLeaf`. A non-empty
state with no `x_deriv` is refused as `StoreWithoutUpdate`, a primitive that
defines neither `x_init` nor `s_init` as `TierUnreadable`, and one that defines
both as `DeclarationOnWrongTier`.
"""
x_init(::Any) = NamedTuple()

# Design: §8.2, D-195, D-231, D-263.
# `s` is the discrete tier's own letter (D-195). The store is the tier marker,
# and it is disjoint from `x_init`. The fallback serves the value readers; the
# classifier asks whether the method is declared.
"""
    s_init(c) -> NamedTuple

Return the [component](@ref g-component)'s initial discrete state, as a
`NamedTuple` of named values.

A discrete primitive declares its state by value, as in
`s_init(::Counter) = (n = 0,)`. Every field is isbits or a `Symbol`, and the
field types stay as written at every [activation](@ref g-activation). Text and
bulk data belong on the component instance.

Every primitive defines exactly one of [`x_init`](@ref) and `s_init`, and the
one it defines makes it continuous or discrete. A stateless discrete primitive
declares `s_init(::C) = (;)`, and holds its outputs between its
[ticks](@ref g-tick). A non-empty state needs an [`s_update`](@ref) method.

The build refuses a value that is not a `NamedTuple` as `StoreNotNamedTuple`,
and a field that is neither isbits nor a `Symbol` as `IllegalStoreField`. A
non-empty state with no `s_update` is refused as `StoreWithoutUpdate`, and a
primitive that also defines `x_init` as `DeclarationOnWrongTier`.
"""
s_init(::Any) = NamedTuple()

# Design: §8.2, D-231.
"""
    m_init(c) -> NamedTuple

Return the [component](@ref g-component)'s initial modes, as a `NamedTuple` of
named values.

A continuous primitive declares its modes by value, as in
`m_init(::Engine) = (phase = off,)`. Every field is isbits or a `Symbol`, as for
[`s_init`](@ref). Event handlers write the modes, and nothing else may. A
primitive may declare modes that no event of its own changes.

Modes are continuous-only, because the event system is continuous-side only.
The build refuses a non-empty `m_init` on a discrete primitive as
`DeclarationOnWrongTier`, a value that is not a `NamedTuple` as
`StoreNotNamedTuple`, and a field that is neither isbits nor a `Symbol` as
`IllegalStoreField`.
"""
m_init(::Any) = NamedTuple()

# Design: §8.2, D-077, D-263.
"""
    ws_init(c, ::Type{T})

Allocate the [component](@ref g-component)'s [workspace](@ref g-workspace) at
the scalar type `T`.

The framework calls the allocator and hands its result to the component's
functions as the `ws` field of their [bundle](@ref g-bundle). Declaring is
allocating, so `ws_init` is the one declaration that takes the scalar. Sizes
come from the instance and eltypes from `T`, as in
`ws_init(c::KF, ::Type{T}) where {T} = (P = Matrix{T}(undef, c.n, c.n),)`.

The allocator takes `T` on both [tiers](@ref g-tier). A continuous allocator is
called at the scalar of each [activation](@ref g-activation), and a discrete one
always receives `Float64`. The contents at each call are unspecified, and the
framework never reads or writes them. A component that needs no
[scratch](@ref g-scratch) defines no method.
"""
function ws_init end

# Design: D-263.
"""
    u_types(c) -> NamedTuple

Return the types the [component](@ref g-component) accepts on its inputs, a
`NamedTuple` of input name => type.

The entries are written at `Float64` and take the component alone on both
[tiers](@ref g-tier), as in
`u_types(::Engine) = (throttle = Float64, starter = Bool)`. On a continuous
primitive every `Float64` position follows the scalar of each
[activation](@ref g-activation), and an entry wrapped in [`Pinned`](@ref) does
not. On a discrete primitive every entry stays as written. The default declares
no inputs.

An entry states what the component allows to arrive. An unwrapped `Float64`
leaf tolerates both the activation scalar and a frozen `Float64`, and a
`Pinned` entry demands an arriving value that never carries partials.

The build refuses a wire whose producer type does not fit the entry as
`WireTypeMismatch`, and a producer that follows the scalar at a `Pinned` entry
as `WalkingFaceAtFrozenEntry`. A `Pinned` marker below the top of an entry is
refused as `IllegalPortType`, and a `Pinned` entry on a discrete primitive as
`DeclarationOnWrongTier`.
"""
u_types(::Any) = NamedTuple()

# Design: §8.2, §9.3, D-263.
"""
    y_types(c) -> NamedTuple

Return the types of the [component](@ref g-component)'s output
[ports](@ref g-port), a `NamedTuple` of port name => type.

The entries are written at `Float64` and take the component alone on both
[tiers](@ref g-tier), as in
`y_types(::Engine) = (M_shaft = Float64, P = Float64)`. The declaration is read
literally. On a continuous primitive, a port's value at each
[activation](@ref g-activation) has the declared type with every `Float64`
position, alone or as a type parameter, at that activation's scalar. An entry
wrapped in [`Pinned`](@ref) keeps its type at every activation. On a discrete
primitive every entry stays as written.

One declaration covers both output stages, [`y_state`](@ref) and
[`y_direct`](@ref), and no port names its stage. The build finds which stage
produces each port by its [probe](@ref g-probe), and checks each return against
this declaration.

A primitive with an empty state and no `y_types` is refused as
`StatelessWithoutOutputs`. A declared port no stage returns is refused as
`DeclaredNotProduced`, a returned name the declaration lacks as
`UndeclaredReturnField`, and a port both stages return as `ProducedByTwoStages`.
"""
y_types(::Any) = NamedTuple()

# Design: §8.2, D-263, D-265.
# Defined in `leaves.jl` beside the entry walk that dispatches on it.
"""
    Pinned{P}

The marker that keeps one `u_types` or `y_types` entry at type `P`, whatever
scalar the model runs at.

`Pinned` wraps a whole entry of [`u_types`](@ref) or [`y_types`](@ref), as in
`Pinned{Float64}` or `Pinned{SVector{3,Float64}}`, to say the entry never
follows the scalar of an [activation](@ref g-activation). On an output the
[port](@ref g-port)'s value is a `P` at every activation. On an input the entry
demands an arriving value that never carries partials. The build strips the
marker at `Float64`, so no value, layout or message carries the wrapper itself.
It is a type-level marker, never instantiated.

A marker below the top of an entry, in a type parameter, is refused as
`IllegalPortType` on both [tiers](@ref g-tier). The marker is continuous-only: a
discrete [primitive](@ref g-component)'s entries never follow the scalar, so a
`Pinned` entry there is refused as `DeclarationOnWrongTier`.
"""
Pinned

# --- what an assembly declares (§8.6) -----------------------------------------
# All three are ordered collections of `Pair`s of strings, and every arrow reads
# along the signal flow. Direction is declared by the method, never inferred: the
# resolved endpoints only cross-check it.

# Design: §8.5, §8.6, D-170.
# Defining it is the assembly class marker, which is why it has no fallback to
# match.
"""
    local_wires(c)

Return the [assembly](@ref g-assembly)'s internal wires, an ordered collection
of `"child/face" => "child/face"` pairs.

Every pair runs from a child's output [face](@ref g-face) to a child's input
face, and its arrow reads along the signal flow. Both endpoints are relative to
the declaring assembly, each one an immediate child and one of its faces, so
`"aircraft/2/face"` names a container element's face in one level.

Defining `local_wires` is what makes a [component](@ref g-component) an
assembly, so an assembly defines it even with no wires, as
`local_wires(::A) = ()`. The assembly's own boundary is declared by
[`input_wires`](@ref) and [`output_wires`](@ref).

The build refuses an endpoint whose [port](@ref g-port) has the wrong direction
as `FaceDirectionConflict`, an input fed twice as `TwoProducers`, and a
component that defines `local_wires` beside any primitive declaration as
`ClassMixed`.
"""
function local_wires end

# Design: §8.6, D-170, D-210.
"""
    input_wires(c)

Return the [assembly](@ref g-assembly)'s inward boundary, an ordered collection
of input name => internal endpoint path pairs.

Each input name is a [face](@ref g-face), and it routes inward to an input of an
immediate child, as in `"throttle" => "engine/throttle"`. A face that feeds
several children takes a tuple of paths, `"trn" => ("left/trn", "right/trn")`,
fanning out through the boundary. The default declares no input face. At the
root of a build these faces are the [root inputs](@ref g-root-input).

Face names contain no `/`, and are unique across `input_wires` and
[`output_wires`](@ref) together. The build refuses a face name holding `/` as
`FaceNameIllegal`, a name declared twice as `FaceNameCollision`, an endpoint
that resolves to an output as `FaceDirectionConflict`, and an empty tuple of
paths as `UnknownPort`.
"""
input_wires(::Any) = ()

# Design: §8.6, D-170.
"""
    output_wires(c)

Return the [assembly](@ref g-assembly)'s outward boundary, an ordered collection
of internal source path => output name pairs.

Each output name is a [face](@ref g-face), and it exposes an output of an
immediate child, as in `"aircraft/pose" => "view_pose"`. The source comes first,
so the pairs read along the signal flow, like every pair of
[`local_wires`](@ref) and [`input_wires`](@ref). The default declares no output
face.

The build refuses a face name holding `/` as `FaceNameIllegal`, a name declared
twice across the two boundary declarations as `FaceNameCollision`, and a source
that resolves to an input as `FaceDirectionConflict`.
"""
output_wires(::Any) = ()

# Design: §8.5, D-211.
# "At most one" is unrepresentable otherwise here: the return is one `Symbol`
# or `nothing`.
"""
    transparent_container(c) -> Union{Symbol,Nothing}

Return the name of the one [container field](@ref g-container-children) whose
children go by bare key, or `nothing`.

Its elements are children of the [component](@ref g-component), named
`"field/key"` or `"field/1"`. Returning that field's `Symbol` names them `"key"`
and `"1"` instead, everywhere a child name appears: wiring endpoints,
[`sample_times`](@ref) keys, read paths, [`at`](@ref) prefixes and diagnostics.
Naming is the only thing it changes, and the container still has no wires,
[faces](@ref g-face) or rate of its own.

The declaration is optional, and a component may name at most one field. The
default, `nothing`, keeps every container's key segment. The build refuses a
name that matches no container field as `TransparentContainerUnknown`, and a
bare key that collides with a sibling child's name as `ChildNameCollision`.
"""
transparent_container(::Any) = nothing

# Design: §8.2, §13.5, D-316.
"""
    stop_reason(c) -> String

Return the reason the [component](@ref g-component)'s
[stop requests](@ref g-stop-request) report, `""` by default.

A stop request is an output [port](@ref g-port) of type [`StopFlag`](@ref). The
build reads `stop_reason` for every component that publishes such a port, and
all of the component's requests share the reason. It is instance data, never a
port value. A run that a request ends carries the reason on its
[`ModelRequestedStop`](@ref) source.
"""
stop_reason(::Any) = ""

# --- rate scopes (§8.7, §10.5) --------------------------------------------------
# The two forms of the sample-time declaration, and the wrappers are the
# whole value vocabulary — a bare integer or bare quantity in a `sample_times`
# entry is a declaration error. They are plain data carriers (D-185): range
# validation is the structure step's, with path attribution, in the fold. The one
# constructor-side refusal is floats, because it is a normalization failure
# rather than a range check: grid derivation is GCD arithmetic, ill-defined over
# floats, so every period and offset is an exact `Rational{Int}` and a float
# argument throws the teaching error naming the exact spelling.

# Design: §10.5.
"""
    Period(T::Union{Integer,Rational{<:Integer}}) -> Period

A time period `T`, in exact rational seconds.

A `Period` is what [`Absolute`](@ref) and the [`Δt_base`](@ref g-dt_base)
keyword of [`Deployment`](@ref) take. `Period(1//50)` and `Hz(50)` are the same
value, a spelling choice: both are normalized to the exact rational period at
construction. See [`Hz`](@ref) for the frequency spelling.

A float is refused as `ArgumentInvalid`, because the base grid is derived by
GCD arithmetic, which is ill-defined over floats. Write `Period(1//50)`, not
`Period(0.02)`.
"""
struct Period
    T::Rational{Int}
    Period(T::Union{Integer,Rational{<:Integer}}) = new(Rational{Int}(T))
    Period(T::AbstractFloat) =
        throw(DiagnosticError(ArgumentInvalid(call = :Period, reason = :inexact, value = T)))
end

# Design: §10.5, D-185.
"""
    Hz(frequency::Union{Integer,Rational{<:Integer}}) -> Period

Return the [`Period`](@ref) of a frequency, `1 // frequency` seconds.

`Hz(50)` and `Period(1//50)` are the same value, and either may be given to
[`Absolute`](@ref) or as the [`Δt_base`](@ref g-dt_base) keyword of
[`Deployment`](@ref). A float is refused as `ArgumentInvalid`, because the grid
arithmetic is exact: write `Hz(1//2)` for 0.5 Hz, not `Hz(0.5)`.
"""
Hz(frequency::Union{Integer,Rational{<:Integer}}) = Period(1 // frequency)
Hz(frequency::AbstractFloat) =
    throw(DiagnosticError(ArgumentInvalid(call = :Hz, reason = :inexact, value = frequency)))

period(q::Period) = q.T

# Design: §10.5.
"""
    Relative(K, φ) -> Relative
    Relative(K::Integer) -> Relative

A sample time in [ticks](@ref g-tick) of the enclosing scope: every `K`-th tick,
starting from the `φ`-th.

A [`sample_times`](@ref) [entry](@ref g-entry) `Relative(K, φ)` runs its child
at every `K`-th tick of the enclosing [rate scope](@ref g-rate-scope), starting
from its `φ`-th, and `φ` defaults to `0`. Scope ticks are the unit system, so
relative entries compose affinely down the tree. Under a scope that ticks every
`D_s` [base ticks](@ref g-dt_base) at [phase](@ref g-phase) `Φ_s`, the child
ticks every `K·D_s` base ticks at phase `Φ_s + φ·D_s`.

`K = 1` admits no stagger. Two same-rate siblings are staggered one level down
instead: declare their scope at twice their rate, and give them
`Relative(2, 0)` and `Relative(2, 1)`.

The constructor checks nothing. The build refuses `K < 1`, or a `φ` outside
`0 ≤ φ < K`, as `RatesViolation`.
"""
struct Relative
    K::Int
    φ::Int
end
Relative(K::Integer) = Relative(K, 0)

# Design: §9.1, §10.5, D-186.
"""
    Absolute(q::Period, τ::Union{Integer,Rational{<:Integer}} = 0) -> Absolute

A sample time in exact rational seconds, with [ticks](@ref g-tick) at
`t = τ + k·T`.

`q` is a period `T`, built with [`Period`](@ref) or [`Hz`](@ref), and `τ` is
the offset in seconds. The entry is an [anchor](@ref g-anchor). It severs its
child from the enclosing scope's grid, so the child may tick faster than its
scope. The child's ticks are counted in [base ticks](@ref g-dt_base) only once a
[`Deployment`](@ref) fixes `Δt_base`. Anchor periods and nonzero offsets
constrain that grid together, and an offset of `T/1000` can cost a grid 1000
times finer.

A float offset is refused as `ArgumentInvalid`, and so is a bare number in place
of a `Period`: write `Absolute(Hz(50), 1//500)`. The build refuses a period
that is not positive, or an offset outside `0 ≤ τ < T`, as `RatesViolation`.
"""
struct Absolute
    T::Rational{Int}
    τ::Rational{Int}
    Absolute(q::Period, τ::Union{Integer,Rational{<:Integer}} = 0) = new(q.T, Rational{Int}(τ))
    Absolute(::Period, τ::AbstractFloat) =
        throw(DiagnosticError(ArgumentInvalid(call = :Absolute, reason = :inexact, value = τ)))
    Absolute(q::Real, τ...) =
        throw(DiagnosticError(ArgumentInvalid(call = :Absolute, reason = :not_a_quantity, value = q)))
end

# Design: §8.7, §10.5.
"""
    sample_times(c) -> NamedTuple

Return the [assembly](@ref g-assembly)'s sample times, a `NamedTuple` of
immediate child name => [`Relative`](@ref) or [`Absolute`](@ref).

A [rate scope](@ref g-rate-scope) schedules the assembly's discrete children and
sub-assemblies, as in
`sample_times(::A) = (nav = Relative(5), gnss = Absolute(Hz(10)))`. The
declaration is optional, and so is every key: an unlisted discrete child
defaults to `Relative(1)`, so only multiplied, phased or anchored children
appear. A [container field](@ref g-container-children)'s bare name keys one
entry for all its elements.

The rates belong to the assembly type, as design ratios or a modeled
instrument's own rate. A rate that is a deployment preference is exposed as a
constructor parameter, and read off the instance here.

The build refuses a value that is not such a `NamedTuple`, a bare number in
place of a wrapper, a key that names no immediate child, and a key on a
continuous child, each as `RatesViolation`.
"""
sample_times(::Any) = (;)

# --- state events (§2.3, §8.2) -------------------------------------------------

# Design: §5.2, §10.4, D-090, D-179.
# The policy is read off the probe the build already runs, so the illegal
# form/policy pairing is unrepresentable rather than merely diagnosed.
"""
    StateEvent(guard, handler) -> StateEvent

One event of a [`state_events`](@ref) declaration: a [guard](@ref g-guard) and
its handler, and nothing else.

The guard and the handler both take the [component](@ref g-component) and its
[bundle](@ref g-bundle). The bundle may carry `x`, `m`, `y`, `u`, `t` and `ws`.
There is no detection keyword, because the guard's return type declares the
policy. A `Bool` guard is [boundary-detected](@ref g-boundary-detected). A guard
returning a `Float64` is [localized](@ref g-localized), and its event holds
where the value is `≥ 0`.

The handler returns a `NamedTuple` of the [stores](@ref g-store) it writes, such
as `(; m = (; phase = running))`. A present `x` replaces the whole continuous
state, and a present `m` merges into the modes.

The build refuses a guard that returns neither form as `GuardForm`, a missing
guard or handler method as `EventHalfMissing`, and a handler key that names no
store of the component as `HandlerReturnKey`.
"""
struct StateEvent{G,H}
    guard::G
    handler::H
end

# Design: §5.2, §8.2, §10.6.
"""
    state_events(c) -> NamedTuple

Return the [component](@ref g-component)'s events, a `NamedTuple` of name =>
[`StateEvent`](@ref), in priority order.

A continuous primitive declares its events as named entries,
`state_events(::Engine) = (start = StateEvent(start_guard, start_handler),)`.
Order is semantics. At a [boundary](@ref g-boundary) a component fires at most
one event per round, the first eligible one in declaration order, and the rounds
repeat until none fires, so the [guards](@ref g-guard) are decided again after
each firing. Nothing here is inferred, and the default declares no events.

Events are continuous-only, like [`m_init`](@ref), because the event system is
continuous-side only. The build refuses a non-empty `state_events` on a discrete
primitive as `DeclarationOnWrongTier`, and an entry that is not a `StateEvent`
as `EventHalfMissing`.
"""
state_events(::Any) = (;)

# Design: §5.3, §8.2, §9.3.
# It runs between a state write and its decode, and its return is written back
# to the buffer wholesale, so the probe holds it complete against the state
# shape.
"""
    x_projection(c, x) -> NamedTuple

Return the continuous state `x` projected back onto the
[component](@ref g-component)'s manifold.

`x_projection` takes the state alone, not a [bundle](@ref g-bundle): one
[store](@ref g-store) in, the same store out, which is why it alone stays
positional. An attitude model might declare
`x_projection(c::Attitude, x) = (; q = normalize(x.q))`. It runs after each
integration step and after each event handler fires. Its return replaces the
whole continuous state, so it carries every state field at the state's type.

The method is optional and continuous-only. The build refuses it on a discrete
primitive, or on one with an empty state, as `DeclarationOnWrongTier`, and a
return whose fields or types differ from the state's as `ConformanceFailure`.
"""
function x_projection end

"""The §2.3 predicate of a guard's return: the `Bool` form itself, or `σ ≥ 0`."""
_holding(σ::Bool) = σ
_holding(σ) = σ ≥ 0

# --- what an author defines (the §5.2 signatures) -----------------------------
# Every stage takes the component and exactly one NamedTuple bundle of views,
# destructured by name: `y_direct(c::MyComp, (; x, u)) = ...`. The
# framework's call is one fixed shape; the bundle law (below) decides what the
# tuple carries.
#
# The two output stages are one pair of names shared by both tiers (D-220):
# `y_state`/`y_direct`, whose legal bundle set is tier-dependent —
# `x, m, t [, ws]`/`x, m, u, y_x, t [, ws]` continuous, `s, t, Δt [, ws]`/
# `s, u, y_s, t, Δt [, ws]` discrete. "No `direct` in the name" is the
# no-feedthrough marker within either tier's pair.
#
# A component defines the stages it needs. `has_stage` is how the build asks,
# and it is a question about method existence, not a declaration the author
# repeats — the definition site is the single source of truth.

# Design: §5.2, §5.3, §8.2, §10.5, D-220, D-252.
"""
    y_state(c, bundle) -> NamedTuple

Return the [component](@ref g-component)'s
[stage-1 outputs](@ref g-stage-function).

`y_state` is the first of a primitive's two output stages, defined by a method
for the component's type, as in `y_state(::Engine, (; x)) = (; ω = x.ω)`. Its
[bundle](@ref g-bundle) carries no inputs, so a stage-1 [port](@ref g-port)
never depends instantly on an input and breaks would-be feedback loops. A
primitive sits on one [tier](@ref g-tier). On the continuous tier the bundle may
carry `x`, `m`, `t` and `ws`, and on the discrete tier `s`, `t`, `Δt` and `ws`,
each only if the component has it.

The stage returns a `NamedTuple` of port values at their [`y_types`](@ref)
types. [`y_direct`](@ref) receives the return as `y_x`, or `y_s` on the
discrete tier, so an intermediate both stages need is computed once. A
component exposes a state or mode field by returning it here. A discrete
primitive's stages run only at its [ticks](@ref g-tick), and its ports hold
their values in between.

The stage is optional, and a component with no stage-1 ports defines no method.
The build refuses a read outside the bundle as `BundleFieldError`, a return of
bare `(;)` as `DeadStage`, and a returned name `y_types` lacks as
`UndeclaredReturnField`.
"""
function y_state end

# Design: §5.2, §5.3, §8.2, D-006, D-220, D-252.
"""
    y_direct(c, bundle) -> NamedTuple

Return the [component](@ref g-component)'s
[stage-2 outputs](@ref g-stage-function).

`y_direct` is the second of a primitive's two output stages, as in
`y_direct(eng::Engine, (; x, m, u)) = (; M_shaft = ..., P = ...)`. Beside the
state, its [bundle](@ref g-bundle) carries the inputs `u` and the return of
[`y_state`](@ref) as `y_x`. A primitive sits on one [tier](@ref g-tier), and a
discrete primitive receives that return as `y_s`. On the continuous tier the
bundle may carry `x`, `m`, `u`, `y_x`, `t` and `ws`, and on the discrete tier
`s`, `u`, `y_s`, `t`, `Δt` and `ws`, each only if the component has it.

Every stage-2 [port](@ref g-port) is taken to depend on every wired input. The
stage returns a `NamedTuple` of port values at their [`y_types`](@ref) types,
and the two stages together produce each declared port exactly once.

The stage is optional. The build refuses a read outside the bundle as
`BundleFieldError`, a port that both stages return as `ProducedByTwoStages`,
and a returned name `y_types` lacks as `UndeclaredReturnField`.
"""
function y_direct end

# Design: §5.2, §5.3, §8.2, D-015, D-220.
"""
    x_deriv(c, bundle) -> NamedTuple

Return the time derivative of the [component](@ref g-component)'s continuous
state.

`x_deriv` is the continuous primitive's update law, its [flow](@ref g-flow), as
in `x_deriv(eng::Engine, (; x, y, u)) = (ω = (y.M_shaft - u.M_load) / eng.J,)`.
It runs after the output stages, when every [port](@ref g-port) is fresh, so it
reads the component's own outputs `y` instead of computing them again. Its
[bundle](@ref g-bundle) may carry `x`, `m`, `y`, `u`, `t` and `ws`, each only if
the component has it.

The return has exactly the fields of [`x_init`](@ref), each at the state's
type. A continuous primitive with a non-empty state must define it.

The build refuses a non-empty `x_init` with no `x_deriv` as
`StoreWithoutUpdate`, a return whose fields or types differ from the state's
as `ConformanceFailure`, and a read outside the bundle as `BundleFieldError`.
A primitive that also defines [`s_update`](@ref) or [`s_init`](@ref) is refused
as `DeclarationOnWrongTier`.
"""
function x_deriv end

# Design: §5.2, §5.3, §8.2, §10.5, D-195, D-220.
"""
    s_update(c, bundle) -> NamedTuple

Return the [component](@ref g-component)'s discrete state after one
[tick](@ref g-tick).

`s_update` is the discrete primitive's update law, as in
`s_update(::Counter, (; s)) = (n = s.n + 1,)`. It runs at each of the
component's ticks, once the [boundary](@ref g-boundary)'s outputs and events
have settled. Its [bundle](@ref g-bundle) may carry `s`, `y`, `u`, `t`, `Δt` and
`ws`, each only if the component has it, and `Δt` is the component's own tick
period.

The return replaces the whole state, so it has exactly the type of the value
[`s_init`](@ref) returns. A discrete primitive with a non-empty state must
define it.

The build refuses a non-empty `s_init` with no `s_update` as
`StoreWithoutUpdate`, a return of another type as `ConformanceFailure`, and a
read outside the bundle as `BundleFieldError`. A primitive that also defines
[`x_deriv`](@ref) or [`x_init`](@ref) is refused as `DeclarationOnWrongTier`.
"""
function s_update end

# --- the family, and the forgotten import (§8.1, D-246) -----------------------
# The declaration and stage family, in §8.1's import-list order. Every name here
# is a generic function this module owns, which is what makes the check below a
# comparison against `Redstone`'s own object.

const DECLARATION_FAMILY = (:x_init, :s_init, :m_init, :ws_init,
    :u_types, :y_types, :state_events, :y_state, :y_direct,
    :x_deriv, :s_update, :x_projection, :local_wires,
    :input_wires, :output_wires, :sample_times,
    :transparent_container, :stop_reason)

"""
The family names `comp`'s parent module binds to something other than the
framework's function, in family order — the forgotten-import evidence of
§8.1 (D-246). Empty for a module that imported what it extends.
"""
function foreign_declarations(@nospecialize(comp))
    author_module = parentmodule(typeof(comp))
    Symbol[name for name in DECLARATION_FAMILY
           if isdefined(author_module, name) &&
              getfield(author_module, name) !== getfield(@__MODULE__, name)]
end

has_stage(fn, @nospecialize(comp)) = hasmethod(fn, Tuple{typeof(comp),NamedTuple})

"""
Is `fn` declared *for this component* in the arity `extra` names, as against
matching a framework fallback? `hasmethod` cannot tell the two apart, so the
matched method's own signature is what answers: a fallback carries `Any` in the
component position.
"""
_declares(fn, @nospecialize(comp), extra...) =
    hasmethod(fn, Tuple{typeof(comp),extra...}) &&
    Base.unwrap_unionall(which(fn, Tuple{typeof(comp),extra...}).sig).parameters[2] !== Any

# --- tiers (§8.2) -------------------------------------------------------------
# A tier is never spelled in a signature; the store every leaf declares names it
# (D-263). The enum is the build's internal answer, not an authoring surface.

@enum Tier CONTINUOUS DISCRETE

tier_word(tier::Tier) = tier === CONTINUOUS ? "continuous" : "discrete"

"""
A contract declaration `fn` as the tier reads it (D-263): on the continuous tier
walked at `S`, a `Pinned` entry yielding its type (D-265); on the discrete
tier as written. `S` is `Float64` for every reader but the structure step's
wire pass, which also reads it at the marker.
"""
function declared_at(fn, @nospecialize(comp), tier::Tier, ::Type{S} = Float64) where {S}
    _declares(fn, comp) || return NamedTuple()
    decl = invoke_declaration(fn, comp)
    tier === CONTINUOUS ? map(P -> retype_entry(S, P), decl) : decl
end

# The tier's own update law (D-195). Everything downstream asks for it
# *through* the tier, so no code path ever holds a name that serves both; the
# output stages are one pair of names shared by both tiers (D-220), so every
# caller names them directly instead.
update_of(tier::Tier) = tier === CONTINUOUS ? x_deriv : s_update

# --- the bundle law (§5.2) ----------------------------------------------------
# A name appears in a component's bundle iff the corresponding store or fact
# exists for that component. Undeclared stores are *absent*, never
# `nothing`-filled, so a body destructuring what it does not own fails at the
# destructuring rather than reading a filler.

"""
Bundle field names for `fn` on component `comp` at tier `tier`, given its discovered
stage-1 ports.

The by-type declarations are asked at nominal `Float64`: presence is a property
of the declaration's key set, which is fixed by the declaration and cannot vary
with the activation scalar, so the bundle shape is the same at every activation.

The per-function, per-tier name sets are closed, and so are the state letters:
`x`/`y_x` with `m` on the continuous tier, `s`/`y_s` with `Δt` on the discrete
(D-195).
"""
function bundle_names(fn, @nospecialize(comp), tier::Tier, stage1_ports::Tuple)
    update = update_of(tier)
    bundle_fields = Symbol[]
    if tier === CONTINUOUS
        !isempty(invoke_declaration(x_init, comp)) && push!(bundle_fields, :x)
        !isempty(invoke_declaration(m_init, comp)) && push!(bundle_fields, :m)
    else
        !isempty(invoke_declaration(s_init, comp)) && push!(bundle_fields, :s)
    end
    if fn === y_direct || fn === update
        !isempty(declared_at(u_types, comp, tier)) && push!(bundle_fields, :u)
    end
    if fn === y_direct
        !isempty(stage1_ports) && push!(bundle_fields, tier === CONTINUOUS ? :y_x : :y_s)
    elseif fn === update
        !isempty(declared_at(y_types, comp, tier)) && push!(bundle_fields, :y)
    end
    _declares_workspace(comp) && push!(bundle_fields, :ws)
    push!(bundle_fields, :t)
    tier === DISCRETE && push!(bundle_fields, :Δt)
    tuple(bundle_fields...)
end

_declares_workspace(@nospecialize(comp)) = _declares(ws_init, comp, Type{Float64})

"""
Bundle field names for a guard or handler (§5.2): the update law's view of the
world — `x, m, y, u, t [, ws]` — one closed set shared by both halves, on the
continuous tier only. The same iff rule as `bundle_names`, without a stage-1
distinction: guards and handlers run against the complete fresh table.
"""
function event_bundle_names(@nospecialize(comp))
    bundle_fields = Symbol[]
    !isempty(invoke_declaration(x_init, comp)) && push!(bundle_fields, :x)
    !isempty(invoke_declaration(m_init, comp)) && push!(bundle_fields, :m)
    !isempty(declared_at(u_types, comp, CONTINUOUS)) && push!(bundle_fields, :u)
    !isempty(declared_at(y_types, comp, CONTINUOUS)) && push!(bundle_fields, :y)
    _declares_workspace(comp) && push!(bundle_fields, :ws)
    push!(bundle_fields, :t)
    tuple(bundle_fields...)
end

# The maximal legal sets (§5.2, Appendix B), keyed by family and tier. A
# component's bundle narrows one of these to declared reality.
const LEGAL_BUNDLE = Dict(
    (:y_state, CONTINUOUS)     => (:x, :m, :t, :ws),
    (:y_direct, CONTINUOUS)    => (:x, :m, :u, :y_x, :t, :ws),
    (:x_deriv, CONTINUOUS) => (:x, :m, :y, :u, :t, :ws),
    (:y_state, DISCRETE)       => (:s, :t, :Δt, :ws),
    (:y_direct, DISCRETE)      => (:s, :u, :y_s, :t, :Δt, :ws),
    (:s_update, DISCRETE)       => (:s, :y, :u, :t, :Δt, :ws),
    (:guard, CONTINUOUS)            => (:x, :m, :y, :u, :t, :ws),
    (:handler, CONTINUOUS)          => (:x, :m, :y, :u, :t, :ws))

# Every name any family may carry at a tier: the wrong-tier test's universe.
_tier_names(tier::Tier) =
    union((fields for ((_, set_tier), fields) in LEGAL_BUNDLE if set_tier === tier)...)

"""
§5.2's three classes for a bundle field the component's bundle lacks: a name
this family may carry that the component did not declare; a name this tier
never carries but the other does (the state letters included, D-195); or a
name illegal for this family, which is also every name from nowhere.
"""
function classify_bundle_field(family::Symbol, tier::Tier, field::Symbol)
    field in get(LEGAL_BUNDLE, (family, tier), ()) && return :undeclared
    field in _tier_names(tier) && return :illegal_for_family
    field in _tier_names(tier === CONTINUOUS ? DISCRETE : CONTINUOUS) && return :wrong_tier
    :illegal_for_family
end

# --- probe values (§9.3) -----------------------------------------------------
# Root inputs are the one terminal with no producer; the build synthesizes their
# values here. Overridable per type — that is the seam a constrained type uses
# to state a valid default.

probe_value(::Type{T}) where {T<:Real} = zero(T)
probe_value(::Type{Bool}) = false
probe_value(::Type{E}) where {E<:Enum} = first(instances(E))
probe_value(::Type{P}) where {P<:StaticArray} = zero(P)
probe_value(::Type{P}) where {P} = P()

# Whether `P`'s probe value comes from the chain above rather than an author's
# override. A `MethodError` out of the chain is a missing synthesis (§9.3). One
# out of an override is the override's own bug and propagates.
_framework_synthesis(::Type{P}) where {P} =
    which(probe_value, Tuple{Type{P}}).module === @__MODULE__

# --- the user-code frame (§13.2, D-248) ---------------------------------------
# Every user-authored method the framework invokes is reached through one of the
# two accessors below, and every per-component body that reads declarations
# without a path in hand runs under `at_component`, which fills the path in.

# What passes through a frame unwrapped: none of these is user code failing.
_passes_frame(err) =
    err isa DiagnosticError || err isa InternalInvariant || err isa InterruptException

"""
The framing accessor for a declaration (§13.2, D-248): `fn(comp, args...)`, a
throw out of it framed as `UserCodeFraming` naming the method. The path is
not known here; `at_component` fills it.

A few reads stay bare because the build already invoked the same declaration
through this accessor and it returned: `conditions.jl`'s `_resolve_entries`,
`_store_bases` and `_declared_workspace`, build.jl's `establish_defaults!`,
`children` reaching `assembly.jl`'s `_children`, and
`tracer.jl`'s sampled `_trace_direct`.
"""
function invoke_declaration(fn, @nospecialize(comp), args...)
    try
        fn(comp, args...)
    catch err
        _passes_frame(err) && rethrow()
        throw(DiagnosticError(UserCodeFraming(fn = String(nameof(fn)), cause = err)))
    end
end

"""
The framing accessor for a probed bundle-taking function (§13.2, D-248):
`fn(comp, bundle)`. A `FieldError` matched against the bundle's own type is the
bundle-law diagnostic, classified (§5.2); any other throw is the plain frame,
carrying the bundle's names and the synthesized inputs as a spelling.
"""
function invoke_probed(fn, family::Symbol, path::String, @nospecialize(comp), tier::Tier,
                       @nospecialize(bundle::NamedTuple))
    try
        fn(comp, bundle)
    catch err
        _passes_frame(err) && rethrow()
        if err isa FieldError && err.type === typeof(bundle)
            throw(DiagnosticError(BundleFieldError(path = path, family = String(family),
                tier = tier === CONTINUOUS ? :continuous : :discrete, field = err.field,
                legal = collect(keys(bundle)),
                reason = classify_bundle_field(family, tier, err.field))))
        end
        throw(DiagnosticError(UserCodeFraming(path = path, fn = String(family),
            bundle = collect(keys(bundle)), inputs = _inputs_spelling(bundle), cause = err)))
    end
end

# One line, whatever the author's `show` does. A `show` that throws must not
# replace the throw the frame is already carrying.
function _inputs_spelling(bundle::NamedTuple)
    haskey(bundle, :u) || return ""
    try replace(sprint(show, bundle.u; context = :compact => true), '\n' => ' ')
    catch err; err isa InterruptException ? rethrow() : "<unshowable>" end
end

"""
The component frame (§13.2, D-248): runs `thunk()` for the component at `path`
and fills the path into a `UserCodeFraming` an accessor raised without one.
Every other throw passes.
"""
function at_component(thunk, path::String)
    try
        thunk()
    catch err
        if err isa DiagnosticError{UserCodeFraming} && isempty(err.carried.path)
            framing = err.carried
            throw(DiagnosticError(UserCodeFraming(path = path, fn = framing.fn,
                                                  bundle = framing.bundle,
                                                  inputs = framing.inputs,
                                                  cause = framing.cause)))
        end
        rethrow()
    end
end
