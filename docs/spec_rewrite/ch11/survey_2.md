# Survey of spec chapter 11, half 2, before its readability rewrite — 2026-10-13

Scope: `docs/design/spec.md` lines 7579–8388 at commit `f61b1af`: §11.5 "Inbound:
the input trace" (7579–7708), §11.6 "Devices: one authoring contract, no
taxonomy" (7709–8086), §11.7 "The GUI write path: port resolution, peek,
staging contract" (8087–8244), §11.8 "Diagnostics and liveness: the
per-writer cell" (8245–8386), and the chapter's closing `---` (8387). The
sibling survey (`survey_1.md`) covers the heading, roadmap and §11.1–§11.4
(6777–7578). The convention is `docs/design/tools/spec_style.md`; the method
is `docs/spec_rewrite/recipe.md` step 1; the model is chapter 10's survey at
`0f9ce8a`.

Line numbers are lines of the frozen copies in `scratch_survey/h2/`
(`spec.md`, `decisions.md` at `f61b1af`). Log lines are marked `log`. Every
entry cited below was read in full; `src/` was read where a name or a claim
was in doubt. Numbering: part A rows from 501, moves from M51, findings from
F51, part G questions from q21, units F, G1, G2, H, J (K unused).

Classification codes used in part A, as chapter 10's:

- **C** cited, and ruled by the cited entry's Position (at the spot, or in
  the same or the next paragraph, marked "adjacent").
- **U** ruled by an entry's Position that the section does not cite at that
  spot.
- **S** cited to a superseded entry.
- **R** ruled only in an entry's Rationale, Rejected list or annotation.
- **N** no entry found. Where the sentence reads as a description or a
  consequence rather than a ruling, the row says so.
- **B** borderline; both readings are given.

