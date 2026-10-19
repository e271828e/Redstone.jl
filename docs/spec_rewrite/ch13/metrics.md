# Chapter 13's metrics

10,635 words at `1fee0fc`, surveyed in two halves.

| step | agent runs | subagent tokens | findings |
|---|---|---|---|
| survey | 2, one per half | 0.96M | 364 rules (166 + 198); 51 factual findings, 1 marked serious and ruled (R2) |
| rewrites | 4, plus fix rounds | 1.07M | checker failures at hand-back: 0; 15 rulings after launch (R16–R30) |
| unit verification | 4, plus re-checks | 0.73M | DRIFT 5, LOST 0 |
| chapter passes, inbound checks, editorial fixers | 6 | 1.16M | 59 pass findings (14 RULING); 47 non-OK rows of 557, no loss |
| consolidation, evidence check, ruled edits | 4 | 0.65M | 87 items (24 blocking); 4 UNCONFIRMED |
| final verification and PDF check | 3 | 0.44M | 14 (two rulings, one lost claim caught at B12 before it) |

The orchestrator's context: 209k tokens at checkpoint 1, 289k at the end of step 4, 372k at checkpoint 4.
