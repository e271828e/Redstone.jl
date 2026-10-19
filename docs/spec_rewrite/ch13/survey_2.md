# Survey of spec chapter 13, half 2, before its readability rewrite — 2026-10-19

Scope: `docs/design/spec.md` lines 10443–11141 at commit `1fee0fc`, 5,791
words: §13.5 (10443–10670), §13.6 (10671–10727), §13.7 (10728–11005) and §13.8
(11006–11141). Half 1 (the heading, the roadmap and §13.1–§13.4, 9909–10442)
is the sibling survey's. The convention is `docs/design/tools/spec_style.md`;
the method is `docs/spec_rewrite/recipe.md` step 1; the model is chapter 12's
half-1 survey (`git show eb1d832:docs/spec_rewrite/ch12/survey_1.md`). The
prompt is `survey_prompt.md`.

Line numbers are lines of the frozen copies in `scratch_survey/h2/`
(`spec.md` and `decisions.md` at `1fee0fc`). Lines marked `log` are
`decisions.md` lines. Entry claims rest on the entry as read in full; the log
line is given where the point sits outside the Position's first sentence.
`src/` was read at the working tree where a name or a claim was in doubt. The
script that ran the half's code and claims against the package is
`scratch_survey/h2/run/blocks.jl`, its output `scratch_survey/h2/run/output.txt`
(part C, "Running the half's code"). `scratch_survey/h2/mine.tsv` holds the 291
inbound rows part D analyses, and `scratch_survey/h2/gloss_firstuse.txt` the raw
first-use scan behind the glossary tables.

Classification codes used in part A, as in chapters 10 to 12:

- **C** cited, and ruled by the cited entry's Position (at the spot or in the
  same paragraph, marked "adjacent").
- **U** ruled by an entry's Position that the section does not cite at that
  spot.
- **S** cited to a superseded entry, or to a bullet a later entry superseded.
- **R** ruled only in an entry's Rationale, Rejected list or annotation
  (whether or not the entry is cited).
- **N** no entry found. Where the sentence reads as a description of an
  inherited status quo or of the code, the row says so.
- **B** borderline; both readings are given.

"Marking" is how the spec marks the rule now: **Rule.** label, labelled bold
lead-in ("**Why one binding site.**"), bold list lead-in ("**Detection**"),
bold sentence, bold clause, bold word or term, or plain.

