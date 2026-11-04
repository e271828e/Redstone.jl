using Redstone
import Base.Docs
api = read("docs/src/api.md", String)
names_on_page = String[]
for m in eachmatch(r"```@docs\n(.*?)```"s, api)
    append!(names_on_page, filter(!isempty, strip.(split(m[1], '\n'))))
end
rows = Tuple{String,Int,String,Int,Int}[]
missing_names = String[]
for entry in names_on_page
    expr = Meta.parse(entry)
    base = expr isa Expr && expr.head == :call ? expr.args[1] : expr
    mod = Redstone
    obj = try Core.eval(Redstone, base) catch; nothing end
    obj === nothing && (push!(missing_names, entry); continue)
    b = base isa Symbol ? Docs.Binding(Redstone, base) : Docs.Binding(Core.eval(Redstone, base.args[1]), base.args[2].value)
    b = Docs.aliasof(b)
    found = false
    for m in Docs.modules
        d = Docs.meta(m)
        haskey(d, b) || continue
        for (sig, doc) in d[b].docs
            p = String(get(doc.data, :path, "?"))
            occursin("/src/", p) || continue
            txt = join(string.(doc.text))
            push!(rows, (basename(p), get(doc.data, :linenumber, 0), string(b.var), length(split(txt, '\n')), length(split(txt))))
            found = true
        end
    end
    found || push!(missing_names, entry)
end
sort!(unique!(rows))
open(ARGS[1], "w") do io; for r in rows; println(io, join(r, '\t')); end; end
println(length(names_on_page), " entries; ", length(rows), " docstrings; missing: ", missing_names)
files = Dict{String,Tuple{Int,Int}}()
for r in rows
    a = get(files, r[1], (0,0)); files[r[1]] = (a[1]+1, a[2]+r[5])
end
for (f,(n,w)) in sort(collect(files); by = x -> -x[2][2]); println(rpad(f,18), lpad(n,4), lpad(w,7)); end
