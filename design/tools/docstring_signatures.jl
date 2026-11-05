# Compare each docstring's signature lines with the methods they describe. It
# prints candidates for a reader, not verdicts: rules 10 to 14 hide methods on
# purpose. Run from the repository root:
#   julia --startup-file=no --project=test design/tools/docstring_signatures.jl
using Redstone
import Base.Docs

entries = String[]
for m in eachmatch(r"```@docs\n(.*?)```"s, read("docs/src/api.md", String))
    append!(entries, filter(!isempty, strip.(split(m[1], '\n'))))
end
wanted = Set(Symbol(last(split(first(split(e, '(')), '.'))) for e in entries)

# The indented lines above the summary, a wrapped line joined to its head.
function sig_lines(text)
    out = String[]
    for l in split(text, '\n')
        startswith(l, "    ") || break
        if startswith(l, "     ") && !isempty(out)
            out[end] *= " " * strip(l)
        else
            push!(out, strip(l))
        end
    end
    out
end

argname(a::Symbol) = a
argname(a::Expr) = a.head in (:kw, :(=), :(::), :...) ? argname(a.args[1]) : nothing
argname(a) = nothing

function parse_sig(line)
    ex = try Meta.parse(first(split(line, r"\s+(->|where)\s+"))) catch; return nothing end
    (ex isa Symbol || (ex isa Expr && ex.head == :curly)) && return :type
    ex isa Expr && ex.head == :call || return nothing
    kws, pos = Symbol[], 0
    for a in ex.args[2:end]
        if a isa Expr && a.head == :parameters
            append!(kws, filter(!isnothing, argname.(a.args)))
        else
            pos += 1
        end
    end
    (; kws, pos)
end

bullets(text) = begin
    i = findfirst("# Keywords", text)
    i === nothing ? Symbol[] :
        [Symbol(m[1]) for m in eachmatch(r"^- `([^`]+)`"m, text[last(i):end])]
end

for m in Docs.modules
    (m === Redstone || parentmodule(m) === Redstone) || continue
    for (b, md) in Docs.meta(m)
        b.var in wanted || continue
        obj = try getfield(b.mod, b.var) catch; continue end
        ms = try collect(methods(obj)) catch; continue end
        ms = [x for x in ms if parentmodule(x) === m || parentmodule(x) === Redstone || occursin("/src/", string(x.file))]
        decl = [Base.kwarg_decl(x) for x in ms]
        splat = any(any(endswith(string(k), "...") for k in d) for d in decl)
        accepted = Set(Symbol(k) for d in decl for k in d)
        arities = Set(x.nargs - 1 for x in ms)
        va = any(x.isva for x in ms)
        shown_all = Symbol[]
        for (_, d) in md.docs
            path = String(get(d.data, :path, ""))
            occursin("/src/", path) || continue
            text = join(string.(d.text))
            loc = string(basename(path), ":", get(d.data, :linenumber, 0), " ", b.var)
            shown = Symbol[]
            for l in sig_lines(text)
                p = parse_sig(l)
                p === :type && continue
                p === nothing && (println(loc, ": unparsed signature: ", l); continue)
                append!(shown, p.kws)
                !va && !isempty(ms) && !(p.pos in arities) &&
                    println(loc, ": ", p.pos, " positional, methods take ", sort!(collect(arities)), ": ", l)
            end
            listed = bullets(text)
            splat || (x = setdiff(shown, accepted); isempty(x) || println(loc, ": shown, not accepted: ", x))
            x = setdiff(listed, shown); isempty(x) || println(loc, ": listed, not on a signature: ", x)
            x = setdiff(shown, listed); isempty(x) || println(loc, ": on a signature, not listed: ", x)
            append!(shown_all, shown)
        end
        x = setdiff(filter(k -> !endswith(string(k), "..."), accepted), shown_all)
        isempty(x) || println(b.var, ": accepted, on no signature: ", sort!(collect(x)))
    end
end
