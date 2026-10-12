# Unit F rulings: §5.6

Line numbers are `spec.md` lines at `b08afca` unless marked `log`
(`decisions.md` at `b08afca`). Claim ids are `inventory.json`'s.

## Corrections proposed

None new. Applied as ruled:

- R5, F5 (F-036): "`init_*`" became "the `x_init`, `s_init` and `m_init`
  declarations" (D-267 bullet 1, log 10723).
- R7 (F-011): the diagnostic is named once, "an `AlgebraicCycle` error
  ([Appendix C])", where Detection and naming says each cluster becomes one
  diagnostic. Appendix C 12406 cites §5.6 for the kind.
- R2, M4 (F-014 to F-032): the two modes, what tracing touches and the `Dual`
  paragraph now follow Detection and naming. "There are two modes" now says
  whose: "The feedthrough tracer has two modes". "tracer tags", "global
  tracer", "sampled states" and "may-depend" are now defined before the
  classifier and the caveats use them.
- R11 (F-013): old 1148 ("Neither the raw stall residue nor a single back
  edge …") kept with its D-012 citation.

Other edits under the brief's rules:

- "**Boundaries.**" became `#### What tracing touches`. The other bold
  lead-ins became `####` labels (Detection and naming; Caveats the diagnostic
  carries, with the lead-in's claim as a plain topic sentence) or plain
  sentences (the two mode bullets; "Classification needs no execution order"
  keeps D-012's bold as a headline clause). The **Rule.** label went.
- Old 1153–1154 "out-of-cycle cells" and "in-cycle cells" read "cell values",
  and lose the `#g-cell` link: the evaluation has no table (old 1170–1171).
- The two "local"s are kept apart by two added sentences after "The two must
  not be conflated": "The local variant is not the local set-tracer mode. A
  member's map may come from either mode, or from structure ([D-245])." The
  source is old 1184–1186 and D-245 Position bullet 3 (log 9231). Editorial
  fixer, chapter pass finding 22: ", or from structure ([D-245])" is dropped
  as a repeat of the bold ruling at old 1184–1186, which keeps it.
- The modes' lead sentence gains "Both are set-tracers. A traced value
  carries a set of input indices, its tracer tags." It claims only what the
  two bullets say, and defines "tracer tags" before the classifier uses it.
- The colon in old 1167–1168 became "the expected reading, that the loop is
  real iff every hop survives", keeping "for a simple cycle" on the claim.
- "This is the *local* variant" (old 1172) now names its subject: "The cycle
  classifier uses the *local* variant of tracing". "No activation machinery is
  touched" now reads "Classification touches no activation machinery".
- Glossary links added at first use, each with a gloss from its glossary entry:
  `#g-feedthrough-tracer`, `#g-nominal` (the old parenthetical serves as its
  gloss), `#g-face`, `#g-walked`. Glosses added to the existing links for
  execution order, probe point, guards and contract.

## Citations added or replaced

| claim | entry | words that rule it |
|---|---|---|
| F-002, tracing is diagnostic only (bold) | D-012 Position, log 528–529 | "Set-propagation tracers (global + sampled-local), diagnostic-only" |
| F-010, one nontrivial SCC names one cluster (bold) | D-012 Position, log 529–530 | "cycle diagnostics from SCC decomposition of the … topological stall (one SCC = one named loop)" |
| F-033, classification needs no execution order (plain, R15) | D-012 Position, log 530–532 | "classified by a schedule-free per-member local trace at the probe point (each member evaluated once in isolation; in-cycle cells from `probe_value` under tracer tags)" |
| F-039, the verdict as one graph question (bold) | D-245 Position, log 9225–9229 | "The classifier decides a cluster as one graph question … The loop is real iff a cycle survives in that graph, artificial iff none does." Old 1166 cited D-245 two sentences later |
| F-053, discrete members trace structurally (bold) | D-012 Position, log 533–534 | "conservative on discrete members (pinned signatures admit no tracer scalar)". Old 1179 cited D-012 one sentence earlier |
| F-054, the hint only for continuous members | D-140 Rationale, log 4660–4661 | "[§5.6]'s hint offers both exits … continuous members only as before". Listed below |
| F-055, unwalked continuous faces and ports trace structurally | D-245 Rationale, log 9246–9249 | "The structural answer extends from discrete members to any continuous face or port declared without a walking leaf, for the same reason: no tracer scalar can enter it." Listed below |
| F-056, the diagnostic records each member's map source (bold) | D-245 Position bullet 3, log 9231 | "Each member records its tracing mode: global, sampled or structural." Old 1186 cited D-245 at the end of the same sentence; the split repeats it |
| F-058, the hint's two exits | D-140 Rationale, log 4660 | "[§5.6]'s hint offers both exits ("split this component, or narrow the neighbor's contract")". Listed below |
| F-060, classification is a bonus on the error (plain, R15) | D-012 Position, log 535 | "classification optional on the error" |

Section pointer added, no entry involved: §7.2 at "Dual-cleanliness in CI"
(F-032), where §7.2 1641–1645 states the CI invariant, a `T = Dual` sweep that
fails loudly on any Float64-pinning. `[Appendix C][sC]` added with R7 (F-011).

## Rationale-only rulings

| claim | entry | field | log line |
|---|---|---|---|
| F-054, the remedy hint is offered only for continuous members | D-140 | Rationale | 4660–4661 |
| F-055, a continuous face or port with no walking leaf traces structurally | D-245 | Rationale | 9246–9249 |
| F-058, the hint names both exits | D-140 | Rationale | 4660 |
| F-052, the trace speaks for the branch taken at the probe point, "probe state" in the old text, renamed by chapter pass finding 23 (cited to D-012 as before; D-012's Position implies it through "at the probe point", D-140's Rejected list states it) | D-140 | Rejected | 4681–4683 |

None of these is bold. The modes' properties, what tracing seeds and never
touches, the blind spot and `Dual`-cleanliness have no entry (survey part E)
and stay plain.

## Bold on the same entry elsewhere

None. D-012 is bold three times here (F-002, F-010, F-053), one per ruling of
its semicolon chain (R15). F-033 and F-060 cite it plain. D-245 is bold three
times (F-039, F-044, F-056), one
per bullet. §9.4 4446–4452 cites D-012 plain. Unit E's `new.md` bolds D-140
(the three-rung ladder); this unit cites D-140 plain. No other unit's
`new.md`, and no bold in chapters 7 to 10 of the base spec, cites D-012 or
D-245.

## Inbound citations affected

None broken. The rows citing §5.6 (spec 1641, 4447, 4450, 5171, 12406, 13675;
`implementation.md` 198, 884, 1089; `pid_anti_windup.md` 327, 456;
`sample_time_proposal.md` 516; log 4636, 4660, 9243, 9258) rely on content
that stays in §5.6: the tracer as the cycle classifier, the two variants, one
`AlgebraicCycle` per cluster, structural tracing of discrete members, the
hint's two exits, and the caveats carried in the diagnostic (D-245 Rationale
9243 quotes "ride in the diagnostic rather than being assumed away"; the
topic sentence now reads "carries the tracer's caveats rather than assuming
them away"). No file links a `####` anchor of chapter 5 (survey part C).

## Open questions

None. Both earlier questions are answered by the coordinator: the tracer-tags
gloss now claims only what the two bullets say, and "the one evaluation that
feeds structure" stays (§9.1 calls it "the single evaluation-feeds-structure
step").
