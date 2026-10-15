R="/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch12/"
rows=[l.rstrip("\n").split("\t") for l in open(R+"inbound.tsv")]
hdr=rows[0]; mine=[r for r in rows[1:] if r[2] in ("§12.5","§12.6","§12.7")]
V={
 17:("OK","sync, pre-existing: §12.7 'one substitution' holds, but 'staging fed from a recording' contradicts it; the drain reads the trace and no staging cell is swapped (new 1095-1099)"),
 22:("OK","§12.7 never names log_max; it compares the Deployment and lists its fields, so the exclusion is implicit there (explicit in §11.2 and §12.4)"),
 29:("MISSING","never did: §12.6 never says init! takes the header at the end of boundary zero; the bold is §11.5's own ruling (D-274), and §12.7 1329-1330 says only that the checkpoint holds the state after boundary zero; drop §12.6"),
 32:("OK","checkpoint(sim) on demand is §12.6's (965-972); the init!-for-the-header half is §11.5's own (row 7716), never §12.6's"),
 49:("OK","restore! puts it back is §12.6's; 'not a condition, no algebra' was never §12.6's and rests on D-273/D-274, cited beside"),
 50:("OK","sync R12: §12.6 now checks the fingerprint and the deployment"),
 51:("OK","'not a condition, no algebra' was never §12.6's; D-274, cited beside, rules it"),
 53:("MISSING","never did (survey 2 D, F73): §12.6 (new 951-956) says the trace, log and termination record are new objects rather than cleared ones, and that staging batches are cleared"),
 58:("MISSING","never did (survey 2 D): §12.6 never says restore!(model) takes no status gate; D-319 bullet 2 does. Sync R12: the check is fingerprint and deployment. Note R14: 'A writing door' names a Model entry point"),
 60:("MISSING","never did (survey 2 D, F73): 'recordings cleared'; §12.6 makes them new objects"),
 61:("OK","sync R12 (C-169): the ModelState list lacks 'and the deployment' (new 968-970)"),
 62:("OK","sync R12: restore!(sim, cp) checks the fingerprint and the deployment (new 989-992)"),
 63:("OK","sync R12: 'the same fingerprint check' is now the same check of fingerprint and deployment (new 1007-1008)"),
 66:("RETARGET","§11.3: 'surface-checked' moved out of §12.6 (C-137, relocated); §11.3 7263-7265 says drained, traced and surface-checked exactly as any device's. 'GUI's writes' predates D-310"),
 68:("OK","sync F68: a halt names a frame from the one the feed starts from through the recording's last (new 1131-1135)"),
 74:("OK","pre-existing (survey 2 D), confirmed: payload lists run!/step! only; §12.7 names MissingInit for live! (1191) and replay!(restore = false) (1338); cite §12.7 too"),
 75:("OK","sync R12: CheckpointMismatch fires on a fingerprint or deployment mismatch; the payload already lists the deployment arm"),
 76:("OK","same sync as row 13393 §12.6"),
 81:("OK","pre-existing (survey 2 D), confirmed: §12.7 names ArgumentInvalid for the halt keywords (1135) and live! on :live (1193); the row lacks §12.7 and live!"),
 83:("OK","sync R14: 'Its doors' names the Model's entry points, which R14 no longer calls doors"),
 84:("RETARGET","§11.3: any task (D-200, 7263), surface-checked (7265) and drains last (7278) are §11.3's; §12.6 keeps ordinary and traced (918-919). Put §11.3 first"),
 85:("RETARGET","§11.3: every clause (any task, the derived surface, ClaimedFaceEntry) is §11.3's (7263-7271); §12.6 now points at §11.3 for the harness writer (R5)"),
 88:("OK","survey 2 D's checkpoint/replay glossary clash: this entry now agrees with R12 and §11.5; the replay entry (14376) does not"),
 92:("MISSING","never did (survey 2 D, F73): the recorders are not cleared; §12.6 (951-956) makes the trace and log new objects with each fresh run"),
 93:("OK","pre-existing (survey 2 D, F51), confirmed, and sync R12/F57: the fingerprint is the structural layout and the deployment is beside it; restore and clock restore are the default form's"),
 121:("RETARGET","§11.1: R5 cut 'Task topology follows the roster each time' to a pointer at §11.1 (C-201); the 'roster-derived' shorthand is gone from §12.6. Log annotation: rule 1 applies"),
 127:("OK","pre-existing (survey 2 D): ReplayHeaderMismatch is now CheckpointMismatch with no entry ruling the rename; the §12.7 citation itself holds"),
 142:("OK","§12.7 compares the Deployment and never names log_max; D-137 is cited for replay recovering full density"),
 149:("OK","§12.7 never names join_timeout; its exclusion is implicit in the compared Deployment and explicit in §12.4"),
 150:("OK","log wording 'clears the record'; §12.6 says the record is a new object (F73), historical"),
 165:("OK","pre-existing (survey 2 D): StopFaceInvalid retired (D-316) with no annotation on D-249; §12.7 still binds the policy at replay! (1149-1151)"),
 176:("RETARGET","§11.1: R5 cut 'An unattended run is the same loop with empty staging (§11.1)' to a pointer (C-115); §11.1 6890-6891 defines the unattended run. §12.6 keeps 'Deviceless, run! is fully synchronous'"),
 209:("OK","to_time is §12.7's (1157), not §12.6's; pre-existing looseness"),
 217:("RETARGET","§11.3: what the harness cell and writer are now lives in §11.3 (R5, C-132/C-133/C-137); §12.6 keeps only the stepping use"),
 220:("RETARGET","§11.3 (survey 2 D, confirmed): the derived surface is §11.3's (7267-7271); §12.6 never said it"),
}
out=["\t".join(hdr+["verdict","note"])]
for i,r in enumerate(mine,1):
    v,n=V.get(i,("OK",""))
    out.append("\t".join(r+[v,n]))
open(R+"inbound_check_2.tsv","w").write("\n".join(out)+"\n")
from collections import Counter
c=Counter(); cf=Counter()
for i,r in enumerate(mine,1):
    v=V.get(i,("OK",""))[0]; c[v]+=1; cf[(r[0],v)]+=1
print(c); 
for k in sorted(cf): print(k,cf[k])
for i,r in enumerate(mine,1):
    if i in V: print(i,r[0],r[1],r[2],V[i][0])
