import csv,collections
C='/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/'
rows=list(csv.reader(open(C+'inbound.tsv'),delimiter='\t'))
hdr=rows[0];rows=rows[1:]
T={'§14','§14.1','§14.2','§14.3','§14.4','§14.5','§14.6'}
mine=[r for r in rows if r[2] in T]
V={
109:('MISSING','Never stated: §14.4 never names ReadSetMisuse, old or new; it is stated in §14.9 (new 1376) and §14.10. Wrong before the rewrite (survey 1 part D, F5). Retarget to §14.9 at landing.'),
118:('MISSING','Glossary #g-selector (line 14579) says a selector resolves against a source "before any client policy applies". The old §14.4 stated it; R31 cut the clause as false after R5. Landing edit per R31: drop the clause.'),
208:('MISSING','Never stated: §14.2 names no rejection of init as a third scheduled sweep; it rejects the initialize(::C, spec) schema entry. The third-sweep rejection is D-064 Rejected. Wrong before the rewrite (survey 1 part D). Log text: annotate D-139 (track 2).'),
261:('RETARGET','§14.3. D-253 Spec lists §14.1, which never cites it, old or new; §14.3 does (new 311, face chains from Structure). Wrong before the rewrite (survey 1 part D, Spec fields). Track 2 annotation.'),
341:('MISSING','Never stated since D-276: §14.4 gives get_state(path, leaf) etc. with a leaf address, not a trailing [, i] index. Wrong before the rewrite (survey 1 part D). Companion fix.'),
350:('MISSING','Never stated: §14.2 names no third-sweep rejection; that is D-064 Rejected. Wrong before the rewrite (survey 1 part D). Companion fix: cite D-064.'),
354:('MISSING','Never stated: as row at line 65; the third-sweep rejection is D-064 Rejected. Wrong before the rewrite (survey 1 part D). Companion fix: cite D-064.'),
}
N={
32:'Cited text lists three sites "namely"; new §14.6 lists four (R3, linearize under about). Wrong before the rewrite (survey 1 part D, F2). R3 landing edit.',
48:'As line 4692: three sites "namely"; R3 adds linearize under about. R3 landing edit.',
130:'The entry at 14770-14772 lists three sites; R3 adds the fourth. Landing edit already in the brief.',
132:'"all four services": the opening now names five (R1, F3). Wrong before the rewrite. Landing edit already in the brief.',
122:'"the baseline keyword init!/trim! take": init! takes no baseline (F26). Wrong before the rewrite. Landing edit already in the brief.',
100:'Appendix C lists four ConditionResolution sub-kinds; new §14.2 and §14.3 name seven reasons. Appendix C to complete (survey 1 part D).',
101:'As the §14.2 row on the same line.',
102:'Payload "(path, store, field)": new §14.3 makes a u payload\'s leaf its root input (R9, F11). Wrong before the rewrite. Appendix C carried list per the brief.',
103:'Payload lacks :set_payload (F8) and says "node kinds" where §14.2 now says node types (R38). Appendix C carried list per the brief.',
146:'§14.2 states the initialize(::C, spec) rejection; the per-field protocol ground is D-064 Rejected, never §14.2\'s. Historical log text.',
149:'As line 2396.',
159:'Six-member family in the Position predates D-165 and D-206; §14.4 has five. Track 2 annotation (survey 1 part D).',
161:'D-098 Position (3172-3176) names capture; §14.4 says checkpoint. Track 2 annotation (survey 1 part D).',
176:'Citation holds. The next clause, "the baseline keyword of trim!/init!" (4043-4044), is wrong (F26). Track 2.',
185:'Citation holds. The adjacent clause putting device read bindings under inspection (4310-4312) contradicts D-414. Track 2.',
256:'Citation holds. Adjacent 9606-9609 puts bindings and GUI panels under inspection, against D-414. Track 2.',
209:'Historical six-member list; §14.4 has five.',
138:'D-064 Spec lacks §14.1 (pre-sweep doctrine). Track 2.',
139:'D-065 Spec lacks §14.3. Track 2.',
163:'Historical: D-274 moved the header to the end of the sequence, as new §14.5 states; D-101 carries the annotation.',
217:'"everything at boundary zero" predates D-185 phases; new §14.5 says phase-free divisors. D-147 is annotated by D-185.',
231:'The caveat it names was removed by D-205, which records it.',
67:'The survey\'s F1 disagreement with §14.4 is resolved: new §14.4 puts bindings and series under the service walk (R5).',
338:'New §14.4 says snapshot inspection reads a cell by path and port name (R5, F21), pointing to §11.2.',
26:'Guidance, not enforcement (R5); new §14.4 keeps it.',
46:'Guidance (R5); kept.',
111:'Guidance (R5); kept.',
183:'Guidance (R5); kept.',
309:'New §14.4 is client-free, as this rejection says.',
71:'New §14.4: "Which of the two a service uses is internal, never user-facing API."',
}
out=open(C+'scratch_step5/inbound1/inbound_check_1.tsv','w')
w=csv.writer(out,delimiter='\t',lineterminator='\n')
w.writerow(hdr+['verdict','note'])
cnt=collections.Counter();byfile=collections.defaultdict(collections.Counter)
for i,r in enumerate(mine,1):
    v,n=V.get(i,('OK',N.get(i,'')))
    w.writerow(r+[v,n]); cnt[v]+=1; byfile[r[0]][v]+=1
print(cnt)
for f,c in byfile.items(): print(f,dict(c))
