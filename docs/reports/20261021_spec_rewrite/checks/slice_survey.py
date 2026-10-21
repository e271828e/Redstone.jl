"""Write units/<U>/survey.md, a survey with the per-section blocks of other
sections reduced to stubs. From docs/spec_rewrite:

    python3 checks/slice_survey.py ch12 survey.md A 12.1 12.2

A `###` block whose heading names a section (`### §12.1 ...`) is kept when
the section is one of those listed, and stubbed otherwise. Blocks whose
heading names no section (Tally, Moves, Overlaps, ...) and every `##` part
are kept whole. So parts A and F shrink to the unit's sections and the
chapter-wide parts stay. The orchestrator still reads the whole survey.
"""
import os, re, sys

SEC = re.compile(r'^### (?:§|Section )?(\d+\.\d+)\b')


def slice(text, secs):
    out, lines, i, stubbed = [], text.split("\n"), 0, []
    while i < len(lines):
        m = SEC.match(lines[i])
        if not m or m.group(1) in secs:
            out.append(lines[i]); i += 1; continue
        j = i + 1
        while j < len(lines) and not re.match(r'^##? |^### ', lines[j]): j += 1
        out.append(lines[i]); out.append(f"(§{m.group(1)} is another unit's; see the full survey.)\n")
        stubbed.append(m.group(1)); i = j
    return "\n".join(out), stubbed


if __name__ == "__main__":
    root, survey, u, secs = os.path.abspath(sys.argv[1]), sys.argv[2], sys.argv[3], set(sys.argv[4:])
    text = open(os.path.join(root, survey)).read()
    sliced, stubbed = slice(text, secs)
    out = os.path.join(root, "units", u, "survey.md")
    head = f"<!-- Sliced from {survey} for unit {u} (§{', §'.join(sorted(secs))}) by checks/slice_survey.py. -->\n"
    open(out, "w").write(head + sliced)
    print(f"wrote {out}: {len(sliced.encode())} of {len(text.encode())} bytes; stubbed §{', §'.join(stubbed) or 'nothing'}")
