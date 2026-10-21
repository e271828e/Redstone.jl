# Dependency audit of a Julia package's src/ directory.
# Usage: julia --startup-file=no audit.jl <repo> [--dsm] [--envy] [--scatter] [--cycles] [--clusters] [--git] [--all]
const REPO = ARGS[1]
const SRC = joinpath(REPO, "src")
const FLAGS = length(ARGS) > 1 ? Set(ARGS[2:end]) : Set(["--all"])
want(f) = "--all" in FLAGS || f in FLAGS

order = [m.captures[1] for m in eachmatch(r"include\(\"(.*?)\"\)", read(joinpath(SRC, "Redstone.jl"), String))]
files = order
fidx = Dict(f => i for (i, f) in enumerate(files))

struct Def
    name::Symbol
    kind::Symbol
    file::String
    line::Int
    ex::Any
end
defs = Def[]

function callname(ex)
    ex isa Symbol && return ex
    ex isa Expr || return nothing
    if ex.head in (:where, :call, :curly)
        return callname(ex.args[1])
    elseif ex.head == :(::)
        t = ex.args[end]
        if t isa Expr && t.head == :curly && t.args[1] == :Type
            return callname(t.args[2])
        end
        return callname(t)
    elseif ex.head == :.
        return Symbol(string(ex.args[1]), ".", ex.args[2].value)
    end
    nothing
end
typename(ex) = ex isa Symbol ? ex :
    ex isa Expr && ex.head in (:(<:), :curly) ? typename(ex.args[1]) : nothing

function harvest!(ex, file, line)
    ex isa Expr || return
    h = ex.head
    if h in (:toplevel, :block)
        for a in ex.args
            a isa LineNumberNode ? (line = a.line) : harvest!(a, file, line)
        end
    elseif h == :macrocall
        for a in ex.args[2:end]
            a isa LineNumberNode ? (line = a.line) : harvest!(a, file, line)
        end
    elseif h == :function
        n = callname(ex.args[1]); n === nothing && return
        push!(defs, Def(n, :function, file, line, ex))
    elseif h == :(=) && ex.args[1] isa Expr && ex.args[1].head in (:call, :where)
        n = callname(ex.args[1]); n === nothing && return
        push!(defs, Def(n, :function, file, line, ex))
    elseif h == :struct
        push!(defs, Def(typename(ex.args[2]), :struct, file, line, ex))
    elseif h == :abstract
        push!(defs, Def(typename(ex.args[1]), :abstract, file, line, ex))
    elseif h == :primitive
        push!(defs, Def(typename(ex.args[1]), :primitive, file, line, ex))
    elseif h == :macro
        n = callname(ex.args[1]); n === nothing && return
        push!(defs, Def(Symbol("@", n), :macro, file, line, ex))
    elseif h == :const
        lhs = ex.args[1]
        if lhs isa Expr && lhs.head == :(=) && lhs.args[1] isa Symbol
            push!(defs, Def(lhs.args[1], :const, file, line, ex))
        end
    elseif h == :(=) && ex.args[1] isa Symbol
        push!(defs, Def(ex.args[1], :global, file, line, ex))
    elseif h in (:if, :for, :let, :quote, :elseif)
        for a in ex.args
            harvest!(a, file, line)
        end
    elseif h == :module
        harvest!(ex.args[3], file, line)
    end
end

for f in files
    harvest!(Meta.parseall(read(joinpath(SRC, f), String); filename=f), f, 0)
end

isqual(s) = occursin('.', string(s))
local_defs = filter(d -> !isqual(d.name), defs)
ext_defs = filter(d -> isqual(d.name), defs)

# inventory: name -> files defining it, and kinds
inv = Dict{Symbol,Vector{String}}()
kinds = Dict{Symbol,Set{Symbol}}()
for d in local_defs
    push!(get!(inv, d.name, String[]), d.file)
    push!(get!(kinds, d.name, Set{Symbol}()), d.kind)
end
foreach(v -> unique!(v), values(inv))


