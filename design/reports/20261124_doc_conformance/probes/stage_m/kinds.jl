# Item 4: compare Appendix C's kind set with the code's, in both directions,
# severity included. Prints a TSV:
#   doc-only       a kind the appendix lists and the code does not define
#   code-only      a concrete `Diagnostic` subtype the appendix does not list
#   severity       the appendix's severity differs from `severity`'s method
#   no-severity    an appendix entry with no `Error ·` or `Warning ·`
include("corpus.jl")

const D = Redstone.Diagnostic
line0, text = section("design/spec.md", "## Appendix C", "## Appendix D")

doc = Dict{String,Tuple{Int,String}}()
lines = split(text, '\n')
for (i, l) in enumerate(lines)
    m = match(r"^- \*\*`(\w+)`\*\*", l)
    m === nothing && continue
    j = findnext(l -> startswith(l, "- ") || isempty(strip(l)), lines, i + 1)
    entry = join(lines[i:(j === nothing ? length(lines) : j - 1)], ' ')
    s = match(r"\b(Error|Warning) ·", entry)
    doc[m[1]] = (line0 + i - 1, s === nothing ? "" : lowercase(s[1]))
end

concrete(T) = isconcretetype(T) ? [T] : reduce(vcat, concrete.(subtypes(T)); init = Any[])
using InteractiveUtils: subtypes
code = Dict(String(nameof(T)) => T for T in concrete(D))

warns = Set{Any}()
for m in methods(Redstone.severity)
    T = m.sig.parameters[2]
    T === D || push!(warns, T)
end
sev(T) = any(W -> T <: W, warns) ? "warning" : "error"

tsv("tier", "line", "kind", "detail")
for k in sort!(collect(setdiff(keys(doc), keys(code))))
    tsv("doc-only", doc[k][1], k, "")
end
for k in sort!(collect(setdiff(keys(code), keys(doc))))
    tsv("code-only", "", k, parentmodule(code[k]))
end
for k in sort!(collect(intersect(keys(doc), keys(code))))
    line, s = doc[k]
    if isempty(s)
        tsv("no-severity", line, k, "")
    elseif s != sev(code[k])
        tsv("severity", line, k, "appendix $s, code $(sev(code[k]))")
    end
end
