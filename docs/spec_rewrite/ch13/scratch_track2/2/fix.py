"""The verifier's four findings (track2_verify.md). Usage: python3 -I fix.py <root>"""
import os, re, sys
ROOT = sys.argv[1]
SPEC = os.path.join(ROOT, 'docs/design/spec.md'); LOG = os.path.join(ROOT, 'docs/design/decisions.md')
spec, log = open(SPEC).read(), open(LOG).read()

def once(text, old, new, label):
    assert text.count(old) == 1, (label, text.count(old))
    return text.replace(old, new)

# 1. D-408's Rationale names its source
log = once(log, """the same protocol from the catch path. The design text that ruled [D-030][d-030]
stated the discard and the promotion, since the boundary is all-or-nothing
outside the loop, and the log's entry did not carry them. The entry decides
nothing new.""", """the same protocol from the catch path. The design text at `6fe7de2` (§15.6),
which filled the seat D-030's catch-path clause left, stated the discard and
the promotion, since the boundary is all-or-nothing outside the sim task, and
no entry carried them. The entry decides nothing new.""", 'F1')

# 2. D-409 keeps bullet 1 alone
log = once(log, """**Position.** Two rulings on observation by path.

- Observation by path is rejected. Service observation must speak the
  contract, while inspection observation sees everything, [§6.1][s6-1]'s knowledge
  rule applied to reads.
- The ignore list narrows the rejection. It reads no arbitrary cell. It
  addresses the `Build`'s requester roster, a build product like the
  root-input list, and it binds at an advance, a stopped-sim point where
  conditions already address state by path ([§14.1][s14-1]).
""", """**Position.** Observation by path is rejected. Service observation must speak
the contract, while inspection observation sees everything, §6.1's knowledge
rule applied to reads.
""", 'F2 Position')
log = once(log, """**Rationale.** The first bullet restates the ground of [D-060][d-060]'s rejection of
observation by path, which its Position does not state. The second restates
the paragraph of [D-316][d-316]'s Rationale on the narrowed rejection, which [D-060][d-060]'s
annotation of 2026-10-08 also records. [D-316][d-316]'s Position states neither.
[D-083][d-083]'s Position states the inspection half for output-device reads alone.
The entry decides nothing new.

**Rejected.** None beyond the source entries' lists.""", """**Rationale.** This restates the ground of D-060's rejection of observation
by path, which its Position does not state. D-083's Position states the
inspection half for output-device reads alone, and D-129's has service reads
speak the contract and inspection reads speak structure. The entry decides
nothing new.

**Rejected.** None beyond D-060's list.""", 'F2 Rationale')

# 3. Drop D-410, revert its citation, renumber D-411..D-414 down by one
m = re.search(r'^### D-410 — .*?(?=^### D-411 )', log, re.S | re.M)
assert m and log.count('### D-410 ') == 1
log = log[:m.start()] + log[m.end():]
log = once(log, "| [D-410][d-410] | Leave post-terminal dynamics to the model | ratified |\n", "", 'F3 row')
spec = once(spec, "which is better modeling ([D-060][d-060], [D-410][d-410]).",
            "which is better modeling ([D-060][d-060]).", 'F3 cite')
for t in (log, spec):
    assert '[D-410]' not in t.split('<!-- citation link definitions')[0] or t is log
assert '[D-410][d-410]' not in log.split('<!-- citation link definitions')[0]
counts = {}
for n in (411, 412, 413, 414):
    for name in ('log', 'spec'):
        t = log if name == 'log' else spec
        body, sep, defs = t.partition('<!-- citation link definitions')
        counts[(n, name)] = body.count(f'D-{n}')
        body = body.replace(f'### D-{n} ', f'### D-{n-1} ').replace(f'[D-{n}][d-{n}]', f'D-{n-1}')
        assert f'D-{n}' not in body, (n, name)
        if name == 'log': log = body + sep + defs
        else: spec = body + sep + defs
print('renumbered occurrences', counts)

# 4. D-412 (was D-413) moves to the sentence it rules
spec = once(spec, "validity broke even on a run that continued ([D-316][d-316], D-412).",
            "validity broke even on a run that continued ([D-316][d-316]).", 'F4 from')
spec = once(spec, "is what tells a reader which, and the framework never will.\n",
            "is what tells a reader which, and the framework never will (D-412).\n", 'F4 to')

open(SPEC, 'w').write(spec); open(LOG, 'w').write(log)
print('ok')
