# Item 5: compare §13.9 with the schema of record, `src/descriptor.json`.
# Prints a TSV:
#   doc-only     a quoted string in §13.9's code spans the schema never names
#   unmentioned  a schema property §13.9 never names as a word
include("corpus.jl")
using JSON

schema = JSON.parsefile("src/descriptor.json")
props = Dict{String,Set{String}}()   # definition => its property names
function collect_props!(where, node)
    node isa AbstractDict || (node isa AbstractVector && foreach(n -> collect_props!(where, n), node); return)
    if haskey(node, "properties")
        union!(get!(props, where, Set{String}()), keys(node["properties"]))
    end
    for (k, v) in node
        k == "definitions" && continue
        collect_props!(where, v)
    end
end
collect_props!("(root)", schema)
for (name, def) in schema["definitions"]
    collect_props!(name, def)
    get!(props, name, Set{String}())
end
strings(n) = n isa AbstractDict ? union(Set(keys(n)), strings.(values(n))...) :
             n isa AbstractVector ? union(Set{String}(), strings.(n)...) :
             n isa AbstractString ? Set([n]) : Set{String}()
known = strings(schema)

line0, text = section("design/spec.md", "### 13.9", "## 14.")
words = Set(m.match for m in eachmatch(IDENT, text))

tsv("tier", "line", "name", "detail")
for (line, span) in spans(text, line0), m in eachmatch(r"\"([\p{L}_][\p{L}\p{N}_]*)\"", span)
    m[1] in known || tsv("doc-only", line, m[1], span)
end
for def in sort!(collect(keys(props)))
    for p in sort!(collect(props[def]))
        p in words || tsv("unmentioned", "", "$def.$p", "property")
    end
end
