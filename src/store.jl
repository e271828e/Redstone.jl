# The signal table: per-eltype homogeneous cell stores with build-time offsets
# (D-162, §9.7). Cells are flattened by the §7.1 leaf walk into one contiguous
# buffer per element type; a mixed-leaf cell (§8.2's leaf walk, D-263
# pinning) simply spans several of them. An address carries the port type as
# its parameter and one cursor per distinct leaf eltype as an `NTuple` *field*,
# so instances of one component type share one compiled body; `K` is a pure
# function of `P` (bench-confirmed 2026-08-20: the C2M point in
# `design/prototypes/cellstore_bench` keeps D-162's flat curve), and the homogeneous cell is
# the `K = 1` case of the same representation.

struct CellAddr{P,K}
    offsets::NTuple{K,Int}
end

struct CellStore{T}
    buffer::Vector{T}
end

"""
The store bundle: one homogeneous `CellStore` per element type present in the
model's cells, keyed by the eltype's name — the *plural* in §9.7's "per-eltype
stores". One concrete bundle type per model, so `Chunk`'s store parameter stays
a single type: chunk-type count, not model size, is what bounds the compile
curve D-162 measured. Selection is static — the address's port type names its
leaf eltypes at compile time, so a gather binds exactly the buffers `P`'s
leaves live in, with no runtime lookup — and each of an address's offsets is
relative to its own eltype's buffer, `leaf_eltypes` fixing the order.
"""
struct StoreBundle{NT<:NamedTuple}
    stores::NT
end

# The bundle's field name for one leaf eltype. `Symbol(L)` will not do: `show`
# for a type abbreviates the module prefix when the type is visible from the
# *printing* module, and the module a `@generated` body prints from is not the
# one `compile` prints from — so a scalar tagged by a type outside `Base` (a
# service's own seeding tag, §9.4) keys the bundle one way at construction and
# is looked up another way at the gather. Printing with no module context at all
# fixes one fully-qualified spelling for every site.
_cell_key(::Type{L}) where {L} = Symbol(sprint(show, L; context = :module => nothing))

# The stop-request buffer's key, fixed once: `_cell_key` prints and allocates
# (§13.5, D-316).
const STOP_FLAG_KEY = _cell_key(StopFlag)

@generated function gather_cell(bundle::StoreBundle, addr::CellAddr{P,K}) where {P,K}
    eltypes = leaf_eltypes(P)
    binds = [:($(Symbol(:buffer, k)) = getfield(bundle.stores, $(QuoteNode(_cell_key(L)))).buffer)
             for (k, L) in enumerate(eltypes)]
    expr = _mreconstruct_expr(P, eltypes, zeros(Int, K))
    quote
        $(Expr(:meta, :inline))
        offsets = addr.offsets
        $(binds...)
        $expr
    end
end

@generated function scatter_cell!(bundle::StoreBundle, addr::CellAddr{P,K}, value) where {P,K}
    eltypes = leaf_eltypes(P)
    binds = [:($(Symbol(:buffer, k)) = getfield(bundle.stores, $(QuoteNode(_cell_key(L)))).buffer)
             for (k, L) in enumerate(eltypes)]
    block = _mflatten_expr(P, :value, eltypes, zeros(Int, K))
    quote
        $(Expr(:meta, :inline))
        offsets = addr.offsets
        $(binds...)
        $block
        nothing
    end
end

# Address groups are NamedTuples — `face => address` — so the name binding the
# wiring established is carried in the type and the gather reassembles the
# bundle the author destructures. A bare side is one address, no group: its
# bundle field is the cell's value and its stage returns that value (D-437).

@generated function gather_group(addrs::NamedTuple{Ns}, store) where {Ns}
    args = [:(gather_cell(store, addrs[$i])) for i in 1:length(Ns)]
    quote
        $(Expr(:meta, :inline))
        NamedTuple{$Ns}(($(args...),))
    end
end

# One bundle field off its side's addresses: a named side's `NamedTuple`, a bare
# side's value itself (§5.2, D-437).
@inline gather_input(addrs::NamedTuple, store) = gather_group(addrs, store)
@inline gather_input(addr::CellAddr, store) = gather_cell(store, addr)

