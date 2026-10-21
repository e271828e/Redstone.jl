"""First use per numbered section (### N.M, or ## N. for chapter intros) of
each new glossary term in the body of spec.md. Prints anchor, line, section,
whether the line already links that anchor, and the line."""
import re, sys
spec = sys.argv[1]
TERMS = {
 'g-auto-bubbling': [r'auto-bubbl\w*'],
 'g-bound-law': [r'bound law', r'walk clause', r'walk-compatibility clause'],
 'g-branch-shape-rule': [r'branch-shape rule'],
 'g-export-chain': [r'export chain'],
 'g-locality-law': [r'locality law', r'one-level rule'],
 'g-opaque-leaf': [r'opaque leaf', r'opaque leaves'],
 'g-fused-idiom': [r'fused idiom'],
 'g-hand-down': [r'hand-down'],
 'g-hop': [r'dead hops?', r'\bhops?\b'],
 'g-boundary-sequence': [r'boundary sequence', r'macro-sequence'],
 'g-trial-evaluation': [r'trial evaluations?'],
 'g-shadowing-check': [r'shadowing check'],
 'g-door': [r'\bdoors?\b'],
 'g-heartbeat': [r'heartbeats?'],
 'g-inspection-read': [r'inspection read', r'integration read', r'\*inspection\* read', r'\*integration\* read'],
 'g-levels-doctrine': [r'levels doctrine'],
 'g-tail': [r'\bthe tail\b', r'shutdown tail', r'\bone tail\b'],
 'g-fingerprint': [r'fingerprints?'],
 'g-read-set': [r'read sets?'],
 'g-stopped-sim': [r'stopped-sim'],
}
L = open(spec).read().split('\n')
end = L.index('## Appendix D. Glossary')
sec = None; fence = False; seen = set()
for i, l in enumerate(L[:end]):
    if l.startswith('```'): fence = not fence; continue
    if fence: continue
    m = re.match(r'^(##|###) (\d+(?:\.\d+)?|Appendix [A-C])', l)
    if m: sec = m.group(2); continue
    if l.startswith('#') or sec is None: continue
    s = re.sub(r'`[^`]*`', '', l)
    s2 = re.sub(r'\]\([^)]*\)|\]\[[^\]]*\]', ']', s)
    for a, pats in TERMS.items():
        if (a, sec) in seen: continue
        if any(re.search(p, s2, re.I) for p in pats):
            seen.add((a, sec))
            print(f"{a}\t{i+1}\t{sec}\t{'LINKED' if '#'+a in l else ''}\t{l.strip()[:110]}")
