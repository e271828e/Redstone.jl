# Item 3: compare the keyword arguments of Appendix B's signatures with the
# package's methods, in both directions. Prints a TSV:
#   unparsed    a call-shaped span Meta.parse refused
#   unresolved  a called name no package module defines
#   doc-only    a keyword the appendix lists and no method takes
#   code-only   a keyword a method takes and no appendix span lists
include("corpus.jl")

line0, text = section("design/spec.md", "## Appendix B", "## Appendix C")

ownmod(m) = m === Redstone || parentmodule(m) === Redstone
function code_kwargs(f)
    ks = Set{Symbol}()
    for m in methods(f)
        ownmod(m.module) || continue
        union!(ks, filter(k -> !endswith(String(k), "..."), Base.kwarg_decl(m)))
    end
    ks
end

callname(e) = e isa Symbol ? e : (e isa Expr && e.head === :. ? callname(e.args[2]) :
                                  e isa QuoteNode ? e.value : nothing)
kwname(e) = e isa Symbol ? e : (e isa Expr && e.head in (:kw, :(=), :(::)) ? kwname(e.args[1]) : nothing)

listed = Dict{Symbol,Set{Symbol}}()
lines = Dict{Symbol,Int}()
tsv("tier", "line", "name", "detail")
for (line, span) in spans(text, line0)
    occursin(r"^[\p{L}_][\p{L}\p{N}_!.]*\(", span) || continue
    sig = replace(span, r"\s*→.*$" => "", r"\[,[^\]]*\]" => "", r";\s*…" => "", "…" => "x")
    ex = try Meta.parse(sig) catch; nothing end
    if !(ex isa Expr && ex.head === :call)
        tsv("unparsed", line, span, "")
        continue
    end
    f = callname(ex.args[1])
    f === nothing && continue
    get!(lines, f, line)
    kws = get!(listed, f, Set{Symbol}())
    for a in ex.args[2:end]
        a isa Expr && a.head === :parameters || continue
        for p in a.args
            p isa Expr && p.head === :... && continue
            k = kwname(p)
            k === nothing || push!(kws, k)
        end
    end
end
for f in sort!(collect(keys(listed)))
    m = findfirst(M -> isdefined(M, f), MODS)
    if m === nothing
        tsv("unresolved", lines[f], f, "")
        continue
    end
    code = code_kwargs(getfield(MODS[m], f))
    for k in sort!(collect(setdiff(listed[f], code)))
        tsv("doc-only", lines[f], f, k)
    end
    for k in sort!(collect(setdiff(code, listed[f])))
        tsv("code-only", lines[f], f, k)
    end
end