const TYPELIKE = Set([:struct, :abstract, :primitive, :const, :global, :macro])
typelike(s) = haskey(kinds, s) && !isempty(intersect(kinds[s], TYPELIKE))
bump!(acc, s) = (s isa Symbol && length(string(s)) > 1) && (acc[s] = get(acc, s, 0) + 1)
qual(ex) = ex isa Expr && ex.head == :. && length(ex.args) == 2 && ex.args[1] isa Symbol && ex.args[2] isa QuoteNode ?
    Symbol(ex.args[1], ".", ex.args[2].value) : nothing
function refs!(acc, ex)
    if ex isa Symbol
        typelike(ex) && bump!(acc, ex)
    elseif ex isa Expr
        h = ex.head
        if h == :call
            hd = ex.args[1]
            hd isa Symbol ? bump!(acc, hd) : (q = qual(hd); q === nothing ? refs!(acc, hd) : bump!(acc, q))
            foreach(a -> refs!(acc, a), ex.args[2:end])
        elseif h == :. && length(ex.args) == 2 && ex.args[2] isa Expr && ex.args[2].head == :tuple
            ex.args[1] isa Symbol ? bump!(acc, ex.args[1]) : refs!(acc, ex.args[1])
            refs!(acc, ex.args[2])
        elseif (q = qual(ex)) !== nothing
            bump!(acc, q)
        elseif h == :macrocall
            m = ex.args[1]
            m isa Symbol ? bump!(acc, m) : ((q = qual(m)) === nothing || bump!(acc, q))
            foreach(a -> refs!(acc, a), ex.args[2:end])
        elseif h == :kw
            refs!(acc, ex.args[2])
        else
            foreach(a -> refs!(acc, a), ex.args)
        end
    end
end

# node = (file, name); aggregate methods
nodes = Dict{Tuple{String,Symbol},Vector{Def}}()
for d in local_defs
    push!(get!(nodes, (d.file, d.name), Def[]), d)
end
for d in ext_defs
    push!(get!(nodes, (d.file, d.name), Def[]), d)
end

# symbol-level edges: node -> Dict{(tfile, tname) => weight}
nedges = Dict{Tuple{String,Symbol},Dict{Tuple{String,Symbol},Float64}}()
for (key, ds) in nodes
    acc = Dict{Symbol,Int}()
    for d in ds
        refs!(acc, d.ex)
    end
    out = Dict{Tuple{String,Symbol},Float64}()
    for (s, c) in acc
        s == key[2] && continue
        haskey(inv, s) || continue
        tf = inv[s]
        for f in tf
            out[(f, s)] = get(out, (f, s), 0.0) + c / length(tf)
        end
    end
    nedges[key] = out
end

# file-level DSM
n = length(files)
dsm = zeros(n, n)
for ((f, _), out) in nedges, ((tf, _), w) in out
    dsm[fidx[f], fidx[tf]] += w
end

short(f) = first(replace(f, ".jl" => ""), 6)

if want("--dsm")
    println("=== FILE DSM (row references column; weighted reference counts, include order) ===")
    print(rpad("", 13))
    for f in files; print(lpad(short(f), 7)); end
    println()
    for (i, f) in enumerate(files)
        print(rpad(f, 13))
        for j in 1:n
            v = dsm[i, j]
            print(lpad(i == j ? "·" : v == 0 ? "" : string(round(Int, v)), 7))
        end
        println()
    end
    println()
    println("=== PER-FILE SUMMARY ===")
    println(rpad("file", 14), lpad("defs", 6), lpad("nodes", 6), lpad("intern", 8), lpad("out", 6), lpad("in", 6), lpad("cohes", 7), "  fan-out files -> fan-in files")
    for (i, f) in enumerate(files)
        ndef = count(d -> d.file == f, defs)
        nnode = count(k -> k[1] == f, keys(nodes))
        intern = dsm[i, i]
        out = sum(dsm[i, :]) - intern
        inn = sum(dsm[:, i]) - intern
        coh = intern + out == 0 ? 0.0 : intern / (intern + out)
        fo = count(j -> j != i && dsm[i, j] > 0, 1:n)
        fi = count(j -> j != i && dsm[j, i] > 0, 1:n)
        println(rpad(f, 14), lpad(ndef, 6), lpad(nnode, 6), lpad(round(Int, intern), 8), lpad(round(Int, out), 6), lpad(round(Int, inn), 6), lpad(round(coh, digits=2), 7), "  $fo -> $fi")
    end
    println()
    # forward references in include order
    println("=== FORWARD REFERENCES (earlier file references a later file, include order) ===")
    fw = [(dsm[i, j], files[i], files[j]) for i in 1:n for j in i+1:n if dsm[i, j] > 0]
    sort!(fw, rev=true)
    for (w, a, b) in fw
        syms = String[]
        for ((f, nm), out) in nedges
            f == a || continue
            for ((tf, ts), _) in out
                tf == b && push!(syms, string(ts))
            end
        end
        println(rpad("$a -> $b", 32), lpad(round(Int, w), 5), "   ", join(sort(unique(syms)), " "))
    end
    println("total forward weight (include order): ", round(Int, sum(w for (w, _, _) in fw; init=0.0)))
    println()