Section sizes (words, `wc -w` over the frozen lines): §13.5 2,058; §13.6 391;
§13.7 2,178 (opening 324, "The standard component library" 1,508, "The
component test rig" 346); §13.8 1,164.

Bold now, code fences excluded: 44 spans and 316 words in the half. §13.5 20
spans (137 words), §13.6 2 (23), §13.7 14 (97), §13.8 8 (59). Labels: one
**Rule.** (10612) and one labelled lead-in, "**Why one binding site.**"
(10565), both in §13.5. Five bold list lead-ins in §13.5 ("**Detection**",
"**Publication**", "**Placement**", "**The roster**", "**Policy**"), two bold
terms there ("**Inspection**", "**A read the run acts on**") and a bold glossary
link ("**[`StopPolicy`]**", 10494). Three bold words or phrases in §13.7
("**discrete**" 10870, "**source block**" 10898, "**declared stop-gradient**"
10924).

Entries the half rules most and cites least: D-030 (the shutdown protocol's
"loop failure runs the same protocol from the catch path") rules §13.6 and is
cited nowhere in it; D-143 (the `Constant` source) rules four §13.7 paragraphs
and is cited only in §6.2 (1733, 1742); D-120 (the rig's stub child) rules the
rig subsection and is cited only in §8.2 (2671); D-316 bullet 7 (the scan after
every publication) and bullet 5 (`StopRequest`) are stated in §13.5 with no
citation at the statement.

## A. Per section

### §13.5 Termination is a state, not an exception (10443–10670, 2,058 words)

Purpose: how a model ends its own run. Detection by events, publication as a
`StopFlag` port, the build's placement checks and requester roster, the
per-advance ignore policy, the scan after every publication, `StopRequest`,
the unbounded run, the termination record and its four sources, the source
order, and the doctrine around them.

Subheadings: none. The section opens on a history sentence (FlightCore's
idiom) and has no parts sentence. Bold list lead-ins at 10451, 10458, 10469,
10477, 10485. Labels: **Why one binding site.** 10565, **Rule.** 10612. Bold
lead-in sentences 10519, 10545, 10576. Two code blocks (10523–10534,
10555–10563).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 501 | 10445–10447 | "FlightCore's `SimulationTermination` idiom … has **no counterpart here** (D-060)" | bold clause | D-060 Position, last chained ruling ("no `SimulationTermination` exception type") | C; a history sentence carrying a ruling; the chapter roadmap (9919–9921) says the same |
| 502 | 10447 | "The discipline is that **exceptions from model code are always abnormal**." | bold clause | D-060 Position, chained ruling 5 | C, adjacent (D-060 cited 10447) |
| 503 | 10448–10449 | "Graceful termination is model *state*, and it reaches the loop through declared machinery." | plain | D-060 Position, first ruling ("Graceful termination is model state, never an exception"), restated as standing by D-316's Supersedes line (log 13868–13869) | U; D-060's headline ruling, bold nowhere in the spec (part G, q24) |
| 504 | 10451 | "**Detection** is ordinary guard/handler/mode machinery." | bold list lead-in | D-060 Position ("detection by ordinary guard/handler machinery") | U |
| 505 | 10451–10453 | "If the stop should be localized, declare the predicate as a sign-form event." | plain | D-060 Position ("Tier-2 event where the stop must be localized") | U; "Tier-2" is old vocabulary |
| 506 | 10453–10457 | "Such an event is localized … Touchdown overload is precisely a zero-crossing. The boundary is localized to the crossing, the handler sets `m.crashed`, and the snapshot at the crossing instant carries the touchdown state." | plain | none for the example; D-081 Rejected (log 2614, "§13.5's snapshot-at-the-crossing") relies on it | N; worked example, an aerospace name needing an introducing clause |
| 507 | 10458–10459 | "**Publication** is a stop request (an output port of the framework enum `StopFlag`), declared where the condition is detected." | bold list lead-in | D-316 Position, first sentence | U, adjacent (D-316 cited 10461) |
| 508 | 10460–10461 | "**A port whose type is exactly `StopFlag` is a stop request, whoever publishes it** (D-316)" | bold sentence, 14 words | D-316 bullet 1, last sentence | C; whole-sentence bold where "A port … is a stop request" would do |
| 509 | 10461 | "The enum is `@enum StopFlag NO_STOP STOP_REQUESTED`." | plain | D-316 bullet 1 | C, adjacent; a display-code candidate |
| 510 | 10462–10464 | "An enum is one leaf, pinned at every activation (§4.3), and cells are stored per element type (§9.7), so every request in the model lands in one `StopFlag` block." | plain | D-316 bullet 1 | C, adjacent; §4.3 886 states the leaf half (part B) |
| 511 | 10464–10468 | "The condition is gathered at its owning boundary in one visible block. `Ldg` ORs its three legs … No level above it re-exports anything, because the loop reads the request where it is." | plain | D-316 Rationale (log 13873–13880, the per-level hop removed); D-037 Position (junctions at ownership boundaries) | R; `Ldg` is §6.2's landing gear (1716), reader-cold here; "condition" in its ordinary sense (part A glossary) |
| 512 | 10469 | "**Placement** is checked at build." | bold list lead-in | D-316 bullet 2 | C, adjacent |
| 513 | 10469–10471 | "**A `StopFlag` leaf nested inside a port of another type is `IllegalPortType`, and so is a root input whose type carries a `StopFlag` anywhere** (D-316)" | bold sentence, 24 words | D-316 bullet 2 | C; whole-sentence bold |
| 514 | 10471–10474 | "The first is refused because the build rosters requests per port … The second is refused because a request is the model's, never an operator's." | plain | D-316 bullet 2 (the "since" clauses) | C, adjacent |
| 515 | 10474–10475 | "The operator's path is the control plane (§12.1)." | plain | D-316 Rationale (log 13889–13890) | R |
| 516 | 10475–10476 | "A `StopFlag` input port places nothing and is left alone." | plain | D-316 bullet 2, last sentence | C, adjacent; §8.2 2514–2515 restates it, citing §13.5 |
| 517 | 10477–10480 | "**The roster** names every request. **The build records one `Requester(path, port, reason)` per `StopFlag` output port, as the `requesters` of the activation's cell layout, index-aligned with the `StopFlag` block** (D-316)" | bold list lead-in, then bold sentence, 24 words | D-316 bullet 4 | C; whole-sentence bold; "roster" here is the requester roster, not the glossary's device roster (part A glossary) |
| 518 | 10480–10481 | "Entry `i` owns the block's offset `i - 1`, and roster order is build order." | plain | D-316 bullet 4 | C, adjacent; D-316's "written by address after placement, never by walk order" is not carried (mechanism, part H) |
| 519 | 10481–10484 | "The reason is the publishing component's `stop_reason`, an optional declaration with default `""` (§8.2). One reason serves all of a component's requests. It is instance data on the component, never a port value." | plain | D-316 bullet 3, bold at §8.2 2905–2906 | C (D-316 cited 10480); a pointer-level restatement of §8.2 |
| 520 | 10485–10487 | "**Policy** is declared per advance. `t_end` and `ignore_stop_requests` are keywords of `run!` and `replay!`, with `Inf` and `()` as defaults, and `step!` states the same defaults itself (D-255)." | bold list lead-in | D-255 bullets 4–5 as amended by D-316 (annotation log 10280–10283); §12.6 bolds "The stop policy is declared per advance" (9581) | C; the carried B82 double (part B, H1). "`step!` states the same defaults itself" is D-255's wording; §12.6 9582 lists `step!` among the keywords' owners plainly |
| 521 | 10487–10488 | "**Every request is honoured unless the advance ignores it** (D-316)." | bold sentence | D-316 Position, first sentence | C |
| 522 | 10489–10491 | "`ignore_stop_requests = :all` ignores every requester. An iterable of strings names requesters by component path. Each path is validated against the roster on every call, and duplicates collapse, in the order given." | plain | D-316 bullet 6 | C, adjacent; run: duplicates collapse (part C) |
| 523 | 10491–10493 | "A path naming no requester is `StopRequestInvalid`, collected over the given paths (Appendix C)." | plain | D-316 bullet 6 | C, adjacent; run: two bad paths raise two (part C) |
| 524 | 10493–10497 | "Each advance builds a **`StopPolicy`**, the immutable value of `t_end` plus the ignored requester paths, and passes it to the loop with an ignore mask, one `Bool` per requester, as a second argument (D-261)." | bold glossary link | D-316 bullet 7 ("The binder returns the policy and an ignore mask … the mask its compiled companion"); D-261's bullet on the loop's argument is superseded by D-316 (log 13867–13868) | S; the bold is a term, not a ruling; cite D-316 for the mask |
| 525 | 10497–10499 | "The value lives as long as the call, and afterwards only on the termination record of the advance that ended the run (§12.6, D-260)." | plain | D-260 bullet 3 | C; §12.6 9584–9586 says the same (H1) |
| 526 | 10499–10503 | "A `t*` hit reaches the loop as `frame!`'s return value, a `Bool` saying whether the frame was abandoned, never as a field of the policy or of the execution cursor (D-261, D-317). The loop then reads the requester off the snapshot it just published." | plain | D-317 bullet 5; D-261 bullet ("a `t*` stop hit is `frame!`'s return value"), its type clause superseded by D-317 (log 14018–14019) | C; mechanism (part H) |
| 527 | 10504–10506 | "After *every* published boundary the loop scans the `StopFlag` block of the snapshot it just published, in roster order. Grid boundaries, `t*` (§10.4) and boundary zero (§14.5) all count." | plain | D-316 bullet 7 | U; no citation in the paragraph; Part I §2.4 537–543 states the law (part B, H7) |
| 528 | 10506–10508 | "The first honoured request reading `STOP_REQUESTED` initiates §12.4 shutdown with *this* snapshot as the final one." | plain | D-316 bullet 7 | U |
| 529 | 10508–10509 | "The terminal snapshot is the terminal state. There is no roll-back, and nothing §12.4 does not already do." | plain | D-316 (via §2.4 543, "no rollback (D-316)"); D-030 Rejected ("Mid-frame abort") | U; Part I's law restated at Part I depth (H7) |
| 530 | 10509–10511 | "That terminal snapshot's status carries the run's final cumulative diagnostic counters (§11.8)." | plain | D-136 and D-201 (the account closes at the final frame top) | U; a pointer-level fact §11.8 owns |
| 531 | 10512 | "`run!` therefore checks the boundary-zero snapshot before the first step." | plain | none states the entry check; D-316 bullet 7 implies it for boundary zero; D-138's annotation (log 4815–4824) calls "§13.5's terminal-at-`t₀` path" historical for a run that starts later | B: N for the check as stated; U by D-316 for boundary zero. Wrong in scope: every advance checks the latest snapshot at entry, and a run need not start at boundary zero (F51) |
| 532 | 10512–10515 | "An authored condition … that is already terminal ends the run at `t₀` with that snapshot final, integrating nothing." | plain | as row 531 | B; true after `init!` (run: part C), not after `step!` or `restore!` (F51) |
| 533 | 10515–10517 | "The request is the author's and the override the integrator's, and the override sits beside `t_end` at the same declaration site." | plain | D-316 Rationale (log 13906–13907) | R; "override" is a glossary function name (part A glossary) |
| 534 | 10519 | "**The library spelling is `StopRequest`.**" | bold sentence | D-316 bullet 5 | U; no D-citation in the sentence or paragraph |
| 535 | 10519–10521 | "It is a stateless continuous leaf in the mould of `Constant` (§13.7). Its one input is the `Bool` condition, its one output the flag, and its reason is instance data." | plain | D-316 bullet 5 | U |
| 536 | 10523–10534 | the `StopRequest` sketch | code | D-316 bullet 5 | ran: matches `src/blocks.jl` 188–196 and ends a run (part C) |
| 537 | 10536 | "Its output is consumed by nobody, which §6.1 allows silently (D-084)." | plain | D-084 Position | C |
| 538 | 10537–10540 | "`StopRequest` is continuous, so it refreshes at every boundary, `t*` included. Assemblies are virtual … so one leaf sits anywhere in the tree (§10.5, D-019)." | plain | D-316 bullet 5 (which cites D-019); D-019 Position | C |
| 539 | 10540–10542 | "Fed by a discrete detector, it sees the tick at the tick's own boundary, because the boundary sweep walks the full execution order in topological order (§10.5, D-147)." | plain | D-316 bullet 5; D-147 Position | C; run: `tick_alarmed()` stops at its third tick |
| 540 | 10542–10543 | "The block holds no privilege. Any component may publish a `StopFlag` port directly." | plain | D-316 bullet 1 ("whoever publishes it"); Rationale (log 13885–13888) | U; §13.7 10781–10782 says it again (H3) |
| 541 | 10545 | "**An unbounded run is allowed.**" | bold sentence | D-255 bullet 5 ("A run with `Inf` and no faces is allowed"), amended by D-316 | U in the sentence; D-255 is cited 10550 |
| 542 | 10545–10548 | "`run!(sim)` with `t_end = Inf` and no honoured request is the interactive session's ordinary shape, and the operator interrupt is its escape (§12.4). The model may have no requester, or the advance may ignore them all." | plain | D-255 Rationale (log 10261–10264); D-316 bullet 9 | B: R for the shape and the escape; C adjacent for the two cases |
| 543 | 10549–10551 | "The loop raises `UnboundedRun` into its own diagnostic cell, and the status record carries it (§11.8, D-255, D-316). Its message says which of the two cases holds." | plain | D-255 bullet 5; D-316 bullet 9 | C; `run!` raises it before the loop starts (`src/sim.jl` 1107–1108), into the loop's cell; "the loop raises" is loose |
| 544 | 10551–10553 | "The advisory fires in `:live` only. A `run!` in `:replay` is bounded by the recording, whatever its policy says (§12.7, D-218)." | plain | D-316 bullet 9 ("at `run!` in `:live`"); D-218 bullet 2 | C; D-218's Spec field lacks §13.5 (part D) |
| 545 | 10555–10563 | the policy example, five calls | code | D-255, D-316 | fails as written: `Simulation(world; h = 0.02)` is `DeploymentInvalid` (`:inexact`), `h` must be exact (F52); with `h = 1//50` each line behaves as its comment says (part C) |
| 546 | 10565 | "**Why one binding site.**" | labelled bold lead-in | — | label; goes under the convention |
| 547 | 10565–10567 | "A `StopPolicy` is what the caller declares for one advance, so it is a value that advance builds (D-255). The defaults belong to the calls that take it." | plain | D-255 Rationale (log 10254–10256) | R |
| 548 | 10567–10569 | "With no constructor defaults the trace header has no policy to record (§11.5), and the termination record carries the policy that actually ended the run." | plain | D-255 bullet 6 | U; §11.5 7757–7760 states it (H1) |
| 549 | 10569–10572 | "This is not the root-declared stop policy rejected below. Binding at the call moves the policy one notch *later* along the same axis, more deployment-flavored rather than less (D-060)." | plain | D-091 Rejected (log 2909–2911, "the override moves binding *later* along the deployment axis"), D-091 superseded → D-255; D-060 Rejected ("Root-type-declared policy") | R; the "notch later" argument lives only in a superseded entry's Rejected list; adversarial |
| 550 | 10572–10574 | "The `stopped → init! → run!` cycle and the `step!` idiom (§12.6) are precisely where one `Simulation` wants different stopping policies on different runs." | plain | D-091 Rejected ("Ctor-only binding"); §12.6 9586–9588 states it | R; H1 |
| 551 | 10576 | "**The termination record names the source, as a typed value.**" | bold sentence | D-203 bullet 1 | U; no D-203 citation in the paragraph (D-255 is cited for the policy) |
| 552 | 10576–10578 | "The run's termination record carries its *outcome*, and the `StopPolicy` of the advance that ended it (D-255)." | plain | D-255 bullet 6 | C |
| 553 | 10578–10580 | "The record holds four things, the final boundary time, the terminating policy, the source and the tail residue." | plain | D-203 Position (three fields) plus D-255 (the policy) | U; matches `TerminationRecord` (`src/sim.jl` 74–79) |
| 554 | 10581–10582 | "The tail residue is the post-account diagnostics the run's-end sweep folds in (§11.8)." | plain | D-203 Position (amending D-201) | U |
| 555 | 10582–10584 | "The time is always present, because boundary zero precedes every record and a throw inside boundary zero writes none (§12.6, D-233)." | plain | D-233 Position | C; D-233 is cited nowhere else and bold nowhere (q24) |
| 556 | 10584–10586 | "The source follows the diagnostic convention, so its kind is its identity and its payload is plain data (§13.2). It has four kinds." | plain | D-203 bullet 1 | U |
| 557 | 10588–10590 | "`EndTimeReached` means `t_end`'s frame completed. It has no payload. The record's own `t` is the fact, and the bound that was configured is in the record's own policy." | plain | D-203 bullet 1; Rejected ("Carrying the configured `t_end`") and annotation 2026-10-13 (log 7771–7774) | B: U for the kind; R for "the bound is in the record's policy" |
| 558 | 10591–10594 | "`ModelRequestedStop` … The payload is the requester's component path, its port and its reason. When two requests hold at one boundary, the record names the first in roster order (D-316)." | plain | D-316 bullet 7; D-203 annotation 2026-10-08 | C |
| 559 | 10595–10596 | "`ControlRequestedStop` means a control-plane stop. The payload is its issuer (§12.1): the requesting device, `:code`, or `:interrupt`." | plain | D-203 bullets 1, 3 | U |
| 560 | 10597–10598 | "`LoopError` means the abnormal entry of §13.6. The payload is the propagated cause." | plain | D-203 bullet 1 | U |
| 561 | 10598–10603 | "A throw inside the frame reaches the record with the `Model` already marked `:inconsistent` … a loop fault outside the frame … closes the run as `stopped` with the `Model` consistent … (D-317). The record covers both exactly alike." | plain | D-317 bullets 6, 7; D-203 bullet 1 ("covers `errored` exactly as it covers `stopped`") | C; overlaps §13.4's disposition (10398) and §13.6 (H5) |
| 562 | 10605–10607 | "A `stopped` simulation therefore answers 'why did it stop?' without its consumer reconstructing the answer from the clock. It answers 'how did the stop go?' from the same value." | plain | D-203 Rationale (log 7738–7742); D-260 Rejected (log 10563–10566) | R |
| 563 | 10607–10610 | "The operator interrupt is a tag on an ordinary stop, not a kind of its own, because nothing failed. Appendix C gains nothing from it." | plain | D-203 bullet 2; Rejected ("A fifth source kind", "Termination sources as Appendix C diagnostics") | U for the tag; R for the reason. D-203 Rejected (log 7797) cites "the interrupt sentence in §13.5"; "kind" is linked to the diagnostic-kind entry (part A glossary) |
| 564 | 10612–10615 | "**Rule.** The sources are consulted in a fixed order … control stop at frame top, then `t_end`, then the stop requests at each publication. When two sources hold at one boundary, the recorded source is the first in that order (D-203)." | **Rule.** | D-203 bullet 5, amended by D-316 bullet 7 (log 13854–13856) | C; matches `_advance!` (`src/sim.jl` 1584–1652) |
| 565 | 10617–10618 | "The taught contract is this. **Stop requests are sampled at completed boundaries; declare a sign-form event if you need the stop localized.**" | bold sentence, 17 words, two clauses | D-060 Position (detection clause, standing; "sampled at completed boundaries" sat in the superseded policy clause); D-316 bullet 7 | U; no citation; whole-sentence bold joining two rulings by a semicolon; Appendix A 12702–12705 carries the taught contract |
| 566 | 10618–10622 | "Both shapes of the condition feeding a request work without framework latching. A handler-set `m` flag is sticky by nature. A transient stage-2 Bool is caught because the loop reacts to the first request it reads holding." | plain | none | N; consequence of row 527; "transient" means "true at one published boundary", not "true between boundaries" |
| 567 | 10622–10624 | "Compound stop logic composes in-model, as a monitor component reading the relevant signals and feeding one request. That is the same move §12.5 made for scripts." | plain | D-060 Rejected annotation (log 1922–1924) | R |
| 568 | 10626–10629 | "An ignored request is still a cell in every snapshot, so the log records when validity broke even on a run that continued. Two uses share the mechanism … The reason string is what tells a reader which, and the framework never will." | plain | D-316 Rationale (log 13907–13911) | R |
| 569 | 10631–10638 | "Post-terminal dynamics are the model's job … Today `robot2d` *throws* when it falls … The discipline forces models to have well-defined terminal states, which is better modeling." | plain | D-060 Rejected ("Termination-by-exception … models never state their terminal dynamics") | R; worked example. `robot2d` is FlightApps' self-balancing robot in Flight.jl, which throws `LostBalance <: SimulationTermination` past 45° of tilt (`lib/FlightApps/src/robot2d/robot2d.jl` 531, 557); "Today" dates the sentence |
| 570 | 10640–10646 | "The rejected mechanisms are litigated in D-060 and D-316. They are predicate closures …, root-type-declared stop policy, `terminal` event flags, a control-plane capability for components, and observation-by-path …. The `Bool` face re-exported level by level … fell to stop requests (D-316). D-060 also rejected blessed terminal types scanned from the tree." | plain | D-060 Rejected; D-316 Rejected and Supersedes | R; adversarial, a roll call of rejections (q26) |
| 571 | 10646–10650 | "The stop request supersedes that arm on its own terms. The requester is loud at inspection … Substitution is answered by the override, and disabling is one keyword. The trigger is the author's knowledge and the override the integrator's." | plain | D-316 Rationale (log 13902–13907) | R; row 533 says the last clause already |
| 572 | 10652–10656 | "The observation-by-path line leaves doctrine behind it, narrowed by D-316. **Inspection** is human-facing, has no effect on run semantics, and legitimately sees every public cell. The log …, GUI panels …, and replay inspection are all inspection." | bold term | D-060 Rejected ("Observation-by-path"); D-316 Rationale (log 13899–13902); D-083 Position | R; "GUI panels" names the parked GUI (F53) |
| 573 | 10656–10660 | "**A read the run acts on** changes what the run *does*, and it reads only what the model declared for it, never an arbitrary cell. The stop scan is the one such read. It reads the `StopFlag` block …" | bold term | D-316 Rationale (log 13899–13902) | R; the doctrine's rule has no Position (part E) |
| 574 | 10660–10662 | "The ignore list addresses the `Build`'s requester roster, a build product like the root-input list. It binds at an advance, a stopped-sim point where conditions already address state by path (§14.1)." | plain | D-316 Rationale (log 13899–13902); D-060 annotation (log 1913–1915) | R |
| 575 | 10662–10664 | "Output devices are the other half of the same doctrine. Their reads are inspection bindings on snapshot paths (§11.2)." | plain | D-083 Position | U |
| 576 | 10666–10669 | "The wall-clock channel (GUI stop button, device handle, code) is orthogonal and untouched. That is the control plane's operator path. The sim-time, model-detected channel specified here meets it at §12.4 and nowhere else." | plain | none; D-203 bullet 5 orders the two channels; D-316 Rationale names the control plane the operator's path | N; context-shaped; "GUI stop button" is the carried B83 (F53) |

D-060 is cited four times and rules rows 501–505; its headline ruling (row
503) is bold nowhere in the spec. D-316 is cited nine times and rules rows
507–540; bullets 5 and 7 (rows 527–528, 534–535) carry no citation where they
are stated. D-203 rules rows 551–564 and is cited only at the **Rule.**
(10615). D-233 (row 555) is cited here and nowhere else in the spec; D-083
(row 575) is not cited in the section.

Descriptions that read like rules: row 518's roster order (D-316 states it);
row 526 (the hit as a return value, D-261 and D-317 state it); row 531 (the
entry check, which no entry states); row 566 (the two shapes need no
latching); row 576 (the two channels "meet at §12.4 and nowhere else").

Display-block candidates: the enum (10461), `@enum StopFlag NO_STOP
STOP_REQUESTED`; the advance keywords as one signature, `run!(sim; t_end = Inf,
ignore_stop_requests = ())`, which Appendix B 13121 already spells; the four
sources as a short list of constructors with payloads. Each is an addition
the inventory declares.

Glossary terms in §13.5 (lesson 35). "First use" is the first use in the
section's prose, code excluded.

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| guard | 10451 | yes, no gloss | yes |
| predicate | 10452 | yes, no gloss | yes |
| localized | 10453 | yes, glossed | yes |
| boundary | 10455 | no; never linked in §13.5 | yes |
| snapshot | 10456 | yes, no gloss | yes |
| stop request | 10458 | yes, glossed | yes |
| port | 10458 | no; linked at 10655 instead | yes |
| cell | 10462 | no; linked at 10654 | yes |
| activation | 10462 | no | yes |
| pinned (`#g-walked`) | 10462 | no | yes |
| root input | 10470 | no; never linked | yes |
| roster | 10471 | no | **no**: the glossary's roster is the device roster (14427–14430); §13.5 means the requester roster nine times (10471, 10477, 10480, 10491, 10505, 10593, 10648, 10660 and the bold at 10477). Spell "requester roster", never bare "roster" |
| control plane | 10475 | yes, no gloss | yes; linked again at 10642 and 10667 (two extra links) |
| component | 10481 | no; linked at 10622 and again at 10643 | yes |
| replay | 10486 (`replay!`) | no; linked at 10656 | yes |
| termination record | 10498 | no; linked at 10577 | yes |
| frame | 10500 | no | yes |
| `t*` | 10500 | no (no glossary anchor of its own) | — |
| execution cursor | 10502 | yes, no gloss | yes |
| boundary zero | 10506 | yes, no gloss | yes |
| condition | 10459 ("where the condition is detected") | no | **two senses**: the stop condition, a `Bool` (10459, 10464, 10521, 10618), and the glossary's path-addressed overlay (10513, linked and glossed). §14 owns the word (glossary 14609–14613), so the first sense needs another word ("the stop's `Bool`", "the detected state") |
| override | 10516 | no | **no**: `#g-override` is the condition combinator (14637); §13.5 means the ignore keyword (10516, 10649, 10650). Keep unlinked and prefer "the ignore list" |
| operator interrupt | 10547 | yes, no gloss | yes; linked again at 10608 |
| diagnostic cell | 10549 | yes, no gloss | yes |
| trace header | 10568 | yes, no gloss | yes |
| holding (`#g-edge-semantics`) | 10593 ("hold"), 10621 | no | yes, as §12.6 9486 uses it |
| kind | 10584 | no; linked at 10609 | **borderline**: the glossary's kind is a diagnostic's identity in Appendix C's set (14700); 10584–10586 and 10609 mean a termination-source kind, which D-203 keeps outside that set. Link nowhere in §13.5, or say "source type" |
| payload | 10585 | no | yes, by extension (D-203 applies the convention) |
| blessed | 10646 | yes, no gloss | yes |
| `Build` | 10660 | no | yes |
| device | 10596 | no | yes |

"Stop word" is not used in §13.5 (it says "a pending control stop", 10613).
"Tail residue" (10580) has no entry; it is defined at 10581.

Appendix C kinds cited to §13.5:

| kind | Appendix C line | condition stated at | named there |
|---|---|---|---|
| `IllegalPortType` (reasons `:stop_flag_nested`, `:stop_flag_at_root`) | 13404–13412 | 10469–10471 | yes; the two reason symbols are not given (the code's message, run in part C, cites §13.5) |
| `StopRequestInvalid` | 13473–13476 | 10491–10493 | yes |
| `UnboundedRun` | 13663–13670 | 10545–10551 | yes |

Kinds whose condition §13.5 states but which Appendix C does not cite to it:
none. One the code cites to §13.5 and no spec sentence states: `t_end < 0` or
a non-real `t_end` is `ArgumentInvalid` at all three advances
(`src/sim.jl` 236–240, message "… (§13.5)"), refused before the ignore list
is looked at (run: part C). Appendix C's `ArgumentInvalid` (13595) does not
cite §13.5 and no section states the range (F54).

### §13.6 Abnormal shutdown: one tail, two entries (10671–10727, 391 words)

Purpose: why a loop-side failure can take §12.4's tail, what the abnormal
entry does, the record it writes, tail hygiene, and what an errored
simulation keeps and refuses.

Subheadings: none, and no context paragraph; the section opens on a bold
reason. One chart (10692–10703).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 577 | 10673 | "**The boundary is all-or-nothing outside the sim task.**" | bold sentence, no citation | D-030 Rejected ("Mid-frame abort: torn final snapshot"); no Position | R; "sim task" is FlightCore-era: the loop runs on the calling task (§11.1 6870, D-310), and "sim task" occurs nowhere else in the spec (F55) |
| 578 | 10673–10674 | "That is why a `StepError` cannot break §12.4." | plain | none | N |
| 579 | 10674–10677 | "Sweeps write into table blocks. Integration intermediates live in framework-owned integrator buffers, never in a component's workspace as §7.3 defines it." | plain | D-121 Rationale (log 3941–3943) | R; description (part H) |
| 580 | 10677–10681 | "The only externally visible act is snapshot publication at the very end of the sequence. A boundary that throws has published nothing. The last *published* snapshot is a complete, consistent boundary by construction …" | plain | D-030 Position (publish after completing the boundary); §2.4 523–526 states that intermediates are never published | U; Part I restates the law (H8) |
| 581 | 10683–10684 | "The abnormal path therefore **discards the failed boundary, promotes the previous snapshot to final, and rejoins the ordinary tail.**" | bold clause, 15 words, after "therefore" | D-030 Position ("loop failure runs the same protocol from the catch path"); no entry states discard and promote | B: U by D-030 for rejoining; N for discard-and-promote. "therefore" demotes the ruling to a consequence; §12.4 (7) 8950–8952 states it plain and points here, so this is the bold home |
| 582 | 10684–10686 | "The protocol becomes one tail with two entry points. Graceful entry follows a *completed* final boundary, and abnormal entry follows a *discarded* one." | plain | D-030 Position | U |
| 583 | 10686–10690 | "Everything downstream of 'final snapshot' runs identically: sticky stopped, waiters woken …, `unblock!`/close hooks, and named joins with timeout. Those waiters observe stopped rather than a new boundary, so no device task hangs." | plain, a colon list | D-030 Position | U; "close hooks" names no hook: since D-373 the tail calls `shutdown!` (§12.4 (4) 8920–8921) (F56) |
| 584 | 10692–10703 | the two-entry chart | chart | D-030 | cannot run; a fourth statement of tail steps (1)–(5) beside §12.4's list and one-line chart (H9) |
| 585 | 10705–10706 | "This fills the seat §12.4 reserved for it. A loop-side failure runs the same protocol from the catch path." | plain | D-030 Position, last clause | U; §12.4 (7) 8949–8950 says it citing D-030 |
| 586 | 10706–10709 | "The termination record covers this entry too. Its source is `LoopError`, and the payload is the propagated cause (§13.5, D-203)." | plain | D-203 bullet 1 | C; restates §13.5 row 560 |
| 587 | 10711–10713 | "Tail hygiene follows from the hooks being user code too. Each is individually caught and logged. Shutdown therefore runs to completion even if a device's hook misbehaves." | plain | none; D-372 (shutdown! tolerates a partial init) is adjacent, not this | N; realized by `_shutdown!` (`src/devices.jl` 371–381) and `_tail!`'s guarded `unblock!` (`src/sim.jl` 1429–1440) |
| 588 | 10713–10714 | "The join timeout already bounds a hook that hangs rather than throws." | plain | D-030 Position ("join with named timeout"); D-198 | U |
| 589 | 10716–10719 | "What is lost is quarantined. The state stores may hold mid-boundary values (a half-written `m`, integration intermediates). They are retained on the errored `Simulation` for post-mortem inspection, …" | plain | D-059 Rejected ("stores may be mid-boundary"); D-232 Rationale; D-108 Rationale | R. Scope: a loop fault outside the frame ends `stopped`, not `errored` (§13.5 10600–10603, D-317), so "the errored `Simulation`" covers only the in-frame case (F57) |
| 590 | 10719–10720 | "… but an errored sim is terminally stopped, not resumable. The reproduction tool is trace replay, not resurrection." | plain | D-059 Position ("Status goes terminal"); D-387 Position | U; §12.6 bolds "`errored` is terminal" (9411) and states the reproduction with D-387 (9411–9412) (H10). "terminally stopped" reads as the `stopped` state; the code's refusal message uses the same words (part C) |
| 591 | 10720–10722 | "The stopped-sim services enforce that non-resumability by refusing an errored simulation outright (`ServiceLifecycle`, §14)." | plain | D-108 Rationale ("`errored` is terminal for all four"); §14 bolds it (11185) | R; run: `init!`, `checkpoint` and `run!` refuse with `ServiceLifecycle` (part C) |
| 592 | 10722–10723 | "The roster operations refuse it with them (§11.3, D-232)." | plain | D-232 Position | C |
| 593 | 10723–10724 | "Inspection is reading, but `attach!` configures a run that cannot follow." | plain | D-232 Rationale (log 9111–9117) | R |
| 594 | 10724–10726 | "The published record (snapshot chain, log, trace) ends at the last consistent boundary. Nothing downstream of the sim ever sees half a boundary." | plain | D-030 Rejected ("Mid-frame abort") | R; run: an `Exploder` throw in frame 3 left `latest(sim).t` and the record's `t` at 0.2, the last completed boundary (part C) |

D-030 rules rows 580–588 and is cited nowhere in §13.6, though its Spec field
names it. D-059 and D-387, which rule row 590, do not list §13.6 in their Spec
fields (part D).

Descriptions that read like rules: row 579 (where intermediates live); row
587 (each hook caught and logged, which no entry states).

Display-block candidates: none beyond the chart.

Glossary terms in §13.6 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| boundary | 10673 | yes, inside the bold, no gloss | yes |
| sweep | 10674 | yes, no gloss | yes |
| component | 10676 | yes, no gloss | yes |
| workspace | 10676 | yes, no gloss | yes |
| snapshot | 10678 | yes, no gloss | yes |
| device | 10681 | yes, no gloss | yes |
| boundary counter | 10688 ("boundary-counter plus `Condition` path") | no | yes |
| termination record | 10707 | yes, no gloss | yes |
| store | 10716 | yes, no gloss | yes; "state stores" is a pleonasm |
| trace, replay | 10720 | yes, both, no gloss | yes |
| roster | 10722 ("roster operations") | no | yes (the device roster) |
| calling task | — ("sim task", 10673) | — | the stale "sim task" should be the calling task, linked |

Appendix C kinds cited to §13.6: none (checked: no Appendix C line cites
§13.6). The section names `ServiceLifecycle` (10722, whose entry cites §11.3,
§12.7 and §14) and `StepError` (10674). It states the join timeout (10713)
without naming `DeviceJoinTimeout`, whose home is §12.4.

### §13.7 Tooling consequences: face routes and the component library (10728–11005, 2,178 words)

Purpose: the two tooling commitments, rendering (`select`, `show`, face routes)
and the standard library (its admission, packaging, doctrine and the six
blocks), and the component test rig.

Subheadings: an unlabelled opening (10730–10764), "#### The standard component
library" (10766), "#### The component test rig" (10957). Five code blocks
(10821–10832, 10874–10884, 10901–10909, 10927–10934, 10977–10986).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 595 | 10730–10731 | "Termination chains are the second structural customer of computed interface connections, after generic-holding contracts." | plain | none | N; stale since D-316: a stop request is read where it is, with no re-export (10467–10468; D-316 Rationale log 13873–13880), so termination chains no longer use computed connections (F58) |
| 596 | 10731–10733 | "Computed connections are therefore prominent in this section. Two commitments follow, a library and an idiom." | plain | D-062 Position ("Three tooling commitments") | B: framing; D-062 counts three (predicate selection, the printer, the library), the sentence two (a library and an idiom) |
| 597 | 10735–10737 | "The passthrough helpers take a predicate. `select` is the third selector beside `except` and `only`, on `input_passthrough` and `output_passthrough` alike (§8.8, D-251)." | plain | D-251 Position; D-062 bullet 1 ("`faces` gains predicate selection", stale spelling) | C; §8.8 bolds "The selectors are exclusive" (3909) and states `select` (H11); D-251's Spec field lacks §13.7 |
| 598 | 10737–10740 | "It stays explicit at the declaration site, evaluated at build, and printable. That is the blessed side of the auto-bubbling line, where the author writes down the *rule* and the build evaluates it into inspectable data." | plain | D-322 bullet 1 (no auto-bubbling), uncited; D-251 Rationale | R; "auto-bubbling" is reader-cold here (defined by D-322, stated in §6.1) |
| 599 | 10742 | "**Every artifact renders itself through `show`** (§9.2, D-257)." | bold sentence | D-257 bullet 1, bold at §9.2 4513 | C; a double bold (H12, q27) |
| 600 | 10742–10749 | "`Structure` … has one. So does `Outputs` …. So does `Events` …, which prints each component's event names with their policies. So does `Schedule` …. So do `Build` and `Deployment` …. There are no accessor functions returning the tables alongside." | plain, five glossed links | D-257 bullet 1 and its amendments | C, adjacent; §9.2 4515–4527 lists the same (H12) |
| 601 | 10749–10753 | "`show(::Build)`'s parts include the events. Between the outputs table and the events table it prints a line of the feedthrough edges …. The edges are derived from the structure's connections and the producers' stage-2 names (D-261)." | plain | D-257 bullet 1, extension 2026-09-22; D-261 bullet 2 extension | C; run: the `feedthrough:` line sits between `Outputs` and `Events` (part C); §9.2 4524–4527 states it (H12); D-261's Spec field lacks §13.7 |
| 602 | 10755 | "**`show(::Structure)` owes face routes.**" | bold sentence | D-257 bullet 3 (amended 2026-09-30); D-062 bullet 2 ("The `Build` printer renders face routes") | C, adjacent (cited 10761). D-062 puts the routes on the `Build` printer, stale since D-257 |
| 603 | 10755–10757 | "For every root face, that means the resolved chain down to the producing terminal, printed as one line per chain (`crashed → aircraft/crashed → aircraft/monitor/out`)." | plain | D-257 bullet 3 | C, adjacent; run: `crashed → inner/crashed → inner/mon/tripped` (part C). The example face `crashed` is a pre-D-316 stop face |
| 604 | 10757–10759 | "Once faces are computed rather than hand-listed, 'what does this face actually reach' is a question the artifact must answer, not the reader." | plain | none (D-062 Rationale "Recorded only through the rejections") | N; constructive reason |
| 605 | 10760–10762 | "`show(::Structure)` derives each face's routing chain from the declared wires and prints the root's routes (D-257, D-315). Each line joins the hops with `→` and ends at the terminal." | plain | D-257 annotation 2026-10-07; D-315 bullet 3 | C; §9.2 4518–4520 says it (H12) |
| 606 | 10762 | "An input face that fans out prints one line per consumer." | plain | D-315 bullet 3 ("one per consumer for an input face") | C, adjacent; `implementation.md` 60 cites §13.7 for it |
| 607 | 10762–10764 | "The same rendering serves the wiring diagnostics, which already carry endpoint paths." | plain | none | N; not checked against every wiring kind. `UnconnectedInput`'s payload lists the faces the input was handed up through (13304–13307), a route of sorts; no kind is rendered through `face_routes` (`src/show.jl` 64–82 is the only caller found) (F59) |
| 608 | 10768–10769 | "**A standard component library makes good on the junction promise (§6.2).**" | bold sentence | D-062 bullet 3 and Rejected ("Per-site hand-written junctions: prices §6.2's explicit-junction doctrine dishonestly") | C, adjacent (D-062 cited 10772); the bold is a reason, not the ruling's headline ("ships as ordinary components", row 618) |
| 609 | 10769–10772 | "That promise rests on explicit junctions being *cheap*. A junction hand-written per arity per type is not cheap. The junctions, summing junctions and Bool gates alike, are the library's seed (D-062)." | plain | D-062 Rejected; D-062 bullet 3 | B: R for "cheap"; C for the seed |
| 610 | 10774–10777 | "The starting inventory holds the `Junction`, with `SumJunction{V, N}`, `Or{N}` and `And{N}` as its named forms, `UnitDelay{V}`, `Constant{V}`, `Freeze{V}` and `StopRequest`." | plain | D-062, D-143, D-266, D-311, D-312, D-316 | B: U by D-143 for `Constant` (uncited); C by the rest. "Starting" is historical: `src/blocks.jl` ships about twenty more (`implementation.md` 126–167); extensions.md 346 and migration_outline.md 20 cite "§13.7's starting inventory" |
| 611 | 10777 | "`UnitDelay` is the spelling the second loop-breaking remedy (§5.5) needs." | plain | D-348 bullet 1; §5.5 1486–1488 | U; §5.5 lists "an explicit unit delay" second of three routes, so the pointer holds |
| 612 | 10777–10778 | "`Constant{V}` is the source block. `Freeze{V}` is the declared stop-gradient (D-266)." | plain | D-143 Position; D-266 bullet 2 | B: U by D-143; C by D-266 |
| 613 | 10778–10782 | "`StopRequest` is the library spelling of a stop request (a port that ends the run when it reads `STOP_REQUESTED`, §13.5, D-316). The request is its port's `StopFlag` type, which any component may publish, so the block holds no privilege." | plain | D-316 bullet 5; Rationale | C; restates §13.5 rows 534, 540 (H3) |
| 614 | 10783–10784 | "**A block joins the library's inventory by judgement against three guidelines** (D-313)." | bold sentence | D-313 Position, first sentence | C |
| 615 | 10784–10788 | "The guidelines ask whether a block is domain-agnostic and generally useful, whether it has didactic value, and whether its implementation is difficult to get right. None is a requirement. They are weighed, not satisfied one by one, and a listed block is built whenever wanted." | plain | D-313 Position; Rationale (log 13608–13609, "weighed, not satisfied one by one") | C, adjacent; R for "weighed" |
| 616 | 10788–10789 | "The inventory, and the Simulink mapping that prunes it, is `companions/library_inventory.md`." | plain | D-313 bullet 1 | C, adjacent |
| 617 | 10789–10793 | "A one-line expression such as a gain earns no block, because a separate component costs a build entry, a cell, a gather and a scatter (§9.7). Domain components … belong in separate packages …. Simulink's library is a language, while this is a toolbox." | plain | D-313 Rationale (log 13596–13600, 13605–13608); D-062 Rejected ("Upfront Simulink-scale inventory: a language, not a toolbox") | R; library_inventory.md 21–22 quotes the last sentence verbatim (part D) |
| 618 | 10795–10797 | "The library is the submodule `Redstone.Blocks`, `Group` included, written against the extension-only surface (§8.1) as a user's component file is (D-313)." | plain | D-313 bullet 2 | C |
| 619 | 10797–10798 | "A workspace sub-package or a separate repository is an after-release question." | plain | D-313 bullet 2 | C, adjacent; "workspace" is Pkg's, not the glossary's (part A glossary) |
| 620 | 10800–10802 | "One member is admitted by persona rather than by need. `Group` is the on-the-fly assembly, and its declaration-layer treatment lives in §8.5 (D-184)." | plain | D-184 Position and Rationale (log 7015–7017, "its one persona-admitted member") | C; "rather than by need" assumes the demonstrated-need charter D-313 retired (F60) |
| 621 | 10802–10804 | "`Group` serves the model assembler, for whom topology is data rather than a named type. It needs no rule the declaration layer does not already have." | plain | D-184 Rationale (log 7013–7016) | R; D-184's annotation (log 7019–7023) records `Group` declaring its `children` name-transparent, "one opt-in declaration where this entry claimed zero new declaration rules". The declaration exists for any assembly, so the sentence holds read as "no new rule"; it fails read as "no declaration beyond the basics" |
| 622 | 10806–10807 | "The doctrine is that **library blocks are ordinary components**, with no framework privileges and no special vocabulary." | bold clause | D-062 bullet 3 ("ships as ordinary components"); D-316 Rationale (log 13885–13888, "§13.7's doctrine … stands") | U; no D-citation in the sentence or paragraph |
| 623 | 10807–10811 | "Ordinary status is what keeps schema authority total …. That same status makes the library a permanent ergonomics torture test. If a three-input OR gate is painful to write under the declaration rules, the rules are wrong." | plain | D-062 Rejected ("Framework-privileged library blocks: schema authority no longer total; the library stops testing the declaration layer's ergonomics") | R |
| 624 | 10813 | "**Arity and port types come from type parameters** (D-311)." | bold sentence | D-311 bullet 1; D-062 bullet 3 ("arity by type parameter") | C. The carried item says §6.2 bolds this ruling; at `1fee0fc` §6.2 states it plain (1647–1649), so this is its only bold (part E) |
| 625 | 10814–10816 | "`Junction{In, Out, N, F}` builds `(in1 = In, …, inN = In)` programmatically and applies the fold its instance holds, so `Or{N}` is the junction at `|` and `And{N}` at `&`, each a constant alias." | plain | D-311 bullets 1, 2 | C, adjacent; run: matches `src/blocks.jl` 32–81 (part C) |
| 626 | 10816–10819 | "A gate exists for its consumer, which wants one consolidated `Bool` input instead of several. That is a derivation §8.2 blesses, and an early validation that the contract functions support parametric components." | plain | D-311 Rationale (log 13486–13488); D-062 Position ("computed contracts") | R |
| 627 | 10821–10832 | the `Junction` sketch | code | D-311 | ran: builds and folds; its declarations equal `Blocks.Or{3}`'s (part C) |
| 628 | 10834–10836 | "The parameters are the nominal port types and the arity, as in `SumJunction{Wrench{Float64}, 3}`, and the fold is instance data (D-311)." | plain | D-311 bullets 1, 3 | C |
| 629 | 10836–10837 | "`Wrench` is FlightPhysics' force-and-torque type, here parametrized by its scalar type as a walked type of §7.2." | plain | none; chapter 6's R12 gloss | N; an introducing clause, carried |
| 630 | 10838–10840 | "`SumJunction{V, N}` is the `Junction` at `+`. A custom fold, such as a weighted blend or a mass-properties composition, is written at the site as `Junction{In, Out, N}(f)`, which infers `F`." | plain | D-311 bullets 1, 2; Rationale | C, adjacent; run: `Junction{Float64, Float64, 2}(max)` infers `F` |
| 631 | 10842–10843 | "The junction is a continuous leaf, so its contracts are written at nominal `Float64` and the leaf walk retypes them (§8.2)." | plain | D-263 Position (Spec lists §13.7) | U |
| 632 | 10843–10845 | "An input entry at `Wrench{Float64}` is the tolerant form a promoting consumer writes. Walking, frozen and root-input contributors are all admissible behind it." | plain | D-263; D-264 Position (a frozen arrival admitted at a tolerant entry) | U |
| 633 | 10847–10851 | "A named site-specific junction documents a fixed contributor set better than generated slots, at the price of hard-coding it into a type (D-037). … Both are plain components, and the framework is not involved." | plain | D-037 Position ("generic positional or named site-specific — plain components") | C; "slots" is pre-D-206 vocabulary for root inputs, here meaning generated input ports |
| 634 | 10853–10857 | "Wrench, mass properties and internal angular momentum each get their own junction, never one bundled contribution struct (D-037, D-323). Contributors are ragged …. A bundled struct would force zero-filled identity values through every port, the 'silently sum nothing' hazard in a new coat." | plain | D-323 bullet 3 | C; D-323 bullet 3 is bold nowhere (§6.2 does not state it), so this is its bold home (q24) |
| 635 | 10859–10863 | "A `sum_ports!`-style helper would instantiate a junction, wire it and export its total in one call. **Such a helper is guarded-addition sugar** …, added when real models show the pattern repeated (D-037)." | bold clause | D-037 Position ("helper/macro sugar guarded") | C |
| 636 | 10865–10868 | "Tier-transparency falls out of settled semantics. A stateless continuous `y_direct` recomputes every sweep. Fed ZOH-held discrete signals, its output therefore changes only at ticks. No tier-neutral class is needed." | plain | D-062 bullet 3 ("stateless-continuous hence tier-transparent"); D-143 Position cites "§13.7's existing tier-transparency argument" | U; "ZOH" unexpanded; "tier-neutral class" uses *class* in the leaf-category sense the glossary keeps unlinked (part A glossary); §8.2 3066 cites it |
| 637 | 10870–10872 | "`UnitDelay{V}` is a **discrete** leaf at `K = 1`. It is the tier's native `z⁻¹` (§10.6), the shape an anti-windup chain's previous-saturation port hand-writes. It needs no framework support." | bold word | D-312 bullet 2 (the spelling); none for the description | N; pid_anti_windup.md 83–84 cites it |
| 638 | 10874–10884 | the `UnitDelay` sketch | code | D-312 bullet 2 | ran: matches `src/blocks.jl` 152–159 (part C) |
| 639 | 10886–10887 | "**The delay holds its initial value as instance data** (D-312), so `UnitDelay(v0)` needs no `zero` method on `V`." | bold clause | D-312 bullet 2 | C |
| 640 | 10887–10888 | "The store is isbits by rule (D-231), which bounds `V`." | plain | D-231 Position | C; D-231's Spec field lacks §13.7; the kind is `IllegalStoreField`, unnamed |
| 641 | 10890–10891 | "`UnitDelay`'s tier semantics are the point, and they must be stated wherever the remedy is recommended (D-348)." | plain | D-348 bullet 1 | C; §5.5 bolds "A unit delay is a modeling decision" (1492), the same bullet (H13) |
| 642 | 10891–10896 | "Inserting a `UnitDelay` into a *continuous* loop moves that signal onto the discrete tier and inserts a `Δt_base`-scale ZOH …. That is a modeling decision …. The cycle diagnostic (§13.8) therefore says so rather than offering the remedy as free." | plain | D-348 bullet 1 and Rationale | C, adjacent |
| 643 | 10898–10899 | "`Constant{V}` is the **source block**. It has no inputs, no state, and a stage-1 body returning the value the instance holds." | bold term | D-143 Position | U; D-143 is not cited in §13.7 |
| 644 | 10901–10909 | the `Constant` sketch | code | D-312 bullet 1 | ran: `Pinned{Float64}` port, matches `src/blocks.jl` 134–139 |
| 645 | 10911–10912 | "`Constant` is a stateless continuous leaf, so the tier-transparency argument above already covers discrete consumers. No discrete variant is needed." | plain | D-143 Position ("no discrete variant") | U |
| 646 | 10912–10914 | "The block's output *is* its stored value, so **the leaf is deliberately pinned at that value's own type** (D-312)." | bold clause, after "so" | D-312 bullet 1 | C; "so" demotes the ruling |
| 647 | 10915–10919 | "A `Constant{Float64}` declares a `Pinned{Float64}` port and means it. A constant is never seeded, so it carries zero partials under any `Dual` activation …. The honest pin is spelled rather than inferred." | plain | D-312 Rationale (log 13537–13545) | R |
| 648 | 10920–10922 | "The same holds for every library block whose output depends on neither its continuous state nor a walking input, such as a step source or a relay, and each declares its `out` pinned (D-312)." | plain | D-312 annotation 2026-10-06 (log 13568–13574) | R (cited, but only the annotation states it) |
| 649 | 10924–10925 | "`Freeze{V}` is the **declared stop-gradient**. It feeds a walking producer into a pinned entry, which the walk clause (§6.1) otherwise refuses." | bold term | D-266 bullet 2 | U in the paragraph (D-266 cited 10778); the refused case is `WalkingFaceAtFrozenEntry`, unnamed |
| 650 | 10927–10934 | the `Freeze` sketch | code | D-312 bullet 3 | ran: matches `src/blocks.jl` 170–174; strips a `Dual` leafwise; `Freeze{Plant}` is a `TypeError` |
| 651 | 10936–10937 | "At nominal the strip is the identity, so the block costs one gather and one scatter." | plain | D-266 Rationale (log 11101–11103) | R |
| 652 | 10937–10939 | "**`V` is a `Real` or a `StaticArray` of them, constrained at the type** (D-312), so a struct-valued freeze is refused at the spelling until a model needs one." | bold sentence | D-312 bullet 3; Rejected ("Writing the allocation-free leafwise map now") | C; R for "until a model needs one" |
| 653 | 10939–10942 | "Under a `Dual` activation it drops the partials, and its output satisfies the pinned entry. What the wire then declares is a zero coupling in every Jacobian along that path, the modelling decision §14.10 asks an author to state on the page …." | plain | D-266 bullet 2 | U |
| 654 | 10942–10944 | "A sampler is the other non-walking source, and it changes the model, holding the value between ticks (§10.5); the block is for a continuous value the consumer cannot differentiate through." | plain | D-266 Rationale (log 11104–11107) | R; a semicolon join |
| 655 | 10944–10946 | "Where the coupling matters to the Jacobian, the local rule (§14.10) is the answer, not this block." | plain | D-266 bullet 1 | U |
| 656 | 10948–10950 | "Two demonstrated needs admit `Constant` under the inventory's demonstrated-need charter. The zero-contributor configurations (§6.2) are one." | plain | D-143 Rationale (log 5212–5214, "strictly from demonstrated need charter"), retired by D-313 ("Whether a model already demonstrates a block is no condition", log 13609–13610) | R; stale (carried item, F60) |
| 657 | 10950–10952 | "There, a required aggregate input has no physical contributor, and the zero total must be spelled as a wire. The rig stub below is the other." | plain | D-143 Rationale; §6.2 bolds the spelling (1731–1734, D-143) | R; H14 |
| 658 | 10952–10955 | "The block's value is instance data, like junction arity, not an overridable default. A configuration wanting an externally settable source uses a root input (§11.3). That keeps the block from drifting into a back-door input default." | plain | D-143 Position, clarification (ii) | U. Scope: a root input must be isbits-handled; a bulk-data handle cannot be one and enters through a `Constant` (D-364 Position; D-237) (F61) |
| 659 | 10959–10960 | "**The component test rig is the library's companion idiom.**" | bold sentence | D-120 Position; D-208 bullet 3 | U; neither is cited in the subsection except D-208 at 10962 |
| 660 | 10960–10962 | "Exercising a leaf alone needs no rig of its own. Any component may be the root of a build, and its input faces then become the model's root inputs (§8.2, D-208)." | plain | D-208 Position | C |
| 661 | 10962–10964 | "Ordinary conditions and devices feed them, and every output is observable in the snapshot table." | plain | none | N |
| 662 | 10964–10967 | "The rig is a one-child assembly whose `input_wires` surface the child's entire input face set, as `input_passthrough(rig, "child")` verbatim (§8.8). What it buys is a place to wire something *beside* the component under test." | plain | D-120 Position (spelled `faces(rig, child; except)`, stale) | U; the glossary (14604) says "exporting the child's entire input face set" |
| 663 | 10969–10972 | "The demonstrated need is the root-input rule (§8.2). An *abstract* input entry (`terrain = AbstractTerrainField`, §8.2) cannot surface as a root input, because abstract-at-root is a build error. The rig therefore satisfies that entry *inside* the rig." | plain | D-120 Position; abstract-at-root is §8.2's (D-120 Rejected: "D-078 stands") | U; `AbstractAtRoot` unnamed (lesson 20, F62) |
| 664 | 10972–10975 | "A concrete stub child (a `SampleTerrainField` provider) is wired to the face, and the concrete remainder is exposed via `input_passthrough(rig, "strut"; except = ("terrain",))`." | plain | D-120 Position | U |
| 665 | 10977–10986 | the `StrutRig` sketch | code | D-120 | cannot run as written (`Strut`, `SampleTerrainField` are Flight.jl names); its shape ran as `test/fixtures.jl`'s `TerrainRig` (1411–1424): builds, root inputs `dut.k` only |
| 666 | 10988–10990 | "That stub child is typically just a `Constant` holding the test handle, which makes it the source block's first shipped instance. Bespoke stubs remain ordinary components wherever the double must compute something." | plain | D-143 Rationale (log 5208–5212); D-364 Position (a bulk-data handle enters a rig through a constant source) | B: R by D-143; U by D-364, cited nowhere in §13.7 and whose Spec field lacks it |
| 667 | 10992–10997 | "The rig adds zero new machinery, because wiring and `except` already exist. It is the substitutability contract doing its job. An abstract entry … declares that a substitute must be chosen. The rig chooses its test double explicitly, as ordinary inspectable code." | plain | D-120 Position ("zero new machinery, the substitutability contract read as …") | U |
| 668 | 10999–11004 | "The rig is `design_world`'s little sibling (§14.9). … The machinery is deliberately ordinary end to end, with no framework support. That makes the rig, like the library blocks, a standing ergonomics test of the declaration rules." | plain | D-120 Rejected ("§13.7's no-framework-support charter") | R |

D-143 rules rows 610, 612, 643, 645, 658 and is cited nowhere in §13.7. D-120
rules rows 659, 662–664, 667 and is cited nowhere in §13.7. D-062 is cited
once (10772) and rules rows 596, 602, 608–609, 622–623, 636.

Descriptions that read like rules: row 607 (the wiring diagnostics share the
rendering); row 637 (the delay needs no framework support); row 661.

Display-block candidates: the three selectors as one call form,
`input_passthrough(asm, "child"; select = name -> …)`; one printed route line
(10757 already inlines it). Each is an addition the inventory declares.

Glossary terms in §13.7 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| contract | 10731 | yes, no gloss | yes |
| predicate | 10735 ("take a predicate") | no | **distinct usage**: a predicate over face names, not a guard's predicate; keep unlinked, as the glossary entry asks for its other distinct usages (14093–14098) |
| selector | 10736 | no | **distinct usage**: `#g-selector` is the read-selector family (14446); keep unlinked |
| blessed | 10739 | yes, no gloss | yes |
| artifact | 10742 | no | yes |
| `Structure` | 10742 | yes, glossed | yes |
| component | 10743 (inside the `Structure` gloss) | no; linked at 10768 | yes |
| face | 10743 (inside the gloss) | no; linked at 10755 and again at 10961 | yes |
| `Outputs`, `Events`, `Schedule`, `Deployment` | 10744–10748 | yes, each glossed | yes |
| execution order | 10744 (inside the `Outputs` gloss) | no | yes |
| nominal | 10744 ("the nominal evaluation's product") | no | "nominal evaluation" names the build step; `#g-nominal` is the `Float64` activation (14244). §13.8 links it this way (row 676) |
| `Build` | 10748 | no | yes |
| feedthrough | 10751 | yes, glossed | yes |
| summing junction | 10771 | no | yes |
| stop request | 10779 | yes, glossed | yes |
| cell | 10791 | no | yes |
| workspace | 10797 ("A workspace sub-package") | no | **distinct usage**: a Pkg workspace; keep unlinked |
| assembly | 10801 | yes, no gloss | yes |
| schema authority | 10808 | yes, glossed | yes |
| torture test | 10810 | yes, no gloss | yes |
| leaf walk | 10843 | no | yes |
| sweep | 10866 | yes, no gloss | yes |
| tick | 10867 | yes, no gloss | yes; linked again at 10944 |
| tier | 10865 ("Tier-transparency") | yes, no gloss | yes |
| class | 10868 ("tier-neutral class") | no | the leaf-category sense `spec_style.md`'s trap names; keep unlinked |
| store | 10887 | no | yes |
| `Δt_base` | 10892 | no | yes |
| pinned (`#g-walked`) | 10913 | yes, no gloss | yes |
| activation | 10917 | yes, glossed | yes |
| root input | 10954 | yes, no gloss | yes |
| component test rig | 10959 | yes, no gloss | yes |
| device, snapshot | 10963–10964 | yes, no gloss | yes |
| condition | 10962 | no | yes |
| abstract entry | 10994 | yes, glossed | yes |
| `design_world` | 10999 | yes, no gloss | yes |
| guarded addition | 10861 | yes, glossed | yes |
| constant source | 10898 ("source block") | no | the glossary's term is "constant source" (`#g-constant-source`); the section says "source block" |

Appendix C kinds cited to §13.7:

| kind | Appendix C line | condition stated at | named there |
|---|---|---|---|
| `AbstractAtRoot` (its remedy hint, "in a rig a stub child, §13.7") | 13327–13329 | 10969–10971 ("abstract-at-root is a build error") | **no** (F62) |

Kinds whose condition §13.7 states but which Appendix C cites elsewhere:
`WalkingFaceAtFrozenEntry` (10925, "which the walk clause otherwise refuses";
its message names the `Freeze` remedy, §8.2 2603–2608), `IllegalStoreField`
(10887, the isbits store), `EmptyFaceSelection` and `UnknownFaceSelection`
(not stated; §8.8 is their home). A named clause for `WalkingFaceAtFrozenEntry`
is optional, since §8.2 states it.

### §13.8 Cycle diagnosis: feedthrough tracing (11006–11141, 1,164 words)

Purpose: how a rejected cycle is named, the tracer's two modes and reach, how
classification runs and decides, and what the diagnostic carries.

Subheadings: five `####` labels (11022, 11034, 11053, 11072, 11107), and a
context paragraph ending in a parts sentence (11017–11020). No code block.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 669 | 11008 | "The build rejects an algebraic loop (§5.5)" | plain | D-005 Position, bold at §5.5 1484 | U; a pointer |
| 670 | 11008–11009 | "and tracing is diagnostic only, never relied on for correctness (D-012)." | plain | D-012 Position ("diagnostic-only"), bold at §5.5 1507 | C; already plain here |
| 671 | 11009–11010 | "Tracing improves error messages and verification." | plain | none | N; "verification" names nothing the section describes |
| 672 | 11010–11012 | "When the build finds a cycle, it triggers the feedthrough tracer … to classify that cycle." | plain | D-012 Position | U, adjacent |
| 673 | 11012–11015 | "A genuine cycle gets 'break it with a state, a stage-1 (`y_state`) port, or a `UnitDelay`', and an artificial one gets the remedy ladder (§5.4)." | plain | D-140 Position; D-343 bullet 5 | U; run: the real message ends "… or a `UnitDelay`, which moves the signal onto the discrete tier and inserts a Δt_base-scale zero-order hold (§5.5)" (part C) |
| 674 | 11015–11017 | "Where the diagnostic recommends a unit delay, it states the delay's tier caveat rather than offering it as a free remedy (§5.5, §13.7, D-348)." | plain | D-348 bullet 1 | C |
| 675 | 11017–11020 | the parts sentence | plain | — | framing; names four parts for five `####` labels ("the tracer's two modes and what tracing touches" covers two) |
| 676 | 11024–11025 | "A cycle surfaces as a topological-sort stall in the nominal evaluation (the build's second step, the one evaluation that feeds structure)." | plain | D-012 Position ("the Stratum-B topological stall") | U, adjacent; the link is `#g-nominal`, whose entry is the `Float64` activation (part A glossary) |
| 677 | 11026 | "The stalled subgraph is decomposed into strongly connected components (SCCs)." | plain | D-012 Position | C, adjacent |
| 678 | 11027 | "**Each nontrivial SCC names one cyclic cluster exactly** (D-012)." | bold sentence | D-012 Position ("one SCC = one named loop") | C |
| 679 | 11028–11029 | "Each cluster becomes one diagnostic, an `AlgebraicCycle` error (Appendix C)." | plain | D-012 Position | C, adjacent |
| 680 | 11029–11031 | "The diagnostic presents the cluster's members and the wires among them as one readable loop of terminal pairs in the canonical slash form (§8.6, `aero/F → dyn/F, dyn/a → aero/a`)." | plain | none states the rendering; D-012 names the loop | N; run: `d/y → g/e, g/out → d/b` (part C); a citation inside the example's parentheses |
| 681 | 11031–11032 | "Neither the raw stall residue nor a single back edge names the cluster correctly (D-012)." | plain | D-012 Rejected (both) | R; adversarial, one clause |
| 682 | 11036–11037 | "**The feedthrough tracer has two modes**, and they degrade gracefully (D-349)." | bold clause | D-349 bullet 1 | C; "degrade gracefully" is unexplained until the local bullet |
| 683 | 11037–11038 | "Both are set-tracers. A traced value carries a set of input indices, its tracer tags." | plain | D-349 bullet 1 | C, adjacent |
| 684 | 11040–11045 | "The *global* (value-blind) set-tracer is a `Real` subtype …. It has may-depend semantics, a sound over-approximation. A saturated `clamp` still reports, and $u^2$ at $u = 0$ still reports. It is exact, in one evaluation. It requires the traced stage-2 code to be free of branches and lookups on *input-tainted* values." | plain | D-349 bullet 1 | C, adjacent; `src/tracer.jl` 19–31 (`Tracer{true}`); the `$…$` math is the only TeX in the chapter |
| 685 | 11046–11051 | "The *local* (primal-carrying) set-tracer at sampled states is the fallback whenever the global tracer hits an undecidable branch …. Its only misses are untaken branches (D-012, D-349)." | plain | D-349 bullet 1; D-012 Position ("sampled-local") | C. The code samples eight states at a fixed seed (`src/tracer.jl` 210–218); "randomized states" is that |
| 686 | 11055–11056 | "**Only *inputs* are seeded** (D-349), so branching on state, modes, parameters or time never interferes." | bold clause | D-349 bullet 2; Rationale for the "so" | C |
| 687 | 11056–11060 | "Stage-2 functions also receive state views, but neither those nor the stage-1 hand-down are ever seeded. Stage-1 functions are never traced …. Derivatives, guards …, handlers and projections are outside tracing's jurisdiction entirely." | plain | D-349 bullet 2 | C, adjacent |
| 688 | 11062–11064 | "A known tracer blind spot is documented. Value-severing operations pass dependence through a bare `Int` index, as a nearest-neighbor lookup does." | plain | D-349 bullet 2, last sentence | C (D-349 cited 11055) |
| 689 | 11064–11065 | "Linear and cubic interpolation are immune, because dependence flows through the fractional weights." | plain | D-349 Rationale (log 14768–14769) | R |
| 690 | 11067–11070 | "**Dual-cleanliness in CI effectively guarantees traceability** (D-349). Dual-clean means passing the `T = Dual` sweep of §7.2. The guarantee holds because both modes ride the same `T <: Real` genericity as `Dual` …." | bold sentence | D-349 bullet 3 | C; "sweep" here is §7.2's genericity sweep, not `#g-sweep` |
| 691 | 11074–11075 | "Classification needs no execution order, the order in which the stage functions run (D-012)." | plain | D-012 Position ("schedule-free") | C |
| 692 | 11075–11084 | "It runs inside the nominal evaluation's failure path …. each SCC member is evaluated *once, in isolation*, at the probe point …. in-cycle cell values synthesized through `probe_value` (§9.3) under tracer tags. The tracer's product is a per-member dependence set rather than a value, so no ordering has to be valid …." | plain | D-012 Position ("each member evaluated once in isolation; in-cycle cells from `probe_value` under tracer tags") | C, adjacent; mechanism (part H) |
| 693 | 11086–11087 | "**The traced maps decide the verdict as one graph question over the cluster** (D-245)." | bold sentence | D-245 Position, first sentence | C |
| 694 | 11087–11093 | "The verdict is the one §5.4 defines. Every wire holds. A hop inside a member runs from the face … that one wire enters to the port the next wire leaves. The hop holds iff that member's map routes the face to the port. The loop is real iff a cycle survives in that graph. It is artificial iff none does …." | plain | D-245 bullet 1 | C; §5.4 1443–1450 states the same verdict citing D-245 (H15) |
| 695 | 11094–11096 | "**The diagnostic lists every dead hop under either verdict**, so a real loop still shows the chords the trace found false (D-245)." | bold clause | D-245 bullet 2; Rationale for the reason | C |
| 696 | 11096–11097 | "For a simple cycle this reduces to the expected reading, that the loop is real iff every hop survives." | plain | D-245 Rationale (log 9640, 9645–9647); D-012's superseded verdict clause | R |
| 697 | 11099–11101 | "Classification touches no activation machinery. There is no activation …, no layouts and no table." | plain | none; D-012 "schedule-free" | N; mechanism; `src/tracer.jl` 1–8 says the same |
| 698 | 11101–11105 | "The cycle classifier uses the *local* variant of tracing (D-012), the order-free per-member trace at the probe point. The 'tracer activation' (§9.4) names the other variant (D-012), the global set-tracer run as an ordinary activation. The two must not be conflated. The local variant is not the local set-tracer mode. A member's map may come from either mode." | plain | D-012 Position ("classified by a schedule-free per-member local trace") | C; "local" names two different things four lines apart (F63). §9.4 4793–4797 states the variant pair |
| 699 | 11109–11111 | "The diagnostic carries the tracer's caveats rather than assuming them away. The trace speaks for the branch taken at the probe point (the diagnostic-only doctrine, D-012, D-343)." | plain | D-343 bullet 8; D-140 Rejected | C; D-343 bullet 8 is bold nowhere (q24) |
| 700 | 11111–11113 | "**Discrete members trace structurally**, because the discrete tier's plain, wholesale-pinning declarations admit no tracer scalar (D-012)." | bold clause | D-012 Position ("conservative on discrete members (pinned signatures admit no tracer scalar)") | C |
| 701 | 11113–11114 | "Structural tracing is sound as a may-depend answer but never sharp, so the remedy hint is offered only for continuous members (D-140, D-343)." | plain | D-343 bullet 5 | C; D-343 bullet 5 is bold nowhere (q24) |
| 702 | 11114–11117 | "A continuous face or port declared with no walking leaf … admits no tracer scalar either, so the hops through it trace structurally too (D-245, D-343)." | plain | D-343 bullet 9; D-245 Rationale | C; bold nowhere (q24) |
| 703 | 11119–11120 | "**The diagnostic records the source of each member's map** (D-245). The source is the global tracer, sampled states or structure." | bold sentence | D-245 bullet 3 | C; the payload field is `traced`, `:global`, `:sampled`, `:structural` (`src/diagnostics.jl` 891–905) |
| 704 | 11120–11121 | "A reader can thus weigh a dead hop found on a few sampled paths against one found exactly." | plain | D-245 Rationale (log 9650–9651) | R |
| 705 | 11121–11124 | "The hint itself is to split this component, *or* to narrow the neighbor's contract … when the dead hop's input is consumed only in a fallback branch. Those are the ladder's two remedies (§5.4, D-140, D-343)." | plain | D-343 bullet 5; D-140 Rationale | C |
| 706 | 11126–11131 | "The build diagnostic offers both exits explicitly (D-140, D-343). For a loop between `systems/aero` and `systems/dyn` it reads 'artificial at port level: …'. The dead hop is the member with the input face that it does not route to the output port." | plain | D-343 bullet 5 | C; run: the message's form matches (part C). The last sentence calls a hop a member: a dead hop is a (member, face, port) triple (D-245, Appendix C 13421–13425) (F64) |
| 707 | 11132–11134 | "The diagnostic carries the dead hop (D-245) as a separate field of its payload … rather than dotting the hop onto the path (§8.6, §13.2)." | plain | D-245 bullet 2 (the list); the separate-field rule is §13.2's payload convention | B: C for the list; U by the payload convention for the field |
| 708 | 11136–11138 | "If a member's evaluation itself throws, the diagnostic ships with its members and wires alone, unclassified. Classification is a bonus on the cycle error, never its precondition (D-012)." | plain | D-012 Position, last chained ruling ("classification optional on the error") | C; that ruling is bold nowhere (q24) |

D-012 is cited ten times and rules rows 670–692, 698–700 and 708. D-349
rules rows 682–690, D-245 rows 693–707. D-343 is cited five times and states
three rulings here (rows 699, 701, 702) that are bold nowhere in the spec.

Descriptions that read like rules: row 680 (the rendering of the loop), row
697.

Display-block candidates: the two quoted messages (11013–11014,
11128–11130), as verbatim fenced output. Each is an addition the inventory
declares.

Glossary terms in §13.8 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| algebraic loop | 11008 | no | yes |
| feedthrough tracer | 11011 | yes, glossed | yes; the glossary's "global value-blind, or local primal-carrying" names the modes, not the variants |
| port | 11013 | no | yes |
| tier | 11016 | no; linked at 11112 | yes |
| nominal | 11024 ("nominal evaluation") | yes, glossed as the build step | **mismatch**: `#g-nominal` is the `Float64` activation (14244–14249) |
| component | 11093 | no | yes; "strongly connected components" (11026) is the graph sense and must not be linked |
| guard | 11058 | yes, glossed | yes |
| projection | 11059 | yes, no gloss | yes |
| execution order | 11074 | yes, glossed | yes |
| probe | 11078 | yes, glossed | yes |
| cell | 11080 | no | yes |
| face | 11088 | yes, glossed | yes |
| trace | 11095 ("the chords the trace found false") | no | **distinct usage**: the tracer's result, not `#g-trace` (the input recording); every "trace" in §13.8 is this sense, and none may be linked |
| sweep | 11068 ("the `T = Dual` sweep of §7.2") | no | **distinct usage**: the CI genericity sweep, not `#g-sweep`; keep unlinked |
| activation | 11099 | yes, glossed (a second gloss of the same text as §13.7's) | yes |
| walked | 11115 | yes, glossed | yes |
| contract | 11122 | yes, glossed | yes |
| payload | 11133 | yes, glossed | yes |

Appendix C kinds cited to §13.8:

| kind | Appendix C line | condition stated at | named there |
|---|---|---|---|
| `AlgebraicCycle` | 13421–13425 | 11024–11029 | yes. Its payload (members, wires, classification, dead hops, per-member mode) matches rows 680, 695, 703 |

### Tally

| section | rules | C | U | S | R | N | B |
|---|---|---|---|---|---|---|---|
| §13.5 | 73 | 28 | 22 | 1 | 15 | 3 | 4 |
| §13.6 | 17 | 2 | 6 | 0 | 6 | 2 | 1 |
| §13.7 | 69 | 30 | 16 | 0 | 12 | 6 | 5 |
| §13.8 | 39 | 27 | 4 | 0 | 4 | 3 | 1 |
| total | 198 | 87 | 48 | 1 | 37 | 14 | 11 |

The count leaves out ten rows that are code, a chart, a label or framing
(536, 545, 546, 584, 627, 638, 644, 650, 665, 675), and classes each row by
its first code, counted by script over the tables above. "C, adjacent" counts
as C.

The U rows cluster in five entries: D-316 (rows 507, 527–529, 534–535, 540,
§13.5's bullets 5 and 7 stated uncited), D-203 (551, 553–554, 556, 559–560,
563, cited only at the **Rule.**), D-030 (580–583, 585, 588, cited nowhere in
§13.6), D-143 (610, 612, 643, 645, 658) and D-120 (659, 662–664, 667), both
cited nowhere in §13.7. The R rows cluster in D-316's Rationale (511, 515,
533, 568, 571–574), D-060's Rejected list (549, 567, 569, 570, 572), D-062's
Rejected list (609, 617, 623) and D-312's Rationale and annotation (647, 648,
652). The one S row is row 524 (D-261's superseded mask bullet). §13.8 is the
best-cited section of the half: 27 of 39 rows C.

Bold weight now: 44 spans, 316 words. Labels: **Rule.** ×1, **Why one binding
site.** ×1. Bold list lead-ins ×5 and bold terms ×4 (two in the inspection
doctrine, the `StopPolicy` link, "source block"), plus "**discrete**" and
"**declared stop-gradient**". The rest are rulings, five of them spans of 14
words or more (rows 508, 513, 517, 565, 581).

## B. Overlaps

Overlaps are numbered H1 to H29. "Home" is where the rewritten text of
chapters 1 to 12 already put the fact, or, inside chapter 13, where this
survey proposes it.

### Inside half 2

- **H3. `StopRequest` holds no privilege.** §13.5 10542–10543 (row 540) and
  §13.7 10778–10782 (row 613) both say the block holds no privilege because
  any component may publish a `StopFlag` port. Home: §13.5, which defines the
  request; §13.7 keeps the inventory entry and the gloss, and drops the
  second "so the block holds no privilege".
- **H5. `LoopError` and the abnormal entry.** §13.5 10597–10603 (rows
  560–561) gives the source, its payload and the in-frame/outside-frame
  split; §13.6 10705–10709 (rows 585–586) repeats the source and payload.
  Home: §13.5 for the record, §13.6 for the entry; §13.6 keeps a pointer.
  The split (`errored` versus `stopped`) also bears on §13.6 10716–10720
  (F57).
- **H9. The tail's steps.** §13.6's chart (10692–10703) and 10686–10689
  restate steps (1)–(5), which §12.4 lists (8892–8936) and charts in one line
  (8957–8962). The §13.6 chart adds what §12.4's lacks, the two entries
  merging, so it earns its place; the colon list at 10686–10689 is the
  double.
- **H13. The unit delay's caveat.** §13.7 10890–10896 (rows 641–642) and
  §13.8 11015–11017 (row 674) state D-348 bullet 1 plainly; §5.5 bolds it
  (1492–1493). D-348's own Rationale records that §5.5 and §13.7 "each
  stated the caveat citing only the other". Home: §5.5 (bold). §13.7 keeps
  the tier semantics as the block's description, §13.8 the clause that the
  diagnostic states the caveat.

### With half 1

- **H4. The unbounded run.** §13.2 10165–10168 (half 1) lists "Unbounded run
  (§13.5)" with its `:replay` exemption and "lands in the loop's own cell,
  because `run!` mutates state (D-255)"; §13.5 10545–10553 (rows 541–544)
  states the same. Home: §13.5; §13.2's list item is the catalogue entry and
  points here.
- **H6. Inspection versus the reads a run rests on.** §13.3 10204–10248
  (half 1) splits resolution into wiring, service and inspection clients on
  D-083's line; §13.5 10652–10664 (rows 572–575) splits reads into
  inspection and "a read the run acts on" on the same line. Two framings of
  one doctrine, neither citing the other. Home: §13.3 for the resolution rule,
  §13.5 for the stop scan as the one run-acting read; each gets a pointer at
  the other (q28).
- **H16. FlightCore's `SimulationTermination`.** The chapter roadmap
  (9917–9921) says §13.5 replaces it; §13.5 10445–10447 (row 501) says it has
  no counterpart, in bold; §12.4 (7) 8952–8954 calls it the precedent. Home:
  §13.5 for the ruling (D-060's last chained clause); the roadmap and §12.4
  keep their clauses.
- **H29. The boundary-zero failure.** §13.4 10376–10382 (half 1) says a throw
  inside boundary zero has "no snapshot to promote" and retains the stores
  "as an errored simulation's are (§13.6)". It leans on §13.6's promote and
  quarantine sentences (rows 581, 589). A rewrite of either keeps the words
  "promote" and "retained".
- **§13.4's disposition** (10398–10408, half 1) and §13.5's `LoopError`
  bullet (row 561) both say a loop-side failure ends `stopped` or `errored`.
  Folded into H5.

### With other chapters

| H | half-2 lines | other lines | what | home chosen by the rewritten text |
|---|---|---|---|---|
| H1 | §13.5 10485–10499, 10565–10574 (rows 520, 525, 547–550) | §12.6 9579–9588 | the per-advance stop policy, its keywords, its lifetime, and why one `Simulation` wants different policies (the carried B82) | §12.6, bold at 9581 with D-255 and D-316. §13.5 keeps what §12.6 lacks: the ignore list's semantics (row 522), `StopRequestInvalid` (row 523) and the mask (row 524); the lifetime and the "Why one binding site" paragraph reduce to a pointer (q22) |
| H2 | §13.5 10567–10569 (row 548) | §11.5 7757–7760; Appendix B 12872–12874 | the trace header carries no policy | §11.5; §13.5 keeps the pointer |
| H7 | §13.5 10504–10509 (rows 527–529) | §2.4 537–543 | the scan after every published boundary, boundary zero and `t*` included; the first honoured request ends the run; its snapshot final, no rollback | Part I states the law at Part I's depth. §13.5 restates it at the same depth in rows 528–529 ("The terminal snapshot is the terminal state. There is no roll-back"). §13.5's own content is the mechanism: roster order, the `StopFlag` block, the snapshot just published, the entry check. Flag under "Part I's depth": keep the mechanism, point to §2.4 for the law |
| H8 | §13.6 10677–10681, 10724–10726 (rows 580, 594) | §2.4 523–526 | intermediates are never published; nothing downstream sees half a boundary | Part I states the law; §13.6 gives the reason the abnormal path can rely on it. Keep §13.6's argument as mechanism; drop "Nothing downstream of the sim ever sees half a boundary" or point to §2.4 |
| H10 | §13.6 10719–10720 (row 590) | §12.6 9411–9413; §14 11185 | `errored` is terminal; reproduction is trace replay, not resurrection | §12.6, bold at 9411 (D-059) with D-387. §14's bold is the carried B84 (chapter 14's). §13.6 states both plain with a pointer |
| H11 | §13.7 10735–10740 (rows 597–598) | §8.8 3909–3931 | `select` as the third, exclusive selector | §8.8, bold at 3909 (D-251). §13.7 keeps a one-sentence pointer |
| H12 | §13.7 10742–10753, 10760–10762 (rows 599–601, 605) | §9.2 4511–4527 | each artifact renders itself; the list of `show` methods; the `feedthrough:` line; routes derived from wires | §9.2, bold at 4513 (D-257 bullet 1). §13.7's bold at 10742 is a double; §13.7 keeps the face routes, which §9.2 points to (4520) (q27) |
| H14 | §13.7 10948–10955 (rows 656–658) | §6.2 1731–1745 | the zero-contributor `Constant` wire; not the banned default | §6.2, two bolds with D-143. §13.7 keeps the block's admission and the instance-data clause, citing D-143 |
| H15 | §13.8 11087–11097 (rows 694, 696) | §5.4 1443–1450 | the hop-by-hop verdict | §5.4 states it plain with D-245 and is a cross-cutting chapter; §13.8 bolds D-245's headline (row 693) where the classification runs, which `spec_style.md` asks. Both keep their statements: §5.4 the definition, §13.8 the run (no change proposed) |
| H17 | §13.5 10612–10615 (row 564) | §12.4 8896–8903 | the three initiation events; the consultation order | §12.4 lists the events; §13.5 is the order's home (**Rule.**, D-203) |
| H18 | §13.5 10576–10578 | §12.1 8654–8656 | `ControlRequestedStop` outside the stop policy | §12.1, bold (D-255). §13.5 does not restate it; no change |
| H19 | §13.5 10462–10464 (row 510) | §4.3 886–889 | an enum is one leaf, pinned; `StopFlag` the one enum with a framework meaning | §4.3 states it plain; §13.5 keeps it as the reason the requests share one block |
| H20 | §13.5 10481–10484 (row 519) | §8.2 2903–2910 | `stop_reason`'s default, its sharing, instance data | §8.2, bold at 2905 (D-316 bullet 3). §13.5 is already plain; keep as a pointer-level clause |
| H21 | §13.5 10617–10618 (row 565) | Appendix A 12702–12705 | the taught contract: sampled at completed boundaries, a sign-form event to localize | Appendix A carries taught contracts by convention; §13.5 keeps the statement and its bold (q24) |
| H22 | §13.5 10551–10553 (row 544) | §12.7 9683–9690; Appendix C 13663–13670 | `UnboundedRun` silent under `:replay` | §13.5 (D-316 bullet 9); §12.7 states replay's keywords |
| H23 | §13.7 10952–10955, 10988–10990 (rows 658, 666) | §14.9 (mounting), §4.4; D-364 | a rig's environment: a root input only for isbits handles, a constant source for bulk data | §14.9 and §4.4 (D-364's Spec field). §13.7 should point there (F61) |
| H24 | §13.7 10924–10946 (rows 649–655) | §8.2 2550–2556, 2603–2608; §14.10 12569–12590 | `Freeze` and the local rule as the two doors | §8.2 bolds D-266's headline (2551–2552); §14.10 owns the local rule. §13.7 keeps the block |
| H25 | §13.8 11101–11105 (row 698) | §9.4 4793–4797 | the tracer activation versus the cycle classifier | §9.4 states the pair; §13.8 keeps it with the terminology repaired (F63) |
| H26 | §13.8 11067–11070 (row 690) | §7.2 1872–1874 | the tracer rides `T <: Real` genericity | §7.2 points to §13.8; §13.8 is the home (D-349 bullet 3) |
| H27 | §13.7 10800–10804 (rows 620–621) | §8.5 3320–3380 | `Group` | §8.5 (D-184); §13.7 keeps the persona clause |
| H28 | §13.5 10536 (row 537) | §6.1, §6.2 1677–1678 | an unconsumed output is legal and silent | §6.1 (D-084); §13.5 keeps the clause |

**Part I's depth.** Three places in half 2 restate Part I at Part I's depth
instead of giving the mechanism: rows 528–529 (H7), and rows 580 and 594
(H8). Row 503 ("Graceful termination is model *state*") is §13.5's own
headline and Part I states no equivalent sentence; it stays. No sentence in
half 2 states a semantic law that Part I lacks, as far as checked: the entry
check (row 531) is a consequence of §2.4's "boundary zero … included", and the
source order (row 564) changes only which source the record names, not the
values a run produces.

## C. Proposed structure

No section is renumbered and none is retitled. 291 inbound rows point at
the half's sections (part D). No file links a `####` anchor of §13.5–§13.8:
the only `spec.md#13…` links outside the spec are section-level link
definitions (checked with `rg 'spec.md#[a-z]'` over `docs/`, which finds no
chapter-13 subheading), so `####` labels can be added or retitled freely.

### Moves

| move | content | from | to | needs a ruling |
|---|---|---|---|---|
| M51 | the two channels: "The wall-clock channel … meets it at §12.4 and nowhere else" | §13.5 10666–10669 (row 576) | up, into §13.5's context paragraph, before the bullets, with "a front end's stop" for "GUI stop button" (F53) | no |
| M52 | the `StopRequest` block: lead-in, sketch and its properties | §13.5 10519–10543 (rows 534–540) | up, directly after the publication paragraph (ends 10468), which says "(below)" of it | no |
| M53 | the source order (**Rule.**) | §13.5 10612–10615 (row 564) | up, directly after the scan and the entry check (10504–10517), where the sources are consulted; the label goes | no |
| M54 | the taught contract and its two shapes | §13.5 10617–10624 (rows 565–567) | up, after M53, before the unbounded run: it reads the scan to the author | no |
| M55 | the per-advance policy: keywords, defaults, lifetime, "Why one binding site" | §13.5 10485–10499 and 10565–10574 (rows 520, 525, 547–550) | merged into one policy paragraph that points to §12.6 for the declaration and lifetime and keeps the ignore list, `StopRequestInvalid`, the mask and the `t*` hit | yes, q22 |
| M56 | the rejected mechanisms | §13.5 10640–10650 (rows 570–571) | reduced to one sentence pointing to D-060 and D-316; the constructive clauses (the requester loud at inspection; the trigger the author's, the override the integrator's) fold into M57's doctrine | yes, q26 |
| M57 | the inspection doctrine | §13.5 10652–10664 (rows 572–575) | stays last, with a pointer to §13.3's client split (H6) | yes, q28 |
| M58 | §13.6's reason paragraph (all-or-nothing) | §13.6 10673–10681 (rows 577–580) | after the ruling (10683–10690), so the rule comes first; a one-sentence context opens the section | no |
| M59 | the errored quarantine's terminal and reproduction clauses | §13.6 10719–10720 (row 590) | trimmed to a pointer to §12.6, which bolds them (H10) | no |
| M60 | the `show` list | §13.7 10742–10753 (rows 599–601) | trimmed to one sentence pointing to §9.2, the bold dropped (H12) | yes, q27 |
| M61 | `Constant`'s admission and instance-data clause | §13.7 10948–10955 (rows 656–658) | up, directly after the `Constant` paragraph (ends 10922), before `Freeze`: the paragraph is about `Constant`, and the rig stub it names follows later | no |
| M62 | the variant terminology | §13.8 11099–11105 (rows 697–698) | up, to follow the classification's mechanism (ends 11084) and precede the verdict (11086): the reader meets "the local variant" right after "evaluated once, in isolation", which is what it names | no |
| M63 | the overlaps with half 1 (H4, H5, H6, H16, H29) | — | each kept in its home with a pointer at the other | yes, q28, ruled with the sibling |

All moves stay inside one section, so each stays inside one unit. M63 changes
only half 2's text; the matching half 1 pointers belong to the sibling's
units.

### Order within each section

Define-before-use was checked for each order below against the terms each
block uses.

- **§13.5.** Context: the FlightCore idiom has no counterpart (D-060's last
  clause, bold); graceful termination is model state (D-060's headline, q24);
  exceptions from model code are abnormal (bold); the two channels (M51). A
  parts sentence. Then, as `####` labels or as bold-free topic sentences
  (q23): *Detection and publication* (10451–10468, the `StopFlag` enum, then
  `StopRequest` by M52); *Placement and the requester roster* (10469–10484);
  *The policy per advance* (M55, with "honoured" and "ignored" defined, which
  the scan uses next); *Sampling and the source order* (10504–10517, M53, M54);
  *Unbounded runs* (10545–10563, with the fixed example, F52); *The
  termination record* (10576–10610); *What the discipline buys* (10626–10638:
  the ignored request as a cell, post-terminal dynamics); *Inspection and the
  run's reads* (M57, M56). "Requester roster" is introduced at its first use
  (row 517) and never shortened to "roster". "Holding" is glossed at 10593
  or 10621 if linked.
- **§13.6.** One context sentence: a loop-side failure arrives mid-boundary,
  and the run must still end through §12.4's tail. The ruling (row 581, its
  bold kept without "therefore"). Why it is safe (M58). The chart. The record
  (row 586, a pointer). Tail hygiene (rows 587–588). What is quarantined
  (rows 589–594, with M59 and F57). "Calling task" replaces "sim task" (F55).
- **§13.7.** Context: the two commitments, rendered routes and a library
  (F58 replaces the termination-chain sentence). `select` as a pointer (H11).
  `show` as a pointer (M60), then the face routes (rows 602–607), under a
  `####` label "Face routes" if q23 adds labels. "#### The standard component
  library": the promise (row 608), the guidelines (rows 614–617), the
  inventory (row 610, "starting" kept or dropped by q29), the package (rows
  618–619), `Group` (rows 620–621), the doctrine (rows 622–623), then the
  blocks in inventory order: `Junction` and its sketch, the bundled-struct
  rejection, the helper, tier-transparency, `UnitDelay`, `Constant` with M61,
  `Freeze`. Tier-transparency (row 636) must stay before `Constant` (row 645
  says "above"). "#### The component test rig" unchanged in order.
- **§13.8.** Context and parts sentence (fix the count, row 675). Detection
  and naming. The two modes. What tracing touches. Classification: the
  mechanism (rows 691–692), the variants (M62), the verdict (rows 693–696).
  Caveats and hints. "Local" is qualified at each use: "the per-member
  (local) variant" against "the local, primal-carrying mode" (F63).

### Rewrite units

| unit | lines (original) | moves in | moves out | words |
|---|---|---|---|---|
| F | 10443–10727: §13.5, §13.6 | M51–M59 within | — | 2,449 |
| G | 10728–11141: §13.7, §13.8 | M60–M62 within | — | 3,342 |

Total 5,791 words. Units H to K are unused.

G runs 342 words over the 3,000 ceiling. M60 and the H3 and H11 trims take
about 150 words out of §13.7, and §13.8 is the half's best-cited section (27
of 39 rows C) with no code, so its rewriting cost is low. The alternative is
three units: F = §13.5 (2,058), G′ = §13.6 + §13.7 (2,569), H′ = §13.8
(1,164). It parts §13.6 from §13.5, with which it shares the termination
record and H5, and leaves H′ far under the floor. Splitting §13.7 at "####
The component test rig" instead is not clean: the rig's stub is the
`Constant` that M61 moves, and the rig alone is 346 words. Recommendation:
F and G (q30).

### Code blocks, charts and tables

The half holds six code blocks, one chart and no table:

- 10523–10534: the `StopRequest` sketch, a `julia` fence. Runnable; carry
  verbatim (M52 moves it whole).
- 10555–10563: the policy example, a `julia` fence of five calls on free names
  `world` and `cond`. Its first line, `Simulation(world; h = 0.02)`, is
  refused by the package (F52); a ruled edit to `h = 1//50` makes it run.
- 10692–10703: the two-entry chart, a plain fence. `norm.py` treats it as
  prose; carry verbatim.
- 10821–10832: the `Junction` sketch. Runnable; carry verbatim. Its comment
  cites §8.2.
- 10874–10884: the `UnitDelay` sketch. Runnable; carry verbatim.
- 10901–10909: the `Constant` sketch. Runnable; carry verbatim; its comment
  cites §8.2.
- 10927–10934: the `Freeze` sketch. Runnable; carry verbatim.
- 10977–10986: the `StrutRig` sketch, on Flight.jl's `Strut` and
  `SampleTerrainField`. Not runnable as written; its shape is
  `test/fixtures.jl`'s `TerrainRig`. Carry verbatim; the two names need an
  introducing clause (q31).

Inline math: `$u^2$` and `$u = 0$` (11043), the only TeX in the chapter;
`z⁻¹` (10871) and `K = 1` (10870) as plain text.

New display blocks (part A candidates): the `StopFlag` enum, the advance
keywords, the four sources (§13.5); the selector call (§13.7); the two
messages (§13.8). Each is an addition the inventory declares.

### Running the half's code

Loaded with `test/repl.jl` inside `module H2Check` (script
`scratch_survey/h2/run/blocks.jl`, run with `julia --project=test -t 2`;
output in `scratch_survey/h2/run/output.txt`). Each check printed PASS or the
value; none failed except as noted.

- **10523–10534, `StopRequest`: ran and passed.** The sketch, defined as
  `StopRequestSketch`, built in a `Group` with a sawtooth and an `Overload`
  monitor. The roster read `[Requester("stop", :flag, "sketch")]`; the run
  ended `ModelRequestedStop("stop", :flag, "sketch")` at `t ≈ 0.315`, the
  localized crossing. `Blocks.StopRequest`'s declarations equal the sketch's.
- **10555–10563, the policy example: failed as written.**
  `Simulation(overloaded(); h = 0.02)` threw `DeploymentInvalid(:h,
  :inexact, 0.02)`: "`h` must be exact — a Rational (`h = 1//100`) or a
  `Period`/`Hz` value" (F52). With `h = 1//50`: `run!(t_end = 60)` stopped on
  the request; `ignore_stop_requests = ("stop",)` ended `EndTimeReached` with
  `policy.ignored == ["stop"]`; `step!(frames = 100)` stopped after 16
  frames with `StopPolicy(Inf, String[])`; `run!(pace = 1.0,
  ignore_stop_requests = :all)` ran until a `stop!` from another task and
  ended `ControlRequestedStop(:code)`; the run's first published status
  carried `UnboundedRun: 1 occurrence` in the loop's cell, its message naming
  the ignored requester (`run/unbounded.jl`).
- **10692–10703, the chart: cannot run.**
- **10821–10832, `Junction`: ran and passed.** The sketch's `u_types` equal
  `Blocks.Or{3}`'s; it built and folded with `|`; `SumJunction{Float64, 3} ===
  Junction{Float64, Float64, 3, typeof(+)}`; `Junction{Float64, Float64,
  2}(max)` inferred `F`.
- **10874–10884, 10901–10909, 10927–10934: ran and passed** against
  `Redstone.Blocks`: `UnitDelay(1.5)` has `s_init == (v = 1.5,)` and ports
  `in`, `out`; `Constant(2.0)` declares `(out = Pinned{Float64},)`;
  `Freeze{Float64}` is tolerant in and pinned out and strips an
  `SVector` of `Dual`s to `SVector(1.0, 1.0)`; `Freeze{Plant}` is a
  `TypeError`.
- **10977–10986, the rig: cannot run as written** (Flight.jl names). Its
  shape, `TerrainRig`, built; `TerrainGain` alone raised `AbstractAtRoot`
  with the remedy "in a test rig, a stub …"; the rig's root inputs are
  `dut.k` only.
- Claims checked in passing:
  - Ignore-list validation: two unknown paths raised two
    `StopRequestInvalid`, collected; `("stop", "stop")` collapsed to
    `["stop"]`; `t_end = -1` beside an unknown path raised the
    `ArgumentInvalid` alone, its message citing §13.5 (F54).
  - **The entry check off boundary zero**: `tick_alarmed()` after
    `step!(frames = 12, ignore_stop_requests = :all)` sat at `t = 1.2` with its
    request holding; the next `run!` ended at `t = 1.2`, zero frames,
    `ModelRequestedStop`, and a `step!` there advanced 0 frames and ended the
    run `stopped` (F51). After `init!` with `at("mon", set(m = (tripped =
    true,)))`, `run!` ended at `t = 0.0` as §13.5 says.
  - Placement: `SVector{2, StopFlag}` raised `IllegalPortType` reason
    `:stop_flag_nested`; a `StopFlag` root input `:stop_flag_at_root`; a
    `StopFlag` input fed by a `StopRequest` built.
  - The abnormal entry: an `Exploder` armed in frame 3 threw
    `StepError{Exploded}`; the lifecycle read `errored`; the record's `t` and
    `latest(sim).t` were 0.2, the last completed boundary; its source
    `LoopError` carried the `StepError`. `init!`, `checkpoint` and `run!`
    each refused with `ServiceLifecycle` ("terminally stopped, never
    resumable or re-initialized … (§13.6, §12.7)"); `state(sim, "")` read.
  - `show`: a nested `Group` printed `input routes: sig → inner/sig →
    inner/mon/sig` and `output routes: crashed → inner/crashed →
    inner/mon/tripped`; `show(::Build)` printed `feedthrough: none` between
    the `Outputs` and `Events` tables.
  - `select`: `input_passthrough(r, "t"; select = n -> n == "a")` built.
  - `AlgebraicCycle`: the artificial case printed "algebraic loop among `d`,
    `g`: d/y → g/e, g/out → d/b — artificial at port level: `d`'s `y` does
    not route `b`; split `d`, or narrow the neighbor's contract if `b` is
    consumed only in a fallback branch (§5.4)", the form 11128–11130 quotes;
    the real case ended with the `UnitDelay` caveat.

## D. Inbound citations

The rows analysed are the 291 rows of `inbound.tsv` whose target is §13.5,
§13.6, §13.7 or §13.8 (copied to `scratch_survey/h2/mine.tsv`). The eight bare
§13 rows are half 1's.

By file: `decisions.md` 144 (Spec 72, Rationale 31, Position 21, Rejected 16,
Annotation 4), `spec.md` 83, `implementation.md` 32, the companions 26
(`library_inventory.md` 5, `pid_anti_windup.md` 5, `longitudinal_aircraft.md`
4, `frame_walkthrough.md` 3, two each in `examples_inventory.md`,
`handle_walk_walkthrough.md`, `limited_integrator_variants.md` and
`migration_outline.md`, one each in `linear_blocks.md`, `lqr_tracker.md` and
`sample_time_proposal.md`), `extensions.md` 3, `pending.md` 1. The 83
`spec.md` rows: Part I 8, Part II 17, Part III 27, Part IV outside chapter 13
6, Appendix A 3, Appendix B 8, Appendix C 5, the glossary 9.

By target: §13.5 138, §13.6 20, §13.7 101, §13.8 32 (in `spec.md` alone: 49,
7, 20, 7; in `decisions.md`: 60, 11, 56, 17).

Ranges recorded at their ends only: `implementation.md` 875 ("§13.4–§13.6")
also covers §13.5.

### Citations relying on moved or trimmed content

M55, the policy reduced to a pointer:

| file:line | fact relied on | after M55 |
|---|---|---|
| spec 9584 (§12.6) | §12.6's own bold cites §13.5 for the `StopPolicy` each call builds and passes to the loop | holds only if §13.5 keeps the binder, the ignore list and the mask. If §13.5 points back to §12.6 for the policy, the two point at each other (chapter 11's R30); the brief should say which half each keeps |
| spec 7758 (§11.5), 12874, 13129–13130, 13140 (Appendix B), 14485, 14554 (glossary), 9849 (§12.7) | the keywords and their per-call validation | hold; §13.5 keeps the ignore list's semantics |
| log 10231 (D-255 Position), 10251 (D-255 Rationale), 4155 (D-127), 8390 (D-217), 2898 (D-091, superseded) | §13.5's second binding site, "the honest cost" | historical; nothing in today's §13.5 |

M56, the rejected mechanisms reduced:

| file:line | fact relied on | after M56 |
|---|---|---|
| spec 11218 (§14.1), 11562 (§14.4); log 2053 (D-065), 2679 (D-083), 13899 (D-316 Rationale) | §13.5's observation-by-path rejection, narrowed | holds: M57 keeps the doctrine, and the one-sentence pointer must still name observation-by-path |
| spec 9474 (§12.6); log 3051 (D-095 Rejected), 3089 (D-096 Rejected), 15691 (D-390 Position, "the closure-evaluation API whose cost §13.5 rejects") | §13.5 rejects predicate closures (`stop_when`) | holds only if the pointer names predicate closures. Note that §13.5 never states the closures' cost; D-060's Rejected list does ("opaque, unserializable, a public snapshot API"). D-390's wording relies on the list alone |
| log 1922 (D-060 Rejected annotation) | "from §13.5's inline treatment, migrated" | historical |

M59, the errored clauses trimmed:

| file:line | fact relied on | after M59 |
|---|---|---|
| spec 7326 (§11.3), 9154, 9179 (§12.4), 13001 (Appendix B); log 9111–9112 (D-232 Rationale), 3941 (D-121 Rationale); glossary 13836 | an errored simulation's stores retained for post-mortem; integration intermediates in integrator buffers; the roster operations refuse it | hold: rows 579, 589 and 592 stay |

M60, the `show` list trimmed:

| file:line | fact relied on | after M60 |
|---|---|---|
| spec 4520 (§9.2), `implementation.md` 60, 769, 779 | §13.7 for the face routes, one line per chain, one per consumer | hold: rows 602–606 stay |

M61 and M62 reorder within their sections; no row names a moved sentence by
position. Row 595 replaced (F58): no row relies on "termination chains"
(`rg -i 'customer'` over the inbound rows finds none for §13.7).

Rows that quote §13.7 verbatim or by phrase, which a rewrite must keep or
the citing file must follow:

| file:line | phrase |
|---|---|
| `library_inventory.md` 21–22 | "Simulink's library is a language, while this is a toolbox" (row 617) |
| `extensions.md` 346; `migration_outline.md` 20; spec 3326 (§8.5) | "§13.7's starting inventory", `Group` "its one persona-admitted member" (rows 610, 620) |
| spec 3057, 3066 (§8.2) | the tier §13.7 steers stateless leaves to; "§13.7 records why one stateless continuous leaf already serves consumers" (row 636) |
| `pid_anti_windup.md` 83–84 | "§13.7 names `UnitDelay` as the shape of its previous-saturation port" (row 637) |
| log 9663 (D-245 Rejected), 14764 (D-349 Rationale) | "the sampled miss §13.8 documents" (row 685) |
| log 7797 (D-203 Rejected) | "the interrupt sentence in §13.5 already ruled the appendix gains nothing" (row 563) |
| log 11326, 11389 (D-268) | "§13.5's consultation order" (row 564) |

The corrections part G proposes touch these rows:

- F51 (the entry check off boundary zero): spec 12695–12698 (Appendix A,
  stage totality) and log 4794 (D-138 Rationale, annotated) lean on the
  terminal-at-`t₀` path; both hold for a run that starts after `init!`.
- F53 (the parked GUI): half 1's 10210 and 10403 use the same GUI; the carried
  B83 counts "GUI stop button" twice, and §13.5 has it once (10666) beside
  "GUI panels" (10655).
- F58 (termination chains): none.

### Citations already wrong before the rewrite

The inbound check will flag these whatever the rewrite does; they belong to
track 2 or to the other chapter.

| file:line | claim | what half 2 says |
|---|---|---|
| spec 5385 (§9.7) | "The seam is diagnostic only (§13.5)" | §13.5 says nothing of the measurement seam. Two readings: §13.5's inspection doctrine ("has no effect on run semantics", 10653) read loosely, or a stale number. §9.7 is rewritten; a loose fix there |
| spec 11338 (§14.2) | "`set`/`at`/`combine` are §13.7 standard-library material" | §13.7's library is `Redstone.Blocks`, components only; the condition algebra lives in `src/conditions.jl` and §14 |
| spec 12351 (§14.9) | a `product(…)` helper "belongs in the §13.7 library" | D-071 Position (log 2274) records it so, but §13.7's library holds components, not helpers; consistent with the log, inconsistent with §13.7 |
| `migration_outline.md` 80 | "Falling-edge consumers wire a NOT gate (the Bool gates, §13.7)" | D-311 bullet 2 rejects `Not` ("a one-input gate consolidates nothing"); §13.7 lists `Or{N}` and `And{N}` |
| `extensions.md` 334 | "the §13.7 migration" | §13.7 has no migration; the parametric spelling it once carried fell with D-263 (D-311 bullet 3) |
| log 5050 (D-141 Rationale) | "§13.7's grow-by-migration-demand rule" | retired by D-313 |
| log 5212–5214 (D-143 Rationale) | "§13.7's strictly from demonstrated need charter" | retired by D-313; §13.7 10948–10949 still says it (F60) |
| log 11844 (D-274 Position) | "`checkpoint(sim)` is a stopped-sim service (§13.7)" | already annotated (log 11919, "reads §14") |
| log 1974–1976 (D-062 Position) | "`faces` gains predicate selection"; "The `Build` printer renders face routes" | `select` is on the passthrough helpers (D-251); the routes print in `show(::Structure)` (D-257). D-062's annotation (log 1985–1989) covers neither |
| log 3912 (D-120 Position) | "`faces(rig, child; except)`" | the helper is `input_passthrough` (§8.8) |

### Log entries whose Spec field would change

- Under M51–M62: none; every move is inside its section.
- Under the citations part E adds: D-059 and D-387 gain §13.6 (row 590);
  D-364 gains §13.7 (rows 658, 666); D-322 gains §13.7 (row 598); D-201
  gains §13.5 if cited at row 530; D-264 gains §13.7 (row 632).

Spec fields stale before any move, entries that rule a half-2 sentence citing
them without listing its section (track 2): D-019, D-084, D-147, D-218 (all
cited in §13.5, none lists it); D-231, D-251, D-261 (cited in §13.7, none
lists it).

## E. Log repairs and factual problems

Log repairs go to the second track, after landing. The rewrite only adds
citations; it states no repair. Factual problems stay as written and go to
the units' `rulings.md`, unless part G pre-rules them.

### Entries to cite at the rule

From part A's U rows: D-316 (rows 507, 527–529, 534–535, 540; bullets 5 and
7 are stated with no citation), D-203 (551, 553–554, 556, 559–560, 563; cited
only at the **Rule.**), D-060 (503–505), D-255 (541, 548), D-136 or D-201
(530), D-083 (575), D-030 (580–583, 585, 588; cited nowhere in §13.6), D-059
and D-387 (590), D-062 (622, 636), D-143 (610, 612, 643, 645, 658; cited
nowhere in §13.7), D-120 (659, 662–664, 667; cited nowhere in §13.7), D-263
(631), D-264 (632), D-266 (649, 653, 655), D-348 (611), D-364 (666), D-322
(598), D-005 (669), D-012 (672, 676), D-140 and D-343 (673).

### Superseded and half-superseded citations

- No citation in the half is to an entry whose status reads superseded.
- **D-261** (cited 10497 for the ignore mask as the loop's second argument,
  row 524): D-316's Supersedes line (log 13867–13868) retires "D-261's bullet
  making `StopPolicy` `t_end` and the stop faces with the faces' compiled
  addresses as the loop's argument". The mask is D-316 bullet 7's. Cite D-316.
- **D-261** (cited 10502 for the `t*` hit): its clause typing the hit "a face
  or `nothing`" is superseded by D-317 (log 14018–14019); the cited clause
  (a return value, never a cursor field) stands, and D-317 is cited beside it.
- **D-060** (cited 10572 for "one notch later along the same axis"): the
  argument is D-091's Rejected list (log 2909–2911), and D-091 is superseded
  by D-255. D-060's own Rejected list says only "stopping is run policy;
  absolutes bind at deployment".
- **D-203** (cited 10615 and 10709): its Position's "three-field value — the
  final boundary time, absent when no boundary ever ran" is amended by D-233
  (log 9132–9134, "this amends D-203's first field"), and D-203 carries no
  annotation naming D-233 (its annotations are 2026-10-02, -08, -13).
- **D-255** (cited four times) and **D-060** (four times) are amended in part
  by D-316 and annotated; the clauses the half cites stand.

### Rulings that need an entry stating them in a Position

1. The inspection doctrine: inspection sees every public cell; a read the run
   acts on reads only what the model declared; the stop scan is the one such
   read; the ignore list addresses the requester roster (rows 572–574): D-060
   Rejected ("Observation-by-path"), D-316 Rationale (log 13899–13902).
2. Compound stop logic composes in-model (row 567): D-060 Rejected annotation
   (log 1922–1924).
3. An ignored request stays a cell, and the reason string tells the two uses
   apart (row 568): D-316 Rationale (log 13907–13911).
4. Post-terminal dynamics are the model's job (row 569): D-060 Rejected.
5. The operator's path is the control plane (row 515): D-316 Rationale.
6. `EndTimeReached`'s bound is read off the record's policy (row 557): D-203
   Rejected and annotation 2026-10-13.
7. A stopped simulation answers "why" and "how" from the record (row 562):
   D-203 Rationale; D-260 Rejected.
8. The interrupt adds nothing to Appendix C (row 563, second half): D-203
   Rejected.
9. A boundary is all-or-nothing, so no torn final snapshot is ever published
   (rows 577, 594): D-030 Rejected ("Mid-frame abort").
10. The stopped-sim services refuse an errored simulation (row 591): D-108
    Rationale; §14 bolds it with D-059 and D-108.
11. A gain earns no block; the library is a toolbox (row 617): D-313
    Rationale; D-062 Rejected.
12. Ordinary status keeps schema authority total and makes the library a
    torture test (row 623): D-062 Rejected.
13. `Constant`'s honest pin, and the pin for every block whose output depends
    on neither state nor a walking input (rows 647–648): D-312 Rationale and
    annotation 2026-10-06.
14. `Freeze`'s cost, and the sampler as the other non-walking source (rows
    651, 654): D-266 Rationale.
15. The policy bound at the call moves binding "one notch later" (row 549):
    only D-091's Rejected list, a superseded entry. A candidate for q26's cut
    rather than for an entry.
16. Tracing: interpolation immune to the blind spot (row 689), D-349
    Rationale; the simple-cycle reduction (row 696), D-245 Rationale; weighing
    a sampled dead hop (row 704), D-245 Rationale.

### Rulings with no entry at all

The entry check reading the latest snapshot before the first frame (row 531,
F51); the two shapes of a request needing no latching (row 566); tail
hygiene, each hook caught and logged (row 587); the cycle loop rendered as
terminal pairs in slash form (row 680); classification touching no
activation machinery (row 697); the wiring diagnostics sharing the route
rendering (row 607, F59); the two channels meeting only at §12.4 (row 576).
Descriptions with no entry, needing none: rows 506, 578, 579, 604, 629, 637,
661, 671.

### Stale entry text and Spec fields

- D-060 Position (log 1899–1904): "Tier-2 event", "`stop_on` root faces at
  `Simulation` construction"; the policy clauses are annotated as superseded
  (log 1910–1916), the vocabulary is not.
- D-062 Position (log 1974–1979): "`faces` gains predicate selection" (the
  selector is on `input_passthrough`/`output_passthrough`, D-251); "The
  `Build` printer renders face routes" (`show(::Structure)`, D-257);
  "demand-driven" (D-313, annotated).
- D-120 Position (log 3910–3914): `faces(rig, child; except)` for
  `input_passthrough(rig, child; except)`; Rejected's "slot-typing" (root
  inputs since D-206).
- D-143 Position (log 5189): "a root slot (§11.3)"; Rationale (log
  5212–5214): the demonstrated-need charter D-313 retired. The annotation of
  2026-10-12 covers `Pinned` and `y_types` only.
- D-141 Rationale (log 5050): "§13.7's grow-by-migration-demand rule".
- D-203 Position (log 7710–7712): the absent-time arm, retired by D-233 with
  no annotation.
- D-012 Position (log 600): "Stratum-B topological stall" (the nominal
  evaluation since D-259).
- Spec fields: part D's list (D-019, D-084, D-147, D-218, D-231, D-251,
  D-261), and D-059, D-387, D-364 for the citations above.

### Findings carried from earlier chapters

`docs/spec_rewrite/README.md` 52–65 lists four chapter 13 items that fall in
half 2 (the fourth, §13.4's unmask points, is half 1's):

- **§13.5 repeats §12.6's per-advance stop policy down to its lifetime
  (chapter 12's B82).** Confirmed: rows 520, 525 and 547–550 against §12.6
  9579–9588, which bolds the ruling (9581). §12.6's own bold cites §13.5 for
  the policy each call builds (9584), so a pointer from §13.5 back to §12.6
  must leave §13.5 the binder, the ignore list and the mask (H1, M55, q22).
- **§13.5's "GUI stop button" (twice) becomes a front end's (B83).** Half 2
  has "GUI stop button" once (10666) and "GUI panels" once (10655); half 1
  has "GUI panels" (10210) and "the control plane and GUI" (10403). The
  chapter-12 wording "a front end's" applies to both of half 2's (F53).
- **§13.7 bolds D-311's ruling on the junction's type parameters, which §6.2
  bolds.** Not confirmed at `1fee0fc`: §6.2 states it plain, "Its arity and
  its port types are type parameters, and the fold is instance data (D-311)"
  (1647–1649); §6.2's bolds are D-037 ×3 and D-143 ×2 (checked by
  `rg '\*\*'` over 1629–1758). §13.7's bold (10813, row 624) is the ruling's
  only bold and stays.
- **§13.7 admits `Constant` "under the inventory's demonstrated-need
  charter", which predates D-313.** Confirmed: 10948–10949 (row 656), from
  D-143's Rationale (log 5212–5214). D-313's Position: "A listed block is
  built whenever wanted, with no demonstrating model required" (log
  13584–13585). Row 620's "admitted by persona rather than by need" leans on
  the same charter (F60).

### Factual problems in half 2

None is serious: each is settled by the code, by a later entry, or is
wording. The evidence is given so the clear ones can be ruled before the
brief.

- **F51. The entry check's scope.** 10512–10515: "`run!` therefore checks the
  boundary-zero snapshot before the first step. An authored condition … that
  is already terminal ends the run at `t₀`". Every advance (`run!`, `step!`,
  `replay!`) checks the latest snapshot at entry (`_advance!`, `src/sim.jl`
  1590–1591, `_stop_hit` on `latest(sim)`). After `init!` that snapshot is
  boundary zero; after `step!` or `restore!` it is not. Run (part C):
  `tick_alarmed()` stepped 12 frames with every request ignored, then `run!`
  ended at `t = 1.2` with zero frames, and a `step!` there advanced none.
  D-138's annotation (log 4815–4824) already calls "§13.5's terminal-at-`t₀`
  path" historical for a run that starts later. Settled by the code.
  Proposed correction: "Every advance reads the latest snapshot's requests
  before its first frame. After `init!` that snapshot is boundary zero's, so
  an authored condition already terminal ends the run at `t₀`, integrating
  nothing. A run that starts later ends where it started, advancing no
  frame."
- **F52. The policy example does not run.** 10556:
  `Simulation(world; h = 0.02)`. The package refuses a float `h`:
  `DeploymentInvalid(:h, :inexact, 0.02)`, "`h` must be exact — a Rational
  (`h = 1//100`) or a `Period`/`Hz` value: grid derivation is GCD arithmetic"
  (`src/deployment.jl` 351; run, part C). It is the only `h = <float>` call
  in the spec. Proposed correction: `h = 1//50`, a ruled edit to a code block.
- **F53. The parked GUI.** 10655 ("GUI panels rendering a component's
  ports") and 10666 ("GUI stop button"). D-310 parks the built-in GUI (log
  13411–13424). Proposed correction, chapter 12's R2 wording: "a front end's
  panels", "a front end's stop button".
- **F54. `t_end`'s range is stated nowhere.** `_t_bound` (`src/sim.jl`
  236–240) refuses a `t_end` that is not a real ≥ 0 as `ArgumentInvalid` at
  each advance, fail-fast before the ignore list, its message citing §13.5
  (run, part C). No spec sentence states the range; D-255 says "validated per
  call" only (log 10229–10230); Appendix C's `ArgumentInvalid` (13595) does
  not cite §13.5. The spec lags the code. Proposed correction: one clause in
  §13.5's policy paragraph, "A `t_end` that is not a non-negative real is
  `ArgumentInvalid`, refused before the ignore list is read", and §13.5 added
  to Appendix C's `ArgumentInvalid` in track 2 (q34).
