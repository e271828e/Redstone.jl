# Chapter 12: cost and catch, for recipe section 3

Orchestrator context is `input_tokens + cache_read_input_tokens +
cache_creation_input_tokens` from the session transcript's last `usage`
record.

| step | agent runs | subagent tokens | findings |
|---|---|---|---|
| survey | 2, one per half | 0.87M (0.43M, 0.45M) | 380 rules; 24 + 33 factual findings; 2 serious (escalated) |
| rewrites | 4, plus fix rounds | about 1.1M | checker failures at hand-back: 0 in every unit |
| unit verification | 4, plus re-checks | about 0.79M | DRIFT A 4, B 5, F 1, G 4; LOST 0 everywhere; 6 rulings after step 3 (R15–R20), 3 of them the orchestrator's own dictated wording |

Orchestrator context: checkpoint 1, 174,827 tokens.

Units: A 1,918, B 2,796, F 2,770, G 2,331 old words; the chapter grew from
9,815 to 11,577 words.

Step 5: chapter passes 0.40M (0.18M, 0.21M), 77 findings (half 1: 25
EDITORIAL, 10 RULING; half 2: 32 EDITORIAL, 10 RULING); inbound checks 0.34M
(0.16M, 0.18M), 460 rows, 439 OK, 11 RETARGET, 10 MISSING, none a loss (one
row, Appendix B's "dead from boundary zero", follows R8).

Consolidation: 1 Sonnet run, 0.14M, 88 items (21 blocking, 19 landing, 41
track 2, 7 carried).

Orchestrator context: checkpoint 2 (blocking items ruled), 290,831 tokens.

Evidence check: 1 Opus run, 0.25M, 67 items, 63 CONFIRMED, 4 UNCONFIRMED.
Orchestrator context: checkpoint 3 (every item ruled), 304170 tokens.

Ruled edits: 1 Opus run, 0.14M. Final verification: 2 Opus runs, 0.37M, 2 findings (one lost clause, restored as O-1; one log note). PDF check: 1 Sonnet run, no damage.
Orchestrator context: checkpoint 4 (landing approved), 332611 tokens.