end

if want("--cycles")
    println("=== STRONGLY CONNECTED FILE GROUPS (cycles) ===")
    # Tarjan
    index = zeros(Int, n); low = zeros(Int, n); onst = falses(n); st = Int[]; idx = Ref(0); sccs = Vector{Vector{Int}}()
    function strong(v)
        idx[] += 1; index[v] = idx[]; low[v] = idx[]; push!(st, v); onst[v] = true
        for w in 1:n
            (w == v || dsm[v, w] == 0) && continue
            if index[w] == 0
                strong(w); low[v] = min(low[v], low[w])
            elseif onst[w]
                low[v] = min(low[v], index[w])
            end
        end
        if low[v] == index[v]
            c = Int[]
            while true
                w = pop!(st); onst[w] = false; push!(c, w); w == v && break
            end
            push!(sccs, c)
        end
    end
    for v in 1:n; index[v] == 0 && strong(v); end
    for c in sccs
        length(c) > 1 || continue
        println("group: ", join(files[sort(c)], " "))
    end
    # a layering heuristic: repeatedly place the file with least out-weight into the unplaced set
    remaining = Set(1:n); layered = Int[]
    while !isempty(remaining)
        best = argmin(i -> (sum(dsm[i, j] for j in remaining if j != i; init=0.0), i), collect(remaining))
        push!(layered, best); delete!(remaining, best)
    end
    fwl = sum(dsm[layered[i], layered[j]] for i in 1:n for j in i+1:n)
    println("\nsuggested bottom-up order (forward weight $(round(Int, fwl))):")
    println("  ", join(files[layered], " "))
    println()
end

if want("--scatter")
    println("=== NAMES DEFINED IN MORE THAN ONE FILE (method count per file) ===")
    for (s, fs) in sort(collect(inv), by=x -> (-length(x[2]), string(x[1])))
        length(fs) > 1 || continue
        parts = ["$f:$(length(nodes[(f, s)]))" for f in sort(fs, by=f -> fidx[f])]
        println(rpad(string(s), 28), join(parts, " "))
    end
    println()
    println("=== EXTENSION METHODS (qualified names) BY FILE ===")
    byf = Dict{String,Vector{String}}()
    for d in ext_defs
        push!(get!(byf, d.file, String[]), string(d.name))
    end
    for f in files
        haskey(byf, f) || continue
        cnt = Dict{String,Int}()
        for s in byf[f]; cnt[s] = get(cnt, s, 0) + 1; end
        println(rpad(f, 14), join(["$k×$v" for (k, v) in sort(collect(cnt))], " "))
    end
    println()
end

