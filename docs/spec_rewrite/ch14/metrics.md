# Chapter 14 metrics

| step | agent runs | subagent tokens | findings |
|---|---|---|---|
| survey | 2, one per half | 1.05M (0.528M, 0.524M) | 455 rules (223, 232); 62 factual findings (29, 33), none serious; 81 part H rows (36, 45) |
| rewrites | 5, plus fix rounds | 1.52M | checker failures at hand-back: 0; 23 rulings after launch (R17–R39) |
| unit verification | 5, plus re-checks | 0.92M | DRIFT 11 (A 1, B 3, F 1, G 4, H 2), LOST 0 |
| chapter passes, inbound checks, editorial fixers | 6 | 1.23M | 88 pass findings (14 RULING); 17 non-OK rows of 653, no loss |
| consolidation, evidence check, ruled edits | 4 | 0.63M | 80 items (20 blocking); 6 UNCONFIRMED |
| final verification and PDF check | 3, plus fix rounds | 0.50M | 17 (one lost clause, restored); PDF clean |
| landing | 1 | 0.11M | 0 stops; 1 rebaseline (D-167), 1 whitelist trim |
| track 2, its plan, verification and fixes | 3 | 0.69M | 9 findings; 4 of 14 entry groups dropped or narrowed at the plan; 13 entries (D-415 to D-427), 16 annotations, 21 Spec fields |
| total | 28, plus fix rounds | about 6.65M | |

Orchestrator context, from the session transcript's last `usage` record:

- checkpoint 1: about 183k tokens.
- after step 4: about 327k tokens.
- checkpoint 4: about 405k tokens.
- at the close: about 460k tokens.
