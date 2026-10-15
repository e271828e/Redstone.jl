import sys
R='/Users/miguel/.julia/dev/Redstone.jl/docs/design/'
dry = len(sys.argv)>1 and sys.argv[1]=='--dry'
# spec edits: (label, old, new); citations bare, linkify links them
E=[
("S1 D-386 §12.2","structurally absent from framework tasks.","structurally absent from framework tasks (D-386)."),
("S2 D-392 §12.2","attached device entries ([§11.3][s11-3]). Tight means","attached device entries ([§11.3][s11-3], D-392). Tight means"),
("S3 D-395 §12.2","The threshold is deliberately loose, because the heartbeat\nis advisory.","The threshold is deliberately loose, because the heartbeat\nis advisory (D-395)."),
("S4 D-399 §12.1","owns), not to `Control` ([§12.6][s12-6], [D-255][d-255]).","owns), not to `Control` ([§12.6][s12-6], [D-255][d-255], D-399)."),
("S5 D-401 §12.1","is cleared at the top of each run, because a stop belongs to the","is cleared at the top of each run (D-401), because a stop belongs to the"),
("S6 D-389 §12.4","run-scoped observables. A device unplugged","run-scoped observables (D-389). A device unplugged"),
("S7 D-396 §12.4","**The report is the ordinary `DeviceCrash`, not a kind of its own**\n([D-138][d-138], [Appendix C][sC]).","**The report is the ordinary `DeviceCrash`, not a kind of its own**\n([D-138][d-138], D-396, [Appendix C][sC])."),
("S8 D-396 §12.4","top ([D-138][d-138]). That needs no machinery.","top ([D-138][d-138], D-396). That needs no machinery."),
("S9 D-396 §12.4","The claims of a failed device persist to run end ([D-138][d-138]).","The claims of a failed device persist to run end ([D-138][d-138], D-396)."),
("S10 D-396 §12.4","uniformly with (6)**\n([D-138][d-138]).","uniformly with (6)**\n([D-138][d-138], D-396)."),
("S11 D-394 §12.4","**Masking across the boundary is normative, not an implementation hint**\n([D-132][d-132]).","**Masking across the boundary is normative, not an implementation hint**\n([D-132][d-132], D-394)."),
("S12 D-394 §12.4","The framework flips nothing process-global\n([D-132][d-132]).","The framework flips nothing process-global\n([D-132][d-132], D-394)."),
("S13 D-394 §12.4","immediately** ([D-132][d-132]).","immediately** ([D-132][d-132], D-394)."),
("S14 D-401 §12.4","**A frame that throws with an interrupt pending ends `errored`**\n([D-268][d-268]).","**A frame that throws with an interrupt pending ends `errored`**\n([D-268][d-268], D-401)."),
("S15 D-401 §12.4","**A forced throw reaches the defensive arm** ([D-268][d-268]).","**A forced throw reaches the defensive arm** ([D-268][d-268], D-401)."),
("S16 D-400 §12.6","the next door may declare otherwise ([D-261][d-261]).","the next door may declare otherwise ([D-261][d-261], D-400)."),
("S17 D-399 §12.6","the lifecycle state below says whether that run ever started.","the lifecycle state below says whether that run ever started (D-399)."),
("S18 D-387 §12.6","not resurrection ([§12.7][s12-7]).","not resurrection ([§12.7][s12-7], D-387)."),
("S19 D-388 §12.6","returns ([D-088][d-088]). A stepped simulation","returns ([D-088][d-088], D-388). A stepped simulation"),
("S20 D-390 §12.6","the duration spelling. It is mutually exclusive","the duration spelling (D-390). It is mutually exclusive"),
("S21 D-389 §12.6","**A stepping session is deviceless by construction** ([D-093][d-093]).","**A stepping session is deviceless by construction** ([D-093][d-093], D-389)."),
("S22 D-390 §12.6","([D-096][d-096]). Both entry points work under `run!` too.","([D-096][d-096], D-390). Both entry points work under `run!` too."),
("S23 D-390 §12.6","termination untouched ([§13.5][s13-5], [D-096][d-096]).","termination untouched ([§13.5][s13-5], [D-096][d-096], D-390)."),
("S24 D-388 §12.6","Between `step!` calls a simulation reports `initialized` ([D-088][d-088]).","Between `step!` calls a simulation reports `initialized` ([D-088][d-088], D-388)."),
("S25 D-388 §12.6","tail and leaves the simulation\n`stopped`. `step!` therefore","tail and leaves the simulation\n`stopped` (D-388). `step!` therefore"),
("S26 D-388 §12.6","**`stopped → init! → run!` remains the authored re-run** ([D-088][d-088]).","**`stopped → init! → run!` remains the authored re-run** ([D-088][d-088], D-388)."),
("S27 D-388 §12.6","**Device attachments persist across re-initialization** ([D-088][d-088]),","**Device attachments persist across re-initialization** ([D-088][d-088], D-388),"),
("S28 D-397 §12.7","than the end of an operation ([D-218][d-218]).","than the end of an operation ([D-218][d-218], D-397)."),
("S29 D-402 §12.7","applied twice and nothing is skipped ([D-274][d-274]).","applied twice and nothing is skipped ([D-274][d-274], D-402)."),
("S30 D-393 §12.7","deterministically ([D-127][d-127]).","deterministically ([D-127][d-127], D-393)."),
("S31 D-398 §12.7","append to the re-recorded prefix. `live!`","append to the re-recorded prefix (D-398). `live!`"),
("S32 D-391 §12.7","**Replay re-records** ([D-101][d-101]).","**Replay re-records** ([D-101][d-101], D-391)."),
("S33 D-391 §12.7","are unchanged** ([§10.7][s10-7], [§12.1][s12-1], [D-101][d-101]).","are unchanged** ([§10.7][s10-7], [§12.1][s12-1], [D-101][d-101], D-391)."),
("S34 D-391 §12.7","**Validation is loud and up front** ([D-101][d-101]).","**Validation is loud and up front** ([D-101][d-101], D-391)."),
("S35 D-391 §12.7","once, off the loop ([D-101][d-101],\n[D-176][d-176]).","once, off the loop ([D-101][d-101], D-391,\n[D-176][d-176])."),
("S36 D-391 §12.7","*Parametric* difference is not\n([D-101][d-101]).","*Parametric* difference is not\n([D-101][d-101], D-391)."),
("S37 D-402 §12.7","followed by the feed from the next\nframe ([D-274][d-274]).","followed by the feed from the next\nframe ([D-274][d-274], D-402)."),
]
spec=open(R+'spec.md').read()
a=spec.index('## 12. Runtime periphery'); b=spec.index('# Part IV')
ch=spec[a:b]
bad=False
for lab,o,n in E:
    c=spec.count(o); cc=ch.count(o)
    if c!=1 or cc!=1: print('MISMATCH',lab,c,cc); bad=True
dec=open(R+'decisions.md').read()
M='<!-- citation link definitions'
assert dec.count(M)==1
ent=open('entries.md').read()
if bad: sys.exit(1)
for lab,o,n in E: spec=spec.replace(o,n)
dec=dec.replace(M, ent+M)
if dry: print('dry ok'); sys.exit(0)
open(R+'spec.md','w').write(spec); open(R+'decisions.md','w').write(dec); print('applied')