if want("--envy")
    println("=== FEATURE-ENVY CANDIDATES (node references another file more than its own) ===")
    println("columns: file  name  kind  methods  own-refs  foreign-file:refs  | referenced-from files")
    callers = Dict{Tuple{String,Symbol},Dict{String,Float64}}()
    for ((f, nm), out) in nedges, (t, w) in out
        c = get!(callers, t, Dict{String,Float64}())
        c[f] = get(c, f, 0.0) + w
    end
    rows = []
    for ((f, nm), out) in nedges
        isqual(nm) && continue
        byfile = Dict{String,Float64}()
        for ((tf, _), w) in out
            byfile[tf] = get(byfile, tf, 0.0) + w
        end
        own = get(byfile, f, 0.0)
        foreign = [(w, tf) for (tf, w) in byfile if tf != f]
        isempty(foreign) && continue
        w, tf = maximum(foreign)
        w > own && w >= 3 || continue
        cs = get(callers, (f, nm), Dict{String,Float64}())
        cstr = join(["$k:$(round(Int, v))" for (k, v) in sort(collect(cs), by=x -> -x[2])], " ")
        push!(rows, (w - own, f, nm, first(kinds[nm]), length(nodes[(f, nm)]), own, tf, w, cstr))
    end
    sort!(rows, by=r -> (r[2], -r[1]))
    for r in rows
        println(rpad(r[2], 14), rpad(string(r[3]), 30), rpad(string(r[4]), 9), lpad(r[5], 3), lpad(round(Int, r[6]), 5), "  ", rpad("$(r[7]):$(round(Int, r[8]))", 22), " | ", r[9])
    end
    println()
end

if want("--clusters")
    println("=== INTERNAL CONNECTED COMPONENTS PER FILE (undirected, intra-file edges only) ===")
    for f in files
        ks = [k for k in keys(nodes) if k[1] == f]
        kid = Dict(k => i for (i, k) in enumerate(ks))
        parent = collect(1:length(ks))
        find(x) = parent[x] == x ? x : (parent[x] = find(parent[x]))
        for k in ks, (t, _) in get(nedges, k, Dict())
            haskey(kid, t) || continue
            a, b = find(kid[k]), find(kid[t])
            a != b && (parent[a] = b)
        end
        comps = Dict{Int,Vector{Symbol}}()
        for k in ks
            push!(get!(comps, find(kid[k]), Symbol[]), k[2])
        end
        cs = sort(collect(values(comps)), by=c -> -length(c))
        big = filter(c -> length(c) >= 2, cs)
        singles = length(cs) - length(big)
        println(f, ": ", length(ks), " nodes, ", length(cs), " components (", singles, " isolated)")
        for c in big
            println("   [", length(c), "] ", join(sort(string.(c)), " "))
        end
    end
    println()
end

if want("--git")
    println("=== CHANGE COUPLING (commits touching both files; src only) ===")
    log = read(`git -C $REPO log --name-only --pretty=format:%H -- src`, String)
    commits = Vector{Vector{String}}()
    local cur = String[]
    for line in split(log, '\n')
        if occursin(r"^[0-9a-f]{40}$", line)
            isempty(cur) || push!(commits, cur); cur = String[]
        elseif startswith(line, "src/") && endswith(line, ".jl")
            push!(cur, basename(line))
        end
    end
    isempty(cur) || push!(commits, cur)
    single = Dict{String,Int}(); pair = Dict{Tuple{String,String},Int}()
    for c in commits
        u = unique(c)
        for f in u; single[f] = get(single, f, 0) + 1; end
        for i in 1:length(u), j in i+1:length(u)
            k = tuple(sort([u[i], u[j]])...)
            pair[k] = get(pair, k, 0) + 1
        end
    end
    println("commits touching src: ", length(commits))
    println(rpad("pair", 32), lpad("both", 5), lpad("A", 5), lpad("B", 5), lpad("jacc", 6), "  static edges A->B / B->A")
    rows = [(v, k) for (k, v) in pair]
    sort!(rows, rev=true)
    for (v, (a, b)) in rows[1:min(40, end)]
        haskey(fidx, a) && haskey(fidx, b) || continue
        jac = round(v / (single[a] + single[b] - v), digits=2)
        ab = round(Int, dsm[fidx[a], fidx[b]]); ba = round(Int, dsm[fidx[b], fidx[a]])
        flag = ab + ba == 0 ? "  <-- no static link" : ""
        println(rpad("$a + $b", 32), lpad(v, 5), lpad(single[a], 5), lpad(single[b], 5), lpad(jac, 6), "  $ab / $ba", flag)
    end
    println()
end
