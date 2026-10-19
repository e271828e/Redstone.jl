"""Agent 2's track 2 edits. Usage: python3 -I apply.py <repo root> <edits record out>

Asserts every old text once (log edits: once inside the named entry) before
writing anything, then spills any spec line pushed past 80 rendered columns
onto the next line of its paragraph."""
import os, re, sys

ROOT, OUT = sys.argv[1], sys.argv[2]
SPEC = os.path.join(ROOT, 'docs/design/spec.md')
LOG = os.path.join(ROOT, 'docs/design/decisions.md')
HERE = os.path.dirname(os.path.abspath(__file__))
LIMIT = 80

def rendered(line):
    s = re.sub(r'\[([^\]]*)\]\[[^\]]*\]', r'\1', line)
    s = re.sub(r'\[([^\]]*)\]\([^)]*\)', r'\1', s)
    s = s.replace('**', '').replace('`', '')
    return re.sub(r'(?<![\w*])\*(?=\S)|(?<=\S)\*(?![\w*])', '', s)

def tokens(line):
    """Split on spaces outside link text and link targets."""
    out, cur, depth, prev = [], '', 0, ''
    for ch in line:
        if ch == '[' or (ch == '(' and prev == ']'):
            depth += 1
        elif ch in '])' and depth:
            depth -= 1
        if ch == ' ' and depth == 0:
            out.append(cur); cur = ''
        else:
            cur += ch
        prev = ch
    out.append(cur)
    return out

SPEC_EDITS = [
    ('S1 D-408, §13.6 bold',
     "to final, and rejoins the ordinary tail** ([D-030][d-030]).",
     "to final, and rejoins the ordinary tail** ([D-030][d-030], D-408)."),
    ('S2 D-409, §13.5 inspection doctrine',
     "a line [D-316][d-316] narrows. Inspection is human-facing",
     "a line [D-316][d-316] narrows (D-409). Inspection is human-facing"),
    ('S3 D-413, §13.5 ignored requests',
     "validity broke even on a run that continued ([D-316][d-316]).",
     "validity broke even on a run that continued ([D-316][d-316], D-413)."),
    ('S4 D-410, §13.5 post-terminal dynamics',
     "which is better modeling ([D-060][d-060]).",
     "which is better modeling ([D-060][d-060], D-410)."),
    ('S5 D-414, §13.5 t_end range',
     "`ArgumentInvalid`, refused before the ignore list is read.",
     "`ArgumentInvalid`, refused before the ignore list is read (D-414)."),
    ('S6 D-414, §13.5 entry check',
     "an honoured request before its\nfirst frame. After `init!`",
     "an honoured request before its\nfirst frame (D-414). After `init!`"),
    ('S7 D-108 (lesson 42, B51), §13.6 refusal',
     "errored simulation outright (`ServiceLifecycle`, [§14][s14]).",
     "errored simulation outright (`ServiceLifecycle`, [§14][s14], D-108)."),
    ('S8 D-369 (lesson 42, B56), §13.2 surfacing',
     "beside the signal table) ([§11.2][s11-2]). The liveness",
     "beside the signal table) ([§11.2][s11-2], D-369). The liveness"),
    ('S9 D-412, §13.7 pin generalization',
     "each declares its `out` pinned ([D-312][d-312]).",
     "each declares its `out` pinned ([D-312][d-312], D-412)."),
    ('S10 D-411, §13.7 two uses',
     "Two uses need `Constant` ([D-143][d-143]), though",
     "Two uses need `Constant` ([D-143][d-143], D-411), though"),
    ('S11 D-411, §13.7 first shipped instance',
     "the source block's first shipped instance ([D-143][d-143]).",
     "the source block's first shipped instance ([D-143][d-143], D-411)."),
]

entries = open(os.path.join(HERE, 'entries.md')).read().rstrip('\n') + '\n'
titles = re.findall(r'^### (D-\d{3}) — (.*)$', entries, re.M)
index_rows = ''.join(f'| [{i}][{i.lower()}] | {t} | ratified |\n' for i, t in titles)

LOG_EDITS = [  # (label, entry or None, old, new)
    ('L1 D-369 Spec field gains §13.2 (lesson 42, B56)', 'D-369',
     "**Spec.** [§11.8][s11-8]\n", "**Spec.** [§11.8][s11-8], §13.2\n"),
    ('L2 Index rows D-408 to D-414', None,
     "| [D-407][d-407] | Read the log through the read-selector family, as columns | ratified |\n",
     "| [D-407][d-407] | Read the log through the read-selector family, as columns | ratified |\n"
     + index_rows),
    ('L3 entries D-408 to D-414', None,
     "  specialization.\n\n<!-- citation link definitions",
     "  specialization.\n\n" + entries + "\n<!-- citation link definitions"),
]

def entry_span(text, eid):
    m = re.search(rf'^### {eid} — .*?(?=^### D-|^<!-- citation link)', text, re.S | re.M)
    return m.start(), m.end()

import subprocess
def head(path):  # the base is HEAD's blob, so a rerun replays every edit afresh
    rel = os.path.relpath(path, ROOT)
    return subprocess.run(['git', '-C', ROOT, 'show', f'HEAD:{rel}'], check=True,
                          capture_output=True, text=True).stdout
spec, log = head(SPEC), head(LOG)
for label, old, new in SPEC_EDITS:
    assert spec.count(old) == 1, (label, spec.count(old))
for label, eid, old, new in LOG_EDITS:
    if eid:
        a, b = entry_span(log, eid)
        assert log[a:b].count(old) == 1, label
    else:
        assert log.count(old) == 1, (label, log.count(old))

record = []
lines_before = spec.split('\n')
for label, old, new in SPEC_EDITS:
    pos = spec.index(old)
    spec = spec[:pos] + new + spec[pos + len(old):]
    # spill: from the edit's first line, push overflow onto the paragraph's next line
    L = spec.split('\n')
    first = spec[:pos].count('\n')
    last = first + new.count('\n')
    i, spilled = first, False
    while i < len(L) and (i <= last or spilled):
        spilled = False
        if len(rendered(L[i])) > LIMIT:
            toks = tokens(L[i]); moved = []
            while len(rendered(' '.join(toks))) > LIMIT and len(toks) > 1:
                moved.insert(0, toks.pop())
            L[i] = ' '.join(toks)
            nxt = L[i + 1] if i + 1 < len(L) else ''
            if nxt.strip() == '' or nxt.startswith(('#', '|', '```', '- ')):
                L.insert(i + 1, ' '.join(moved))
            else:
                L[i + 1] = ' '.join(moved) + ' ' + nxt
            spilled = True
        i += 1
    spec = '\n'.join(L)
    record.append((label, first + 1, i + 1))

for label, eid, old, new in LOG_EDITS:
    if eid:
        a, b = entry_span(log, eid)
        log = log[:a] + log[a:b].replace(old, new) + log[b:]
    else:
        log = log.replace(old, new)

open(SPEC, 'w').write(spec)
open(LOG, 'w').write(log)
with open(OUT, 'w') as f:
    for label, a, b in record:
        f.write(f'{label}: spec lines {a}-{b} after the edit\n')
print('applied', len(SPEC_EDITS), 'spec and', len(LOG_EDITS), 'log edits')
