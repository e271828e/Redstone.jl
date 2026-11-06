# The update entry's shape with none of the framework: a wide value gathered
# from a Vector by an unrolled read and stored into a Ref, in a body whose
# only other writes are field stores. Needs StaticArrays and nothing else.
#
#     julia --startup-file=no --project=test repro_escape_analysis.jl
#
# Variant a is the shape; b to e each change one thing (report.md, section 2).
using StaticArrays

mutable struct Cursor; comp::Int; fn::Symbol; end
struct Addr{P}; offsets::Tuple{Int}; end
struct CellStore; buffer::Vector{Float64}; end
struct Bundle{NT}; stores::NT; end
struct Entry{SS, IA, YA}
    sstore::SS
    inputs::IA
    y::YA
    ci::Int
    cursor::Cursor
end
mutable struct Chunk{E, S}; entry::E; store::S; end

@generated function gather(bundle::Bundle, addr::Addr{P}) where {P}
    Expr(:block, Expr(:meta, :inline),
         :(offsets = addr.offsets),
         :(buffer1 = getfield(bundle.stores, :f).buffer),
         Expr(:call, P, [:(@inbounds buffer1[offsets[1] + $i]) for i in 1:length(P)]...))
end
@noinline gather_barrier(bundle, addr) = gather(bundle, addr)
@noinline store_barrier!(r, v) = (r[] = v; nothing)

# a: cursor stores, `u` and `y` gathered inline, `s` loaded, `u` stored as the successor
@inline function update_a(entry::Entry, store)
    entry.cursor.comp = entry.ci; entry.cursor.fn = :s_update
    nt = (s = entry.sstore[], u = gather(store, entry.inputs), y = gather(store, entry.y))
    entry.sstore[] = nt.u
    nothing
end
# b: the gathers behind a function barrier
@inline function update_b(entry::Entry, store)
    entry.cursor.comp = entry.ci; entry.cursor.fn = :s_update
    nt = (s = entry.sstore[], u = gather_barrier(store, entry.inputs), y = gather_barrier(store, entry.y))
    entry.sstore[] = nt.u
    nothing
end
# c: the store behind a function barrier instead
@inline function update_c(entry::Entry, store)
    entry.cursor.comp = entry.ci; entry.cursor.fn = :s_update
    nt = (s = entry.sstore[], u = gather(store, entry.inputs), y = gather(store, entry.y))
    store_barrier!(entry.sstore, nt.u)
    nothing
end
# d: a, plus a `donotdelete` on the successor
@inline function update_d(entry::Entry, store)
    entry.cursor.comp = entry.ci; entry.cursor.fn = :s_update
    nt = (s = entry.sstore[], u = gather(store, entry.inputs), y = gather(store, entry.y))
    Base.donotdelete(nt.u)
    entry.sstore[] = nt.u
    nothing
end
# e: a, with the store a one-element Vector instead of a Ref
@inline function update_e(entry::Entry, store)
    entry.cursor.comp = entry.ci; entry.cursor.fn = :s_update
    nt = (s = (@inbounds entry.sstore[1]), u = gather(store, entry.inputs), y = gather(store, entry.y))
    @inbounds entry.sstore[1] = nt.u
    nothing
end

# the chunk-like barrier the walk calls through
@noinline run_a(chunk::Chunk) = update_a(chunk.entry, chunk.store)
@noinline run_b(chunk::Chunk) = update_b(chunk.entry, chunk.store)
@noinline run_c(chunk::Chunk) = update_c(chunk.entry, chunk.store)
@noinline run_d(chunk::Chunk) = update_d(chunk.entry, chunk.store)
@noinline run_e(chunk::Chunk) = update_e(chunk.entry, chunk.store)

for N in (50, 100, 200, 400)
    P = SVector{N, Float64}
    store = Bundle((f = CellStore(zeros(2N)),))
    chunk = Chunk(Entry(Ref(zero(P)), Addr{P}((0,)), Addr{P}((N,)), 1, Cursor(0, :none)), store)
    vchunk = Chunk(Entry([zero(P)], Addr{P}((0,)), Addr{P}((N,)), 1, Cursor(0, :none)), store)
    print("N = $N")
    for (label, f, c) in (("a inline gathers", run_a, chunk), ("b gather barrier", run_b, chunk),
                          ("c store barrier", run_c, chunk), ("d donotdelete", run_d, chunk),
                          ("e Vector store", run_e, vchunk))
        print("  |  ", label, " ", round((@elapsed precompile(f, (typeof(c),))); digits = 2), " s")
    end
    println()
end