# The same gather behind a function barrier, for the two bundles whose
# consumer writes a store by field store and nothing else, the update entry's
# and the handler's (executor.jl). Julia 1.13 runs its escape analysis on a
# body whose only side effects are field stores, and that analysis costs about
# the cube of a value's leaf count when the value is built in the body from
# as many buffer loads: a 200-wide gather there compiled in 40 s. Behind the
# barrier the value arrives from a call and nothing is tracked. The call
# returns the value on the stack, allocating nothing, and costs about 3 ns
# per gathered side. Record: `design/reports/20261106_update_entry_escape_analysis/report.md`.
@noinline gather_input_barrier(addrs, store) = gather_input(addrs, store)

# §9.5's always-on check, decided at generation (D-235): the key sets must agree
# as sets, and each returned field must be a lawful arrival at its cell under
# the embed-accept relation. A conformant return type generates the straight
# stores below; a non-conformant one generates a throw, which is how the check
# costs nothing on the conformant path.
@generated function scatter_group!(store, addrs::NamedTuple{Ns}, y::NamedTuple{Ys},
                                   ::Type{T}, path::String, what::Symbol) where {Ns,Ys,T}
    Set(Ys) == Set(Ns) ||
        return :(throw(DiagnosticError(ConformanceFailure(
            path = path, what = String(what), reason = :field_set, shape = :ports,
            observed_fields = $(collect(Ys)), declared_fields = $(collect(Ns))))))
    statements = Expr[]
    for (i, port_name) in enumerate(Ns)
        declared = fieldtype(addrs, i).parameters[1]  # the cell's type, CellAddr{P,K}
        observed = fieldtype(y, port_name)
        _accepts(declared, observed, T) ||
            return :(throw(DiagnosticError(ConformanceFailure(
                path = path, what = String(what), reason = :field_type, shape = :ports,
                field = $(QuoteNode(port_name)), observed = $observed,
                declared = $declared, activation = $T))))
        push!(statements, :(scatter_cell!(store, addrs[$i], getfield(y, $(QuoteNode(port_name))))))
    end
    quote
        $(Expr(:meta, :inline))
        $(statements...)
        nothing
    end
end

# Its single-cell twin, a bare port's write (D-437): the return is the port's
# value, held to the cell's type by the same relation and decided at generation.
@generated function scatter_group!(store, addr::CellAddr{P,K}, y, ::Type{T}, path::String,
                                   what::Symbol) where {P,K,T}
    _accepts(P, y, T) ||
        return :(throw(DiagnosticError(ConformanceFailure(
            path = path, what = String(what), reason = :field_type, shape = :ports,
            field = $(QuoteNode(default_name(y_types))), observed = $y, declared = $P,
            activation = $T))))
    quote
        $(Expr(:meta, :inline))
        scatter_cell!(store, addr, y)
        nothing
    end
end

# One boundary's capture: fresh buffers, one allocation per boundary — the
# framework side of §9.8's scope, which carved publication and logging out.
capture_stores(bundle::StoreBundle) = StoreBundle(map(cs -> CellStore(copy(cs.buffer)), bundle.stores))

"""
The clock, in its own mutable cell so the zero-arg phase bodies can close over
it. `t` is a bundle field for every stage (§5.2's bundle law) and varies within
a step — RK stages evaluate at internal times. `t₀` anchors the indexed grid,
held exact (D-457): every instant the model knows exactly is `t₀` plus a whole
or fractional count of the lattice's unit, and its clock is the `Float64`
nearest it, computed from its index and never accumulated (§10.4, D-456). The
frame index `k` and the boundary ordinal are not the clock's: they are the
run's two counters (§12.6, D-317). `t` stays in the model's scalar, so a
`Dual` model takes `t0 = 0.25` alike (D-260). Where the origin is set,
`_set_origin!` puts it and the unit over one denominator `scale`, so a clock
is one integer multiply-add and one division: `origin = t₀·scale` and
`unit = unit·scale`, in `Int128`.
"""
mutable struct Clock{T}
    t::T
    t₀::Rational{Int}   # the origin, exact (D-457)
    origin::Int128      # `t₀` over the common denominator
    unit::Int128        # the lattice's unit over it
    scale::Int128       # the common denominator
