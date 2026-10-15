import sys, json
ROOT = '/Users/miguel/.julia/dev/Redstone.jl/'
DEC = ROOT + 'docs/design/decisions.md'
SPEC = ROOT + 'docs/design/spec.md'
LOG1 = ROOT + 'docs/spec_rewrite/ch12/track2_log_1.md'
LOG2 = ROOT + 'docs/spec_rewrite/ch12/track2_log_2.md'
OUT = ROOT + 'docs/spec_rewrite/ch12/scratch_track2/fix/edits.json'

files = {p: open(p).read() for p in (DEC, SPEC, LOG1, LOG2)}
done = []

def rep(label, path, old, new, count=1):
    s = files[path]
    n = s.count(old)
    if n != count:
        sys.exit(f'{label}: old text matches {n} times, expected {count}')
    files[path] = s.replace(old, new)
    done.append((label, path.replace(ROOT, ''), old, new))

def drop_entry(label, head, nexthead):
    s = files[DEC]
    assert s.count(head) == 1 and s.count(nexthead) == 1, label
    i, j = s.index(head), s.index(nexthead)
    rep(label, DEC, s[i:j], '')

# Findings 1, 4: drop D-397 and D-398 (adjacent entries, dropped one at a time)
drop_entry('F1 drop D-397', '### D-397 — ', '### D-398 — ')
drop_entry('F4 drop D-398', '### D-398 — ', '### D-399 — ')
# Finding 5: drop D-400
drop_entry('F5 drop D-400', '### D-400 — ', '### D-401 — ')

# Findings 2, 3: D-399 cut to its run-field ruling, renumbered D-397
rep('F2/F3 D-399 title, renumbered D-397', DEC,
    '### D-399 — Keep the control plane open to anyone and the run field never `nothing`\n',
    '### D-397 — Keep the run field never `nothing`\n')
rep('F2/F3 D-399 Position', DEC,
    '**Position.** Two rulings on what the control plane and the simulation hold.\n\n'
    '- The control plane is what anyone may poke, and a run\'s outcome is not.\n'
    '- The simulation\'s run field is never `nothing`. The placeholder run gives\n'
    '  every accessor a run to read, and the lifecycle state says whether it\n'
    '  started.\n\n'
    '**Spec.** [§12.1][s12-1], [§12.6][s12-6]\n\n'
    '**Rationale.** Each bullet restates what [D-255][d-255]\'s Rationale',
    '**Position.** The simulation\'s run field is never `nothing`.\n\n'
    '**Spec.** [§12.6][s12-6]\n\n'
    '**Rationale.** This restates what [D-255][d-255]\'s Rationale')
rep('F3 D-399 Rejected item of the dropped bullet', DEC,
    '**Rejected.**\n'
    '- *`termination` staying on `Control`:* the control plane is what anyone\n'
    '  may poke; a run\'s outcome is not ([D-255][d-255]).\n'
    '- *A `Union{Nothing,Run}` field:*',
    '**Rejected.**\n'
    '- *A `Union{Nothing,Run}` field:*')

# Renumber the surviving later entries
rep('Renumber D-401 to D-398', DEC, '### D-401 — ', '### D-398 — ')
rep('Renumber D-402 to D-399', DEC, '### D-402 — ', '### D-399 — ')

# Finding 6
rep('F6 D-396 bullet 1', DEC,
    '- The failure is reported as the ordinary `DeviceCrash`, with no diagnostic\n'
    '  kind of its own. Its payload and disposition already fit.\n',
    '- An init failure gets no diagnostic kind of its own. Its payload and\n'
    '  disposition already fit.\n')

# Finding 7
rep('F7 D-386 Rationale', DEC,
    'not state. The spin\'s rule is not restated, because [D-027][d-027]\'s Position states\n'
    'it. The entry decides nothing new.\n',
    'not state. The spin\'s reason is not restated, because it is a reason and not\n'
    'a ruling, and D-027\'s Rejected list keeps it. The entry decides nothing new.\n')
