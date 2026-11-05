# List the docstrings on the API page, submodules included, with the sheet's
# mechanical checks. Run from the repository root:
#   julia --startup-file=no --project=test design/tools/docstring_roster.jl roster.tsv
using Redstone
import Base.Docs

entries = String[]
for m in eachmatch(r"```@docs\n(.*?)```"s, read("docs/src/api.md", String))
    append!(entries, filter(!isempty, strip.(split(m[1], '\n'))))
end
wanted = Set(Symbol(last(split(first(split(e, '(')), '.'))) for e in entries)

docs = NamedTuple[]
for m in Docs.modules
    (m === Redstone || parentmodule(m) === Redstone) || continue
    for (b, md) in Docs.meta(m), (_, d) in md.docs
        b.var in wanted || continue
        path = String(get(d.data, :path, ""))
        occursin("/src/", path) || continue
        push!(docs, (file = basename(path), line = get(d.data, :linenumber, 0),
                     name = b.var, text = join(string.(d.text))))
    end
end
unique!(d -> (d.file, d.line), docs)
sort!(docs; by = d -> (d.file, d.line))

rendered(s) = replace(s, r"\[([^\]]*)\]\(@ref[^)]*\)" => s"\1")
function summary(text)
    ls = split(text, '\n')
    i = findfirst(l -> !startswith(l, "    ") && !isempty(strip(l)), ls)
    i === nothing && return ""
    j = something(findnext(l -> isempty(strip(l)), ls, i), length(ls) + 1)
    join(ls[i:j-1], ' ')
end
wc(s) = length(split(s))

open(ARGS[1], "w") do io
    println(io, "file\tline\tname\twords\tsummary_words")
    for d in docs
        println(io, join((d.file, d.line, d.name, wc(d.text), wc(rendered(summary(d.text)))), '\t'))
    end
end

println(length(entries), " entries, ", length(docs), " docstrings, ",
        sum(wc(d.text) for d in docs), " words")
found = Set(d.name for d in docs)
println("entries with no docstring found: ", sort!(collect(setdiff(wanted, found))))
checks = [
    "forbidden token" => d -> occursin(r"§|D-[0-9]|FlightCore|Flight\.jl|\b\w+\.md\b", d.text),
    "em dash" => d -> occursin('—', d.text),
    "arrow" => d -> occursin('→', d.text),
    "summary at twenty words" => d -> wc(rendered(summary(d.text))) >= 20,
    "no signature first" => d -> !startswith(d.text, "    "),
    "prose after # Keywords" =>
        d -> occursin(r"# Keywords\n\n(?!- )\S", d.text) ||
             occursin(r"# Keywords\n\n(?:(?:- |  ).*\n)*\n(?!#|See also|\s*$)\S", d.text),
]
for (label, bad) in checks
    println(rpad(label, 26), [d.name for d in docs if bad(d)])
end