"Marking" is how the spec marks the rule now: **Rule.**/**Why.** label, bold
sentence, bold lead-in (a bold phrase opening a paragraph or bullet), bold
words inside a sentence, or plain.

Section sizes (words, `wc -w`): §11.5 1,186; §11.6 2,967; §11.7 1,503;
§11.8 1,345 (with the closing `---`). Half total 7,001.

A note on the brief's pointers. The earlier rewrites placed the
zero-allocation scope "in §7.5". At `f61b1af` chapter 7 ends at §7.4; the
allocation section is §9.8, and "the stepping loop" is at §9.8 5418 (also
§9.4 4868). F52 cites those lines.

## A. Per section

### §11.5 Inbound: the input trace (7579–7708, 1,186 words)

Purpose: what the input trace records, in what format and at what cost; what
its header holds and why; the `Trace` value; the schema list; why recording
is on by default.

Subheadings: none. Labels: **Why.** 7594. Bold lead-ins or bold sentences:
7581, 7587, 7607, 7626, 7645 (a one-item bullet list), 7659, 7669, 7696.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 501 | 7581–7582 | "The input trace is the sequence of drained, device-tagged batches per frame." | bold lead-in (the term) | none; glossary trace 14184 | N, a definition; bold on a term, which the convention forbids |
| 502 | 7582–7585 | extends §10.7's determinism end-to-end; replay reproduces the trajectory bit-identically "with staging fed from the recording and no devices or mappings present" | plain | D-101 Position (replay as the ordinary loop, drain fed by the recording) | U; restates §2.4 567–570 at Part I depth (part B) |
| 503 | 7587 | "One record format: every batch is retained sparse." | bold sentence | D-176 Position (cited 7598) | C (adjacent) |
| 504 | 7587–7591 | at the drain each drained cell is scanned; masked entries recorded as (position ⇒ value) pairs against the writer's schema in `schemas` | plain | D-176 Position ("against the header's schema", stale since D-255 bullet 3 moved the list off the header) | C |
| 505 | 7592 | "an O(surface-width) scan and one small allocation per drained batch" | plain | D-176 Rationale log 6448 | R; src boxes each value too (F68) |
| 506 | 7594–7598 | width is a fact about one binding; a greedy claim is enumerated and as wide as the root contract; "keying retention by claim source is rejected" | **Why.** label | D-176 Rationale log 6453–6456, Rejected log 6459–6461 | R; the rejection clause is adversarial (q24) |
| 507 | 7598–7602 | one record format, no per-entry flag, one decoder in what-if replay, disk serialization and inspection, one inverse conversion in replay | plain | D-176 Position | C (adjacent); the what-if gloss is wrong (F57) |
| 508 | 7602–7603 | "That work is paid once, up front, off the loop (§12.7)." | plain | D-101 Rationale log 3115–3117 | R |
| 509 | 7603–7605 | the conversion site is the drain, not the shim, because the drained tuple is the coalesced truth; a shim-side log would need its own merge | plain | D-107 Rationale log 3324, Rejected log 3333 (D-107 reads "ratified" though D-176 supersedes its density rule) | B: R by D-107, whose standing is unclear (part E) |
| 510 | 7607 | "The costs are recorded rather than argued away." | bold sentence | D-176 Rationale ("Costs recorded where they are paid") | R; a bold lead-in, not a ruling |
| 511 | 7607–7612 | on wide writers conversion keeps the trace honest; render-rate dragging at hundreds of faces would inflate the trace past the budget that justifies trace-on (D-029) | plain | D-107 Position log 3314–3315; D-176 Rationale | R |
| 512 | 7612–7616 | dense component costs "about 2×"; no order of magnitude; D-029's budget stands | bold words | D-176 Rationale log 6445–6447 | R; worked-measurement exempt (`spec_style.md`, "Rationale") |
| 513 | 7616–7619 | allocation in-class with §9.8's carve-out; smaller than the log's snapshot, "the one qualified exception to retains-what-was-already-allocated" | plain | D-176 Rationale log 6448–6450 | R |
| 514 | 7620–7624 | "reversible as pure implementation": lossless both ways; verbatim retention could return per entry; record semantics, header and replay unchanged | bold words | D-176 Rationale log 6450–6453 | R |
| 515 | 7626–7628 | "The trace header is the checkpoint `init!` takes at the end of boundary zero, after the first snapshot is published" | bold sentence | D-274 Position bullet 4 (cited) | C |
| 516 | 7629–7632 | a checkpoint holds `x`, `s`, `m`, the signal table, the priors, `t`, `t₀`, the two counters and the fingerprint | plain | D-274 bullet 1 as amended by D-319 bullet 1 (log 13838–13843, `ModelState`'s nine fields; the counters beside it) | U (D-319 uncited); "fingerprint" vs "layout" (F58) |
| 517 | 7632–7634 | the clock holds `t`, `t₀`; the run holds the frame index and boundary ordinal | plain | D-317 bullet 4 (cited) | C |
| 518 | 7634–7637 | the header holds stores and root-input cells as values, never the overlay; replay must survive edits to declared defaults | plain | D-274 bullet 4 ("values still (D-038)"); D-038 Position (cited) | C |
| 519 | 7639–7641 | an unfed `mixture = 0.5` never appears in a batch; replay is broken without the root inputs; the init/trim services own root-input initialization | plain | D-047 Position ("trace header extends to initial slot values"), Rejected log 1513–1514 | U (D-047 uncited here) |
| 520 | 7641–7643 | the checkpoint's table holds the values the services wrote; "The fingerprint is the part of the header replay compares rather than restores" | plain | D-274 bullet 3 | U; replay compares the deployment too (F58) |
| 521 | 7645–7650 | the deployment carries `Δt_base`, `h`, `N_base`, the algorithm, `localization_tol`, `localization_budget`, `firing_budget` | bold lead-in of a one-item list | D-254 Position bullet 1; D-227; D-181 | U |
| 522 | 7650–7652 | the layout: store layout, root-input faces, each component's `x` type, every cell's address with its type, the event list in the priors' order | plain | D-274 bullet 1 ("the structural layout"); field list matches `src/checkpoint.jl` 10–26 | B: U by D-274 for the layout; N for the field list |
| 523 | 7653–7654 | both taken at the same instant as the state | plain | D-217 Rejected log 8111–8112 ("single-instant capture") | R |
| 524 | 7654–7655 | "The deployment holds no policy" | plain | D-255 bullet 6 (cited) | C |
| 525 | 7655–7657 | `t_end` and `ignore_stop_requests` are each advance's keywords; only the terminating advance's policy explains the stop; the termination record carries it | plain | D-255 bullets 5–6, amended by D-316 (annotation log 9965–9968); D-260 bullet 3 | C for D-255; U for D-316, D-260 |
| 526 | 7659–7660 | "`Trace` is that fixed header plus two append-only lists, `schemas` and `batches`, and its length" | bold sentence | D-255 bullet 3 (cited) | C |
| 527 | 7660–7662 | `Trace` takes no scalar parameter, since a `Simulation` runs only a `Model{Float64}` | plain | D-317 bullet 2 (cited) | C |
| 528 | 7662–7663 | the header is written once, by the door that builds the run, and never again, "which is what makes it an artifact" | plain | D-255 Rationale log 9933–9935; D-274 bullet 4 | B: R by D-255; U by D-274 |
| 529 | 7663–7665 | the lists grow in place, batches at every drain, schemas at every roster change | plain | D-255 bullet 3; D-217 bullet 2 | U |
| 530 | 7665–7667 | the length is the drain's count, frozen into `trace(sim)`; it advances at the top of each drain; records carry it as their frame ordinal | plain | D-255 bullet 3; D-260 bullet 5 (cited) | C; "count" wrong under `restore!` (F59) |
| 531 | 7669 | "Each writer's face-name → position schema lives in the `schemas` list." | bold sentence | D-255 bullet 3; D-217 bullet 2 (cited 7671) | C (adjacent) |
| 532 | 7670–7671 | positional records are meaningless without it; replay does not reconstruct claims | plain | D-217 Rationale log 8090 | R |
| 533 | 7671 | "The list only grows" | plain | D-217 bullet 2 (cited) | C |
| 534 | 7671–7674 | `attach!`/`detach!` push the current writer set in place, because a roster change recompiles the harness writer and a face moves position | plain | D-255 bullet 3 (push in place); D-217 Rationale log 8091–8094 (reason) | U; reason R |
| 535 | 7674–7675 | earlier records keep their index; a record resolves only through its own schema entry | plain | D-217 bullet 2 | C (adjacent) |
| 536 | 7677–7681 | the trajectory depends on the deployment as on the stores; the constructor sits outside the `Build`; the checkpoint carries the clock; without them the header could not back bit-identity | plain | D-254 Position ("Replay compares two deployments as values"); D-273 bullet 3 (`t₀`) | U; first clause restates §2.4 546–554 (part B) |
| 537 | 7681–7682 | the header is what the run metadata names | plain | none; glossary 14179 | N, a description |
| 538 | 7683–7684 | a checkpoint is the one full-state capture, taken by `init!` and by `checkpoint(sim)` | plain | D-274 Position | U |
| 539 | 7684–7688 | the header is the other half of "given the initial state and the trace, the log is recomputable"; header plus batches are primary, everything else derived | plain | D-038 Position | U |
| 540 | 7688–7689 | the trace carries its length, the frame index of its last drain | plain | D-217 bullet 1 (cited) | C; repeats row 530 (M51) |
| 541 | 7689–7692 | under `init!` the drains since the header; under `restore!` records keep the trajectory's own frame indices | plain | D-274 bullet 3 (cited; the clock comes with the checkpoint); the frame-index rule itself only in `src/trace.jl` 47–48 | B: C by D-274 for the restore; N for the record-index rule |
| 542 | 7692–7694 | a recording whose last frames drained nothing still ran them; every advance in `:replay` is capped at that frame | plain | D-217 bullet 1; D-218 bullet 2 (cited) | C |
| 543 | 7696 | "Trace recording is on by default." | bold sentence | D-029 Position (cited 7707) | C (adjacent) |
| 544 | 7696–7699 | `init!` builds a fresh trace under its `trace` keyword; retrievable after the run; a plain kill switch for marathon sessions | plain | D-029 Position; D-260 bullet 5 (switch on the run); D-261 bullet 7 (`trace` a keyword of `init!` and `replay!`) | C for D-029; U for D-260, D-261 |
| 545 | 7699–7703 | the trace is primary, the log derived; an untraced interactive session is unreproducible, permanently | plain | D-029 Rejected log 998–1000 | R |
| 546 | 7703–7706 | one small sparse record per drained batch, at drain-rate × device-count; "tens of MB per hour worst case, two orders of magnitude below the snapshot log" | plain | D-176 Rationale ("two-orders-below-the-log budget"); no entry gives "tens of MB per hour" | R for the budget; N for the figure |
| 547 | 7706–7707 | "There is no sampling and no rolling window" | plain | D-029 Rejected log 1002 (cited) | R |

Descriptions that read like rules: rows 505 and 546 (cost figures), 509 (the
conversion site), 522's field list (no entry; `src` is its only home), 541's
record-index rule.

Display-block candidates: the `Trace` shape (header, `schemas`, `batches`,
length) as a four-line struct sketch at 7659; one record as a pair list
(`(writer = 2, frame = 17, entries = [3 => 0.25, 7 => 1])`) at 7590. Both
are additions the inventory would declare.

Structure note: 7645–7657 is a one-item bullet list whose lead-in names two
things. It reads as the remnant of a list of header contents and should
become a paragraph.

Glossary terms (lesson 35):

- Linked at first use and matching: trace (7581), device, drain (with
  gloss), face, claim, greedy claim, contract (7597, the root's interface,
  the right sense), replay, component, boundary, trace header, boundary
  zero, prior, `Run` (7633), termination record, run metadata.
- Linked late: root input (first use 7589 in the drain gloss, linked 7635);
  checkpoint (used 7626, linked 7629); `Deployment` (7645, linked 7646).
- Linked twice: snapshot (7618, 7628).
- Linked against its entry: what-if replay (7600) is glossed "replay with
  edited inputs"; the glossary and §12.7 define it as changed parameters
  (F57). The staging-cell link at 7589 displays as bare "cell" (F65).
- Used, never linked: frame (7582), batch (7582), binding (7595), log
  (7605), roster (7664), harness writer (7673), executor (7632), signal
  table (7630), `Build` (7650).
- The glossary's *trace record* (14195) points here, and §11.5 never uses
  the phrase. 7587's "One record format" is where it belongs.
- "a class of writers" (7595) uses ordinary-English "class", which the
  glossary reserves for primitive-versus-assembly status (13334). "Kind" is
  reserved too (13327). "Not about which writer stakes the claim" avoids both.

Appendix C kinds cited to §11.5 (lesson 20): `CheckpointMismatch` (13194)
and `ReplaySchemaMismatch` (13221). §11.5 names neither. It states the
fingerprint comparison only as "compares rather than restores" (7642) and the
schema rule without its failure (7669–7675). Both conditions are stated and
named in §12.7 (9462–9472). F64; q27.

### §11.6 Devices: one authoring contract, no taxonomy (7709–8086, 2,967 words)

Purpose: the one device handle; `should_abort`; the authoring contract and
the framework's wrapper; `shutdown!`'s tolerances; the author-owned loop
body; the binding (sides, enumerations, conformance check, roots, greedy
claims, the empty enumeration); `TableBinding`; bad datum versus bug.

Subheadings (`####`): "Every attached device receives the same handle"
(7715), "The authoring contract: four functions, one optional" (7748), "The
author owns the loop body; the framework owns the bracket" (7815), "The
binding: framework-legible by enumeration, opaque in its mappings" (7870),
"One shipped binding type; conditioning has an owner" (8039), "Bad datum
versus bug: two classes, two fates" (8061). Labels: **Rule.** 7911. Fifteen
bold sentences or lead-ins: eight with no D-citation in their paragraph
(7732, 7779, 7806, 7863, 7919, 8005, 8010, 8024), and two whose paragraph
cites an entry other than the one that rules them (7981, 7993).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 548 | 7711–7713 | FlightCore's input/output/GUI trichotomy is lock choreography; with no lock the protocol has no referent | plain | D-025 Rejected log 913–915 (cited) | R |
| 549 | 7717–7720 | the handle carries read and stage plus control (observe running, request shutdown); read returns the latest snapshot, optionally waiting for the next boundary | plain | D-025 Position | U |
| 550 | 7722 | "A handle outlives its roster entry as an object only." | bold sentence | D-244 (cited 7730) | C (adjacent) |
| 551 | 7722–7725 | after `detach!`, `stage!` and `report!` refuse by name (`DeviceContractMismatch`) | plain | D-244 Position | C (adjacent) |
| 552 | 7725–7728 | a batch would land in a cell no drain reads; "Silence is the hidden-bug class this section tolerates nowhere" | plain | D-244 Rationale log 9292–9297 | R |
| 553 | 7728–7730 | the read primitives stay legal | plain | D-244 Position (cited) | C |
| 554 | 7732–7733 | "`should_abort` is an `attach!` keyword, defaulting to `false`" | bold sentence, no citation | D-138 Rationale log 4573–4575; D-177 Position (the `attach!` signature) | U by D-177 for the keyword; R by D-138 for the default |
| 555 | 7733–7734 | per-attachment, never a device property; advisory in one deployment, decisive in another | plain | none found in a Position; glossary 14096–14098 | N |
| 556 | 7734–7737 | clear: the departure is reported and the run continues; set: it also requests a stop; a departure is the body returning, a crash, or a failed `init!` | plain | D-138 Rationale log 4563–4570 | R |
| 557 | 7737–7739 | a hardware-in-the-loop rig attaches its plant interface with it set | plain | none | N, an example |
| 558 | 7741–7744 | input-only and output-only are degenerate uses; a bidirectional peer is one device; the GUI is an ordinary device, the paradigm one | plain | D-025 Position (cited 7713) | U |
| 559 | 7744–7746 | the GUI's "one genuine peculiarity": read-modify-write widgets | plain | D-025 Position names two, "main-thread affinity and RMW widgets" (log 906), affinity retired by D-310 | U; D-025 stale (part E) |
| 560 | 7750–7754 | a device subtypes `AbstractDevice`; one mandatory word; it buys `attach!`'s dispatch gate | plain | D-177 Position | U |
| 561 | 7754–7761 | the framework asks for `init!`, `loop`, `shutdown!`, optional `unblock!` | code | D-102 Position (cited 7819) | U; `src` gives `init!`/`shutdown!` defaults too (F62) |
| 562 | 7763–7777 | the framework owns everything around them; the wrapper is the shutdown protocol made structural | plain + code | D-102 Position and Rationale log 3148–3149 | U; the sketch's `mark_dead!` has no referent (F55) |
| 563 | 7779 | "`shutdown!` must tolerate a partially initialized device." | bold sentence, no citation | D-138 Rationale log 4552 ("a new taught obligation") | R |
| 564 | 7780–7783 | the initialization step brackets each `init!`; a half-acquired device goes straight to `shutdown!` | plain | D-138 Position | U |
| 565 | 7783–7788 | the obligation is "close only what is open"; `init!` owes no cleanup; the bracket does once what each device would duplicate | plain | D-138 Rationale | R |
| 566 | 7790 | "The same tolerance covers a repeated call." | bold sentence | D-268 bullet 6, amended 2026-09-30 (cited 7794) | C |
| 567 | 7790–7795 | the wrapper runs `shutdown!` and records the release; an interrupt between the two makes the tail run it again; each such interrupt adds one call | plain | D-268 bullet 6 | C; the mechanism is stale under D-310 (F54) |
| 568 | 7795–7797 | a `shutdown!` that closes only what is open is idempotent; a repeated call is never reported | plain | D-268 bullet 6 | C |
| 569 | 7799 | "The tolerance also covers a call with no `init!` before it." | bold sentence | D-268 bullet 7 (cited 7801) | C |
| 570 | 7800–7804 | the bracket lists each device before its `init!`; an interrupt between listing and `init!` releases a device that opened nothing; never reported | plain | D-268 bullet 7 | C |
| 571 | 7806 | "An `InterruptException` is never a `DeviceCrash`." | bold sentence, no citation | D-132 Rationale log 4155–4158; D-268 bullet 3 for the `init!` case | R |
| 572 | 7807–7813 | "Under the spawned-loop topology the calling task is the one running a device loop body inline, the GUI's (§11.1)"; Ctrl-C raises there; the wrapper forwards the stop; no crash report, no `should_abort` consultation | plain | D-132 Rationale | R; topology withdrawn by D-310 (F53) |
| 573 | 7817–7819 | one contract means author-owned bodies; a framework hook loop would resurrect the taxonomy as a trait | plain | D-102 Position; Rejected log 3157–3161 (cited) | C for the contract; R for the reason |
| 574 | 7819–7821 | every wait structure is ordinary user code composed from handle primitives | plain | D-102 Position | C |
| 575 | 7823–7850 | three loop bodies: timer-driven, source-driven with the bad-datum catch, boundary-driven output | code | D-102 Position; D-105 Position | U; `stage!` call shape fails against `src` (F56) |
| 576 | 7852–7854 | a bidirectional peer composes both halves with an inner reader task, rather than a framework select engine | plain | D-102 Rejected log 3159–3161 | R |
| 577 | 7854–7858 | two author obligations, taught and diagnosed, never forced: loop on `running(handle)`, interruptible blocking; `DeviceJoinTimeout`; stale heartbeat | plain | D-102 Rationale log 3152–3154 | R |
| 578 | 7858–7861 | liveness timestamps ride inside the handle primitives, in the device's diagnostic cell | plain | D-102 Rationale; D-136 Rationale log 4404–4406 | R |
| 579 | 7863 | "`should_close` dissolves." | bold sentence | D-102 Rationale log 3149–3150 | R |
| 580 | 7863–7866 | a window ✕ or a peer EOT is the body returning; the exit path releases OS resources, "marks it dead for the heartbeat" and consults `should_abort` | plain | D-102 Rationale (whose "claims-release/detach on every exit" is stale) | R; "marks it dead" (F55) |
| 581 | 7866–7867 | claims and the roster entry persist to run end (the freeze) | plain | D-106 Position; D-093 Rationale | U |
| 582 | 7867 | "§12.4(6) is literally 'the task body returned.'" | plain | none | N; the quote is not in §12.4 (F60) |
| 583 | 7867–7868 | the GUI implements the same contract | plain | D-102 Rationale log 3150–3151 | R |
| 584 | 7872 | a binding subtypes `AbstractBinding`, the second mandatory root | plain | D-177 Position (cited 7949) | U |
| 585 | 7873–7877 | its type declares its sides and enumerates what each touches; the legible half runs once at attach on the calling task, the opaque half per datum on the device task | plain | D-177 Rationale log 6481–6485; D-103 Position for the halves | R |
| 586 | 7879–7892 | the `T16000MBinding` sketch: roots, traits, `claims`, `map_input`, `reads`, `map_output` | code | D-177 Rationale; D-146; D-199 | R; partly runnable (part C) |
| 587 | 7894–7896 | the root carries `is_greedy = false`; silence is not greediness; the claim source is declared or absent | plain | D-177 Rationale log 6482–6483 | R |
| 588 | 7898–7901 | the framework needs no contract on the datum's shape; the datum travels only between `loop` and `map_input` | plain | D-103 Rationale log 3178–3179 | R; the `contract` link is the wrong sense (F61) |
| 589 | 7901–7905 | everything enumerable validates at attach, everything opaque is bounded at its enforcement point: `map_input` by staging, `map_output` by the gather's NamedTuple | plain | none states the pair; the mechanisms are D-044 (staging) and D-199 | N |
| 590 | 7905–7909 | "`map_input`/`map_output` are, precisely, conventions of the author-owned loop idiom"; never called, taught, never checked | bold words | D-177 Rationale log 6495–6496 | R |
| 591 | 7911–7917 | `reads(b)` returns a labeled NamedTuple of selectors; labels carried in declaration order; `map_output` receives exactly those names; one value fixes names, order and reads | **Rule.** label | D-199 Position (cited); "one value fixes" D-199 Rationale | C |
| 592 | 7919–7923 | "Sides are declared, and the obligations they create are enforced both ways."; error-throwing fallbacks on the root; a bidirectional conformance check over (trait, method) | bold sentence + bold words | D-177 Rationale log 6481–6486 | R |
| 593 | 7925–7927 | `is_input && !is_greedy` ⇒ `claims(b)` called once, faces staked | bullet | D-177 Rationale log 6486–6487 | R |
| 594 | 7928–7930 | `is_input && is_greedy` ⇒ the claim is computed; a `claims` method is an error | bullet | D-177 Rationale log 6487–6488 | R |
| 595 | 7931 | `is_output` ⇒ `reads(b)` called, gather compiled | bullet | D-177 Rationale log 6488 | R |
| 596 | 7932–7933 | neither side ⇒ attach-time error naming both traits | bullet | D-177 Rationale log 6488–6489; D-216 bullet log 8027 | R |
| 597 | 7934–7935 | `is_greedy` without `is_input` ⇒ error | bullet | D-177 Rationale log 6489 | R |
| 598 | 7936–7942 | a specific `claims`/`reads` method under a false trait ⇒ error, detected by one `which`; "That is the reflection class (§8.1)"; runs at a stopped-sim service point | bullet, bold word | D-177 Rationale log 6489–6492 and annotation log 6514–6516 | R; F51 |
| 599 | 7944–7946 | every violation reports `BindingContractMismatch`, naming type, trait, method and direction | plain | D-177 Rationale log 6493–6495 | R |
| 600 | 7948–7953 | "This is what closes the shadowing hole."; under method-presence detection a shadowed `claims` degraded silently to output-only | bold sentence | D-177 Rationale log 6497–6501; Rejected log 6519–6522 (cited) | R |
| 601 | 7955–7958 | greediness stays orthogonal to `reads`; legal and uninstantiated; customer a motorized control board | plain | D-134 Rationale log 4287–4290 (its `interactive` marker retired by D-174) | R |
| 602 | 7958–7961 | the binding stays an `attach!` argument, never a device field; narrowing the binding narrows the claim | plain | D-103 Rationale log 3179–3180 | R |
| 603 | 7963–7971 | "Why the periphery gets roots where components have one."; the slot is vacant; sidedness is its public contract | bold sentence + bold words | D-177 Position (cited 7973) | C (adjacent) |
| 604 | 7973–7979 | rejected: a binding-type taxonomy, optional roots, a `sides(b)` trait "answered rather than repeated" | plain, bold words | D-177 Rejected and Rationale log 6501–6504 (cited) | R; adversarial (q24) |
| 605 | 7981 | "`is_greedy` is a claim source, not a device class." | bold sentence, no citation | D-174 Position | U |
| 606 | 7981–7988 | one computation at attach; downstream blind to the source (exclusivity, shim, drain, trace, release); no shared derived surface, no class off the marker | plain | D-174 Position | U; duplicates §11.3 7207–7219 (part B) |
| 607 | 7988–7991 | opportunistic writing "for any device" stays dead; a maximal surface is one declared line | plain | D-044 Rejected log 1418–1419 (cited) | R |
| 608 | 7993 | "A second greedy attach stakes the empty remainder." | bold sentence, no citation | D-174 Rationale log 6363–6365 | R |
| 609 | 7994–7997 | the complement is computed against the roster as it stands; a later greedy binding gets the empty claim, legal and useless | plain | D-174 Rationale | R |
| 610 | 7997–8003 | the attach succeeds and records `EmptyGreedyClaim` in the entry's diagnostic cell; it surfaces through the status record; the log line is presentation | plain | D-250 bullet 5 (cited) | C |
| 611 | 8005–8008 | "Several interactive front ends may be rostered at once."; two enumerated devices partition the surface | bold sentence, no citation | D-174 Rationale log 6366–6368 | R |
| 612 | 8010–8012 | "The shipped GUI binding is a greedy one."; it declares `is_input` and `is_greedy`, defines no `claims` | bold sentence, no citation | D-174 Position (the GUI re-classed); D-175 (superseded) for the shipped binding | B: U by D-174; the "shipped" binding has no entry after D-310 parked the GUI (F71) |
| 613 | 8012–8017 | it declares no `reads`; its read path is the handle's primitive read, paced by its own clock, an ad-hoc read set in an inspection read's shape | plain | D-134 Rationale log 4298–4302 | R |
| 614 | 8017–8022 | the same GUI type attaches under explicit claims; greediness is the binding's declaration; other front ends have both spellings | plain | D-192 Rationale log 7055–7058; D-174 Rationale | R |
| 615 | 8024 | "The empty enumeration is not a back door." | bold sentence, no citation | D-177 Rationale log 6505–6508; D-134 Rejected log 4320–4326 | R |
| 616 | 8024–8027 | `claims(b) = ()` is an honest degenerate; its writes stay binding-bounded (`OutOfClaimEntry`) | plain | D-177 Rationale; D-044 Position ("binding-bounded even on unclaimed faces") | U by D-044; R by D-177 |
| 617 | 8027–8033 | no privileged class to promote into; an accidental empty enumeration stays inert; the maximal surface only through `is_greedy` | plain | D-134 Rejected log 4320–4324 | R |
| 618 | 8033–8037 | `claims` never returns `nothing` or a sentinel meaning "compute it for me" | plain | D-134 Rejected log 4317–4319 | R |
| 619 | 8041–8044 | `TableBinding` is data-driven; the framework writes its `map_input` once; a table per device × aircraft pairing | plain | D-103 Rationale log 3180–3182; D-045 bullet 3 | U by D-045 for mappings as data; R by D-103 for `TableBinding` |
| 620 | 8046–8050 | the `TableBinding` call | code | D-103 Rationale log 3180–3181 | R; ran and passed (part C) |
| 621 | 8052–8053 | its generic `map_input` is the shared pure conditioning helper, and its owner | plain | D-103 Rationale log 3182; D-045 bullet 2 | R |
| 622 | 8053–8054 | the entry tuple rides in the type; per-table specialization, no dynamic dispatch | plain | D-103 Rationale log 3181 | R |
| 623 | 8054–8056 | a code-driven binding looks identical to the framework | plain | none | N, a description |
| 624 | 8057–8059 | cross-datum state lives in the device struct and arrives inside the datum; `map_input` stays pure | plain | D-103 Rationale log 3182–3183; D-045 bullet 4 | R |
| 625 | 8063–8067 | a bad datum is tolerated in the loop body: catch, stage nothing, `report!`, continue | plain | D-105 Position (cited 8077) | C (adjacent) |
| 626 | 8067–8071 | the tolerance is bounded by the device's diagnostic cell; any other exception becomes `DeviceCrash` | plain | D-105 Position | C (adjacent) |
| 627 | 8073–8077 | the classification is the author's; no framework per-iteration catch site; no marked exception type | plain | D-105 Rationale and Rejected (cited) | C for the type; R for the reason |
| 628 | 8078–8081 | `report!(handle, …)` writes device-attributed warnings into that device's cell and nothing more; not a general channel | plain | D-105 Rationale log 3247–3249; D-160 Position; D-189 Position | U by D-160/D-189; R by D-105 |
| 629 | 8081–8085 | tolerating everything hides bugs; tolerating nothing kills a telemetry link for the run (D-093) | plain | D-105 Rejected log 3256–3258 | R |

Descriptions that read like rules: rows 555 (no Position states it), 589,
612–613 (the shipped GUI's read path), 622.

Display-block candidates: the `attach!` signature,
`attach!(sim, dev::AbstractDevice, binding::AbstractBinding; should_abort =
false)` (D-177 Position), which §11.6 never shows, at 7732; the handle's
primitives (`running`, `latest`, `wait_next_snapshot`, `stage!`, `report!`,
`binding`, `gather`, `pending`, `stop!`), which §11.6 never lists (Appendix B
12659–12661 does), at 7717; the six conformance outcomes (7925–7942) as a
two-column table, trait combination → outcome.

Glossary terms (lesson 35):

- Linked at first use and matching: snapshot (7719), boundary (7720), drain
  (7726), `should_abort` (7732), periphery (7752), selector (7911), face
  (7926), component (7964), trace (7985), bad datum (8065).
- Linked late: device (first prose use 7733, linked 7750); diagnostic cell
  (7727, linked 7860); roster (7722 "roster entry", linked 7866); calling
  task (first prose use 7807, linked 7875); claim (code comment 7775,
  prose 7865, linked there).
- Linked more than once: device (7750, 7876, 8043, 8067), diagnostic cell
  (7860, 8068, 8079), claim (7865, 7928), roster (7866, 7994), face (7926,
  8042), periphery (7752, 7963), drain (7726, 7985), snapshot (7719, 8015).
- Linked against its entry: contract (7898), a datum-shape contract, not a
  component's declared interface (F61).
- Used, never linked: binding (the section is its home; `#g-binding` 13943
  cites §11.6 and the section never links it); frame (7727); batch (7726);
  operator interrupt (7792); the freeze (7866); greedy claim (7981–7997);
  class in the glossary's sense (7964, 7969, "a component's class"); log
  (8001).
- Reserved words used outside their entry: bare "cell" (7726 "a cell no
  drain reads"); bare "entry" (7722 "retires the entry", 7730 "the
  entry's"), which `#g-entry` 13489 forbids; "class" in ordinary English at
  7728, 7741, 7940 ("the reflection class", F51), 7981, 7987, 8028, 8061;
  "tick" for a GUI render pass (8014), where `#g-tick` 13769 is a discrete
  component's instant.

Appendix C kinds cited to §11.6 (lesson 20):

- `EmptyGreedyClaim` (13127): named at 7998, where its condition is stated.
- `BindingContractMismatch` (13131): named at 7944, right after the list of
  its conditions.
- `DeviceContractMismatch` (13139): named at 7725 for the detached handle.
  Its other two conditions, a device with no `loop` method and `gather`
  against a binding with no output side (D-216 bullet, log 8028–8030), are
  not stated in §11.6 (F63).
- `ArgumentInvalid` (13228): cited to §11.6 for `TableBinding`'s entry
  table. §11.6 states no validation of the table (F63); `src/bindings.jl`
  41–67 checks entry shape, a `face`, the key vocabulary, `deadzone` in
  [0, 1) and `expo` in [0, 1].
- `DeviceCrash` (13283): named at 7768, 7772, 7838, 8071.
- `MalformedDatum` (13290): named at 7839 and 8066.

### §11.7 The GUI write path: port resolution, peek, staging contract (8087–8244, 1,503 words)

Purpose: how a panel's widgets resolve to root inputs, when a widget is
live, what it displays (the peek), when it stages, the orphan case, and the
framework's half of the panel convention (port views, `pending`, `peek`,
`incumbent_status`), with the deferred half.

Subheadings: none. Labels: **Rule.** 8190, 8210, 8228. Bold lead-ins "Peek
rule." (8145) and "Staging contract:" (8154). One table (8203–8208).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 630 | 8089–8091 | panels remain per-component extensions FlightCore-style (`GUI.draw!(ctx, ::LowPassFilter)`), discovered by walking the assembly | plain | D-026 Position; D-310 bullet 3 (the panel method is to return a description, "ruled when the cockpit's design reaches it") | U |
| 631 | 8091–8092 | widgets name "the component's own ports", never root inputs | bold words | D-026 Position (cited 8149) | U |
| 632 | 8092–8095 | build-time wiring answers whether a port is transitively root-driven and by which; every input port has one source, so resolution is total | plain | D-026 Position ("build-time resolution"); D-045 bullet 1 | U |
| 633 | 8097–8099 | root-driven within the GUI's claim: a live widget that peeks and stages through the GUI's staging cell | bold lead-in | D-026 Position; D-174 Rationale log 6382–6383 | U |
| 634 | 8100–8104 | component-driven or under another claim: a read-only rendering from the snapshot, visually distinct, with its source | bold lead-in | D-026 Position ("live vs first-class read-only rendering (with its wiring source shown)") | U |
| 635 | 8106–8108 | retires the dead-slider convention; "a widget is live exactly when the underlying input is yours to command in this configuration" | bold clause, no citation | D-026 Rejected log 938–939; D-045 bullet 1 | U by D-045 |
| 636 | 8108–8111 | the dead slider is the `Cessna172Xv1` throttle, silently overwritten each cycle | plain | D-026 Rejected | R; reader-cold name (F67) |
| 637 | 8111–8114 | user-commandability is a wiring decision; command-plus-override is a mux with a root-wired select | plain | D-045 Rejected log 1444–1445 | R |
| 638 | 8114–8117 | read-only rendering is first-class, since the widget's author cannot know whether it will be live | plain | D-026 Position | U |
| 639 | 8119–8120 | "Liveness is a derived property, and resolution is transitive." | bold sentence | D-045 bullet 1 (cited 8141) | U |
| 640 | 8120–8123 | live iff the feed chain ends in a root input "inside the GUI's own claim" in the frozen partition | plain, bold words | D-174 Rationale log 6382–6383; D-045 bullet 1 says "slot unclaimed", stale | R |
| 641 | 8123–8124 | the chain is walked through local wires and interface connections across all levels | plain | D-045 bullet 1 ("transitive"); D-270 annotation log 11279–11280 | U |
| 642 | 8124–8128 | the claim may be computed or enumerated; "live" reads "inside the surface I declared for" | plain | D-174 Rationale | R |
| 643 | 8130–8132 | under the freeze liveness is static, baked once at run start, never consulted against claim state at render | plain | D-047 Rationale log 1501–1503; D-270 Rationale log 11197–11200 | R |
| 644 | 8132–8134 | no per-port "GUI-controlled" marking; the export chain is the marking | plain | D-045 Rejected log 1442–1443 | R |
| 645 | 8134–8140 | ports become commandable when the assemblies above surface them; the switch is automatic, by wiring at build time and by claims at run start | plain | none | N, a consequence |
| 646 | 8140–8141 | nominally-connected ports with a GUI override channel are rejected | plain | D-045 Rejected (cited) | R |
| 647 | 8141–8143 | "Unexported ports are unpokeable."; FlightCore's poke-any-`u` does not survive contract visibility | bold sentence | D-045 bullet 5 (cited 8141) | C |
| 648 | 8145–8146 | a widget displays its "own pending write if any, else the snapshot value" | bold lead-in + bold words | D-026 Position (cited 8149) | C |
| 649 | 8146–8149 | it peeks its own cell only; another device's pending write is invisible; cross-device peek rejected | plain | D-026 Position and Rejected (cited) | C |
| 650 | 8149–8151 | while paused, staged edits display and apply at the un-pause drain | plain | D-270 Rationale log 11205–11207 | R |
| 651 | 8151–8152 | fan-out is consistent for free | plain | none | N, a consequence |
| 652 | 8154 | "Staging contract: widgets stage on interaction events only." | bold lead-in sentence | D-047 Position; D-026 Position (cited 8167) | U (D-047 never cited in §11.7) |
| 653 | 8155–8157 | value widgets stage the absolute level on edit; edge widgets stage a level computed from the peek; flaps `k` → `k+1` | plain | D-047 Position | U |
| 654 | 8157–8162 | the levels doctrine makes it safe; repeated staging idempotent; multi-click counts through the own-pending-first peek | plain | D-047 Position | U |
| 655 | 8162–8164 | held buttons do not re-stage, which would auto-repeat at frame rate | plain | D-047 Rejected log 1509–1510 | R |
| 656 | 8166–8169 | staging on every render pass is rejected; no motivation under exclusivity; traffic drops to actual edits | plain | D-026 Rejected log 933–936 (cited); D-047 Rejected | R |
| 657 | 8171–8172 | no claim-transition policy, since no claim transition occurs mid-run | plain | D-047 Rationale log 1501–1502 | R |
| 658 | 8172–8179 | the orphan case: the label shows "claimed by `T16000M` — task dead"; the widget shows the last drained level; never blanked | plain | D-047 Rationale log 1502–1503; D-270 Rationale | R |
| 659 | 8181–8182 | "The panel convention has two halves. The framework's half is fixed here, and the GUI package's half is deferred." | bold, two sentences | D-270 Position (cited 8188) | C (adjacent); bold spans two sentences |
| 660 | 8182–8188 | a panel reaches the framework through a port view, the handle and a snapshot; nothing reaches into the loop | plain | D-270 Position (cited) | C |
| 661 | 8190–8201 | `port_views(handle)`: one view per port of every component, keyed by `(path, port)`; producer, verdict, slot, address, incumbent; built at the loop's top after the freeze; `Structure` and nominal `Layout` on the handle; output ports read-only | **Rule.** label | D-270 bullet 1 and annotations log 11253–11256, 11279–11281 | U (D-270 cited one paragraph up) |
| 662 | 8203–8208 | the four-row resolution table | table | D-270 bullet 1 | U |
| 663 | 8210–8213 | `pending(handle, slot)`: one acquire load, never a take; `Some(value)` or `nothing`; a published batch is never mutated | **Rule.** label | D-270 bullet 2 | U |
| 664 | 8214–8218 | `peek(view, handle, snapshot)` composes it with the snapshot; two ports on one root input share slot and address | plain | D-270 bullet 2 and annotation log 11266–11277 (the rename to `peek`) | U |
| 665 | 8220–8226 | between the drain and the publication a live widget shows the previous snapshot's value; a click there stages a drained level, idempotent | plain | D-270 bullet 4 | U |
| 666 | 8228–8233 | `incumbent_status(view, snapshot)`; `orphaned` is a task that returned or crashed; `stale` is §12.2's silence; the label text is the package's | **Rule.** label | D-270 bullet 3 and annotation log 11257–11264 | U |
| 667 | 8235–8238 | the deferred half goes to the browser client over the bridge: what it receives, panel scoping, widgets | bold words | D-310 bullet 3 (cited) | C |
| 668 | 8238–8243 | its constraints: panels name ports by face-name string; resolution and liveness baked at run start; liveness and peek through the framework context; assembly panels compose children by path | plain | D-026 Position; D-270 Position; none for "compose children by path" | B: U for the first three; N for the last |

Descriptions that read like rules: row 645 (the automatic switch, and the
scripted-`World` archetype it leans on), row 668's last clause.

Display-block candidates: the panel kit's four signatures (`port_views`,
`pending`, `peek`, `incumbent_status`) as one block before 8190; the
multi-click sequence of 8160–8162 (`k` → stage `k+1`; peek pending `k+1` →
stage `k+2`) as a two-line chart.

Glossary terms (lesson 35):

- Linked at first use and matching: component (8089), assembly (8091), port
  (8092), root input (8092), peek (8098), staging cell (8099), snapshot
  (8102), derived liveness (8119), local wire (8123), face (8126), roster
  (8130), scenario component (8138), contract (8143, the right sense), drain
  (8150, glossed).
- Linked late: claim (first use 8097, linked 8122); device (8100, linked
  8147).
- Linked twice: staging cell (8099, and 8146 as "[cell](#g-staging-cell)").
- Used, never linked: *stage-on-interaction* (14106), whose glossary entry
  cites §11.7 and which §11.7 neither names nor links (F66); orphaned claims
  (8172); the freeze (8130, 8172); frame (8148); binding (8127); trace
  (8168); `Build` (8137); `Structure` (8199); nominal (8199).
- Term collision: "port view" (8183 onward) beside `#g-view` 13570, a
  zero-copy reconstruction of a store. The compound is the API's
  (`PortView`); a gloss at first use keeps the two apart.

Appendix C kinds cited to §11.7: none, and §11.7 names none.

### §11.8 Diagnostics and liveness: the per-writer cell (8245–8386, 1,344 words before the closing rule)

Purpose: the third cross-task channel. Who writes diagnostics and who reads
them; one cell per writer; the ring bound as the rate limit; the drain; the
heartbeat; the published status; presentation; the run's end; allocation.

Subheadings: none. Labels: none. Bold sentences or lead-ins at 8268, 8285,
8297, 8309, 8319, 8333, 8341, 8357; bold words at 8280–8282, 8300, 8334,
8362–8363.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 669 | 8247–8249 | the warning stream and the heartbeat are a third channel, crossing the same task boundaries | plain | D-136 Position | U |
| 670 | 8249–8256 | written at staging by whichever task stages (three kinds); by device tasks (`MalformedDatum`); by the loop (`DebtReanchor`, `UnboundedRun`); by the frame (`ChatteringBudget`, `FiringBudget`) | plain | D-200 Position (cited); D-317 bullet 5 for the frame | C; U for D-317 |
| 671 | 8257–8261 | written at `attach!` into the entry being created (`EmptyGreedyClaim`); it lives in the roster's status; no other writer exists before `run!` | plain | D-250 bullet 5 (cited) | C |
| 672 | 8261–8263 | read by the loop, folded into the framework status, hence every snapshot | plain | D-136 Rationale log 4407–4411 | R |
| 673 | 8263–8266 | an unspecified structure would be the shared mutable state §11.1 eliminates, so it reuses §11.4's mechanism | plain | D-136 Rejected log 4435–4438 | R |
| 674 | 8268–8270 | "One diagnostic cell per writer: one per rostered device, one for the harness writer, one for the loop itself" | bold sentence | D-200 Position (cited) | C |
| 675 | 8270–8273 | the `Model` owns one more; its frame writes the chattering and firing-budget reports; the drain folds it beside the loop's | plain | D-317 bullet 5 (cited) | C |
| 676 | 8273–8276 | each cell has a single writer, the staging cells' ownership argument; no lock, no arbitration, no new primitive | plain | D-136 Position | U |
| 677 | 8277–8278 | the harness writer's cell is written from whichever task stages; the same CAS append arbitrates | plain | D-200 Position; Rationale log 7364 (CAS) | C; R for the CAS |
| 678 | 8279–8280 | it carries no heartbeat and no `task_state` | plain | D-200 Position | C (adjacent) |
| 679 | 8280–8283 | a "bounded accumulation" and one atomic timestamp; a ring of capacity "16" plus per-kind counts | bold words | D-136 Position | U |
| 680 | 8285 | "That bound *is* the rate limit." | bold sentence | D-136 Rationale log 4398 | R |
| 681 | 8285–8289 | past capacity within one frame an entry is not stored and its kind's count increments; the earliest are retained | plain | D-136 Rationale log 4398–4400 | R |
| 682 | 8289–8295 | rate limiting is a structural property of the channel; a flood costs at most sixteen values and one increment per kind per frame; no writer starves another | plain | D-136 Rationale log 4400–4401 | R |
| 683 | 8297 | "This drain is the same drain §11.4 specifies." | bold sentence | D-136 Rationale log 4402–4403 | R |
| 684 | 8298–8302 | one `atomicswap` per cell at frame top, swapping in a shared "empty sentinel"; a quiet frame allocates nothing; no load-only path | plain, bold words | D-136 Rationale log 4403–4404 | R |
| 685 | 8302–8307 | the take makes publication sound; §11.2's binding rule holds by construction | plain | D-136 Rationale log 4411–4414 | R |
| 686 | 8309 | "The heartbeat rides in the same cell, as an atomic timestamp field." | bold words | D-136 Position | U |
| 687 | 8310–8313 | the device task stores it on every pass inside the handle primitives; the loop acquire-loads it at publication | plain | D-240 Position (cited) | C |
| 688 | 8313–8316 | no separate channel, no second registry; the 2 s threshold reads this field | plain | D-136 Rejected log 4449–4451; Rationale log 4406 | R |
| 689 | 8316–8317 | the heartbeat is a field, not a diagnostic kind, never enumerated in Appendix C | plain | D-136 Rationale log 4406–4407 | R |
| 690 | 8319 | "The published framework status is a concrete frozen value." | bold sentence, no citation | D-136 Rationale log 4407–4408 | R; bold twice (§11.2 6920 bolds it too, part B) |
| 691 | 8319–8325 | per writer: `recent`, `suppressed`, `totals` (loop-owned, copied), `heartbeat` beside `task_state` read off the `Task` at publication | plain | D-136 Rationale log 4408–4411; D-193 Position (`task_state`) | R; U for D-193 |
| 692 | 8325–8326 | beside the records ride the pacer diagnostics | plain | D-136 Rationale log 4411 | R |
| 693 | 8326–8330 | delta plus total is legible at any reading cadence; nothing is lost by not looking | plain | none | N, constructive rationale |
| 694 | 8330–8331 | `who` is the only attribution; a renderer presents each value under its writer | plain | D-228 Position and Rationale (cited) | C |
| 695 | 8333–8336 | "Presentation is where `maxlog` lives."; up to "25" cumulative occurrences, then count-only | bold sentence + bold words | D-136 Rationale log 4414–4416 | R |
| 696 | 8336–8339 | that threshold is presentation policy; counts accumulate; the channel's bound is normative | plain | D-136 Rejected log 4455–4456 | R |
| 697 | 8341–8345 | "The terminal snapshot carries the run's final cumulative counters"; an unattended run still answers from it | bold sentence | D-136 Rationale log 4417–4419 | R |
| 698 | 8345–8350 | final means final at the last frame top; what lands after reaches no snapshot; the loop takes each cell once more at the run's end | plain | D-201 Position (cited) | C |
| 699 | 8350–8355 | the last take goes into the termination record as the tail residue and through the logging backend; loud, recorded, never published | plain | D-203 Position (cited) | C |
| 700 | 8357–8358 | "On a quiet frame nothing allocated scales with diagnostic activity" | bold lead-in + bold clause | D-241 Rationale log 9172–9174 | R (D-241 cited 8362 for the vector) |
| 701 | 8358–8362 | the status costs one small vector per publication; a roster-sized vector, not a snapshot type per roster size | plain | D-241 Position (cited) | C |
| 702 | 8362–8365 | the per-kind counters are a "fixed-shape isbits record, never a `Dict`", licensed by the closed kind set | bold words | D-136 Rationale log 4421–4423 | R |
| 703 | 8365–8372 | a noisy frame allocates values at emission and a fresh ring lazily, on the writer's task; worst case one ring of sixteen per writer per boundary | plain | D-136 Rationale log 4423–4428 | R |
| 704 | 8372–8375 | "The zero-allocation invariant (§9.8), scoped to the model sweep, is untouched"; the cells sit on the framework side | plain | D-305 bullet 1 ("scoped to the stepping loop"); D-136 Rationale log 4428–4429 ("model-sweep") | U by D-305; the wording is D-136's stale one (F52) |
| 705 | 8377–8381 | `totals` is monotone across logged snapshots; decimation loses which boundary, never how many | plain | D-136 Rationale log 4429–4432 | R |
| 706 | 8383–8385 | rejected: a shared queue under a lock, a status referencing the live accumulator, double-buffered rings, unbounded accumulation | plain | D-136 Rejected (cited) | R; adversarial list (q24) |

Descriptions that read like rules: row 693.

Display-block candidates: the published per-writer record
(`who`, `recent`, `suppressed`, `totals`, `heartbeat`, `task_state`) as a
display block at 8319, where four fields are named in four sentences today.

Glossary terms (lesson 35):

- Linked at first use and matching: device (8252), framework status (8262),
  snapshot (8263), diagnostic cell (8268), `Model` (8270, glossed), staging
  cell (8276), unattended run (8342), termination record (8351),
  decimation (8379, glossed).
- Linked late: drain (first use 8272, linked 8297).
- Linked twice: diagnostic cell (8268, 8274).
- Linked against its entry: sweep (8374; `#g-sweep` 13608 is one pass
  through the execution order, narrower than the invariant's scope, F52).
  chattering (8292) links the entry titled "chattering / localization
  budget"; "a chattering model" fits it.
- Used, never linked: harness writer (8252), roster (8257), frame (8255),
  boundary (8320), kind (8286), log (8377).
- Reserved words used outside their entry: bare "cell" in the heading and at
  8245, 8298, 8309, 8314, 8375 (`#g-cell` 13480 "Bare 'cell' means only
  this", D-121 Position); "batch" for the taken diagnostic ring (8303;
  `#g-batch` 13939 "The word means only this"); bare "entry" (8286, 8320).
  F65.

Appendix C kinds cited to §11.8: `UnboundedRun` (13296), named at 8255 as a
loop-written kind, its condition owned by §13.5; and the "rate-limited, a
repeating source (§11.8)" policy pointer of `ReplayDiscardedStaging` (13288)
and `MalformedDatum` (13291), a policy, not a condition. Nothing missing.

### Tally

| section | rows | C | U | S | R | N | B |
|---|---|---|---|---|---|---|---|
| §11.5 | 47 (501–547) | 18 | 10 | 0 | 13 | 2 | 4 |
| §11.6 | 82 (548–629) | 16 | 16 | 0 | 44 | 5 | 1 |
| §11.7 | 39 (630–668) | 6 | 18 | 0 | 12 | 2 | 1 |
| §11.8 | 38 (669–706) | 11 | 5 | 0 | 21 | 1 | 0 |
| total | 206 | 51 | 49 | 0 | 90 | 10 | 6 |

No row cites a superseded entry. Several cite entries whose status reads
"ratified" while a later entry has superseded their Position in whole or in
part: D-103 (by D-177), D-107 (by D-176), D-134 (by D-174), D-127 and D-133
(by D-255, D-274, D-181). Part E lists them. The R share (44 %) is the
chapter's characteristic: §11.6 rests on D-177's Rationale (one Position
sentence about roots, every conformance rule in the Rationale) and on the
Rationales and Rejected lists of D-102, D-103, D-134 and D-138; §11.8 rests on
D-136's Rationale, whose Position names only the cell, the ring and the
timestamp.

## B. Overlaps

### Inside the half

- **§11.5, the trace's length, twice.** 7659–7667 (the `Trace` value, its
  length, the drain's count, the frame ordinal) and 7688–7694 (its length,
  the frame index of the last drain, `init!` versus `restore!`, the replay
  cap). M51 merges them.
- **§11.5, the header, in three places.** 7626–7643 (what the header is and
  holds), 7645–7657 (the deployment and layout bullet, the policy), 7677–7688
  (why it must hold the deployment and clock; the one full-state capture;
  primary versus derived). M52 gathers them.
- **§11.5, primary versus derived, three times.** 7684–7688, 7699–7702 and
  the budget at 7611–7612 against 7703–7706 ("two orders of magnitude").
  M53 keeps one statement of each in the default paragraph.
- **§11.6, greedy material in six paragraphs.** 7894–7896 (the root's
  default), 7928–7930 and 7934–7935 (two conformance bullets), 7955–7958
  (orthogonal to `reads`), 7981–7991 (a claim source), 7993–8003 (the empty
  remainder), 8010–8022 (the shipped GUI binding), 8031–8033 (the explicit
  declaration). M55 and M56 group the non-bullet ones.
- **§11.6, should_abort, twice.** 7732–7739 and 7863–7865 (the exit path
  consults it). Both stay; the second is the wrapper's step.
- **§11.6 against §11.8, the heartbeat in the handle.** 7858–7861 and
  8309–8312 state the same mechanism. §11.8 is the home (D-136); §11.6's
  sentence becomes a pointer.
- **§11.7, the peek and the orphan, each twice.** The peek rule (8145–8152,
  D-026) and its API (8210–8218, D-270) both state fan-out consistency
  (8151–8152, 8217–8218). The orphan display rule (8171–8179) and the orphan
  fact (8228–8233). Each pair is a semantic rule and its spelling; the API
  halves should say "the rule above" rather than restate.
- **§11.7, the panel convention's two halves.** 8181–8188 opens them and
  8235–8243 closes with the deferred half. Not a duplicate; they bracket the
  API.

### With the other half (§11.1–§11.4)

- **§11.6 7981–7991 against §11.3 7207–7219.** Nearly sentence for
  sentence: one computation at attach, everything downstream blind to the
  source, opportunistic writing dead, autonomous devices enumerate. §11.3 is
  the claim's home (D-174 Spec lists both). q22.
- **`EmptyGreedyClaim`, three times.** §11.3 7194–7197, §11.6 7993–8003 and
  §11.8 8257–8261, each citing D-250. §11.6 is the fullest; §11.3 and §11.8
  could point to it.
- **§11.6 7911–7917 against §11.2 7085–7087.** Both say `map_output`
  receives a labeled NamedTuple keyed by the names `reads` declared. §11.6
  holds the **Rule.** with D-199; §11.2's clause is a pointer already.
- **§11.6 8039–8059 against §11.4 7495–7499.** `TableBinding` applies the
  conditioning in its generic `map_input`, "the shared pure helper, with an
  owner (§11.6)". Consistent; §11.4 points here.
- **§11.6 7959–7961, 8024–8027 against §11.3 7166–7187.** Narrowing the
  binding narrows the claim; the empty enumeration is binding-bounded.
  Consistent.
- **§11.6 7863–7868 and §11.7 8171–8179 against §11.3 7305–7316.** Death
  is not detach; the orphan label "claimed by `T16000M` — task dead" appears
  verbatim in §11.3 7312 and §11.7 8174. §11.3 holds the rule (D-106);
  §11.7 holds the display rule (D-047 Rationale).
- **§11.6 7806–7808 contradicts §11.1 6841–6843.** §11.6 cites §11.1 for a
  calling task running the GUI's body inline; §11.1 now says every device
  runs on a spawned task (D-310). F53.
- **§11.7 against §11.4's worked example.** §11.4 7521 says the example
  "produced the §11.7 staging contracts", 7537–7538 calls the
  stage-every-pass contract §11.7's, and 7573 lists "the active-widget
  contract" as a discovery. §11.7 8166–8167 rejects staging on every pass
  (D-026's superseded position). The sibling owns the lines; F70 records it
  for the merge.
- **§11.3 7219 relies on §11.7** for "lets a drained GUI value simply stay
  (§11.7)". §11.7 has no such sentence. The sibling's row; noted for the
  merge.
- **§11.8 against §11.2.** The framework status is bold twice, at §11.2
  6920 ("a concrete frozen value, not a window onto live bookkeeping") and
  §11.8 8319 ("a concrete frozen value"). Each ruling is bold in one place
  only (`spec_style.md`, "Marking rulings"). The terminal counters (8341–8346
  against 7059–7062) and the `totals` monotonicity (8377–8381 against
  7064–7066) are stated in both. §11.8 is the home of the status (D-136);
  q23.
- **§11.8 8249–8252 against §11.4 7446–7456.** The three staging kinds and
  where they are raised. §11.4 holds the rule; §11.8 lists writers. Fine.
- **§11.5 7639–7643 against §11.3 7243–7251.** Root-input initial values are
  the init/trim services', and the trace header captures them. Both cite
  §14.6. §11.3 holds the rule; §11.5 holds the replay reason.
- **§11.5 7669–7675 against §11.4 7374–7375 and §11.3 7269–7271.** The
  schema lives in the roster entry (§11.4) and on the trace's `schemas` list
  (§11.5); the trace tags a stable device id (§11.3). Consistent; §11.5 could
  say the list records each roster entry's schema.
- **§11.5 7696–7707 against §11.2 6983–6992.** The log takes "the same plain
  on/off switch the trace has (§11.5)"; decimation is the log's alone.
  Consistent.

### With other chapters

- **§11.5 7629–7634 against §12.6 9220–9226 and the glossary checkpoint
  (14134–14141).** All three list the checkpoint's contents. §12.6 is the
  checkpoint's home (D-319 Spec lists §12.6, not §11.5). §11.5 could keep
  "the trace header is the checkpoint" and point. Their lists disagree on
  the deployment and layout (F58).
- **§11.5 against §12.7.** 7642 (the fingerprint compared), 7669–7671
  (replay does not reconstruct claims), 7692–7694 (the replay cap) are
  §12.7's rules (9305–9310, 9462–9480) stated briefly here with citations.
  Fine as pointers.
- **§11.6 7779–7804 against §12.4 8793–8805.** The init bracket and the
  listing before `init!` are §12.4's; the tolerances they impose on
  `shutdown!` are §11.6's. §12.4 cites §11.6 three times for them (8794,
  8798, 8805). Keep both; §11.6 states the author obligation, §12.4 the
  bracket.
- **§11.6 7806–7813 against §12.4 8865–8872.** §12.4 states the `init!`
  case and says "The device wrapper makes the same discrimination for a
  raise inside a loop body (§11.6)". Keep §11.6's rule; fix its reason
  (F53).
- **§11.6 7854–7858 against Appendix A 12358–12365.** Appendix A indexes the
  two loop idioms. Appendix A also teaches "Keep `is_input`/`is_output`/
  `is_greedy` trivial, a literal or a flag read off a field fixed at the
  constructor call" (12373–12375), which §11.6 never states and no entry
  rules. Part D.
- **§11.8 8309–8317 against §12.2 8534–8551.** §12.2 owns staleness and
  `task_state`; §11.8 owns the field. Consistent.
- **§11.8 8357–8375 against §9.8 5418–5423.** The allocation scope; F52.

### Part I at Part I's depth (`spec_style.md`, "Part I's depth")

Three sentences restate §2.4's laws instead of giving the mechanism:

- 7582–7585: the trace "extends the determinism ([§10.7]) end-to-end.
  Replaying a recorded interactive session reproduces the trajectory
  bit-identically". §2.4 567–570 states the law. §11.5 should point to §2.4
  and keep its mechanism, "staging fed from the recording and no devices or
  mappings present".
- 7677: "The trajectory depends on the deployment exactly as it depends on
  the stores." §2.4 546–554 lists the five things that fix a trajectory. Keep
  the consequence for the header (7678–7681) and point.
- 7700–7702: "Given the initial state and the trace, the log is
  recomputable, which is what bit-identical replay means." Same law. Keep
  the default's asymmetry, which is §11.5's own.

No sentence of §11.6, §11.7 or §11.8 restates Part I.

## C. Proposed structure

No section is renumbered and none is retitled: 286 inbound rows target these
four sections (part D). No file links a `####` anchor of chapter 11
(`git grep` over `docs/` at `f61b1af`), so retitling subheadings is free.
Every move below stays inside its section, so no inbound citation is
retargeted by a move.

### Moves

| move | content | from | to | needs a ruling |
|---|---|---|---|---|
| M51 | the trace's length, its frame-index meaning under `init!` and `restore!`, the replay cap | §11.5 7688–7694 (73 words) | merged into the `Trace` paragraph 7659–7667, which states the length first | no |
| M52 | why the header holds the deployment and the clock; the one full-state capture; the run metadata | §11.5 7677–7686 (85 words) | up, after the header's contents (7626–7657), so the header is described in one place | no |
| M53 | "Header plus batches are the *primary* record. Everything else … is derived" | §11.5 7686–7688 | into the default paragraph (7699–7702), which states the same asymmetry | no |
| M54 | "Bad datum versus bug" | §11.6 8061–8086 (208 words) | up, after the loop-body subsection (after 7868); it is about the loop body's catch, shown in the `UDPInput` sketch, not about bindings | no (optional; changes the G1/G2 split) |
| M55 | "Why the periphery gets roots where components have one" | §11.6 7963–7971 (90 words) | up, after the binding's shape and the `reads` rule (after 7917), before the conformance check; it argues for the mandatory root the binding paragraph introduces. 7973–7979 ("Rejected, correspondingly …") stays after the conformance check, since it cites "the bidirectional check" | no |
| M56 | "Greediness stays orthogonal to `reads` … narrowing the binding narrows the claim" | §11.6 7955–7961 (69 words) | down, into the greedy group, after "`is_greedy` is a claim source" (7981–7991) | no |
| M57 | the `should_abort` paragraph | §11.6 7732–7739 (85 words) | down, after "`should_close` dissolves" (7863–7868), whose exit path consults it; today it uses "the loop body returning" and "a failed `init!`" before the contract defines either | no |
| M58 | "Input-only and output-only devices are degenerate uses … read-modify-write widgets" | §11.6 7741–7746 (55 words) | up, into the context paragraph (7711–7713); it is D-025's Position, which the context cites | no |

### Order within each section

Define-before-use was checked for each order below against the terms each
block uses.

- **§11.5.** Context: what the trace is (7581), with the bit-identity law as
  a pointer to §2.4 and the mechanism kept (part B). Then the record format
  and its costs (7587–7624; "`schemas` list (below)" stays a forward
  pointer). Then the header (7626–7657 as prose, the one-item list
  dissolved, plus M52). Then the `Trace` value with its length (7659–7667
  plus M51). Then the schema list (7669–7675). Then the default (7696–7707
  plus M53). At 1,186 words the section can do without `####` labels; if
  the rewriter wants them: "The record format", "The header", "The `Trace`
  value", "Recording is on by default". The alternative order, the `Trace`
  value first, reads more naturally but moves D-176's bold ruling from the
  top; not recommended.
- **§11.6, unit G1.** Context (7711–7713 plus M58). "The handle"
  (7717–7730). "The authoring contract" (7750–7777, the `attach!` signature
  added as display code if q30 allows). "`shutdown!`'s tolerances"
  (7779–7804). "The operator interrupt" (7806–7813). "Loop bodies"
  (7817–7868, then M57). "Bad datum versus bug" (M54). The handle paragraph
  uses `stage!` and `report!` before the contract shows them; both are
  glossed there today ("Its two write primitives").
- **§11.6, unit G2.** "The binding" (7872–7909), the `reads` rule
  (7911–7917), M55, "The conformance check" (7919–7953, then 7973–7979),
  "Greedy claims" (7981–7991 plus M56, 7993–8022), "The empty enumeration"
  (8024–8037), "`TableBinding`" (8041–8059). The claim-headings become topic
  labels: "The authoring contract: four functions, one optional" also makes
  a claim that F62 questions.
- **§11.7.** One context sentence first (a widget must know whether it may
  write the input it shows), then `####` labels: "Port resolution and
  derived liveness" (8089–8143); "The peek and the staging contract"
  (8145–8169); "The orphan case" (8171–8179); "The framework's half of the
  panel convention" (8181–8233); "What stays deferred" (8235–8243). The
  bullet at 8097–8099 uses "peeks" before the peek rule; its glossary link
  needs a gloss there. The three **Rule.** labels become the labels'
  content.
- **§11.8.** Unchanged order. Labels: "Writers and readers" (8247–8266),
  "One cell per writer" (8268–8283), "The bound and the drain" (8285–8307),
  "The heartbeat" (8309–8317), "The published status" (8319–8339), "The
  run's end" (8341–8355), "Allocation" (8357–8385). Optional at 1,344 words;
  the six bold lead-ins already act as labels.

### Rewrite units

| unit | lines (original) | moves in | moves out | words |
|---|---|---|---|---|
| F | 7579–7708: §11.5 | M51–M53 (internal) | — | 1,186 |
| G1 | 7709–7869: §11.6 to the end of the loop-body subsection | M54 (8061–8086), M57, M58 (internal) | — | 1,111, or 1,319 with M54 |
| G2 | 7870–8060: §11.6 from "The binding" (8061–8086 too without M54) | M55, M56 (internal) | M54 | 1,648 with M54, 1,856 without |
| H | 8087–8244: §11.7 | — | — | 1,503 |
| J | 8245–8388: §11.8 and the chapter's closing `---` | — | — | 1,345 |

Total 7,001 words. §11.6 splits cleanly at its "The binding" subheading
(7870). The only cross-reference between G1 and G2 is G1's loop sketches
calling `map_input` and `binding(handle)`, which G2 defines; both are code,
and the prose of G1 needs neither. K is unused.

### Code blocks, tables and charts

| lines | content | run against the package |
|---|---|---|
| 7756–7761 | the four contract functions | not runnable as written (four signatures with comments). Checked: `init!`, `loop`, `shutdown!`, `unblock!` resolve; `unblock!(::AbstractDevice)` returns `nothing`. So do `init!` and `shutdown!`, which the block does not call optional (F62) |
| 7766–7777 | the wrapper sketch | cannot run (pseudo-code: free `entry` and `handle`, `mark_dead!(...)`). Against `src/devices.jl` 406–425: `src` adds the `InterruptException` arm and the `unblock!`-provoked-throw arm, calls `DeviceCrash(err, should_abort)` with two arguments, consults `should_abort` in `finally`, and has no `mark_dead!` (F55) |
| 7823–7850 | three loop bodies | cannot run whole (hardware and sockets). Ran the call shapes on a real handle (`two_root_inputs`, `Pad`, `TableBinding`): `stage!(handle, map_input(datum, binding(handle)))` fails with `MethodError: no method matching stage!(::DeviceHandle, ::Tuple{Pair{String, Float64}})`; the splatted form passes (F56). `report!(handle, MalformedDatum(e))` passes. The `Telemetry` shape matches `test/test_bindings.jl` 11–24 |
| 7879–7892 | `T16000MBinding` | partly runnable. The struct and the three trait lines run. Without `claims`, calling `claims(b)` fires the root fallback (`BindingContractMismatch`, "declares an input side and defines no `claims` enumeration"), as 7925–7927 says. With `claims` defined, `check_binding` passes. Adding `reads` under `is_output = false` fails with "defines `reads` while `is_output` reads false", as 7936–7938 says. The `claims … = ...` line and the last three lines are call shapes, not definitions |
| 8046–8050 | the `TableBinding` call | ran and passed. `claims` returns `["elevator", "throttle", "brake_count"]`; `map_input((; stick_y = 0.5, trigger = 3), tb)` returns `("elevator" => 0.2532…, "brake_count" => 3)` |
| 8203–8208 | the port-view resolution table | a table; consistent with `src/devices.jl` `port_views` |

Also checked, from 7722–7730: after `detach!`, `stage!` and `report!` on the
retired handle throw `DeviceContractMismatch` ("device 1 (Pad) was
detached"), and `latest(handle)` stays legal. The script is
`scratch_survey/h2/run/blocks.jl`; it loads `test/repl.jl` inside a module
under `Main`.

Carry every block verbatim, each as one claim; edits to code are ruled edits
only (F55, F56). The table carries its cells verbatim.

## D. Inbound citations

Source: `inbound.tsv` (built by `scratch_survey/inbound.py`), the 286 rows
whose target is §11.5, §11.6, §11.7 or §11.8.

By file: `decisions.md` 136 (Spec 70, Rationale 34, Position 16, Rejected
15, Annotation 1), `spec.md` 107, `implementation.md` 22, `pending.md` 6,
`inbound_periphery_walkthrough.md` 6, `flight_case_studies.md` 6,
`frame_walkthrough.md` 2, `extensions.md` 1.

By target: §11.5 63, §11.6 103, §11.7 55, §11.8 65.

By file and target:

| file | §11.5 | §11.6 | §11.7 | §11.8 |
|---|---|---|---|---|
| `decisions.md` | 28 (Spec 17) | 48 (Spec 24) | 26 (Spec 13) | 34 (Spec 16) |
| `spec.md` | 25 | 48 | 15 | 19 |
| `implementation.md` | 5 | 3 | 3 | 11 |
| `pending.md` | 2 | 2 | 2 | 0 |
| companions and `extensions.md` | 3 | 2 | 9 | 1 |

Ranges: `implementation.md` 820 reads "§11.1–§11.5" and is recorded at
§11.5; the sections between, §11.2–§11.4, are the sibling's. `implementation.md`
341 ("§11.1–§11.4") lies wholly in half 1. No range has an end or an interior
in §11.6–§11.8.

### Citations relying on content a proposed move would take

None. M51–M58 move text within its own section, so every row keeps its
target. The rows nearest the moved text, checked:

- M51 (the length): `frame_walkthrough.md` 55 ("the ordinal the trace will
  file this frame's batches under (§11.5)") stays true.
- M54 (bad datum): spec 9797 (§13.2), 10086–10089 (§13.4), 12380 (App A),
  13290 (App C), 13937 (glossary) cite §11.6 for it; the move keeps it in
  §11.6.
- M57 (`should_abort`): spec 8684, 8840 (§12.4), 12610 (App B), 14099
  (glossary) cite §11.6; unaffected.

If q22 trims §11.6 7981–7991 to a pointer at §11.3, the rows that cite
§11.6 for "everything downstream is identical" (spec 12636, glossary 14127,
log 6364 D-174 Rationale, `inbound_periphery_walkthrough.md` 92) all cite
§11.3 beside it or for adjacent facts, and stay true.

If q23 moves the status bold from §11.8 to §11.2 or the reverse, spec 8537
(§12.2, "specified in full by §11.8"), 10161, glossary 14009 and log 7075–7095
(D-193) keep §11.8 as the mechanism's home either way.

### Citations already wrong before the rewrite

They will fail the inbound check whatever the rewrite does; they belong to
track 2 or to the other files' owners.

| file:line | claim | what the half says |
|---|---|---|
| log 2049 (D-067 Rejected), log 2618 (D-084 Rationale), log 5483 (D-153 Rejected) | "§11.7's insurance-masking-invariants pattern", "§11.7's anti-diagnostic lesson", "the anti-diagnostic pattern §11.7 names" | §11.7 8166–8169 gives only "no motivation" and a traffic side benefit. The argument lives in D-026 Rejected log 933–936 and D-047 Rejected log 1506–1508. spec 11273–11275 (§14.5) cites D-026 beside §11.7 and stays true. q29 |
| log 9749 (D-252 Rejected) | "A dev-mode flag publishing every state field (§11.7's note)" | the note is §11.2 6962–6964 |
| log 11555 (D-274 Rationale) | "the persistence deferral of §11.5" | §11.5 has none; the deferral is `pending.md` 127–139 and Appendix B 12838–12839 |
| log 9446 (D-247 Rationale) | "the trace header spell `plant/x.q` (§11.5, §14.4)" | §11.5 says nothing of leaf spellings |
| log 1419 (D-044 Rejected) | "§11.7's stays-put and sole-writer arguments" | §11.7 states neither as an argument; §11.3 7219 says "lets a drained GUI value simply stay (§11.7)", which §11.7 also lacks |
| log 4155 (D-132 Rationale) | the wrapper's discrimination grounded in the spawned-loop topology | §11.6 7807–7808 still says it, and D-310 withdrew the topology (F53) |
| log 3391 (D-109 Rationale), log 4278 (D-134 Position), log 4991 (D-144 Position) | the calling-task GUI in "the identical §11.6 wrapper"; "§11.6's method-presence idiom"; "§11.6's `faces(b)`" | history: D-109 is superseded; D-134's marker retired by D-174; `faces` renamed `claims` by D-146 (rows up to D-145 historical by D-146's own clause). D-134 reads "ratified" (part E) |
| spec 9497 (§12.7) | "on the *structural* side of that line (§11.5)" | §11.5 draws no structural/parametric line; §12.7 9482 does, five lines up |
| spec 12373–12375 (App A) | "Keep `is_input`/`is_output`/`is_greedy` trivial, a literal or a flag read off a field fixed at the constructor call (§11.6)" | §11.6 states no such rule, and no entry does (`grep`) |
| spec 12819 (App B) | "a device stops through `stop!(handle)` (§11.6)" | §11.6 7718 says "request shutdown" and never spells `stop!(handle)` |
| spec 14099 (glossary `should_abort`) | "The shipped GUI attaches with `true` (§11.6, §12.4)" | §11.6 says nothing of it; the claim came from D-138 Rationale log 4576–4578 under the `gui = true` sugar D-310 withdrew (F69) |
| spec 13139, 13228 (App C) | `DeviceContractMismatch`'s no-`loop` and no-output-side conditions; `ArgumentInvalid` over `TableBinding`'s entry table, owned by §11.6 | §11.6 states neither (F63) |
| spec 13194, 13221 (App C) | `CheckpointMismatch`, `ReplaySchemaMismatch` owned by §11.5 | §11.5 names neither (F64) |
| `flight_case_studies.md` 397 | "The GUI peek-batch (§11.7)" | §11.7 has no peek-batch; D-047 Position log 1496–1497 names it |
| log 14546 (D-364 Rationale) | "decoded for replay and what-if replay (§11.5)" | true of §11.5 7600, whose what-if gloss is itself wrong (F57) |

Checked and sound, though they looked doubtful: spec 8549 (§12.2) "`orphaned`
… is exactly `:done` (§11.7, D-270)" — §11.7 8230 says "a task that returned
or crashed", which `:done` is; spec 2078 (§8.1) "the `GUI.draw!`
precedent … (§11.7)" — §11.7 8090 still shows it, D-310 having deferred the
amendment.

### Log entries whose Spec field would change

Under the moves: none.

Spec fields already short of what they rule in this half (track 2, at
landing where the rewrite adds the citation):

- D-047 (log 1499) lists §11.3 only; its Position rules §11.7's staging
  contract (rows 652–654) and §11.5's root-input reason (row 519), its
  Rationale §11.7's orphan and liveness sentences.
- D-216 (log 8036) lacks §11.6 (`DeviceContractMismatch`'s conditions).
- D-305 (log 12951) lists §9.8 only; §11.8 8372–8375 states its scope.
- D-319 (log 13894) lacks §11.5, which lists the checkpoint's contents.
- D-192 (log 7044) lists §11.3 only; §11.6 8017–8022 states its escape
  hatch.
- D-106 (log 3271) lacks §11.6 (7866–7867) and §11.7 (8130, 8172).
- D-101 (log 3102) lacks §11.5 and lists "§2.5", which at `f61b1af` is
  "Exclusions"; the determinism law is §2.4.
- D-316 (log 13516) lacks §11.5 (7655, `ignore_stop_requests`).

## E. Log repairs and factual problems

Log repairs ride track 2, after landing. The rewrite only adds citations;
it states no repair. Factual problems stay as written and go to the units'
`rulings.md`, unless part G pre-rules them.

### Entries to cite at the rule

From part A's U rows: D-101 (502), D-319 (516), D-047 (519, 652–654), D-274
(520, 538), D-254 (521, 536), D-255 (529, 534), D-316 and D-260 (525, 544),
D-261 (544), D-038 (539), D-025 (549, 558–559), D-177 (554, 560, 584), D-102
(561–562), D-138 (564), D-106 (581), D-174 (605–606, 612), D-044 (616),
D-045 (619, 632, 635, 641), D-160 and D-189 (628), D-026 (630–634, 638),
D-270 (661–666), D-136 (669, 676, 679, 686), D-193 (691), D-305 (704),
D-317 (670).

### Superseded and half-superseded citations

No row cites an entry whose status reads "superseded". Four entries the half
leans on read "ratified" while a later entry has displaced their Position:

- **D-103** (log 3164): sides by method presence, `faces`/`selectors`.
  D-177 Rejected log 6519 calls presence-only probing "the prior design of
  record"; D-146 renamed the methods. Rows 585, 588, 602, 619, 621, 622, 624
  rest on its Rationale, which is still true.
- **D-107** (log 3304): density-matched retention. D-176's Position says it
  supersedes D-107's density rule (log 6436–6437). Row 509 rests on D-107's
  Rejected list (shim-side recording), which D-176 did not touch.
- **D-134** (log 4271): the `interactive(b)` marker. D-174 Rationale log 6371
  retires it. Rows 601, 613, 617, 618 rest on its Rationale and Rejected
  list.
- **D-127** (log 3963), **D-133** (log 4196): the trace header's deployment
  block with `n`, `event_budget` and the termination pair, and
  `ReplayHeaderMismatch`. Stale since D-133/D-255/D-274/D-181/D-234 (chapter
  10's survey lists D-133). No row of this half cites them, but their Spec
  fields name §11.5.

Each wants an annotation naming the entry that displaced it.

### Rulings that need an entry stating them in a Position

1. **The binding conformance check** (rows 585–599): every bullet, the error
   fallbacks, the `which` detection, the report's contents. D-177 Rationale
   log 6481–6501. D-177's Position states only the roots and the `attach!`
   signature.
2. **The diagnostic channel's mechanics** (rows 672–673, 680–685, 688–692,
   695–697, 702–703, 705–706): the bound as the rate limit, earliest-retained,
   the sentinel swap, publication soundness, the heartbeat not a kind, the
   status's four fields, `maxlog` 25 as presentation, the terminal counters,
   the isbits counters, the lazy fresh ring, `totals` monotone. D-136
   Rationale log 4398–4432. D-136's Position names only the cell, the ring of
   16, the counts and the timestamp. A D-305-style entry restating them
   would serve.
3. **The trace's record format costs** (rows 505, 510–514): D-176 Rationale.
4. **Device contract obligations** (rows 563, 565, 576–580, 583): `shutdown!`
   tolerates a partial init and owes "close only what is open"; `init!`
   owes no cleanup; the two loop idioms; `should_close` dissolves; liveness
   inside the primitives. D-102 Rationale log 3148–3154, D-138 Rationale log
   4552.
5. **`should_abort`'s keyword and default and its two dispositions** (rows
   554, 556): D-138 Rationale log 4563–4579. Row 555 ("never a device
   property") has no entry text at all.
6. **The wrapper's `InterruptException` discrimination** (rows 571–572):
   D-132 Rationale log 4155–4158, now on a withdrawn topology (F53).
7. **Greedy-claim corollaries** (rows 601, 608–609, 611, 613–614, 617–618):
   orthogonality to `reads`, the empty remainder, several front ends, the
   GUI binding's read path, the empty enumeration not a back door, no
   sentinel return. D-174 Rationale, D-134 Rationale and Rejected, D-192
   Rationale.
8. **`TableBinding`** (rows 619–624): data-driven, owner of the conditioning
   helper, per-table specialization, purity. D-103 Rationale log 3180–3183.
9. **The panel's liveness rule as now worded** (rows 640, 642–643, 650,
   655–658): "inside the GUI's own claim", baked once per run, paused
   editing, held buttons, no claim-transition policy, the orphan display.
   D-174 Rationale log 6382–6383, D-047 Rationale and Rejected, D-270
   Rationale. D-045 bullet 1 still says "slot unclaimed".
10. **The header written once** (row 528) and **both taken at one instant**
    (row 523): D-255 Rationale, D-217 Rejected.
11. **The bad-datum channel's scope** (rows 627–629): D-105 Rationale and
    Rejected.

### Rulings with no entry at all

- Row 501: the trace's definition (a description; the glossary holds it).
- Row 509's conversion site rests on a half-superseded entry (above).
- Row 522: the layout's field list (`src/checkpoint.jl` 10–26 is its only
  home).
- Row 541: under `restore!` records keep the trajectory's own frame indices
  (`src/trace.jl` 47–48 only).
- Row 546: "tens of MB per hour worst case".
- Row 555: `should_abort` "never a device property".
- Row 589: enumerable validates at attach, opaque bounded at runtime.
- Row 668: "assembly panels compose children by path".
- Row 693: delta plus total legible at any cadence (constructive rationale;
  `src/dataplane.jl` 376–378 repeats it).
- `init!` and `shutdown!` no-op defaults (`src/devices.jl` 84–85; F62).

Rows 537, 557, 582, 623, 645, 651 are descriptions or consequences and need
none.

### Stale entry text and Spec fields

- **D-025** Position (log 903–906): the GUI's peculiarities "main-thread
  affinity and RMW widgets". D-310 withdrew the affinity; §11.6 7744 already
  says one peculiarity.
- **D-026** Position (log 923–926): "build-time resolution to root input
  slots"; liveness is baked at run start (§11.7 8130–8131, D-270). "slots"
  is the old vocabulary.
- **D-029** Position (log 991): "cleared at `init!`"; under D-260 `init!`
  builds a fresh trace with the run.
- **D-038** Position (log 1250–1253): the snapshot's "private cells included,
  presentation-filtered" (stale since §11.2's whole public table) and the
  header as "full `(x, m, z)` at `init!`" (stale since D-274's checkpoint).
- **D-044** Position (log 1396–1400): the "derived interactive surface (GUI
  + `stage!`)", superseded in part by D-174 (which says so, log 6387); no
  annotation on D-044.
- **D-045** bullet 1 (log 1428–1429): "slot unclaimed", stale since D-174's
  "inside the GUI's own claim".
- **D-047** Spec (log 1499): §11.3 only (part D).
- **D-093** Rationale (log 2855–2861): the GUI "without a spawned task", the
  loop moving to a spawned task. Withdrawn by D-310.
- **D-101** Rationale (log 3104–3108): the header captured before boundary
  zero, boundary zero re-executed under replay. Stale since D-274 (which
  says "D-101's two substitutions become one", log 11509–11510); no
  annotation on D-101. Spec field names §2.5 for the determinism law.
- **D-102** Rationale (log 3148–3151): "claims-release/detach on every exit"
  (stale since D-106's freeze) and the GUI "called inline on the calling
  task" (stale since D-310).
- **D-105** Position (log 3240–3242): `report(handle, …)` (renamed `report!`
  by D-160) and "the `maxlog = 25` successor" as the device's rate limit
  (D-136 made 25 a renderer's number).
- **D-132** Rationale (log 4155–4158): the spawned-loop topology (F53).
- **D-136** Position (log 4389–4393): "one per rostered device plus one for
  the loop itself", amended by D-200 (harness) and D-317 (the `Model`'s
  cell). Rationale: "acquire-loaded at the drain" (log 4406), amended by
  D-240; "a quiet frame adds zero heap allocation" (log 4419–4421), amended
  by D-241; "model-sweep zero-allocation invariant" (log 4428–4429), F52. D-136
  carries no annotation for any of them.
- **D-138** Position (log 4544): "marks it dead"; Rationale (log 4576–4578):
  "the shipped GUI attaching `should_abort = true`" under `gui = true`,
  withdrawn by D-310.
- **D-160** Position (log 5686): `mark_dead!` named as a contract neighbour
  (F55).
- **D-176** Position (log 6439): "against the header's schema"; the list left
  the header with D-255 bullet 3.
- **D-177** Rationale already carries both its corrections (annotations log
  6510–6516).
- **D-217** bullet 1 (log 8073–8074) and **D-255** bullet 3 (log 9903): the
  length as "the drains since the capture", wrong under `restore!` (F59).
- **D-268** bullet 6, amended 2026-09-30 (log 10949–10955): "the arm releases
  the calling-task entry itself", the entry D-310 withdrew (F54).
- **D-270** Position (log 11175): "`orphaned(record)` is a `:done` or
  `:failed` task", corrected by its own 2026-09-28 annotation. No action.

### Factual problems in the half

- **F51.** 7940 "That is the reflection class ([§8.1]), where the shadowing
  check is an `isdefined`/`!==` pair." §8.1 never says "reflection class"
  (`grep` finds only this line). It calls the check "the shadowing check"
  (2197–2198) and "a two-line `isdefined`/`!==` test" (2208). D-177's
  annotation of 2026-10-02 (log 6514–6516) already corrects the same phrase
  in the log. "Class" is also the glossary's reserved word for
  primitive-versus-assembly status (13334). `src/roster.jl` 64 repeats the
  phrase in a docstring. Proposed: "That is the same kind of reflection
  check as [§8.1]'s shadowing check, an `isdefined`/`!==` pair." Carried
  over from an earlier chapter; confirmed.
- **F52.** 8372–8374 "The zero-allocation invariant ([§9.8]), scoped to the
  model [sweep](#g-sweep), is untouched." §9.8 5418 says "scoped to the
  stepping loop" (D-305 bullet 1, log 12943), and §9.4 4868 "covers only the
  stepping loop". A sweep (`#g-sweep` 13608) is one pass through the
  execution order; §9.8's budgets also cover guards, `x_projection`, ticks
  and handlers (5427–5439), which are not sweeps. The phrase comes from
  D-136 Rationale log 4428–4429 ("[§9.8]'s scoped model-sweep zero-allocation
  invariant"). `grep "model sweep"` finds only this line in the chapter.
  Proposed: "The zero-allocation invariant, scoped to the stepping loop
  ([§9.8], D-305), is untouched," with the sweep link dropped. Carried over
  from an earlier chapter; confirmed. The brief's pointer "§7.5" does not
  exist at `f61b1af`; the home is §9.8.
- **F53.** 7806–7813. The rule "An `InterruptException` is never a
  `DeviceCrash`" stands (`src/devices.jl` 410–415; §12.4 8871–8872 relies on
  it). Its reason does not: "Under the spawned-loop topology the calling
  task is the one running a device loop body inline, the GUI's ([§11.1])."
  D-310 withdrew that topology (log 13059–13061: "The loop runs on the
  calling task in every run, and every rostered device runs on a spawned
  task"), and §11.1 6841–6843 says so. The reason comes from D-132 Rationale
  log 4155–4158, unannotated. Julia delivers SIGINT to the main task, which
  now runs the loop (D-268 Rationale log 11005–11008 records the probe), so
  the wrapper's arm is defensive, as D-132 already calls §13.4's
  "unreachable in practice under masking, kept defensively". Proposed: keep
  the bold rule; replace the reason with the topology-neutral one ("the
  operator interrupt is a stop, never a failure", D-132 Position) and say
  the arm is kept defensively; drop the §11.1 citation. q25.
- **F54.** 7790–7795. "The wrapper runs `shutdown!` once on every exit path
  and records the release just after it returns. An operator interrupt
  landing between the two makes the run's tail run `shutdown!` again."
  D-268's amendment of 2026-09-30 (log 10950–10953) describes the arm
  releasing "the calling-task entry itself when its wrapper never recorded
  the release", the calling-task device D-310 withdrew. In `src` the
  wrapper records no release (`_wrap`, `src/devices.jl` 406–425); the repeat
  arises in `run!`'s interrupt arm, which releases each never-spawned entry
  and advances a cursor after each return ("one between a `shutdown!`'s
  return and its cursor repeats that call", `src/sim.jl` 1226–1227, the
  arm's comment). §12.4, cited at 7793, holds no statement of a repeated
  call (`grep`). The obligation, an idempotent `shutdown!`, stands.
  Proposed: restate the case as the code has it and cite D-268; D-268 owes
  an annotation under D-310. q25.
- **F55.** 7775 `mark_dead!(...)  # heartbeat only — claims stay` and 7865
  "marks it dead for the heartbeat". No `mark_dead!` exists in `src`, `test`
  or `implementation.md` (`rg`). `src/devices.jl` 397–399: "Death is marked
  nowhere beyond the record: the task has ended, `task_state` says so at the
  next publication, and the heartbeat goes stale." D-138 Rationale log 4557
  ("no dead-marking machinery of its own") and D-193 (the `task_state` read)
  agree with the code; D-160 Position log 5686 still names `mark_dead!`.
  §12.4's sketch has the same line (8788, outside the half). Proposed: drop
  the line from the sketch, or replace it with a comment that the task's end
  is read as `task_state = :done` at the next publication (§12.2); reword
  7865 the same way.
- **F56.** 7827, 7836 `stage!(handle, map_input(…, binding(handle)))`. Ran:
  `MethodError` (part C). `src` defines only `stage!(handle::DeviceHandle,
  writes::Pair...)` (`src/devices.jl` 168), and its own idiom splats
  (`src/bindings.jl` 83, `src/devices.jl` 124, `test/test_bindings.jl` 59).
  Proposed: add `...` at both lines, a ruled code edit.
- **F57.** 7600 "[what-if replay](#g-what-if-replay) (replay with edited
  inputs)". The glossary (14201–14205) and §12.7 (9482–9491) define what-if
  replay as the recorded inputs re-driven through a modified model, spelled
  `init!` of the modified model then `replay!(sim, trc; restore = false)`.
  D-274 bullet 5 (log 11511–11515) distinguishes that "parametric what-if"
  from "the edited-inputs what-if of [§11.5]", which no glossary entry
  names. The sentence's claim, one decoder in what-if replay, is true of the
  glossary's what-if too. Proposed: keep the link and give the glossary's
  gloss; name the edited-inputs case separately if it is meant. q21.
- **F58.** The header's compared part has three names. §11.5 7631 lists "the
  fingerprint" among the checkpoint's contents, then 7645–7652 describes
  "the run's `Deployment` and the structural layout" as further header
  items, and 7642 says "The fingerprint is the part of the header replay
  compares rather than restores". In `src` the layout *is* the fingerprint
  (`ModelState.layout::Fingerprint`, `src/checkpoint.jl` 54) and the
  deployment is a separate field "compared as a value at restore" (line 53).
  Replay compares the deployment too (§12.7 9493–9497), which 7642 omits.
  Elsewhere: §12.6 9224 lists "`t₀` and the fingerprint" without deployment
  or layout; §12.7 9462–9463 says "the checkpoint's fingerprint is validated
  against the target, its layout against the `Build`"; the glossary's
  replay (14175–14177) says the fingerprint covers "stores, root-input faces
  and the `Deployment`"; D-274 bullet 1 lists "the fingerprint, the
  deployment and the structural layout". Proposed for §11.5: one term (the
  fingerprint, glossed as the structural layout), the deployment beside it,
  and "replay compares both". The other sites are their chapters'. q28.
- **F59.** 7665 "The length is the drain's count on the live trace". Under
  `restore!` the length starts at the header's frame index (`src/trace.jl`
  47–48; §11.5 7690–7692 says the same), so it is the frame ordinal of the
  last drain, not a count of this trace's drains. 7688 says it right ("the
  frame index of its last drain"). D-217 bullet 1 and D-255 bullet 3 carry
  the count wording. Proposed: "the frame index of the last drain" at 7665,
  folded into M51.
- **F60.** 7867 "[§12.4](6) is literally 'the task body returned.'" §12.4's
  step (6) (8682–8692) contains no such phrase. Proposed: drop "literally"
  and the quote.
- **F61.** 7898 "The framework needs no [contract](#g-contract) on the
  datum's shape". `#g-contract` (13358) is a component's declared interface,
  and its entry says the other contracts are "linked never or at [their]
  own anchor". Proposed: drop the link.
- **F62.** "four functions, one optional" (7748 heading, 7760). `src` gives
  `init!` and `shutdown!` no-op defaults (`src/devices.jl` 84–85, docstring
  67–82: "with no-op defaults — a stub device holds nothing") and makes
  `loop` "the one mandatory function", refused at `attach!` by
  `check_device` (`DeviceContractMismatch`, `:no_loop`, `src/roster.jl`
  97–110). D-216 (log 8028–8030) rules the refusal; no entry gives the
  defaults. The spec reads as three mandatory functions. A fix changes the
  spec or the code, and no Position settles which. q26.
- **F63.** Appendix C cites §11.6 for two conditions §11.6 never states:
  `DeviceContractMismatch` for a device with no `loop` method and for
  `gather` against a binding with no output side (13139–13143; D-216), and
  `ArgumentInvalid` over `TableBinding`'s entry table (13228–13231;
  `src/bindings.jl` 41–67). Lesson 20. q27.
- **F64.** Appendix C cites §11.5 for `CheckpointMismatch` (13194) and
  `ReplaySchemaMismatch` (13221); §11.5 names neither. Lesson 20. q27.
- **F65.** Reserved words. Bare "cell" for a diagnostic or staging cell
  (§11.8 heading and 8245, 8298, 8309, 8314, 8375; §11.6 7726; the
  displayed text of the links at 7589 and 8146). `#g-cell` 13480 and D-121
  Position log 3761: "Bare 'cell' means only this." "Batch" for the taken
  diagnostic ring (8303); `#g-batch` 13939: "The word means only this."
  Bare "entry" (7722, 7730, 8286, 8320); `#g-entry` 13489: "never used
  bare". §11.2 6922 has "per-writer diagnostic batches" too (the sibling's).
  Proposed: "diagnostic cell", "staging cell", "the taken ring", "value",
  "roster entry", at each instance.
- **F66.** `#g-stage-on-interaction` (14106–14109) cites §11.7, and §11.7
  never names or links it; its staging contract is at 8154. §14.5 11272
  links it. Proposed: link at 8154.
- **F67.** Reader-cold names (`spec_style.md`, "Introduce every reader-cold
  name"). `Cessna172Xv1` (8108), FlightCore's Cessna 172 model, with no
  introducing clause; `flight_case_studies.md` 280–281 treats it. `T16000M`
  (7824, 7959, 8174), a joystick type the spec never introduces (first at
  §11.3 7312). `World` (8138), introduced at §8.7 3837 but not in §11.7.
  Proposed: one introducing clause each at first use in the section. q32.
- **F68.** 7592 "an O(surface-width) scan and one small allocation per
  drained batch". `_record!` (`src/trace.jl` 94–120) scans the mask twice
  and allocates the entries vector once, then boxes each touched value into
  `Vector{Pair{Int,Any}}`; its comment says the cost is "that vector and the
  values boxed into it". The order is the same; "one small allocation"
  understates. Proposed: "one small allocation per drained batch, plus its
  boxed values", or leave as an approximation and note it. Low priority.
- **F69.** Outside the half: glossary `should_abort` (14097–14099) "The
  shipped GUI attaches with `true` (§11.6, §12.4)". §11.6 says no such
  thing; the claim came from D-138 Rationale log 4576–4578 under the
  `gui = true` sugar that D-310 withdrew.
- **F70.** Cross-split, the sibling's lines: §11.4 7521 ("produced the
  §11.7 staging contracts"), 7537–7538 ("the active-widget stage-every-pass
  contract (§11.7)"), 7573 ("the active-widget contract" as a discovery).
  §11.7 8166–8167 rejects staging on every pass (D-026 Rejected, "Superseded
  position"). Recorded for the merge.
- **F71.** 8010–8017 "The shipped GUI binding is a greedy one … Paced by its
  own clock, it reads `latest` afresh at each tick". `src` ships no GUI
  binding (`rg`), and D-310 parked the built-in Julia GUI in favour of a
  browser client over the bridge, whose read path D-310 leaves to the
  cockpit's design. The text describes the parked render loop (its source is
  D-134 Rationale log 4298–4302, "VSync-paced `latest` per render").
  "Tick" also collides with `#g-tick`. A design ahead of the code is
  normal; the open point is whether "shipped" and the render-loop read path
  still describe the design. q33.
- **F72.** 8320–8322 "`recent` is the ring this boundary drained, at most
  sixteen entries. `suppressed` is the per-kind counts the ring refused this
  boundary." Drains run at frame tops, not at boundaries; in `src` `recent`
  is the pending delta the first publication after the drain takes, a `t*`
  boundary's if one comes first (`src/dataplane.jl` 370–375, 413–416). The
  loop's record folds two cells, its own and the `Model`'s (8270–8273,
  D-317; `_sweep_tail!` and the frame-top fold), so it can carry up to
  thirty-two. Proposed: "the values drained since the previous publication,
  at most sixteen per cell", and the same for `suppressed`.

## F. Difficulty per section

| unit | section | difficulty | reason |
|---|---|---|---|
| F | §11.5 | medium | 1,186 words, 18 C rows; the work is order (M51–M53: the header in three places, the length twice), one dangling list, three Part I restatements to turn into pointers, and three factual points (F57, F58, F59) that touch glossary-linked terms |
| G1 | §11.6, handle to loop bodies | high | the stale topology (F53, F54) sits inside bold rulings §12.4 cites; the wrapper sketch (F55) and the loop sketches (F56) are code; M57 and M58 reorder; four bold sentences with no D-citation in their paragraph (7732, 7779, 7806, 7863) |
| G2 | §11.6, the binding | high | 1,648–1,856 words; §11.6 holds 44 of the half's 90 R rows, most of them here; the conformance list is all D-177 Rationale; greedy material in six places (M55, M56); the cross-split duplicate with §11.3 (q22); F51, F61 |
| H | §11.7 | medium | one bold rule per paragraph, three **Rule.** labels, two bold lead-ins; most rulings are D-026, D-045, D-047, D-174 and D-270, half of them uncited here; D-047 is never cited in §11.7 though it states the staging contract; F66, F67 |
| J | §11.8 | medium | order is sound and the prose near target, but 21 of 38 rows rest on D-136's Rationale; the reserved-word fixes (F65) touch most paragraphs; F52, F72; the status bold is shared with §11.2 (q23) |

Warnings for the rewriter:

- **Terms of art stay verbatim**: drain, staging cell, diagnostic cell,
  harness writer, harness cell, greedy claim, claim source, computed claim,
  returned claim, empty remainder, may-write-nothing degenerate, write
  surface, the freeze, orphan, incumbent, port view, terminal producer, live,
  read-only rendering, peek, own-pending-first, levels doctrine, fan-out,
  tail residue, delta plus total, empty sentinel. "Discarded, not stored",
  "loud *and* recorded, still never published", "taught and diagnosed, never
  forced", "declared or absent" and "alternatives, not layers" are each a
  distinction an entry fought for; a paraphrase that drops one half changes
  the rule.
- **Two directions in the conformance check.** "declared-but-missing" and
  "defined-but-undeclared" (7946) are the two halves of one check. Keep both
  names and both bullets that carry them.
- **Counts and defaults are rulings.** 16 (the ring), 25 (`maxlog`), 2 s
  (staleness), "about 2×", "two orders of magnitude", `should_abort = false`,
  `is_greedy = false`, `is_input`/`is_output` false on the root. Each has its
  entry in part A.
- **Bold lead-ins are headings.** About thirty in the half. Each becomes a
  `####` label, a plain topic sentence, or a bold headline clause with its
  D-citation. The bold check flags any bold span without one. Count before
  and after.
- **The log's vocabulary is old.** D-025, D-026, D-044, D-045, D-047 say
  "slot" for root input; D-103, D-134 say `faces`, `selectors`,
  `interactive`, "derived surface", "interactive writer"; D-105 says
  `report`; D-127, D-133 say `n`, `event_budget`, `ReplayHeaderMismatch`;
  D-138, D-160 say `mark_dead!`. Never import them when citing an entry.
- **The topology changed under the text.** Any sentence that puts a device
  body on the calling task, or the loop on a spawned task, is stale (D-310).
  F53 and F54 are the two in the half; carry them as written unless q25
  rules them.
- **Two what-ifs, two contracts, two classes.** The glossary's what-if
  replay is the parametric one (F57). The glossary's contract is a
  component's interface; the device contract, the staging contract and a
  datum-shape contract are other senses and take no `#g-contract` link
  (F61). The glossary's class is primitive versus assembly; "device class",
  "the hidden-bug class" and "two classes, two fates" are ordinary English
  and take no link.
- **Glossary links reset per section, and the half under-links.** `binding`
  has its home in §11.6 and is linked nowhere in the half. `frame` is linked
  in none of the four sections. `stage-on-interaction` is §11.7's and is
  never linked there. Part A lists every late and doubled link.
- **The chapter cites by adjacency.** Many C rows have their citation in the
  next sentence or paragraph. A move that separates a rule from that
  paragraph needs the citation repeated (M55, M57 especially).
- **History sentences.** 7711–7713 (FlightCore's trichotomy), 7948–7953 (the
  shadowing hole under the rejected design), 8106–8111 (the dead slider)
  argue from history. Keep their constructive half; q24 rules the
  adversarial ones.
- **Code**: part C. Comments inside blocks are ruled edits only.

## G. Decisions for checkpoint 1

Settled for every chapter and not asked again: log repair rides track 2, and
bold marks one headline clause per ruling.

**q21. The clear corrections, ruled before the brief.** Each has its evidence
in part E and one reading. Options: (a) rule all as dictated wording now;
(b) rule some; (c) leave all to `rulings.md`. The candidates: F51 (reflection
class → shadowing check), F52 (model sweep → stepping loop, D-305), F56 (add
`...` to two `stage!` calls), F57 (the what-if gloss to the glossary's), F59
(length = frame index of the last drain), F60 (drop the false quote), F61
(drop the `contract` link), F65 (reserved words, at each listed instance),
F66 (link stage-on-interaction at 8154), F72 (`recent` drained since the
previous publication). Recommendation: (a). Each is a wording fix inside one
unit, and chapter 10's R8 shows that ruling them up front saves a second
pass. Grep the chapter for each phrase before writing the ruling (chapter
8's lesson); F65's instances are listed.

**q22. §11.6 7981–7991 against §11.3 7207–7219.** The two paragraphs say the
same thing. Options: (a) §11.3 keeps the claim mechanism and §11.6 keeps one
sentence (the binding declares the source; past the attach point nothing
tells them apart) with a pointer; (b) the reverse, §11.6 as the binding's
home; (c) both stay. Recommendation: (a). D-174 is about claims, §11.3 is
the claim's home, and §11.6's paragraph is the later restatement. It needs
the sibling's agreement at the merge.

**q23. The framework status is bold twice** (§11.2 6920, §11.8 8319).
Options: (a) the bold stays in §11.8, the mechanism's home, citing D-136,
and §11.2's sentence becomes plain with a pointer; (b) the bold stays in
§11.2, which states it as the binding rule's consequence. Recommendation:
(a). §11.2's "**Why.** The binding rule forces that shape" is a reason, and
§11.8 holds the four fields.

**q24. Adversarial rationale in the half.** Candidates: 7594–7598's last
clause ("keying retention by claim source is rejected", D-176 Rejected);
7948–7953 (the shadowing hole under method-presence detection, D-177
Rationale and Rejected); 7973–7979 ("Rejected, correspondingly", D-177);
8166–8169 (staging every pass, D-026 and D-047 Rejected); 8383–8385 (D-136's
rejected list). Options: (a) cut each to a one-clause pointer at its entry,
after checking the entry carries it (all do); (b) keep all; (c) cut the pure
lists (7973–7979, 8383–8385) and keep the rest. Recommendation: (c). 7948–7953
says what the declared side buys, which is constructive; 8166–8169 is the
one sentence four inbound citations reach for (q29); the two lists are
verdict-only.

**q25. The stale topology in §11.6 (F53, F54).** Options: (a) rule both now
as edits: keep each bold rule, replace F53's reason with the
topology-neutral one and "kept defensively", restate F54's case as the
interrupt arm's direct release; (b) keep the text and send both to
`escalations.md`, since D-132 and D-268 state the stale premises and no
annotation retires them. Recommendation: (a). D-310's Position settles the
topology, so the two sources do not conflict; the log repairs (annotations
on D-132 and D-268) ride track 2.

**q26. Which device functions are mandatory (F62).** The spec says four
functions, one optional; `src` makes `init!` and `shutdown!` optional with
no-op defaults and refuses a device with no `loop` (D-216). Options: (a)
escalate: the spec and the code disagree and no Position settles it; (b)
rule the spec to match the code, with a new entry naming the rejected
alternative (mandatory `init!`/`shutdown!`); (c) rule the code to match the
spec. Recommendation: (a). A fix changes what the framework does or what it
promises, which the recipe keeps for the owner; the rewrite carries the text
and adds only `loop`'s refusal, which D-216 rules (q27).

**q27. Appendix C kinds the owning sections do not state (F63, F64).**
Options: (a) the rewrite adds one sentence per missing condition, naming the
kind: in §11.6, `DeviceContractMismatch` for a missing `loop` and for
`gather` without an output side (D-216), and `ArgumentInvalid` for a
malformed `TableBinding` table (D-216); in §11.5, one pointer sentence naming
`CheckpointMismatch` and `ReplaySchemaMismatch` where the comparison and the
schema are mentioned; (b) Appendix C drops §11.5 from those two rows and
keeps §11.6's additions; (c) leave both. Recommendation: (a) for §11.6, (b)
for §11.5. §12.7 states and names the two replay kinds, and §11.5 only
points to them; §11.6 is the true home of the device and binding refusals.

**q28. One name for the header's compared part (F58).** Options: (a) in
§11.5, "the fingerprint" glossed as the structural layout, the deployment
named beside it, and "replay compares both"; the other sites follow in their
chapters or in track 2; (b) leave as written and send to `rulings.md`.
Recommendation: (a). `src` is unambiguous (`layout::Fingerprint`, a separate
`deployment`), and §12.7 9493–9497 already says the deployment is compared.

**q29. The anti-diagnostic sentence §11.7 lacks.** Three log rows (D-067,
D-084, D-153) and one spec row (§14.5 11273) cite §11.7 for "insurance that
masks invariant violations is anti-diagnostic". The argument is D-026's and
D-047's Rejected lists. Options: (a) the rewrite restores one clause at
8166–8169 ("as insurance, it would mask invariant violations at render
rate"), cited to D-026, so the citations resolve; (b) repoint the four
citations to D-026 in track 2. Recommendation: (a). It is constructive (what
the adopted contract keeps visible), it costs one clause, and it settles
four citations at once.

**q30. Display blocks the half lacks.** Candidates: the `attach!` signature
(§11.6, D-177 Position); the handle's primitives (§11.6, today only in
Appendix B); the panel kit's four signatures (§11.7); the per-writer status
record (§11.8). Options: (a) add all four as declared additions; (b) add the
`attach!` signature and the status record only. Recommendation: (a). Each is
what a reader would type, and each replaces prose that names the parts one
sentence at a time.

**q31. The units.** Options: (a) F, G1, G2, H, J with M54, so G1 holds the
whole device lifecycle including the loop body's catch (1,319 words) and G2
the binding (1,648); (b) the same split without M54 (G1 1,111, G2 1,856).
Recommendation: (a). Bad datum is about the loop body and `report!`, which
G1 owns, and the split comes out even.

**q32. Reader-cold names (F67).** `Cessna172Xv1`, `T16000M`, `World` in
§11.6–§11.7. Options: (a) one introducing clause each at first use per
section, claiming nothing beyond the source; (b) move the dead-slider
example to `flight_case_studies.md` with a pointer. Recommendation: (a). The
dead slider is the reason the liveness rule exists, and chapter 6's lesson
prefers an introducing clause to a companion move for a status-quo example.

**q33. "The shipped GUI binding" after D-310 (F71).** Options: (a) keep the
paragraph's ruling (the standard GUI binding is greedy, declares no
`claims`, declares no `reads`) and drop the render-loop clause ("paced by
its own clock … at each tick"), which describes the parked GUI; (b) leave as
written and send to `rulings.md`; (c) escalate whether the browser client's
binding is still "shipped". Recommendation: (a), with (c) noted. D-310
keeps §11.7's semantics and parks only the built-in GUI, so the binding's
shape stands; its read path is the bridge's to rule.