end
Clock{T}() where {T} = Clock{T}(zero(T), 0//1, Int128(0), Int128(0), Int128(1))

# The origin and the unit over one denominator (D-457), computed where the
# origin is set and never in the loop. A product past `Int128` throws
# `OverflowError`, which the doors refuse before they write (`_clock_integers`).
function _grid_integers(t₀::Rational{Int}, unit::Rational{Int})
    scale = lcm(Int128(denominator(t₀)), Int128(denominator(unit)))
    Base.Checked.checked_mul(Int128(numerator(t₀)), div(scale, denominator(t₀))),
        Base.Checked.checked_mul(Int128(numerator(unit)), div(scale, denominator(unit))), scale
end

# Boundary zero's clock is `_instant`'s at position 0, as every later one is (D-458).
function _set_origin!(clock::Clock{T}, t₀::Rational{Int}, unit::Rational{Int}) where {T}
    (clock.origin, clock.unit, clock.scale) = _grid_integers(t₀, unit)
    clock.t₀ = t₀
    clock.t = T(_instant(clock, 0))
    nothing
end
# The float a reader of an origin takes: boundary zero's clock (D-458), the
# float nearest the exact origin. `Float64(t₀)` divides the two rounded parts,
# and sits an ulp off it for some origins whose parts pass `2^53`. A frame
# count taken from a clock reads the clock as it stands.
_origin_clock(t₀::Rational{Int}) = _nearest(Int128(numerator(t₀)), Int128(denominator(t₀)))
_origin_clock(t::Float64) = t
# The float nearest the exact instant `t₀ + (position + i·units/steps)·unit`
# (D-456, D-458), from the grid integers: `position` whole units from the origin, and
# `i` of `steps` equal steps across a span of `units` past it. `count` stays
# below `2^127`, so it never wraps. `mul` and `add` are the plain operators in
# the loop, and the checked ones at the door, which refuses an origin whose run
# the integers cannot carry (D-457, `_clock_integers`).
@inline function _instant(origin::Int128, unit::Int128, scale::Int128, position::Int,
                          i::Int = 0, units::Int = 0, steps::Int = 1, mul = *, add = +)
    count = Int128(position) * steps + Int128(i) * units
    _nearest(add(mul(origin, steps), mul(unit, count)), mul(scale, steps))
end

# The float nearest `dividend / divisor`, `divisor > 0`. While both stay within
# `2^53` they convert exactly and one division rounds to nearest; past it the
# division is `_rounded_quotient`'s (D-458).
const MAX_EXACT_INTEGER = Int128(2)^53
@inline _nearest(dividend::Int128, divisor::Int128) =
    -MAX_EXACT_INTEGER ≤ dividend ≤ MAX_EXACT_INTEGER && divisor ≤ MAX_EXACT_INTEGER ?
    Float64(dividend) / Float64(divisor) : _rounded_quotient(dividend, divisor)

# The long division past `2^53` (D-458), in `UInt128` so nothing allocates:
# the integer quotient, extended a chunk at a time until it holds 55 bits, each
# chunk as wide as the remainder can shift without leaving `UInt128`. The remainder
# then folds into the quotient's last bit, below the rounding bit, and the
# one conversion rounds to nearest. An exact quotient stops early.
@noinline function _rounded_quotient(dividend::Int128, divisor::Int128)
    quotient, remainder = divrem(unsigned(abs(dividend)), unsigned(divisor))
    exponent = 0
    while quotient < UInt128(1) << 54 && remainder != 0
        shift = min(leading_zeros(remainder), leading_zeros(quotient) - 73)
        next_bits, remainder = divrem(remainder << shift, unsigned(divisor))
        quotient = quotient << shift | next_bits
        exponent -= shift
    end
    magnitude = ldexp(Float64(quotient | (remainder != 0)), exponent)
    dividend < 0 ? -magnitude : magnitude
end
@inline _instant(clock::Clock, position::Int, i::Int = 0, units::Int = 0, steps::Int = 1) =
    _instant(clock.origin, clock.unit, clock.scale, position, i, units, steps)

"The activation scalar an executor runs at, read off its clock (§9.4)."
activation_scalar(::Clock{T}) where {T} = T
