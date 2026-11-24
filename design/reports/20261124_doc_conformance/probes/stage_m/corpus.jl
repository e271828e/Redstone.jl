# Shared readers for the Stage M scripts. Run from the repository root of the
# pinned worktree, under the test project with the load path `@`.
using Redstone
import Base.Docs
const JS = Base.JuliaSyntax

isfile("Project.toml") && isdir("design") || error("run from the repository root")

const MODS = (Redstone, Redstone.Library)
const IDENT = r"[\p{L}_][\p{L}\p{N}_!′]*"

mdfiles(dir) = sort(filter(endswith(".md"), readdir(dir; join = true)))

# The audited Markdown, glossary.md left out: it is generated from Appendix D.
doc_files() = vcat(["design/spec.md", "design/code_map.md", "README.md"],
                   mdfiles("design/companions"),
                   filter(!endswith("glossary.md"), mdfiles("docs/src")),
                   mdfiles("docs/src/tutorial"))

# The text with fenced blocks blanked, newlines kept, so offsets keep their lines.
function unfenced(text)
    infence = false
    lines = map(split(text, '\n')) do l
        if startswith(lstrip(l), "```")
            infence = !infence
            return ""
        end
        infence ? "" : l
    end
    join(lines, '\n')
end

# Inline code spans as (line, span), a span wrapped across lines joined.
function spans(text, line0 = 1)
    t = unfenced(text)
    nl = findall(==('\n'), t)
    out = Tuple{Int,String}[]
    for m in eachmatch(r"`([^`]+)`", t)
        s = m.captures[1]
        occursin("\n\n", s) && continue
        push!(out, (line0 + searchsortedlast(nl, m.offset), replace(s, r"\s*\n\s*" => " ")))
    end
    out
end

# The lines from the heading that starts with `from` to the one before `to`.
function section(path, from, to)
    lines = readlines(path)
    i = findfirst(startswith(from), lines)
    j = findnext(startswith(to), lines, i + 1)
    (i, join(lines[i:j-1], '\n'))
end

# Every log entry as (id, status, first line of Position, Position text).
function log_entries(path = "design/log.md")
    lines = readlines(path)
    heads = [i for (i, l) in enumerate(lines) if startswith(l, "### D-")]
    out = Tuple{String,String,Int,String}[]
    for (k, i) in enumerate(heads)
        stop = k < length(heads) ? heads[k+1] - 1 : length(lines)
        body = i:stop
        st = findfirst(j -> startswith(lines[j], "**Status.**"), body)
        p0 = findfirst(j -> startswith(lines[j], "**Position.**"), body)
        (st === nothing || p0 === nothing) && continue
        p0 = body[p0]
        p1 = findnext(l -> occursin(r"^\*\*[A-Z][a-z]+\.\*\*", l), lines, p0 + 1)
        p1 = p1 === nothing || p1 > stop ? stop : p1 - 1
        status = strip(replace(lines[body[st]], "**Status.**" => ""))
        push!(out, (match(r"D-\d+", lines[i]).match, status, p0, join(lines[p0:p1], '\n')))
    end
    out
end

# Every docstring of the package's modules as (file, line, text).
function docstrings()
    out = Tuple{String,Int,String}[]
    for m in Docs.modules
        (m === Redstone || parentmodule(m) === Redstone) || continue
        for (_, md) in Docs.meta(m), (_, d) in md.docs
            path = String(get(d.data, :path, ""))
            occursin("/src/", path) || continue
            push!(out, (relpath(path), get(d.data, :linenumber, 0), join(string.(d.text))))
        end
    end
    sort!(unique!(out))
end

# The identifiers in the Julia files under `dirs`, comments and strings excluded.
function code_idents(dirs)
    s = Set{String}()
    for d in dirs
        isdir(d) || continue
        for (root, _, files) in walkdir(d), f in files
            endswith(f, ".jl") || continue
            src = read(joinpath(root, f), String)
            cu = codeunits(src)
            for t in JS.tokenize(src)
                JS.kind(t) == JS.Kind("Identifier") && push!(s, String(cu[t.range]))
            end
        end
    end
    s
end

# Every text unit the name checks read, as (file, first line, text).
function units()
    u = Tuple{String,Int,String}[(f, 1, read(f, String)) for f in doc_files()]
    for (id, status, line, text) in log_entries()
        startswith(status, "ratified") && push!(u, ("design/log.md", line, text))
    end
    for (file, line, text) in docstrings()
        push!(u, (file, line + 1, text))
    end
    u
end

tsv(fields...) = println(join(map(f -> replace(string(f), r"[\t\n]" => " "), fields), '\t'))
