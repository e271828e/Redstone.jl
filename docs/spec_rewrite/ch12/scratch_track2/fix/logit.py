import json
R='/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch12/'
E=json.load(open(R+'scratch_track2/fix/edits.json'))
o=['','## Review fixes','',
'The 13 findings of `track2_verify.md`, one commit, `9d66d54`. The orchestrator',
'ruled findings 1, 4 and 5: drop D-397, D-398 and D-400, cite the Position\'s',
'entry alone where the spec cited them, then renumber D-399, D-401 and D-402',
'to D-397, D-398 and D-399. Before the edits, a grep of `docs/`, `src/`,',
'`test/` and `README.md` found the six old numbers only in `decisions.md`',
'(heading, Index row, link definition) and `spec.md` (citations, link',
'definitions). `scratch_track2/fix/apply.py` made every edit below in order,',
'asserting each old text matched the stated number of times (once unless',
'noted). Old texts are the files as they stood before each edit; new texts',
'carry bare citations, which `linkify.jl` then linked. `linkify.jl` also',
'regenerated the Index rows and the link definitions of both files: the rows',
'and definitions of D-397 to D-402 gave way to those of the new D-397 to',
'D-399, under their new titles\' anchors.','',
'Beyond the Fix lines, findings 2 and 3 together cut D-399 to one ruling, so',
'its title lost "the control plane open to anyone and", the Position lost its',
'headline, the Spec field lost §12.1 (the only §12.1 citation was the one',
'finding 3 removed), the Rationale\'s "Each bullet" became "This", and the',
'Rejected item for the dropped bullet went. D-392\'s title still reads "Check',
'the thread budget once per run, against the frozen roster"; finding 8 did',
'not touch it.','',
'The `track2_log_1.md` edit (finding 13) and the B42 row above (finding 7)',
'are not in the commit.','']
for i,(lab,path,old,new) in enumerate(E,1):
    n=' (2 matches)' if 'D-256' in old and 'fences' in lab else ''
    if lab.startswith('Renumber spec D-401'): n=' (3 matches)'
    if lab.startswith('Renumber spec D-402'): n=' (2 matches)'
    o+=[f'### R{i}. {lab}','',f'`{path}`{n}.','','Old:','','````',old.rstrip('\n'),'````','','New:','','````',new.rstrip('\n') if new else '(nothing)','````','']
o+=['### Battery','',
'`linkify.jl`; `check_refs.jl` OK; `check_rows.jl` OK, no coverage drop,',
'no rebaseline; `check_glossary.jl --strict` OK; `check_bold.jl` OK',
'(chapter 12: 65 bold spans, 596 words); `linkify.jl` again a no-op. No',
'edited chapter 12 line is over 80 rendered columns.','']
open(R+'track2_log_2.md','a').write('\n'.join(o))
