import re
C="/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch13/"
rows=[l.rstrip("\n").split("\t") for l in open(C+"inbound.tsv")]
hdr=rows[0]; mine=[r for r in rows[1:] if re.match(r"§13\.[5-8]$",r[2])]
V={}
def s(k,v,n): V[k]=(v,n)
# RETARGET
s(32,"RETARGET","§12.6: the keywords are §12.6's (R4); §13.5 keeps only a pointer sentence")
s(37,"RETARGET","§12.6: the per-advance declaration is §12.6's (R4, C-074)")
s(52,"RETARGET","§12.6: each advance's declaration of t_end and ignore_stop_requests is §12.6's (R4)")
s(63,"RETARGET","§12.6: the keywords are §12.6's (R4)")
s(68,"RETARGET","§12.6 for the lifetime ('nothing else keeps one'), relocated by R4 (C-042); §13.5 keeps the record carrying the policy")
s(77,"RETARGET","§12.1 for ControlRequestedStop outside the policy (spec 8654, never §13.5's); §12.6 for the lifetime and declaration (R4); §13.5 keeps mask, validation, t* hit")
# MISSING, live
s(25,"MISSING","wrong before: §13.5 never said anything of the measurement seam (survey 2 part D); drop the citation")
s(33,"MISSING","wrong before: neither old nor new §13.5 mentions run metadata; the glossary (14551) defines it; drop §13.5")
s(54,"MISSING","wrong before: §13.7's library is components only (Redstone.Blocks); set/at/combine live in §14 (survey 2 part D)")
s(57,"MISSING","wrong before: §13.7's library holds components, not helpers; consistent with D-071's Position, not with §13.7 (survey 2 part D)")
s(93,"MISSING","wrong before: §13.7 records no product() helper; §14.9 (spec 12351) does; pairs with spec 12351")
s(94,"MISSING","wrong before: D-071's content lives in §14.9 and §14.x trim text, nothing in §13.7; track 2 Spec field")
s(229,"MISSING","wrong before: §13.7 has no migration; the parametric spelling fell with D-263 (D-311 bullet 3)")
s(285,"MISSING","wrong before: D-311 does not admit Not; §13.7 lists Or{N} and And{N} only")
# MISSING, log (historical, no chapter edit)
s(95,"MISSING","wrong before, annotated (log 2338, D-311): SumJunction is parametrized; no edit")
s(100,"MISSING","wrong before: D-091 superseded by D-255; historical, no edit")
s(101,"MISSING","wrong before: D-091 superseded; historical Spec field, no edit")
s(130,"MISSING","wrong before: the grow-by-migration-demand rule was retired by D-313; unannotated, track 2")
s(131,"MISSING","wrong before: the Bool gates are Or{N} and And{N}; D-311 rejects Not, so they cannot cover falling-edge consumers; unannotated, track 2; pairs with migration_outline 80")
s(135,"MISSING","wrong before: stop_on fell to stop requests (D-316); unannotated (D-285's twin text is annotated at 12474), track 2")
s(139,"MISSING","wrong before: the demonstrated-need charter was retired by D-313, and the rewrite cut §13.7's last trace of it (F60); track 2")
s(156,"MISSING","wrong before, annotated (log 7771): the policy lives on the termination record (D-217, D-260); no edit")
s(193,"MISSING","wrong before, annotated (log 11919, reads §14); no edit")
s(198,"MISSING","wrong before, annotated (log 12474, D-316); no edit")
# COMPANION
for k,e in ((224,"D-383"),(225,"D-384"),(226,"D-385")):
    s(k,"COMPANION",f"{e} rules inventory content (controller blocks) that lives in companions/library_inventory.md and lqr_tracker.md; §13.7 only points there, as the old text did; no edit")
# OK with notes
N={
 3:"",
 10:"§13.5 697: 'A StopFlag input port places nothing and is left alone'",
 15:"tier-transparency paragraph and Constant's 'no discrete variant'",
 18:"§13.7's 'starting inventory' sentence (1011) omits Group, though 1022 includes it in the library and 1027 admits it by persona; pre-existing",
 29:"§13.5 880-882 (R29) keeps 'Their reads are inspection'. Landing note: the paragraph's last sentence, 'Every cell is reachable, because the table is public throughout' (spec 7125), contradicts R2 for a binding, which attach refuses past a generic seam; extend the §11.2 landing edit (old 7108-7109) to it",
 30:"no binding-walk claim",
 49:"predicate closures still head §13.5's rejected list (854-855)",
 51:"§13.5 keeps building, validating and passing the policy (722-732); §13.5 points back to §12.6 only for declaration, keywords and lifetime, so no mutual pointer",
 56:"§13.5 751-756",
 61:"§13.5 865-866 still says inspection sees every public cell. Landing note: 'It sees everything' beside 'Bind faces …' reads as a binding's reach, which R2 narrows; consider citing §13.3 here when §11.2's landing edit lands",
 64:"§13.5 733-734",
 66:"§13.5 keeps t_end's validation (727-728); the declaration is §12.6's, which the row could add",
 78:"§13.5 716-718 keeps the trace-header clause",
 80:"glossary's 'local primal-carrying' predates F63's 'sampled'; R28 glossary item is track 2",
 88:"historical annotation; §13.5 still lists the rejection",
 91:"§13.5 857-858, 864",
 99:"§13.5 864-866",
 102:"ignore list names requesters, never paths into cells (873-874)",
 103:"§13.5 lists the rejection; the cost is D-060's Rejected list, never §13.5's (survey 2 part D); pre-existing",
 107:"historical: names the claim D-120 qualified",
 113:"historical narration of the then-text",
 123:"annotated at log 4823",
 128:"historical",
 134:"historical",
 137:"h_xu is y_direct, annotated at log 5219",
 148:"see row 18 on the starting-inventory sentence",
 161:"historical narration of the contradiction D-217 resolved",
 170:"historical",
 177:"historical: records the removal",
 179:"historical",
 183:"§13.5 802 states the termination record carries the policy (D-260's 'one lasting home') but cites D-255; old 591 cited D-260 in the clause R4 relocated. Track 2 or a ruled cite at 802",
 202:"historical",
 227:"as row 103: the cost is D-060's",
 230:"see row 18",
 259:"impl's 'local' predates F63's 'sampled'; §13.8 1292 keeps the gloss tying the names",
 272:"phrase verbatim at §13.7 1009",
 287:"§13.7 1105-1107 keeps the phrase in substance",
}
out=open(C+"inbound_check_2.tsv","w")
out.write("\t".join(hdr+["verdict","note"])+"\n")
cnt={}
for k,r in enumerate(mine,1):
    v,n=V.get(k,("OK",N.get(k,"")))
    if k in N and k in V: n=V[k][1]
    out.write("\t".join(r+[v,n])+"\n")
    cnt[(r[0] if not r[0].startswith("companions") else "companions",v)]=cnt.get((r[0] if not r[0].startswith("companions") else "companions",v),0)+1
for k in sorted(cnt): print(k,cnt[k])
