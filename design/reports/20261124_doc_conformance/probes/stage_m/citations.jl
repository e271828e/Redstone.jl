# Item 6: check the `§N` and `D-nnn` citations in the Julia files. Prints a TSV:
#   no-section   a `§N` the spec's headings do not number
#   no-entry     a `D-nnn` the log has no entry for
#   superseded   a `D-nnn` whose entry is superseded, with its successor
# Whether a citation names the right topic is left to the coverage agents.
include("corpus.jl")

secs = Set{String}()
for l in eachline("design/spec.md")
    m = match(r"^#+ (?:Appendix )?(\d+(?:\.\d+)*|[A-D](?:\.\d+)?)[. ]", l)
    m === nothing || push!(secs, m[1])
end
status = Dict(id => st for (id, st, _, _) in log_entries())

tsv("tier", "file", "line", "cite", "detail")
for d in ("src", "ext", "test", "examples"), (root, _, files) in walkdir(d), f in sort(files)
    endswith(f, ".jl") || continue
    path = joinpath(root, f)
    for (i, l) in enumerate(eachline(path))
        for m in eachmatch(r"§([0-9]+(?:\.[0-9]+)*|[A-D](?:\.[0-9]+)?)", l)
            m[1] in secs || tsv("no-section", path, i, "§" * m[1], "")
        end
        for m in eachmatch(r"\bD-(\d+)\b", l)
            id = "D-" * lpad(m[1], 3, '0')
            st = get(status, id, nothing)
            if st === nothing
                tsv("no-entry", path, i, id, "")
            elseif !startswith(st, "ratified")
                tsv("superseded", path, i, id, st)
            end
        end
    end
end
