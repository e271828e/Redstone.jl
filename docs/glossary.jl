# Generates docs/src/glossary.md from Appendix D of design/spec.md.
# Reads from the appendix heading to the spec's citation link definitions.
# Writes one section per D.n group and one anchored paragraph per entry.
# Skips the meta-vocabulary group, which defines the spec's own conventions.
# Strips spec citations and turns glossary cross-links into @ref links.

# A reference-style cite of a spec section, appendix or decision entry.
const CITE = r"\[([^\]]+)\]\[(?:s[0-9A-Z-]*|d-\d+)\]"
# A parenthesised group with its leading whitespace.
const GROUP = r"(\s*)\(([^()]*)\)"

function strip_cites(text)
    # Hide glossary links so their parentheses do not read as groups.
    text = replace(text, r"\[([^\]]+)\]\(#(g-[a-z0-9-]+)\)" => s"\x01\1\x02\2\x03")
    # Drop cites inside parentheses, then any group left empty.
    text = replace(text, GROUP => function (g)
        m = match(GROUP, g)
        occursin(CITE, m[2]) || return g
        inner = replace(m[2], Regex("[,;]?\\s*" * CITE.pattern) => "")
        inner = strip(lstrip(inner, [',', ';', ' ']))
        isempty(inner) ? "" : string(m[1], "(", inner, ")")
    end)
    # A cite left in running prose is part of the sentence; keep its text.
    text = replace(text, CITE => s"\1")
    text = replace(text, r"\x01([^\x02]*)\x02([^\x03]*)\x03" => s"[\1](@ref \2)")
    occursin(r"\]\[|\]\((?!@ref )", text) &&
        error("glossary: unrecognised link form in: ", text)
    return text
end

function write_glossary(spec, out)
    lines = readlines(spec)
    lo = findfirst(==("## Appendix D. Glossary"), lines)
    hi = findnext(l -> startswith(l, "## ") || startswith(l, "<!-- citation link"),
                    lines, lo + 1) - 1
    # Split the appendix into paragraphs, each joined into one line.
    paras = String[]
    buf = String[]
    for l in [lines[lo+1:hi]; ""]
        if isempty(strip(l))
            isempty(buf) || push!(paras, join(strip.(buf), " "))
            empty!(buf)
        else
            push!(buf, l)
        end
    end
    open(out, "w") do io
        println(io, "# Glossary\n")
        println(io, "This is the vocabulary the reference uses, generated from the ",
                "design's glossary.")
        skip = false
        for p in paras
            if (m = match(r"^### D\.\d+ (.+)$", p)) !== nothing
                skip = m[1] == "Meta-vocabulary"
                skip || println(io, "\n## ", m[1])
            elseif skip
                continue
            elseif (m = match(r"^<a id=\"(g-[^\"]+)\"></a>(.*)$", p)) !== nothing
                println(io, "\n[](@id ", m[1], ") ", strip_cites(m[2]))
            end
        end
    end
    return out
end