- **F55. "The sim task."** 10673: "all-or-nothing outside the sim task". The
  loop runs on the calling task (§11.1 6870, D-310 bullet 1); "sim task"
  occurs nowhere else in the spec. Proposed correction: "outside the loop",
  or "outside the calling task, which runs the loop".
- **F56. "`unblock!`/close hooks".** 10688 and the chart (10701). No close
  hook exists: D-373 dissolved `should_close`, and the tail's per-device
  hooks are `unblock!` and the wrapper's `shutdown!` (§12.4 (3)–(4),
  8909–8921). Proposed correction: "`unblock!` and `shutdown!`", in the
  prose and, as a ruled edit, in the chart.
- **F57. The quarantine assumes `errored`.** 10716–10720: the stores "are
  retained on the errored `Simulation` … an errored sim is terminally
  stopped". §13.5 10600–10603 and D-317 bullet 7 say a loop fault outside the
  frame (the pacer, a yield, the tail) closes the run `stopped` with the
  `Model` consistent, and only an in-frame throw ends `errored`. The abnormal
  entry covers both (§13.5's "The record covers both exactly alike").
  Proposed correction: "A throw inside the frame leaves the stores possibly
  mid-boundary … they are retained on the errored simulation …"; and
  "terminal, not resumable" in place of "terminally stopped, not resumable",
  since `stopped` is a different state (the code's refusal message uses the
  same words; a one-line code-comment note for track 2).
- **F58. "Termination chains are the second structural customer of computed
  interface connections."** 10730–10731, the section's first sentence. Since
  D-316 a stop request needs no re-export ("No level above it re-exports
  anything, because the loop reads the request where it is", 10467–10468;
  D-316 Rationale log 13873–13880, "the per-level plumbing goes"). The
  example route at 10757 (`crashed → aircraft/crashed → …`) is a pre-D-316
  stop face. Proposed correction: open §13.7 on its two commitments
  (D-062): computed faces need a printer that says what each face reaches,
  and explicit junctions need a library that makes them cheap. Recast the
  example route on a neutral face (`wrench → systems/wrench →
  systems/wr_sum/out`), a ruled edit.
- **F59. "The same rendering serves the wiring diagnostics."** 10762–10764.
  No diagnostic renders through `face_routes`; its only caller outside
  `assembly.jl` is `show(::Structure)` (`src/show.jl` 75). `UnconnectedInput`
  carries the faces the input was handed up through (`handed`, Appendix C
  13304–13307), which is route-shaped but built separately. Two readings:
  "the same slash-path vocabulary" (true) or "the same printer" (false).
  Proposed correction: "The wiring diagnostics name endpoints in the same
  slash form."
- **F60. The demonstrated-need charter.** 10948–10949 and 10800 ("admitted by
  persona rather than by need"). D-313 retired admission by demonstrated need
  (Position log 13580–13585; Rejected "Strictly demonstrated need,
  unchanged"). Proposed correction: "`Constant` meets the guidelines and has
  two uses already: the zero-contributor configurations (§6.2, D-143) and the
  rig stub below"; "`Group` is admitted for a persona, the model assembler
  (D-184)".
- **F61. An externally settable source as a root input.** 10953–10954: "A
  configuration wanting an externally settable source uses a root input
  (§11.3)." D-364 (log 14893–14895): a handle that references bulk data never
  enters as a root input, only through a constant source; D-237 refuses a
  handle-typed root input. The sentence holds for isbits values. Proposed
  correction: append "when the value is isbits; a bulk-data handle enters
  only through a `Constant` (§14.9, D-364)".
- **F62. `AbstractAtRoot` unnamed (lesson 20).** 10970–10971: "abstract-at-root
  is a build error". Appendix C's `AbstractAtRoot` (13327–13329) cites §13.7
  in its remedy hint. Proposed correction: "is a build error,
  `AbstractAtRoot` (Appendix C)".
- **F63. "Local", two senses in §13.8.** 11046 names the *local*
  (primal-carrying) mode; 11101–11104 names the *local* variant (the
  per-member trace at the probe point) and then warns "The local variant is
  not the local set-tracer mode." The code uses both (`src/tracer.jl` 4–8,
  "the *local* variant of D-012"; 21–25, "`S = false` is the local tracer").
  D-012 says "global + sampled-local" for the modes and "per-member local
  trace" for the variant. Proposed correction: "the per-member variant" for
  the classifier and "the sampled mode" for the fallback (D-245's own word,
  `:sampled`), keeping "local" only in a gloss.
- **F64. "The dead hop is the member …".** 11130–11131. A hop runs through a
  member, from a face to a port (11088–11090); a dead hop is the triple
  (member, input face, output port) (Appendix C 13421–13425; `dead`'s
  element type in `src/diagnostics.jl` 902). Proposed correction: "The dead
  hop is the member's input face that its stage-2 function does not route to
  the output port."
- **F65. Glossary sense clashes in §13.5 (lesson 35).** "Roster" for the
  requester roster nine times, where `#g-roster` is the device roster;
  "override" for the ignore list (10516, 10649–10650), where `#g-override` is
  the condition combinator; "condition" for the stop's `Bool` (10459, 10464,
  10521, 10618), where §14 owns the word; "kind" linked to `#g-kind` (10609)
  for a termination-source kind, which D-203 keeps outside Appendix C.
  Proposed correction: "requester roster" throughout, "the ignore list" for
  "the override", "the stop's `Bool`" or "the detected state" for the first
  sense of "condition", and no `#g-kind` link in §13.5 (q32).
- **F66. Glossary sense clashes in §13.7 and §13.8.** "nominal" linked to
  `#g-nominal` for the nominal evaluation (11024; the entry is the `Float64`
  activation); "trace" meaning the tracer's result throughout §13.8, never
  `#g-trace`; "sweep" for §7.2's `T = Dual` sweep (11068); "selector" (10736),
  "predicate" (10735), "workspace" (10797) and "class" (10868) in senses the
  glossary keeps apart. All but the first are unlinked now and must stay so.
  Proposed correction: unlink "nominal" at 11024 or link the gloss's own
  wording ("the nominal evaluation (the build's second step)") without the
  anchor.
- **F67. Minor wording facts.** Row 543: `run!` raises `UnboundedRun`, before
  the loop starts, into the loop's own cell (`src/sim.jl` 1107–1108), not "the
  loop raises". Row 520: `step!` takes `t_end` and `ignore_stop_requests` as
  keywords like the others (D-316 bullet 6; `src/sim.jl` 1697–1698), so
  "keywords of `run!` and `replay!` … and `step!` states the same defaults
  itself" reads as if `step!` differed; §12.6 9582 lists all three. Row 596:
  "Two commitments follow" where D-062 makes three. Row 675: the parts
  sentence names four parts for five labels.

Outside the half, met while checking citations: spec 5385 (§9.7), 11338
(§14.2), 12351 (§14.9), `migration_outline.md` 80, `extensions.md` 334, all
in part D.

## F. Difficulty per section

| section | difficulty | reason |
|---|---|---|
| §13.5 (F) | high | 2,058 words, no subheadings, no context paragraph and no parts sentence; five bold list lead-ins, one **Rule.**, one **Why …** lead-in, two bold terms. 22 U and 15 R rows: D-316 bullets 5 and 7 and D-203's four rulings are stated uncited. Six moves (M51–M57) change the section's spine. The policy double with §12.6 (B82, q22) must leave §12.6's citation of §13.5 a referent. Four glossary sense clashes (F65). A failing code block (F52). The entry check (F51) and two GUI mentions (F53) |
| §13.6 (F) | medium | 391 words, no context paragraph, the ruling after "therefore" (row 581), D-030 its home entry cited nowhere; F55, F56, F57 change three sentences; the chart is a ruled-edit-only block |
| §13.7 (G) | medium to high | 2,178 words and five code blocks. D-143 and D-120 rule nine rows and are cited nowhere in the section. A stale opening (F58), a stale charter (F60), a double bold with §9.2 (q27), a bold on a reason rather than the ruling (row 608), and "so" before a bold (row 646). Three distinct-usage traps (selector, predicate, workspace, class). Phrases other files quote verbatim (part D) |
| §13.8 (G) | low to medium | 1,164 words, already labelled, 27 of 39 rows C. The work is M62, the "local" terminology (F63), F64, the `#g-nominal` link (F66), and three bold homes for D-343 and one for D-012 (q24) |

Warnings for the rewriter:

- **Terms of art stay verbatim**: stop request, `StopFlag`, `STOP_REQUESTED`,
  requester roster, `Requester(path, port, reason)`, honoured, ignored, the
  ignore mask, the stop scan, the entry check (as ruled under F51), the
  terminal snapshot, the tail residue, the run's-end sweep, the four source
  names, "a tag on an ordinary stop", "one tail with two entry points",
  "graceful entry", "abnormal entry", "discards the failed boundary, promotes
  the previous snapshot to final", the source block, the declared
  stop-gradient, tier-transparency, the stub child, the component test rig,
  SCC, cyclic cluster, dead hop, set-tracer, may-depend, tracer tags,
  structural tracing, the remedy ladder. "A read the run acts on" and
  "inspection" are a distinction the log fought for (D-060, D-316); a
  paraphrase that drops one half changes the rule.
- **Scope words are exact.** "exactly `StopFlag`", "whoever publishes it",
  "anywhere" (a root input carrying a `StopFlag`), "every call", "in the order
  given", "after *every* published boundary", "in roster order", "the first
  honoured request", "*this* snapshot", "`:live` only", "the first in that
  order", "once, in isolation", "under either verdict", "only for continuous
  members", "iff". Keep each.
- **Counts are rulings.** "four things" (the record), "four kinds" (the
  sources), "three guidelines", "two modes", "two exits", "one gather and one
  scatter", "one `Bool` per requester". Each carries its entry (part A).
- **Two counters of senses.** "Local" (F63) and "trace" (F66) each name two
  things in §13.8; "roster", "override", "condition" and "kind" each clash
  with a glossary entry in §13.5 (F65). Never link those uses.
- **The log's vocabulary is old.** D-060 says "Tier-2 event" and "`stop_on`";
  D-062 says "`faces`" and "the `Build` printer"; D-120 says
  "`faces(rig, child; except)`" and "slot"; D-143 says "root slot",
  "`output_types`" and "demonstrated need"; D-012 says "Stratum-B"; D-203 says
  "stop faces" and "three-field". Never import them when citing an entry.
- **The half cites by adjacency.** Rows 502, 509–510, 512, 514, 516, 518,
  522–523, 615–616, 619, 625, 630, 672, 676–677, 679, 683–685, 687, 692 have
  their citation one or more sentences away. A move that separates a rule
  from its citation (M52–M54, M61, M62) needs the citation repeated.
- **Glossary links reset per section, once each.** §13.5 links *control
  plane* three times, *component* and *operator interrupt* twice, and links
  *termination record*, *port*, *cell* and *replay* after their first use;
  §13.7 links *face* and *tick* twice; §13.8 links *tier* after its first use
  (11016 against 11112). §13.6 and §13.8 gloss *activation* with the same
  wording as §13.7.
- **Labels and lead-ins are headings.** Two labels, five bold list lead-ins,
  four bold terms and two bold words. Each becomes a plain list item, a
  `####` label (q23), a plain topic sentence or a bold headline clause with
  its D-citation. Count before and after.
- **History sentences.** 10445–10447 (FlightCore's `SimulationTermination`),
  10631–10633 (`robot2d`, "Today"), 10737–10740 ("auto-bubbling"),
  10793 (Simulink, quoted verbatim by `library_inventory.md`). Carry them
  until q26 and q31 are ruled.
- **Code.** Part C, "Code blocks". The policy example's `h` (F52) and the
  chart's "close hooks" (F56) are ruled edits only; the rest carry verbatim.

## G. Decisions for checkpoint 1

Settled and not asked again: log repair rides track 2, and bold marks one
headline clause per ruling.

**q21. §13.5's opening (rows 501–503, M51).** The section opens on a history
sentence with a bold ruling inside it, has no parts sentence, and leaves
D-060's headline ruling plain. Options: (a) a context paragraph that states
the problem (a model must be able to end its own run, and FlightCore's way
was an exception), then D-060's headline bold ("**Graceful termination is
model state, never an exception**"), the abnormal-exception bold kept, the
"no counterpart" clause plain with the history, the two channels (M51), and
a parts sentence; (b) keep the opening, adding only the parts sentence.
Recommendation: (a). D-060's headline is bold nowhere in the spec, and
§13.5 is the section its Spec field and the glossary entry name.

**q22. The per-advance policy (B82, H1, M55).** §13.5 restates §12.6's bold
ruling, its keywords and its lifetime, and argues it again in "Why one
binding site". §12.6's bold (9581–9584) cites §13.5 for the policy each call
builds. Options: (a) §12.6 keeps the declaration, the keywords and the
lifetime; §13.5 keeps the ignore list's semantics, `StopRequestInvalid`, the
binder's mask (citing D-316, row 524) and the `t*` hit, with one pointer
sentence to §12.6; "Why one binding site" reduces to that pointer, its
constructive clause ("the defaults belong to the calls that take it") kept
and the "notch later" argument (row 549, a superseded entry's) cut;
(b) leave both. Recommendation: (a). §12.6 is the rewritten home and §13.5
then owns exactly what §12.6 cites it for.

**q23. Subheadings for §13.5, and one for §13.7's opening.** §13.5 runs 2,058
words with five bold list lead-ins acting as headings; §13.7's first 324
words carry no label. Options: (a) `####` labels in §13.5 as part C lists
(about seven) and "#### Face routes" in §13.7, the bold lead-ins becoming
plain; (b) no labels, each bold lead-in a plain topic sentence and a parts
sentence ending the context. Recommendation: (a) for §13.5, whose readers
return to the policy, the scan and the record separately; (b) for §13.7's
opening, which shrinks to about 200 words under q27.

**q24. Bold homes for unbolded rulings, and the bolds to drop or move.**
Unbolded anywhere in the spec: D-060's headline (row 503); D-316 bullet 7,
the scan (row 527); D-203 bullet 2, the interrupt a tag (row 563); D-233,
the time always present (row 555); D-323 bullet 3, no bundled contribution
struct (row 634); D-343 bullets 5, 8 and 9 (rows 701, 699, 702); D-012's last
chained ruling, classification optional (row 708). Bolds to change: row 599
(a double of §9.2's, q27); row 608 (a reason; the ruling's headline is row
622, "library blocks are ordinary components", which then takes the bold and
D-062); row 565 (two rulings joined by a semicolon, uncited: the sampling half
is row 527's ruling and the localization half D-060's detection clause);
rows 581 and 646 (bold after "therefore" and "so"); row 524 (a bold term).
Options: (a) bold each unbolded ruling at its headline clause here with its
citation, and change the listed bolds as stated; (b) leave D-343's three for
a later pass, since §5.4 is D-343's other home. Recommendation: (a). §5.4
states none of the three, and §13.8 is where the diagnostic runs.

**q25. The clear factual corrections.** F51 (the entry check), F52 (`h =
1//50`), F53 (a front end's), F54 (`t_end`'s range, one clause), F55 (the
calling task), F56 (`unblock!` and `shutdown!`), F57 (the quarantine's
scope), F58 (§13.7's opening and its example route), F59 (the slash form),
F60 (the charter), F61 (isbits root inputs), F62 (`AbstractAtRoot`), F63
("per-member variant", "sampled mode"), F64 (the dead hop), F67 (the four
wording facts). Options: (a) rule them all at checkpoint 1 with part E's
evidence and proposed wording, grepping the chapter for each phrase first
(chapter 8's lesson; "GUI", "boundary zero" and "terminally" also occur in
half 1); (b) leave them for rulings. Recommendation: (a). F65 and F66 are
q32.

**q26. Adversarial and history lines.** Candidates: 10640–10650 (the
rejected mechanisms, rows 570–571); 10569–10572 (the "notch later" argument,
row 549); 11031–11032 (residue and back edge, row 681); 10769–10771
("not cheap", row 609); 10793 (Simulink, row 617); 10445–10446 (FlightCore's
idiom, row 501); 10631–10633 (`robot2d`, row 569). Options: (a) cut 10640–10650
to one sentence naming predicate closures and observation-by-path with D-060
and D-316 (part D shows D-390, D-095, D-096 and §12.6 9474 rely on the
closure rejection, and §14.1 and §14.4 on observation-by-path), folding its
constructive clauses into the doctrine; cut row 549; keep rows 501, 569, 609,
617 and 681 as one-clause verdicts with their citations, since 617 is quoted
verbatim by `library_inventory.md` and 569 is a worked example; (b) keep all.
Recommendation: (a).

**q27. The `show` double (H12, M60).** §13.7 10742–10753 bolds and lists what
§9.2 4511–4527 bolds and lists. Options: (a) one plain sentence pointing to
§9.2 ("Every artifact renders itself through `show` (§9.2, D-257)"), keeping
the face routes as §13.7's own; (b) keep the list, unbolded. Recommendation:
(a). §9.2 points to §13.7 for the routes only.

**q28. Overlaps across the split (H4, H5, H6, H16, H29).** Options: (a) one
home each with a pointer at the other: §13.5 for the unbounded run, §13.2's
list item pointing here; §13.5 for the record and §13.6 for the entry;
§13.3 for the three-client resolution rule and §13.5 for the stop scan as
the one read a run acts on, each pointing at the other; the roadmap and
§13.5 each keep their `SimulationTermination` clause; §13.4 and §13.6 keep
"promote" and "retained" verbatim; ruled together with the sibling's
matching question; (b) leave every duplicate. Recommendation: (a).

**q29. "The starting inventory" (row 610).** `Redstone.Blocks` ships about
twenty blocks beyond the six listed (`implementation.md` 126–167), and the
list is the inventory of 2026-08. `extensions.md` 346, `migration_outline.md`
20 and §8.5 3326 cite "§13.7's starting inventory". Options: (a) keep the
six as "the seed the section describes" and point to
`companions/library_inventory.md` for the shipped list; (b) list every
shipped block; (c) keep as written. Recommendation: (a). The six are the ones
§13.7 specifies; the inventory's home is the companion (D-313 bullet 1).

**q30. The units.** Two units as in part C: F 2,449 (§13.5–§13.6), G 3,342
(§13.7–§13.8). The alternative is three units, F 2,058, G′ 2,569, H′ 1,164.
Recommendation: F and G. Each move stays in one unit; G's excess is small
and falls in the half's best-cited section.

**q31. Reader-cold names.** `robot2d` (10632), `Ldg` and its legs (10465),
the touchdown overload and `m.crashed` (10454–10456), `Strut`,
`SampleTerrainField` and `AbstractTerrainField` (10970–10980),
`aircraft/monitor/out` (10757), `systems/aero` and `systems/dyn` (11127),
"auto-bubbling" (10739), "ZOH" (10866, 10892, never expanded in the half),
"an anti-windup chain's previous-saturation port" (10871), Simulink (10789,
10793). Options: (a) an introducing clause each that claims nothing beyond
its source: `robot2d` as "FlightApps' self-balancing robot in Flight.jl,
which throws `LostBalance`, a `SimulationTermination`, past 45° of tilt";
`Ldg` as "§6.2's landing-gear assembly"; `Strut` and `SampleTerrainField` as
Flight.jl's landing-gear strut and a terrain stub (or the sketch recast on
`test/fixtures.jl`'s `TerrainGain`, a ruled edit); ZOH expanded as
zero-order hold; "auto-bubbling" glossed as "promoting an unwired input to a
root input (§6.1, D-322)"; the anti-windup port pointed to
`companions/pid_anti_windup.md`; (b) cut the Flight.jl examples to the log.
Recommendation: (a), with "Today" dropped from row 569. Check `Strut`'s owner
in the Flight.jl source before ruling its clause (chapter 7's lesson).

**q32. Glossary sense clashes (F65, F66).** Options: (a) rule the wordings in
part E: "requester roster" throughout §13.5, "the ignore list" for "the
override", "the stop's `Bool`" for the first sense of "condition", no
`#g-kind` link in §13.5, no `#g-nominal` link at 11024, and "trace" in §13.8
never linked; (b) leave them to the rewriters. Recommendation: (a). Chapter
5's lesson: a sense clash found late reaches other chapters and the glossary.

**q33. Two coinages without entries.** "Requester roster" (§13.5 ×9, §14.4
11562, Appendix B 13130) and "tail residue" (§13.5, §12.4, §11.8, Appendix C)
have no glossary entry; `spec_style.md` gives one to a term "used in three
or more places, or far from its definition". Options: (a) add
`#g-requester-roster` ("the build's list of stop requests, one
`Requester(path, port, reason)` per `StopFlag` output port, in build order,
§13.5") and `#g-tail-residue` in track 2, glossing inline meanwhile; (b)
inline glosses only. Recommendation: (a) for the requester roster, whose bare
form clashes with `#g-roster`; (b) for the tail residue, which the
termination record's entry already names.

**q34. Kinds the half states but does not name (lesson 20).** Options:
(a) add a clause each, as ruled edits: `AbstractAtRoot` at 10971 (F62); the
`t_end` range as `ArgumentInvalid` in §13.5 (F54), with §13.5 added to
Appendix C's `ArgumentInvalid` in track 2; the two `IllegalPortType` reason
symbols, `:stop_flag_nested` and `:stop_flag_at_root`, at 10470;
(b) `AbstractAtRoot` only. Recommendation: (a). `WalkingFaceAtFrozenEntry`
(10925) needs no clause, since §8.2 names it beside the `Freeze` remedy.

## H. Descriptive passages

One row per passage that describes a rule's mechanism rather than stating the
rule, with the source file that realizes it (found through
`implementation.md`'s map and read at the working tree). These rows are the
normative kernel's migration list (`pending.md`, "The normative kernel"); the
rewrite does not act on them, and part C proposes no move on their account.

| id | section | lines | summary | realized in |
|---|---|---|---|---|
| P201 | §13.5 | 10462–10464 | every request lands in one per-eltype `StopFlag` block, because an enum is one pinned leaf and cells are stored per eltype | `src/store.jl` (`STOP_FLAG_KEY`, 44); `src/build.jl` `cell_layout` (334) |
| P202 | §13.5 | 10471–10474 | why the two placements are refused: the roster is per port, a request is the model's | `src/build.jl` `cell_layout` (357–381, the nested and root-input checks) |
| P203 | §13.5 | 10477–10481 | the requester roster: one `Requester` per `StopFlag` output port, index-aligned with the block, entry `i` at offset `i − 1`, build order | `src/build.jl` `Requester` (320), `Layout.requesters` (331), `cell_layout` (424–438) |
| P204 | §13.5 | 10481–10484 | the reason read once per publishing component from `stop_reason` | `src/build.jl` `cell_layout` (431, `invoke_declaration(stop_reason, …)`); `src/declare.jl` (the declaration's default) |
| P205 | §13.5 | 10489–10493 | the ignore list's validation: `:all` expanded, paths checked against the roster per call, duplicates collapsed in order, `StopRequestInvalid` collected | `src/sim.jl` `_ignored_requests` (265–297) |
| P206 | §13.5 | 10493–10497 | the binder: `StopPolicy` plus the ignore mask as the loop's second argument | `src/sim.jl` `_bind_policy` (300–304), `StopPolicy` (55–58) |
| P207 | §13.5 | 10497–10499 | the policy lives as long as the call, then only on the terminating record | `src/sim.jl` `_record` (376–378), `TerminationRecord` (74–79) |
| P208 | §13.5 | 10499–10503 | a `t*` hit as `frame!`'s `Bool`, the requester re-read off the just-published snapshot | `src/frame.jl` `frame!` (34); `src/sim.jl` `LoopHooks` and `settled!` (1528–1541), `_advance!` (1612–1617) |
| P209 | §13.5 | 10504–10508 | the scan after every publication, in roster order, first honoured holding request wins | `src/sim.jl` `_stop_hit` (385–396) |
| P210 | §13.5 | 10509–10511 | the terminal snapshot's status carries the final cumulative counters | `src/sim.jl` `_status` (2174); `src/dataplane.jl` (the account) |
| P211 | §13.5 | 10512–10517 | the entry check before the first frame | `src/sim.jl` `_advance!` (1590–1591); stale in scope (F51) |
| P212 | §13.5 | 10519–10534 | `StopRequest`: a stateless continuous leaf, `Bool` in, `StopFlag` out, reason as instance data; the sketch | `src/blocks.jl` `StopRequest` (188–196) |
| P213 | §13.5 | 10537–10542 | `StopRequest` refreshes at every boundary, `t*` included, and sees a discrete detector's tick at the tick's own boundary | `src/executor.jl` (the interior and boundary sweep variants); `src/frame.jl` (the boundary sequence) |
| P214 | §13.5 | 10549–10553 | `UnboundedRun` raised once at `run!` in `:live` into the loop's cell, its message naming the case | `src/sim.jl` `run!` (1107–1108); `src/diagnostics.jl` `UnboundedRun` (1515), `message` (1606–1615) |
| P215 | §13.5 | 10576–10603 | the record's four fields and the four sources with their payloads | `src/sim.jl` `TerminationSource` and its four subtypes (24–42), `TerminationRecord` (74–79) |
| P216 | §13.5 | 10598–10603 | an in-frame throw marks the `Model` `:inconsistent`; a fault outside the frame closes the run `stopped` | `src/frame.jl` `frame!`'s catch; `src/sim.jl` `_run_body!` (1164–1317, `LoopError` at 1295) |
| P217 | §13.5 | 10612–10615 | the consultation order: stop word at frame top, then `t_end`, then requests at each publication | `src/sim.jl` `_advance!` (1597–1601, 1646) |
| P218 | §13.6 | 10674–10681 | why a boundary is all-or-nothing: sweeps write table blocks, intermediates sit in integrator buffers, publication comes last | `src/frame.jl` `frame!`; `src/stepper.jl` (`RK4`, `Heun` scratch); `src/sim.jl` `publish!` (2134) |
| P219 | §13.6 | 10683–10703 | the abnormal entry: the catch path takes tail steps (1)–(5) with the last published snapshot final; the chart | `src/sim.jl` `_run_body!` (1196–1317), `_finish!` (1399), `_tail!` (1429) |
| P220 | §13.6 | 10711–10714 | each hook caught and logged, the join timeout bounding a hang | `src/devices.jl` `_shutdown!` (371–381); `src/sim.jl` `_tail!` (1429–1440), `_report_join_timeout!` (1470) |
| P221 | §13.6 | 10716–10726 | an errored simulation's stores retained; services, roster operations and advances refuse it | `src/sim.jl` `_assert_advanceable` (401), `assert_stopped` (423, the readers' gate, which admits `errored`) and `assert_configurable` (428, the roster's gate, which refuses it; called by `attach!` 1898 and `detach!` 1958) |
| P222 | §13.7 | 10735–10740 | `select` on the passthrough helpers | `src/assembly.jl` `input_passthrough` and `output_passthrough` (445–460) |
| P223 | §13.7 | 10742–10753 | each artifact's `show`, the `Build`'s parts and its `feedthrough:` line | `src/show.jl` `_lines` methods (84–270), `_feedthrough` (220) |
| P224 | §13.7 | 10755–10764 | the face routes: one line per chain, hops joined by `→`, one per consumer for an input face | `src/show.jl` `_route_lines` (73–82); `src/assembly.jl` `face_routes` (1448) |
| P225 | §13.7 | 10795–10798 | the library as the submodule `Redstone.Blocks`, against the extension-only surface | `src/blocks.jl` (`module Blocks`, 1–1623); `src/Redstone.jl` (32, included last) |
| P226 | §13.7 | 10814–10840 | `Junction`: generated input names, the fold applied positionally, the aliases; the sketch | `src/blocks.jl` `Junction` and aliases (32–81) |
| P227 | §13.7 | 10842–10845 | the junction's contracts written at nominal and retyped by the leaf walk | `src/leaves.jl` (the leaf walk) |
| P228 | §13.7 | 10865–10868 | tier-transparency: a stateless continuous output changes only at ticks when fed held signals | `src/executor.jl` (the sweep variants); a consequence of §10.5, no code of its own |
| P229 | §13.7 | 10870–10888 | `UnitDelay`: `s_init` from `v0`, `y_state` the stored value, `s_update` the input; the sketch | `src/blocks.jl` `UnitDelay` (152–159) |
| P230 | §13.7 | 10898–10922 | `Constant`: a pinned stage-1 output of the instance's value; the sketch | `src/blocks.jl` `Constant` (134–139) |
| P231 | §13.7 | 10924–10946 | `Freeze`: tolerant in, pinned out, `ForwardDiff.value` by broadcast, `V` constrained at the type; the sketch | `src/blocks.jl` `Freeze` (170–174) |
| P232 | §13.7 | 10959–11004 | the component test rig and its stub; the sketch | none in `src/`: an authoring idiom with no framework support, by design; exercised by `test/fixtures.jl` `TerrainRig` (1411–1424) |
| P233 | §13.8 | 11024–11032 | the stall decomposed into SCCs, one `AlgebraicCycle` per nontrivial cluster, its wires as one loop | `src/build.jl` `_cycle_diagnostics` (220), `_tarjan` (259), `_cluster_walk` (291) |
| P234 | §13.8 | 11036–11051 | the two modes: the global value-blind tracer refusing a tainted branch, the sampled fallback | `src/tracer.jl` `Tracer{S}` and `Undecidable` (19–31), `_sample` (161), `_trace_sampled` (215, eight evaluations at a fixed seed) |
| P235 | §13.8 | 11055–11065 | only inputs seeded; the `Int` blind spot | `src/tracer.jl` `_seed_face` (243), `Base.Float64(::Tracer)` (48–49) |
| P236 | §13.8 | 11067–11070 | Dual-cleanliness implies traceability | none: a consequence of `T <: Real` genericity, checked by the suite's `T = Dual` sweep |
| P237 | §13.8 | 11074–11084 | classification inside the nominal evaluation's failure path, each member once at the probe point, in-cycle values from `probe_value` under tags | `src/tracer.jl` `_classify` (279), `_trace_direct` (185), `_seed_face` (243) |
| P238 | §13.8 | 11086–11097 | the verdict: hops held iff routed, real iff a cycle survives, dead hops listed | `src/tracer.jl` `_classify` (dead hops 340–345), `_has_cycle` (384) |
| P239 | §13.8 | 11099–11105 | no activation machinery; the per-member variant against the tracer activation | `src/tracer.jl` header comment (1–8); the tracer activation is not built (`src/tracer.jl` 7–8: "is not built here") |
| P240 | §13.8 | 11109–11124 | structural tracing for discrete and unwalked members; the per-member mode recorded; the hint for continuous members only | `src/tracer.jl` `_classify` (`:structural`, 323); `src/diagnostics.jl` `AlgebraicCycle` (899–905), `_modes` (913), `_cycle_hint` (922) |
| P241 | §13.8 | 11126–11134 | the artificial message and the dead hop as its own payload field | `src/diagnostics.jl` `message(::AlgebraicCycle)` (934–953) |
| P242 | §13.8 | 11136–11138 | a member whose evaluation throws leaves the cycle unclassified | `src/tracer.jl` `_classify` (its catch, 335, 377) |

42 rows. One passage describes a piece the package does not build: the
"tracer activation" P239 names (§9.4's whole-model run at the tracer scalar),
which `src/tracer.jl` 7–8 says "is not built here" and no other file builds
(a planned piece, or a stale one; `pending.md` does not list it, as far as
checked). One passage is stale in scope against the code (P211, F51).