rep('F7 log 2 B42 row', LOG2,
    '| the spin\'s rule (D-027\'s Position states it) |',
    '| the spin\'s reason, a reason and not a ruling, which D-027\'s Rejected list keeps |')

# Finding 8
rep('F8 D-392 Position', DEC,
    '**Position.** The thread budget is checked once per run, against the frozen\n'
    'roster, and never re-checked per attach.\n',
    '**Position.** The thread budget is never re-checked per attach.\n')

# Finding 10
rep('F10 D-138 annotation', DEC,
    'frame and ends `stopped` where it started, its terminal snapshot the one\n'
    'it started from. `DeviceCrash`\'s payload names no device id since [D-228][d-228].\n'
    'The cell it is written to names the device.\n',
    'frame and ends `stopped` where it started, its termination record naming\n'
    'the device. The Rationale\'s "boundary zero is published" and its §13.5\n'
    'terminal-at-`t₀` path are historical. `DeviceCrash`\'s payload names no\n'
    'device id since [D-228][d-228]. The cell it is written to names the device.\n')

# Finding 11
rep('F11 D-198 annotation', DEC, ' says\n"usage contexts".\n', ' says\n"Usage contexts".\n')

# Finding 12
rep('F12 D-268 annotation', DEC,
    'Annotation (2026-10-15): the stop faces of the second bullet and the\n'
    'Rationale are stop requests since [D-316][d-316]. Since',
    'Annotation (2026-10-15): the stop faces of the second bullet are stop\n'
    'requests since [D-316][d-316]. Since')

# spec.md
rep('F3 spec §12.1, D-399 dropped at D-255', SPEC,
    'owns), not to `Control` ([§12.6][s12-6], [D-255][d-255], [D-399][d-399]). The control plane is\n',
    'owns), not to `Control` ([§12.6][s12-6], [D-255][d-255]). The control plane is\n')
rep('F5 spec §12.6, D-400 dropped at D-261', SPEC,
    'otherwise ([D-261][d-261], [D-400][d-400]).\n',
    'otherwise ([D-261][d-261]).\n')
rep('F9 spec §12.6, D-390 moved', SPEC,
    'navigated directly for\nassertions. Advance-assert-advance is `stage!` → `step!` → `latest`\n'
    '([D-096][d-096], [D-390][d-390]). Both entry points',
    'navigated directly for\nassertions ([D-390][d-390]). Advance-assert-advance is `stage!` → `step!` → `latest`\n'
    '([D-096][d-096]). Both entry points')
rep('F1 spec §12.7, D-397 dropped at D-218', SPEC,
    'than the end of an operation ([D-218][d-218], [D-397][d-397]). Whatever',
    'than the end of an operation ([D-218][d-218]). Whatever')
rep('F4 spec §12.7, D-398 replaced by D-219', SPEC,
    'append to the re-recorded prefix ([D-398][d-398]).',
    'append to the re-recorded prefix ([D-219][d-219]).')
rep('Renumber spec D-399 to D-397', SPEC, '[D-399][d-399]', '[D-397][d-397]')
rep('Renumber spec D-401 to D-398', SPEC, '[D-401][d-401]', '[D-398][d-398]', 3)
rep('Renumber spec D-402 to D-399', SPEC, '[D-402][d-402]', '[D-399][d-399]', 2)

# Finding 13
rep('F13 log 1 fences', LOG1, '### D-256 — ```\n', '### D-256 — \n```\n', 2)
rep('F13 log 1 note', LOG1,
    '### L31. B69: D-255 annotation\n\nOld:\n',
    '### L31. B69: D-255 annotation\n\n'
    'The matched text ends with "### D-256 — ", trailing space included.\n\nOld:\n')

if '--dry' not in sys.argv:
    for p, s in files.items():
        open(p, 'w').write(s)
    json.dump(done, open(OUT, 'w'), ensure_ascii=False, indent=1)
print(len(done), 'edits ok')
