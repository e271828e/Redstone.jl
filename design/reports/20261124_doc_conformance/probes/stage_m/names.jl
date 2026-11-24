# Item 1: resolve the names in the docs' code spans against the code.
# Prints a TSV of candidates, one row per (tier, file, name):
#   missing      no Julia file in the tree has the identifier
#   test-only    only test/ has it
#   no-binding   `M.x` with M a package module that does not define x
#   no-field     `T.x` with T a package type that has no field x
# A candidate is a lead for an agent, not a verdict.
include("corpus.jl")

const PKG = code_idents(["src", "ext", "examples/src"])
const TST = code_idents(["test", "examples/test"])
const LOADED = Base.loaded_modules_array()

const KEYWORDS = Set(split("true false nothing missing import using export public try catch finally " *
    "const else elseif end function struct mutable abstract primitive type module baremodule begin " *
    "let local global return for while if do quote macro break continue where in isa outer"))
const FILES = Set(["jl", "md", "toml", "json", "txt", "pdf", "tsv"])

codey(w) = occursin('_', w) || endswith(w, '!') || occursin(r"\p{Ll}\p{Lu}", w)
external(w) = any(m -> isdefined(m, Symbol(w)), LOADED)

function lookup(path)
    v = nothing
    for (k, seg) in enumerate(path)
        s = Symbol(seg)
        if k == 1
            m = findfirst(M -> isdefined(M, s), MODS)
            m === nothing && return nothing
            v = getfield(MODS[m], s)
        elseif v isa Module
            isdefined(v, s) || return (:no_binding, v)
            v = getfield(v, s)
        elseif v isa DataType && isstructtype(v)
            s in fieldnames(v) || return (:no_field, v)
            return nothing
        else
            return nothing
        end
    end
    nothing
end

# The candidates of one span: its head path, and every other codey token.
function candidates(span)
    s = lstrip(span, ':')
    (startswith(s, '"') || (occursin('/', s) && !occursin('(', s))) && return Vector{String}[]
    out = Vector{String}[]
    h = match(Regex("^@?(" * IDENT.pattern * "(?:\\." * IDENT.pattern * ")*)"), s)
    if h !== nothing
        path = split(h[1], '.')
        (length(path) > 1 || length(h[1]) >= 3 || codey(h[1])) && push!(out, path)
    end
    for m in eachmatch(IDENT, s)
        codey(m.match) && !any(p -> m.match in p, out) && push!(out, [m.match])
    end
    out
end

function tier(path)
    (path[end] in KEYWORDS || (length(path) > 1 && path[end] in FILES)) && return nothing
    r = lookup(path)
    r !== nothing && return String(r[1])
    w = path[end]
    (w in PKG || external(w)) && return nothing
    w in TST ? "test-only" : "missing"
end

rows = Dict{Tuple{String,String,String},Vector{Int}}()
for (file, line0, text) in units(), (line, span) in spans(text, line0), path in candidates(span)
    t = tier(path)
    t === nothing && continue
    push!(get!(rows, (t, file, join(path, '.')), Int[]), line)
end
tsv("tier", "file", "name", "lines")
for k in sort!(collect(keys(rows)))
    tsv(k..., join(unique(rows[k]), ','))
end
