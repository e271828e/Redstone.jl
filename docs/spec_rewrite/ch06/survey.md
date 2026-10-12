# Survey of spec chapter 6 before its readability rewrite — 2026-10-12

Scope: `docs/design/spec.md` lines 1221–1509, "## 6. Composition:
connections, aggregation and hierarchy", at commit `b08afca` (the working
tree's `spec.md`, `decisions.md`, `src/` and `test/` equal it). `wc -w` over
1221–1509 gives 2,181 words (the brief says 2,187; the difference is the
counting tool). `chapter_old.md` line 1 will be spec line 1221. The convention
is `docs/design/tools/spec_style.md`; the method is
`docs/spec_rewrite/recipe.md` step 1; the model is chapter 7's survey (`git
show 733be21:docs/spec_rewrite/ch07/survey.md`).

Line numbers are `spec.md` lines at `b08afca` unless marked `log`
(`decisions.md`) or given with a file name. Entry claims rest on the entry's
Position as read, with its log line where the point sits outside the
Position's first sentence. Every entry a rule is classified under was read in
full: the ten the chapter cites (D-007, D-037, D-043, D-084, D-167, D-207,
D-236, D-264, D-303, D-311), and these, which rule the chapter's content
without being cited there: D-295, D-048, D-061, D-062,
D-078, D-085, D-130, D-143, D-170, D-208, D-211, D-263, D-286, D-312, D-313,
D-314. Every entry whose Spec field names §6, §6.1 or §6.2 was read at least
at its Position and its §6 lines (32 entries: D-007, D-037, D-043, D-051,
D-061, D-065, D-073, D-084, D-113, D-125, D-131, D-143, D-163, D-167, D-168,
D-170, D-172, D-207, D-211, D-220, D-236, D-238, D-259, D-263, D-264, D-266,
D-267, D-279, D-295, D-303, D-311, D-314). Copies with log line numbers are in
`scratch_survey/entries/` (`scratch_survey/entry.sh` extracts one).

`src/` was read where a claim about code was in doubt, and every runnable
claim was run: `scratch_survey/probe.jl` (run with `julia --project=test`
from the repository root), output in `scratch_survey/probe_out.txt`. Flight.jl
names were checked in `/Users/miguel/.julia/dev/Flight.jl/lib/`.

Classification codes used in part A:

- **C** cited, and ruled by the cited entry's Position (at the spot or in the
  same paragraph, marked "adjacent").
- **U** ruled by an entry's Position that the section does not cite at that
  spot.
- **S** cited to a superseded entry.
- **R** ruled only in an entry's Rationale, Rejected list or annotation.
- **N** no entry found. Where the sentence reads as a description of an
  inherited status quo (Flight.jl's) rather than a ruling, the row says so.
- **B** borderline; both readings are given.

"Marking" is how the spec marks the rule now: **Rule.**/**Why.**/**Example.**
label, bold sentence, bold lead-in (a bold phrase opening a paragraph or
bullet, used as a heading), bold words, or plain. The chapter carries 28 bold
spans outside code blocks: 9 labels (5 **Rule.** at 1239, 1285, 1339, 1366,
1486; 3 **Why.** at 1263, 1445, 1489; 1 **Example.** at 1449) and 19 others
carrying 94 words (checked by script over the joined text, so the two spans
that break across lines, 1239–1240 and 1366–1367, are counted).

Section sizes (words, `wc -w` over the line ranges): opening 1221–1227 (46);
§6.1 1228–1358 (1,111): context 1228–1236 (74), "How far a path may reach"
1237–1282 (381), "Type-checking a wire" 1283–1334 (479), "Fan-out and fan-in"
1335–1345 (69), "Unconnected ports" 1346–1358 (108); §6.2 1359–1509 (1,024):
opening 1359–1411 (299), "What the explicit form buys" 1412–1435 (213), "The
hierarchical aggregation idiom" 1436–1473 (280), "The zero-contributor end of
the same spectrum" 1474–1497 (173), "The cost, recorded" 1498–1509 (59, the
closing `---` included).

Rows that are reasons, mechanisms, examples, context or code are kept in the
tables for the rewriters but left out of the tally (part A, "Tally").

## A. Per section

### Chapter opening (1221–1227, 46 words)

A context paragraph and a roadmap already: "Components become a system through
wiring", then one sentence each for §6.1 and §6.2. It names "ordinary junction
components" (context for D-037, cited at §6.2). It links `#g-component` and
`#g-assembly`. No rules. No change needed beyond what the section rulings
make stale: if q6 merges §6.1's two last labels, this paragraph still holds.

The Part I roadmap (spec 132) says "[§6] lifts composition from a single
component to a hierarchy of them", and spec 135–137 says "Part I assumes
nothing from later parts. It cites them for spellings only." Chapter 6 is in
Part I, yet §6.1's "Type-checking a wire" states the structure step's marker
retyping, the walk and the conformance identity rule, all Part II machinery
(§8.2, §9.1, §9.5). That is the ground for part C's trims.

### §6.1 Connections and hierarchy (1228–1358, 1,111 words)

Purpose: how far a wiring path may reach (one level, D-207), what type-checks a
wire, how many producers an input takes, and what happens to ports left
unconnected.

Context paragraph 1230–1235, ending in a roadmap sentence naming the four
`####` parts. Subheadings: "How far a path may reach" (1237), "Type-checking a
wire" (1283), "Fan-out and fan-in" (1335), "Unconnected ports" (1346).
Labels: **Rule.** 1239, 1285, 1339; **Why.** 1263.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 1 | 1230–1235 | "A wire names its two endpoints by path, and those paths run down the hierarchy of children. … That question comes first here. Then come …" | plain | — | context and roadmap |
| 2 | 1239–1240 | "**Rule.** Every connection endpoint names an **immediate child and one of its faces** (D-207)." | **Rule.** label, bold words | D-207 Position sentence 1 (log 7552–7554) | C |
| 3 | 1240–1245 | "The rule covers all three wiring declarations (§8.6). An `local_wires` pair wires one child's face to another's. An `input_wires` entry routes a face to an immediate child's face. An `output_wires` entry sources a face from an immediate child's face. An entry of any of the three is a wire, and an entry of the first is a local wire (D-303)." | plain | D-207 Position bullet 1 (log 7556–7559, old names); D-170 Position (the split, log 6098–6108); D-303 Position bullet 3 (log 12740–12741, "wire" covers all three); D-314 Position ("local wire" in prose, log 13184–13185) | C (adjacent) for "wire"; U by D-314 for "local wire", which D-303's bullet calls "inner wire". "An `local_wires`" is an article error (F3). Overlaps §8.6 3134–3150 |
| 4 | 1246–1247 | "Container children (§8.5) keep their key segment, so `"aircraft/2/face"` is one level and not two." | plain | D-207 Position ("container elements included"); D-085 Position (`"field/1"` segments) | U |
| 5 | 1247–1249 | "A container declared name-transparent (§8.5) is the exception. Its elements go by bare key, so `"ctl/face"` reads exactly as a plain child's endpoint does, the same one level." | plain | D-211 Position (log 7695–7707, "[D-207]'s one-level reading unchanged") | U; §8.5 2989 and 3022 bold D-211's other rulings |
| 6 | 1251–1254 | "Routing across several levels is therefore declared level by level, with each assembly speaking only of its own children. … The fan-out is declared at the level where the paths diverge." | plain | D-207 Position (consequence); D-065 Position ("locality law = §6.1's, third instance (own fields, declared children, own faces …)", log 1912–1913) | B: U by D-207 as a consequence; U by D-065 for "speaking only of its own children", which four outside rows call "the locality law" of §6.1 (part D). The example names are reader-cold (F11, q3) |
| 7 | 1256–1261 | `input_wires(::Cessna172) = …` | code | — | code (excerpt, part C "Code blocks") |
| 8 | 1263–1265 | "**Why.** Faces become the only currency crossing an assembly boundary, so substitutability holds at *every* boundary rather than only at generic ones. This is the contract-is-the-interface principle of §8.3 with its one leak closed." | **Why.** label | D-207 title and Position bullet 1 ("the generic-seam stop becomes the universal rule"); D-207 Rejected bullet 1 (log 7587–7590, the bypass "is the one place structure leaks across a boundary §8.3 declares closed") | reason |
| 9 | 1265–1269 | "The second consequence is that the face graph is **total**. Every signal crossing a boundary bears a declared face there, at every level it crosses. Totality is what the condition algebra addresses against. An `at` prefix stopping at a child's face has a name to resolve through (§14.2)." | bold word | D-207 Position bullet 2 (log 7560–7565) | U; D-207 is cited at 1240, two paragraphs up. §9.2 4032 bolds the `Build`'s retention of the face graph (D-207, D-315); part G q4 reads bullet 2 as two rulings |
| 10 | 1271–1277 | "The ceremony this costs is the re-export entry per level. … every level of a realistic tree is a generic seam, where one-level routing was mandatory in any case (§8.8). Where the entries multiply, they are computed rather than typed … Parallel routes threading many boundaries are the signal to gather them into a component of their own." | plain | D-207 Rationale (log 7577–7584); D-009 Rejected ("Strict one-level: re-export ceremony", the objection answered) | R; D-207 says "a custom type" where the spec says "a component of their own" |
| 11 | 1279–1281 | "Enforcement lives in the path-resolution primitive itself (`resolve`, §13.3), which walks declared field types alongside instances. Paths are validated at build time, and renames break loudly." | plain | D-061 Position (log 1821–1827); D-130 Position (wiring client strict, log 3986–3996); D-207 Spec lists §13.3 | U; names no kind, though Appendix C 12306 cites §6.1 for `PathResolution` (q7) |
| 12 | 1285 | "**Rule.** Two clauses type-check a wire (§8.2)." | **Rule.** label | D-236 Position sentence 2 (log 8844–8846); D-263 Position bullet 2 (log 10384–10387) | U; §8.2 2417 bolds it ("Two clauses check a wire", D-263, D-236) |
| 13 | 1287–1290 | "**The nominal bound check** is stated over declaration evaluations. The producer's declaration at `Float64` must be `<:` the consumer's entry at `Float64`. It is one uniform rule, and it degenerates to exact equality for a concrete entry. A violation is `WireTypeMismatch`." | bold lead-in | D-078 Position (log 2356–2358) | U; §9.1 3826 bolds it (D-078); §8.2 2418–2421 states it with "markers stripped". Names its kind |
| 14 | 1292–1296 | "Beside it, and **for a continuous consumer only**, stands the **walk-compatibility clause**. A walking producer leaf, one the producer left unpinned, requires an unpinned entry. A pinned producer leaf, one declared `Pinned`, satisfies either entry, because frozen values embed upward under any activation …" | bold words ×2 | D-236 Position sentence 1 (the lift relation) and Rationale (log 8861–8863, the clause as lifts); D-263 Position bullet 2; tier scope D-295 Position bullet 1 (log 12466–12470) | U; the tier-scope bold is the carried item: §8.2 2433 bolds D-295 bullet 1 ("Discrete consumers take the bound check only"). "one declared `Pinned`" is narrower than *pinned* (F14) |
| 15 | 1298–1302 | "**An opaque leaf is admitted on the same terms.** An opaque leaf (§4.3), a handle stored whole, has no scalar position to embed through, and the clause does not need one. A frozen handle arriving at an unpinned entry is the producer's cell, gathered as stored, and the consumer's own arithmetic promotes whatever it reads from it (D-264)." | bold sentence | D-264 Position sentence 1 (log 10529–10530) | C; stated plain at §8.2 2427 and §9.5 4634, bold nowhere else |
| 16 | 1302–1303 | "A discrete producer of a handle, which pins wholesale, is admitted the same way." | plain | D-264 Position sentence 1 ("a pinned or discrete producer") | C (adjacent) |
| 17 | 1303–1304 | "The identity rule for an opaque leaf (§9.5) governs a store, never a wire." | plain | D-264 Position sentence 2 (log 10531–10532) | C (adjacent); not bold anywhere. "a store" here is §9.5's write into a cell, not the glossary's *store* (F16) |
| 18 | 1304–1306 | "One consequence follows from that rule: a component that re-emits a frozen handle pins that output too, so a handle's pin is a property of its chain." | plain | D-264 Rationale (log 10569–10573) | R; a mid-sentence colon (spec_style) |
| 19 | 1308–1310 | "Both sides are plain declarations the walk retypes, so the clause is decided in the structure step by retyping them at a marker scalar. That is declaration reading, and no user stage code runs (§9.1)." | plain | D-263 Position bullet 2; D-236 Position sentence 2 | U; §9.1 3831 bolds the run (D-263, D-236), §8.2 2427–2429 repeats it |
| 20 | 1310–1314 | "A violation is `WalkingFaceAtFrozenEntry`, naming both endpoints, the leaf and both declared leaf types. The message carries both remedies. Remove the entry's `Pinned` if the consumer promotes, or feed it from a non-walking source if the freeze is genuine, for which the `Freeze` block (§13.7) is the one-line spelling." | plain | payload and remedies: D-167 Rationale (log 5958–5960, superseded entry) and Appendix C 12301–12305; `Freeze`: D-266 Position, D-312 Position bullet 3 | B: N in a live entry for the payload and the remedies, which Appendix C states normatively; U by D-266 for `Freeze`. Names its kind. "the freeze" collides with the glossary's *the freeze* (F15) |
| 21 | 1316–1319 | "For an abstract entry, whose leaves cannot be enumerated, the clause is decided on the whole declaration. The producer's declaration at the marker, or the same with every pinned leaf lifted to the marker, must be `<:` the entry at the marker (D-236)." | plain | D-236 Position bullet 1 (log 8847–8849) | C; §9.1 3831's sentence names "on the whole declaration at an abstract one" after its bold clause, unbolded |
| 22 | 1321–1326 | "**The tier scope is a correctness rule, not tidiness.** A discrete consumer takes the bound check alone, because its stages read exclusively at real ticks in the nominal world … A continuous producer feeding a discrete consumer is therefore unconditionally legal (D-167)." | bold sentence | D-295 Position bullet 1; cited D-167 is superseded → D-263 (log 5934) | S; §8.2 2433–2439 states the same paragraph near-verbatim with the bold (part B) |
| 23 | 1328–1333 | "The same clause also gives the two contract sides their **failure asymmetry**. A pin written at an entry whose consumer really promotes fails at the *first nominal build*, at the wire, with both endpoints named. … The output side has none, so a pin written at a leaf that really participates lurks until the first `Dual` activation. It lurks loudly, never silently (§8.2)." | bold words | input half: D-167 Rationale (log 5969–5972, superseded), D-263 Rationale (log 10432–10439), D-236 Rationale (log 8878–8881); output half: D-286 Position (bold at §8.2 2656) | R for the input half; U by D-286 for the output half. `test/test_build.jl` 567 and 681 cite "§6.1's failure asymmetry" and "the first nominal build". Conditional on a walking producer, unstated (F13) |
| 24 | 1337 | "Fan-out is free. One producer may feed many consumers." | plain | D-170 Position (tuple-of-paths fan-out through a boundary); D-168 Position presupposes fan-out at a root input | B: U by D-170 for boundary fan-out; N for local fan-out, which no entry states. A root input's fan-out is constrained (`RootInputTypeConflict`, D-236 bullet 3), which the sentence does not scope (F17) |
| 25 | 1337 | "The converse is strict." | plain | — | context |
| 26 | 1339–1340 | "**Rule.** Every input port takes **exactly one** connection, with no exceptions." | **Rule.** label, bold words | D-170 Position's last chained ruling ("one invariant spans all three: … every right side fed exactly once", log 6106–6108) | U; §8.6 3154–3157 states the invariant plain. `src/diagnostics.jl` 346 and 361 quote the rule |
| 27 | 1340 | "Aggregation is done by junctions (§6.2)." | plain | D-037 Position, first chained ruling | U; pointer |
| 28 | 1342–1344 | "The rule spans levels. A child input fed by a sibling wire at its own level *and* handed up through its parent's `input_wires` is a two-producers build error. Routing a face upward cannot silently double-feed." | plain | D-170 Position (the invariant spans all three declarations); D-048 Rejected (log 1500–1501, two-producers undecidable below the root) | U; names no kind, though Appendix C 12294 cites §6.1 for `TwoProducers` (q7). "sibling wire" against D-314 (F4) |
| 29 | 1348 | "There is no auto-bubbling of unconnected inputs (D-043)." | plain | D-043 Rejected bullet 1 (log 1343–1344) | R (cited); §8.8 3612 says the same with D-043 |
| 30 | 1348–1349 | "Unconnected output ports are legal, silently, with no build-time warning (D-084)." | plain | D-084 Position (log 2543–2546) | C; bold nowhere |
| 31 | 1349–1350 | "Unconnected input ports are a build error, with no silent defaults." | plain | D-048 Position bullet A ("global wiring + obligations", log 1486–1487); D-051 Rejected (log 1553) and D-143 Rejected (log 4888) call it "§6.1's ban" | B: U by D-048 for the check's existence; R for "no silent defaults", which two Rejected lists state only by pointing back at §6.1 (lesson 16, part F). Names no kind (`UnconnectedInput`, Appendix C 12290, q7) |
| 32 | 1352 | "**The check is a whole-tree property, not a per-declaration one.**" | bold sentence | D-048 Position bullet A ("global wiring + obligations"); D-048 Rejected (log 1500–1501, "per-level validation: obligation/two-producers undecidable below the root") | B: U by D-048, whose bullet A §9.1 3787 already bolds ("The structure step is pure declaration reading"); R for "whole-tree", which only the Rejected list words |
| 33 | 1352–1355 | "Within a single assembly declaration an unfed child input is simply *awaiting a claim from above*, either a sibling wire or an `input_wires` entry handing the obligation up one level (§8.6)." | italic | — | mechanism; "claim" collides with the glossary's *claim* (F15); "sibling wire" (F4) |
| 34 | 1355–1356 | "The error fires at the root build for any input whose obligation chain never terminates." | plain | D-048 Position bullet A | U; `src/assembly.jl` 959 and 979 name "the obligation model" and "the obligation chain" after §6.1 |
| 35 | 1356–1357 | "The one legitimate terminus fed by no component is the root component's own input face, a root input (§11.3)." | plain | D-208 Position (log 7606–7607) | U; §8.2 2517 bolds D-208 |

Descriptions that read like rules: row 24's local fan-out (no entry) and row
20's message payload (Appendix C only).

Appendix C kinds cited to §6.1 (spec 12286–12310), and whether §6.1 names each
where it states the condition:

| kind | Appendix C | condition in §6.1 | named |
|---|---|---|---|
| `UnknownPort` | 12286 (§6.1, §8.4 w1) | not stated anywhere in §6.1 (a wire end naming no port of the child it resolves to) | no |
| `UnconnectedInput` | 12290 (§6.1, §8.4 w2) | 1349–1357 | no |
| `TwoProducers` | 12294 (§6.1, §8.8) | 1342–1344 ("a two-producers build error") | no |
| `WireTypeMismatch` | 12298 (§6.1, §8.2, §8.4 w4) | 1287–1290 | yes |
| `WalkingFaceAtFrozenEntry` | 12301 (§6.1, §8.2) | 1310–1314 | yes |
| `PathResolution` | 12306 (§6.1, §13.3) | 1279–1281 (implied: an endpoint past the immediate child) | no |

All six exist in `src/diagnostics.jl` (314–460), and each docstring cites §6.1.
The probe raised each of the four unnamed ones on the condition §6.1 states
(part C, "Code blocks"). Part G q7 proposes naming three and adding one clause
for `UnknownPort`.

Glossary links (one per term per section): §6.1 links `#g-face` twice (1240,
1263) and otherwise once each: `port`, `face`, `local-wire`,
`container-children`, `seam`, `walked`, `activation`, `tier`, `tick`,
`nominal`, `cell`, `contract`, `component`. Terms used without a link where a
first-use link fits: *assembly* (1251, linked only in the chapter opening),
*root input* (1357), *abstract entry* (1316, `#g-abstract-entry`), *leaf walk*
(if row 43's "activation walk" becomes it, F18). `#g-container-children` has
3 body links in the spec and `#g-nominal` 2; keep both.

Display-block candidates: none new. The one-level example (code 7) stays.

### §6.2 Aggregation: explicit summing junctions (1359–1509, 1,024 words)

Purpose: N-to-1 physical aggregation is ordinary junction components and
explicit wires; the `Junction` block; what the explicit form buys; the
ownership idiom that replaces Flight.jl's generated tree walks; the
zero-contributor spelling; the cost.

Opening 1361–1411 holds context, rule, the `Junction` code and the `Systems`
wiring example, with no roadmap sentence. Subheadings: "What the explicit form
buys" (1412), "The hierarchical aggregation idiom" (1436), "The
zero-contributor end of the same spectrum" (1474), "The cost, recorded"
(1498). Labels: **Rule.** 1366, 1486; **Why.** 1445, 1489; **Example.** 1449.
Bold lead-ins act as bullet headings at 1414, 1418, 1421, 1424.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 36 | 1361–1364 | "Several physical quantities are totals over many contributors. … today they are the work of the generated `get_wr_b`/`get_mp_b`/`get_hr_b` tree walks." | plain | — | context; "today" is Flight.jl's present, and the functions are FlightPhysics' (F11) |
| 37 | 1366–1367 | "**Rule.** N-to-1 physical aggregation is expressed by **ordinary junction components and explicit wires**." | **Rule.** label, bold words | D-037 Position, first chained ruling ("Aggregation by explicit summing junctions (generic positional or named site-specific — plain components)", log 1185–1186) | U; D-037 is cited only from 1428 on |
| 38 | 1369–1371 | "There is no framework aggregation mechanism. There are no multi-connection ports, no declared fold ops and no identity-element opt-outs. Every input port takes exactly one connection, everywhere." | plain | D-037 Rejected bullet 1 (log 1195–1198, reduce-ports and its machinery retired); D-062 Rejected (framework-privileged blocks); the last sentence restates row 26 | R; glossary *summing junction* (12908–12911) quotes "There is no framework aggregation mechanism" with §6.2 |
| 39 | 1373–1384 | the `Junction` block | code | D-311 Position bullets 1–2 | code |
| 40 | 1386–1388 | "**The parameters are the nominal port types and the arity** (D-311), as in `SumJunction{Wrench{Float64}, 3}`, and the fold is instance data." | bold lead-in (headline) | D-311 Position bullet 3 (log 13024–13026), bullet 1, and sentence 1 (the instance holds the fold) | C; §13.7 10004 bolds "Arity and port types come from type parameters" (D-311), in a chapter not yet rewritten (q5). spec 2063 quotes the example |
| 41 | 1388 | "`SumJunction{V, N}` is the `Junction` at `+`." | plain | D-311 Position bullet 2 | C (adjacent) |
| 42 | 1388–1390 | "A custom fold, a weighted blend or a mass-properties composition, is `Junction{In, Out, N}(f)` with the fold written at the site." | plain | D-311 bullet 1 ("`Junction{In, Out, N}(f)` infers `F`"); D-311 Rationale (log 13033–13035, the two example folds) | C (adjacent) for the constructor; R for the examples. The code block above lacks that constructor (part C, "Code blocks") |
| 43 | 1392–1394 | "The junction is a continuous leaf, so its contracts are written at nominal `Float64` and the activation walk retypes them (§8.2)." | plain | D-263 Position sentence 1 and bullet 1 | U; "activation walk" is a one-use name for the glossary's *leaf walk* (F18) |
| 44 | 1394–1396 | "An entry at `Wrench{Float64}` is the tolerant form a promoting consumer writes, and walking, frozen and root-input contributors are all admissible behind it." | plain | D-263 Position bullet 2 (the permissive reading); §8.2 2380–2383 | U |
| 45 | 1396–1397 | "The Bool gates of §13.7 are the same leaf at `\|` and `&`." | plain | D-311 Position bullet 2 | U (D-311 sits in the paragraph before) |
| 46 | 1399–1401 | "Wired at an ownership boundary, the junction is ordinary structure. `wr_sum::SumJunction{Wrench, 3}` is a field of `Systems` like any other child (§8.5)." | plain | D-037 Position ("plain components") | U; `SumJunction{Wrench, 3}` is the unparametrized form D-311 bullet 3 rules out (F1). "ownership boundary" is used before 1441 defines owning contributors |
| 47 | 1403–1410 | `local_wires(::Systems) = (…)` | code | — | code |
| 48 | 1414–1417 | "**Every mistake is loud** under the declaration layer. A forgotten contributor is an unconnected-input error naming `in4`. A double-wired slot violates single-connection. A stale arity surfaces as one or the other. The bookkeeping is ceremony, never silence." | bold lead-in | D-007 Rejected bullet 2 (log 461–462, superseded entry: "objection dissolved by §8's loud declarations"); D-037 Rejected bullet 2 ("silent omission") | R; overclaims against D-084 (F2, q8). Names no kind for either error |
| 49 | 1418–1420 | "**The aggregate is a first-class signal.** `wr_sum.out` is an ordinary port. It is loggable, GUI-visible, and fanned out to a second consumer (a loads monitor) for one wire." | bold lead-in | D-037 Rejected bullet 1 ("the aggregate wasn't even observable") | R; "loads monitor" takes an introducing clause; `wr_sum.out` uses a dot where §8.6's paths use a slash |
| 50 | 1421–1423 | "**Aggregation logic is arbitrary stage-2 code**, such as mass-properties composition with its transport terms, or weighted blends. It is not restricted to a declared commutative-associative binary op." | bold lead-in | D-311 Rationale ("§6.2's arbitrary stage-2 aggregation"); D-037 Rejected bullet 1 (canonical fold) | R |
| 51 | 1424–1428 | "**Fold order is author-visible.** It is the positional order of the junction's inputs. Reassigning contributors to different slots changes summation order, hence bits … deterministic per configuration and under author control, which is strictly more explicit than a framework-canonical order (D-037)." | bold lead-in | D-037 Position, third chained ruling ("fold order author-visible") | C; §9.7 4873 and D-163 Rationale (log 5688) cite "§6.2 made every sum an ordered junction entry" |
| 52 | 1429–1434 | "For the handful of real sites, a **named site-specific junction** documents the contributor set better than generated slots, at the price of hard-coding it into a type. … The generic positional form remains the tool for configuration-variable sites. Both are plain components, and the framework is not involved." | bold words | D-037 Position, first chained ruling ("generic positional or named site-specific — plain components"); "handful of real sites": D-007 Rejected bullet 1 (three-site census) | U; `VehicleWrenchSum` is a made-up name the bullet introduces itself |
| 53 | 1438–1439 | "This is what replaces the tree walk. Only physical contributors publish these ports. A strut publishes `wr_b`, and avionics publishes nothing." | plain | — | N (an example); `wr_b` against `wrench` at 1405–1407 (F5) |
| 54 | 1441–1443 | "Each assembly that *owns* contributors aggregates them with an internal junction and **exports the total**. The junction is a component inside the assembly, and the assembly exports its `out` port (§3.3)." | bold words | D-037 Position, second chained ruling ("hierarchical idiom: junctions at ownership boundaries, totals exported across generic boundaries") | U; D-037 says "generic boundaries", stale since D-207 (part E). §3.3 does not mention exporting `out`; §8.6 declares `output_wires` (F19) |
| 55 | 1445–1447 | "**Why.** The §6.1 connection rules force this shape. A child is opaque to wiring at every boundary, so every assembly that owns contributors must export its aggregate." | **Why.** label | D-207 Position (every boundary) | reason |
| 56 | 1449–1451 | "**Example.** `Ldg` sums its three struts and exports `wr_b`. The systems assembly sums `aero + ldg + pwp`. The vehicle wires the systems totals into Newton–Euler." | **Example.** label | — | example; disagrees with code 47, where `Systems` wires its total into its own child `dynamics` (F6) |
| 57 | 1453–1456 | "Each recursion step of FlightCore's tree walk becomes one visible junction at the level that owns the contributors. For the C172 that is about four junctions and fifteen wires, written once. They read as a manifest of what weighs, what pushes and what spins." | plain | — | N: a Flight.jl status-quo measurement. The tree walk is FlightPhysics', not FlightCore's (F7) |
| 58 | 1458–1459 | "Frame responsibility is unchanged. Contributors publish in the common body frame, applying their own mounting transforms at source." | plain | — | N: "unchanged" from Flight.jl's convention; no entry rules the frame |
| 59 | 1461–1464 | "Do **not** bundle the three quantities into one contribution struct. Contributors are ragged. Aero has wrench but no mass, fuel the reverse, and only `pwp` has angular momentum. A bundle forces zero-filled identity noise through every port, which is the "silently sum nothing" hazard in a new coat (D-037)." | bold word | D-037 Rejected bullet 3 and its annotation (log 1201–1207), which migrated this census from §6.2 on 2026-08-15 | R (cited); adversarial, carried word for word by the log (q9). "bundle" is the glossary's *bundle* in another sense (F15) |
| 60 | 1466–1467 | "A `sum_ports!`-style helper (instantiate + wire + export in one call) is guarded-addition sugar, added when real models show the pattern repeated." | plain | D-037 Position, fourth chained ruling ("helper/macro sugar guarded") | U; *guarded addition* takes `#g-guarded-addition` |
| 61 | 1469–1472 | "The junctions themselves, summing junctions and Bool gates, are the seed of the standard component library committed in §13.7. They are ordinary components with no framework privileges, and the inventory grows by the admission rule §13.7 states." | plain | D-062 Position bullet 3 (library of ordinary components); D-313 Position (admission by judgement) | U; "the admission rule" against D-313's "judgement against three guidelines, none of them a requirement" (F8) |
| 62 | 1476–1480 | "Ragged contributors bottom out at none. … The bare-propagation `Vehicle{NoVehicleSystems}` is one. It has zero contributors to external wrench and to internal angular momentum, while `VehicleDynamics` requires both unconditionally." | plain | D-143 Rationale (log 4864–4871) | context; FlightPhysics names (F11) |
| 63 | 1482–1484 | "There is no junction to write and no producer to wire. §6.1 bans unconnected inputs and silent defaults, and the identity element a zero-arity junction would need is deliberately absent (D-037)." | plain | D-143 Rejected bullet 1 (log 4884–4887); D-037 Rejected bullet 1 | R (cited to D-037's Rejected list) |
| 64 | 1486–1487 | "**Rule.** The spelling is a library `Constant` source (§13.7) wired straight to the consumer's input, as in `Constant(Wrench())` → `dynamics/wr_ext`." | **Rule.** label | D-143 Position sentences 1–2 (log 4844–4849) | U; D-143 is cited nowhere in the chapter |
| 65 | 1489–1491 | "**Why.** The zero total becomes declared structure. The configuration states "external wrench ≡ 0" as a visible wire and an observable port, rather than as an identity method the framework supplies behind the author's back." | **Why.** label | D-143 Rationale (log 4871–4874) | reason |
| 66 | 1493–1496 | "This is not the banned default (§6.1) in component clothing but its opposite. That default is silent and consumer-declared. This one is loud and assembly-declared, with the author writing the child and the wire, both inspectable." | plain | D-143 Position, clarification (i) (log 4850–4853) | U |
| 67 | 1500–1503 | "Adding a contributor from another subtree edits the assembly levels between its producer and the junction (§6.1) instead of zero. In exchange, explicit wiring buys per-contributor values and intermediate totals as observable ports, with every silence inverted into a warning or error (D-007, D-037)." | plain | D-037 Rejected bullet 2 ("the zero-edit convenience *is* the hazard"); D-007 superseded → D-037 | R; S citation (D-007). "every silence" overclaims (F2) |
| 68 | 1505–1506 | "Consumer-declared folds with multi-connection legality are closed (D-007 and D-037)." | plain | D-037 Rejected bullet 1 | R; S citation (D-007) |

Descriptions that read like rules: row 58 (the body frame; Flight.jl's
convention, no entry) and row 57's count (Flight.jl's C172).

Appendix C cites no kind to §6.2. The section states the conditions of two:
row 48's "unconnected-input error naming `in4`" (`UnconnectedInput`) and "a
double-wired slot violates single-connection" (`TwoProducers`). Naming them
there is optional; §6.1 is their home (q7).

Glossary links in §6.2, each once: `component`, `port`, `contract`,
`activation`, `root-input`, `assembly`, `summing-junction`.
`#g-summing-junction` has exactly one body link in the spec, at 1469: keep
it. Unlinked where a link fits: *guarded addition* (1467), *face* (not used
in §6.2 prose), *tier* (only in the code comment 1379).

Display-block candidates: none needed. The zero-contributor wire (1487) could
become a two-line block (`Constant(Wrench())` as a child, the wire in
`local_wires`), but it would be new code; not recommended.

### Tally

| section | rules | C | U | S | R | N | B |
|---|---|---|---|---|---|---|---|
| §6.1 | 30 | 7 | 13 | 1 | 4 | 0 | 5 |
| §6.2 | 26 | 4 | 11 | 0 | 8 | 3 | 0 |
| total | 56 | 11 | 24 | 1 | 12 | 3 | 5 |

The count leaves out the 12 rows that are context, reasons, mechanisms,
examples or code (1, 7, 8, 25, 33, 36, 39, 47, 55, 56, 62, 65), and classes
each row by its first code. Rows 67 and 68 class R by their ruling entry and
also carry a superseded citation (D-007); with row 22 that makes three S
citations at 1326, 1503 and 1505.

Against chapter 7 (C 17, U 25, S 0, R 20, N 2, B 15 of 79): chapter 6 is cited
at a fifth of its spots (11 of 56), and one rule in five lives only in a
Rationale or Rejected list (12). D-143 rules a whole subsection (§6.2's
zero-contributor spelling and its clarification) and the chapter never cites
it. D-170 rules the single-connection rule and D-048 the whole-tree check;
neither is cited in the chapter. Three citations name superseded entries:
D-167 (1326) and D-007 (1503, 1505).

Bold weight now: 28 spans, 9 of them labels; the other 19 carry 94 words.
Five are bullet lead-ins acting as headings (1414, 1418, 1421, 1424, and the
bound check's lead-in 1287), three are bold terms (*total*, *walk-compatibility
clause*, *failure asymmetry*), one is an emphasis word (*not*, 1461), and the
rest mark rulings. Part C proposes 14 bolds, one per ruling.

## B. Overlaps

### Inside the chapter

1. **Every input takes exactly one connection.** §6.1 1339–1340 (the rule)
   and §6.2 1371 ("Every input port takes exactly one connection,
   everywhere"). Home: §6.1. §6.2 keeps a clause pointing to it, since its
   point there is that no aggregation port escapes the rule.
2. **The ban on unconnected inputs and silent defaults.** §6.1 1349–1350
   states it; §6.2 1482–1483 and 1493 restate it as "§6.1 bans …" and "the
   banned default (§6.1)". Distinct jobs: the rule, then two uses of it. No
   change.
3. **The one-level rule as the reason for exports.** §6.1 1251–1254 (routing
   is declared level by level) and §6.2 1445–1447 (the **Why.** of the
   ownership idiom) and 1500–1501 (the cost). Each §6.2 sentence points back
   to §6.1 and keeps its own consequence. No change.
4. **The tree walk.** §6.2 1361–1364 (context), 1438 ("This is what replaces
   the tree walk") and 1453–1454 ("FlightCore's tree walk"). One introducing
   clause at 1363 serves all three (q3); 1453 needs F7's owner fix.
5. **Silence inverted.** 1414–1417 ("Every mistake is loud … ceremony, never
   silence") and 1502–1503 ("every silence inverted into a warning or
   error"). Same claim twice, same overreach (F2, q8). Both stay, scoped the
   same way.
6. **The `Systems` example and the idiom's example.** Code 1403–1410 wires
   the total into `dynamics` inside `Systems`; 1449–1451 has "the vehicle"
   wire the systems totals into Newton–Euler. Two sketches of one hierarchy
   that disagree on where the dynamics sits (F6).

### Other chapters

| content | chapter 6 | elsewhere | home |
|---|---|---|---|
| the three wiring declarations, what each pair joins; "wire" and "local wire" | §6.1 1240–1245 | §8.6 3134–3157 (bold D-170 ×3), glossary *local wire* 12757–12760 (cites §6.1, D-303, D-314) | §8.6 for the declarations; §6.1 keeps its four sentences as the one-level rule's scope, which the glossary cites. Not trimmed: §6.1 must say which declarations the rule covers |
| container key segments; name-transparent bare keys | §6.1 1246–1249 | §8.6 3117–3122 (D-085, D-211); §8.5 2966–3039 (bold D-211) | §8.5/§8.6 for the grammar; §6.1 keeps "one level" for both, which spec 3031 cites |
| fan-out through a boundary, the tuple-of-paths entry | §6.1 1259–1260 (code), 1254 | §8.6 3142–3146 (same `trn` example, "fan-out through the boundary") | §8.6 for the entry form; §6.1 keeps the example as the level-by-level illustration |
| the one-level rule's enforcement in `resolve` | §6.1 1279–1281 | §13.3 9382–9435 (the two duties, the client table, D-083, D-130) | §13.3; §6.1 keeps one sentence and the pointer, and names `PathResolution` (q7) |
| the face graph is total; `at` resolves through faces | §6.1 1265–1269 | §9.2 4032–4038 (bold D-207, D-315: the `Build` retains it), §14.2 10323–10336 (D-207) | §6.1 for totality as the rule's consequence; §9.2 for retention (q4) |
| two clauses check a wire | §6.1 1285 (**Rule.**) | §8.2 2417 (bold, D-263, D-236) | §8.2 for the bold. §6.1 states the clauses plain; §8.2 2430 points back to §6.1 for the bound check's kind and the remedies, so §6.1 must keep both |
| the bound check | §6.1 1287–1290 | §8.2 2418–2421; §9.1 3826 (bold, D-078) | §9.1 for the bold; §6.1 plain, with `WireTypeMismatch` |
| the walk clause, decided at a marker scalar, no user code | §6.1 1292–1296, 1308–1310 | §8.2 2423–2429; §9.1 3831–3835 (bold, D-263, D-236) | §8.2 for the clause, §9.1 for the run. §6.1 keeps the clause in two sentences (spec 2511, 10071, `handle_walk_walkthrough.md` 64 cite §6.1 for it) and points for the run |
| the tier scope: discrete consumers take the bound check only | §6.1 1292 (bold words), 1321–1326 (bold sentence, near-verbatim) | §8.2 2433–2439 (bold, D-263, D-295) | §8.2. §6.1 keeps "for a continuous consumer only" plain and one sentence for continuous → discrete, citing D-295 and pointing to §8.2 (the carried item; q1) |
| an opaque leaf at a wire is the producer's cell | §6.1 1298–1306 | §8.2 2426–2427 (plain, D-264); §9.5 4632–4635 (plain at the wire, citing §6.1) | §6.1, bold (D-264) |
| the misplaced pin lurks until the first `Dual` activation, never silently | §6.1 1331–1333 | §8.2 2650–2664 (bold D-286); §9.4 4460–4465 | §8.2 for the output side; §6.1 keeps the input side and the asymmetry, which `test/test_build.jl` 567 cites by name |
| the AD-incompatible entry is enforced at the wire | §6.1 1310–1314 (the remedies) | §8.2 2388–2395 (the FFI door, citing §6.1); §14.10 11543–11546 (citing §6.1) | §8.2 for the door; §6.1 for the wire's message |
| `Freeze` as the remedy | §6.1 1313–1314 | §13.7 10074–10095 (D-266, D-312) | §13.7; §6.1 keeps its pointer |
| unconnected inputs; whole-tree obligation; root input as terminus | §6.1 1348–1357 | §9.1 3759–3762 (global, decidable at the root, cites §6.1), 3813; §8.6 3197–3205 (root inputs, "The whole-tree obligation model (§6.1) states the complementary error rule"); §11.3 6680–6688 (D-208 by way of §8.2); §8.4 w2 2880–2882 (cites §6.1) | §6.1 for the obligation model. §9.1 for when; §8.6/§11.3 for root inputs |
| no auto-bubbling | §6.1 1348 | §8.8 3612–3615 (D-043), 3714–3716 | both stay; each cites D-043 |
| unconnected outputs legal, no warning | §6.1 1348–1349 | §13.2 9298–9299 (cites §6.1, D-084); Appendix C 12280 | §6.1, bold (D-084) |
| two producers across levels | §6.1 1342–1344 | §8.6 3160–3161 (cites §6.1); §8.8 3580–3581 (fed and passed through); §9.1 3760–3761 | §6.1; names `TwoProducers` (q7) |
| the `Junction` block and its parameters | §6.2 1373–1397 | §13.7 9959–10010 (bold D-311 at 10004, "Arity and port types come from type parameters"); §8.1 2061–2064 (`SumJunction{Wrench{Float64}, 3}`, "at the price §6.2 states openly"); `src/blocks.jl` 15–81 | §6.2 for the junction; §13.7 for the inventory. Both bold D-311 today (q5) |
| junctions are ordinary components, the library's seed | §6.2 1469–1472 | §13.7 9961–9963 ("makes good on the junction promise (§6.2)"), 9997–10002 (bold "library blocks are ordinary components", no citation) | §13.7; §6.2 keeps its pointer sentence |
| `Constant` for zero contributors; value is instance data, not a default | §6.2 1486–1496 | §13.7 10044–10070 (D-312, the pinned port), 10094–10102 ("The zero-contributor configurations (§6.2) are one") | §6.2 for the spelling and the not-a-default clarification (D-143); §13.7 for the block |
| fold order is author-visible; deterministic | §6.2 1424–1428 | §9.7 4871–4874 (cites §6.2); D-163 Rationale | §6.2 |
| the `Systems` assembly with `aero`, `ldg`, `wr_sum` | §6.2 1399–1410 | §8.8 3624–3630 (`output_wires(sys::Systems)`), 3664–3683 (`local_wires(::Systems)` with `"aero/wrench" => "wr_sum/in1"`) | each chapter keeps its example; the face is `wrench` in both, so F5's fix aligns §6.2's prose with §8.8 |
| `Ldg` ORs its legs through a junction | §6.2 (the idiom) | §13.5 9656–9660 ("the ownership idiom, §6.2") | §6.2 |
| the tree-walk → junctions mapping | §6.2 1361–1364, 1453–1456 | `companions/flight_case_studies.md` 30 (section 1's table row); `companions/migration_outline.md` 18 (the contributor survey) | the companion for Flight.jl's status quo (q3) |

Bold already given elsewhere to a ruling chapter 6 states (the one-bold test;
`check_bold.jl` sees chapters 7 to 10 as rewritten; the full list of bold spans
in spec 1510–6344 citing an entry chapter 6 touches is
`scratch_survey/bold_rewritten.txt`, made by `scratch_survey/bolds.py`):

| entry | ruling | bold in | chapter 6 |
|---|---|---|---|
| D-236 sentence 2, D-263 bullet 2 | two clauses check a wire | §8.2 2417 | §6.1 1285 under **Rule.**; plain |
| D-078 | the bound check | §9.1 3826 | §6.1 1287 bold lead-in; plain |
| D-263 bullet 2, D-236 | the walk clause decided by retyping at a marker scalar | §9.1 3831 | §6.1 1308; plain |
| D-295 bullet 1 | discrete consumers take the bound check only | §8.2 2433 | §6.1 1292 and 1321 bold; plain (carried item) |
| D-286 | the misplaced pin lurks, never silently | §8.2 2656 | §6.1 1332–1333; plain |
| D-208 | root inputs are the root's own input faces | §8.2 2517 | §6.1 1357; plain |
| D-048 bullet A | the structure step's reading, wiring and obligations | §9.1 3787 | §6.1 1352 bold; plain (q4) |
| D-207 bullet 2 | the face graph total, retained by the `Build` | §9.2 4032 (with D-315) | §6.1 1266 bold word; q4 |
| D-211 | one name-transparent container; collisions | §8.5 2989, 3022 | §6.1 1247; plain |
| D-043 Position clause 3 | generic holding is an imposed derived contract | §8.8 3721 | not stated; §6.1 cites D-043 for its Rejected list only |
| D-170 rulings 1–2 | child face to child face; boundary split; direction by method | §8.6 3136, 3141, 3153 | not stated in §6.1 |
| D-170 ruling 4 | every right side fed exactly once | not bold (§8.6 3154 plain) | §6.1 1339; bold candidate |
| D-264 sentences 1, 2 | frozen opaque leaf admitted at a wire; identity rule never a wire | not bold (§8.2 2427, §9.5 4634 plain) | §6.1 1298 bold now; 1303 plain; bold candidates |
| D-236 bullet 1 | abstract entry checked on the whole declaration | not bold (inside the tail of §9.1 3831's sentence) | §6.1 1316; bold candidate |
| D-084 | no unconnected-output warning | not bold in 7–10 (§13.2 9298 plain) | §6.1 1348; bold candidate |
| D-037 four chained rulings | junctions; ownership idiom; fold order; sugar guarded | not bold in 7–10 | §6.2; bold candidates |
| D-311 | parameters are the nominal port types and the arity | not bold in 7–10; bold in §13.7 10004 (not rewritten) | §6.2 1386 bold now; q5 |
| D-143 | the `Constant` spelling; not the banned default | not bold anywhere | §6.2 1486, 1493; bold candidates |
| D-303 bullet 3, D-314 | "wire" for any entry; "local wire" in prose | not bold anywhere | §6.1 1244; naming, plain |

## C. Proposed structure

No section is renumbered and no `###` title changes. `inbound.tsv` holds 131
rows, every one by section number: §6 4, §6.1 93, §6.2 34. No file outside the
frozen briefs and reports links a `####` anchor of chapter 6 (checked with
`rg` over `docs/`, `src/`, `test/`; only `briefs/brief_increment_32` and
`_49` and `reports/20260904_conformance` name "Type-checking a wire" or the
idiom, as history), so the `####` labels can change freely.

### Moves

| move | content | from | to | needs a ruling |
|---|---|---|---|---|
| M1 | the tier-scope paragraph, a near-verbatim double of §8.2 2433–2439 | §6.1 1321–1326 (64 words, bold, cites superseded D-167) | one plain sentence after the walk clause: discrete consumers take the bound check alone, so a continuous producer feeding a discrete consumer is always legal, citing D-295 and pointing to §8.2. The bold on "for a continuous consumer only" (1292) goes too | yes, q1 |
| M2 | the run of the walk clause | §6.1 1308–1310 | one sentence placed before the abstract-entry paragraph (1316 needs "the marker" defined): the clause is decided in the structure step by retyping both declarations at a marker scalar, with no user stage code, pointing to §9.1 | yes, q1 |
| M3 | the three wiring declarations and the word "wire" | §6.1 1240–1245 | before the rule at 1239, as the subsection's context: what a wire is, then the rule about its endpoints | yes, q6 |
| M4 | "Fan-out and fan-in" and "Unconnected ports" | §6.1 1335–1358 (two `####`, 177 words) | one `####`, "One producer per input": fan-out free; the rule (exactly one); at most one across levels (`TwoProducers`); at least one, the whole-tree obligation (`UnconnectedInput`), the root input as terminus; unconnected outputs legal | yes, q6 |
| M5 | the name "locality law" | — | one declared clause at §6.1 1251–1252, naming "each assembly speaking only of its own children" as the locality law that conditions and service reads also follow (§14.2) | yes, q2 |
| M6 | kind names and the `UnknownPort` condition | — | §6.1: `PathResolution` at 1279–1281, `TwoProducers` at 1343, `UnconnectedInput` at 1355, and one clause for `UnknownPort` in "How far a path may reach" | yes, q7 |
| M7 | junctions as the library's seed | §6.2 1469–1472 (from the idiom) | after 1397, beside "The Bool gates of §13.7", which uses the library before 1469 introduces it | yes, q6 |
| M8 | the raggedness census | §6.2 1462–1463 ("Aero has wrench but no mass, fuel the reverse, and only `pwp` has angular momentum") | cut to D-037, which carries it word for word (log 1203–1207, migrated from §6.2); 1461's rule and 1463–1464's hazard clause stay | yes, q9 |
| M9 | the C172 count | §6.2 1454–1455 ("For the C172 that is about four junctions and fifteen wires, written once") | `companions/migration_outline.md`, the row "The contributor survey feeding the aggregation chains" (18), as an expanded paragraph; §6.2 keeps "one visible junction at the level that owns the contributors" and the manifest sentence | yes, q3 |

Every move stays inside one unit (part C, "Rewrite units"). M9 sends text out
of the chapter; part D lists the rows it touches (none rely on the count).

### Order within each section

Define-before-use was checked for each order below against the terms each
block uses.

- **Chapter opening.** Unchanged. It names *assembly* and *junction* before
  either section, and links `component` and `assembly`.
- **§6.1 context (1230–1235).** Unchanged but for its roadmap sentence, which
  follows q6's labels. It may name *wire*, *endpoint* and *port* before the
  subsections, as today.
- **§6.1 "How far a path may reach".** (1) What a wire is: the three
  declarations, "wire", "local wire" (row 3, M3). (2) The rule, bold (row 2,
  D-207). (3) Containers, keyed and name-transparent (rows 4–5). (4) The
  `UnknownPort` clause (M6), if q7 adds it. (5) The consequence: level by
  level, each assembly speaking only of its own children, named as the
  locality law (row 6, M5), with the example and its code (7). (6) Why: faces
  the only currency; the face graph total (rows 8–9). (7) The ceremony and its
  computed spelling (row 10). (8) Enforcement in `resolve`, naming
  `PathResolution` (row 11). Checked: (1) needs *face* (glossary link) and
  *immediate child*, both plain words today; (2) then reads with "wire"
  defined; the example (5) uses `trn` and `trn_field`, which q3's clause
  introduces as a terrain field handle and the legs' entries.
- **§6.1 "Type-checking a wire".** (1) Context: once both endpoints resolve,
  two clauses check the wire (row 12, plain, pointing to §8.2). (2) The bound
  check, `WireTypeMismatch` (row 13). (3) The walk clause with its tier scope
  in one plain sentence (rows 14 and 22, M1). (4) The run at a marker scalar
  (row 19, M2). (5) The abstract entry, bold (row 21). (6) The opaque leaf,
  bold twice (rows 15–18). (7) The violation, its payload and remedies, and
  `Freeze` (row 20). (8) The failure asymmetry (row 23). Checked: (3) glosses
  *walking* and *pinned* before (5) and (6) use them; (4) defines *marker*
  before (5)'s "at the marker"; (7) after (6) is fine, since the opaque leaf
  is an admission and (7) the refusal. The section-local glosses for
  *activation* and *nominal* move with their first use, now (2) and (3).
- **§6.1 "One producer per input" (M4).** (1) Fan-out free, the converse
  strict (rows 24–25). (2) The rule, bold (row 26, D-170), with the pointer to
  §6.2 (row 27). (3) At most one: across levels, `TwoProducers` (row 28). (4)
  At least one: no auto-bubbling, the error, the whole-tree obligation, the
  root input as terminus, `UnconnectedInput` (rows 29, 31–35). (5) Outputs
  left unconnected are legal, bold (row 30). Checked: (4) uses *root input*,
  which takes its glossary link here (first use in §6.1). If q6 keeps the two
  labels, the order inside each is unchanged.
- **§6.2 opening.** (1) Context: totals over contributors, and what
  Flight.jl does today, introduced (row 36, q3). (2) The rule, bold (row 37).
  (3) No framework mechanism (row 38). (4) The junction: code, parameters
  (bold, D-311), the continuous leaf and the tolerant entry, the gates (rows
  39–45), and the library's seed (row 61, M7). (5) The junction wired at an
  ownership boundary, with the `Systems` code (rows 46–47). Add a roadmap
  sentence at the end of (1) or (3) naming the four `####` parts, as
  spec_style asks of a section opening with subheadings. Checked: "ownership
  boundary" (46) comes before "owns contributors" (54); one clause at 46 ("the
  assembly that owns the contributors") removes the forward use without a
  move.
- **§6.2 "What the explicit form buys".** Unchanged order (rows 48–52).
  F2's scoping (q8) applies to the first bullet.
- **§6.2 "The hierarchical aggregation idiom".** (1) The rule: owners
  aggregate and export the total, bold (row 54). (2) Why (row 55). (3) The
  example (row 56) and what replaces the tree walk (rows 53, 57; M9). (4)
  Frame responsibility (row 58). (5) Do not bundle (row 59, M8). (6) The
  sugar, bold (row 60). Today's order puts row 53 ("This is what replaces the
  tree walk. Only physical contributors publish these ports") before the rule;
  it reads better after the example, where "these ports" has an antecedent.
- **§6.2 "The zero-contributor end of the same spectrum".** Unchanged order:
  context (62), no junction (63), the rule, bold (64), why (65), not the banned
  default, bold (66). A shorter label, "Zero contributors", is q6's.
- **§6.2 "The cost, recorded".** Unchanged (rows 67–68), D-007 dropped from
  both citations (F9).

### Bold, one per ruling

The section states what each entry below decides, and no rewritten chapter
bolds it (part B's last table). Fourteen bolds, against 28 bold spans (9 of
them labels) today.

| section | entry | ruling | where |
|---|---|---|---|
| §6.1 | D-207 Position sentence 1 | every wiring endpoint addresses an immediate child and one of its faces | row 2's headline |
| §6.1 | D-207 Position bullet 2, first half | the face graph is total | row 9 ("the face graph is total"), if q4 rules (a) |
| §6.1 | D-236 Position bullet 1 | an abstract entry is checked on the whole declaration | row 21's first sentence |
| §6.1 | D-264 Position sentence 1 | a frozen or discrete producer of an opaque leaf is admitted at an unpinned entry, as the producer's cell | row 15's headline |
| §6.1 | D-264 Position sentence 2 | the identity rule for an opaque leaf governs a store, never a wire | row 17 |
| §6.1 | D-170 Position, last chained ruling | every input is fed exactly once | row 26's headline ("Every input port takes exactly one connection") |
| §6.1 | D-084 Position | no unconnected-output warning | row 30 |
| §6.2 | D-037 Position, ruling 1 | aggregation by explicit junctions, positional or site-specific, plain components | row 37's headline |
| §6.2 | D-037 Position, ruling 2 | junctions at ownership boundaries, totals exported | row 54's headline |
| §6.2 | D-037 Position, ruling 3 | fold order author-visible | row 51's lead-in, cited in its sentence |
| §6.2 | D-037 Position, ruling 4 | helper sugar guarded | row 60's headline |
| §6.2 | D-311 Position bullet 3 | the type parameter is the nominal type; arity spelled | row 40's headline, if q5 rules (a) |
| §6.2 | D-143 Position sentences 1–2 | the zero-contributor spelling is a `Constant` wired to the consumer | row 64's headline |
| §6.2 | D-143 Position clarification (i) | the `Constant` is the banned default's opposite | row 66's headline |

Not bold, each for the reason given: D-236 sentence 2 and D-263 bullet 2
(bold at §8.2 2417); D-078 (bold at §9.1 3826); the run, D-263 bullet 2 with
D-236 (bold at §9.1 3831); D-295 bullet 1 (bold at §8.2 2433, the carried
item); D-286 (bold at §8.2 2656); D-208 (bold at §8.2 2517); D-048 bullet A
(bold at §9.1 3787, q4); D-211 (bold at §8.5); D-061, D-130 (home §13.3);
D-303 bullet 3 and D-314 (naming rulings, home §8.6, unbolded there);
D-062 bullet 3 and D-313 (home §13.7); D-263 sentence 1 and bullet 1 (bold at
§8.2 2267 and plain at 2366); D-085 (home §8.5/§8.6). Rows ruled only by a
Rationale or Rejected list (10, 18, 23's input half, 29, 31's "no silent
defaults", 38, 48–50, 59, 63, 67, 68) stay plain and cite their entry; part E
lists the Positions the log owes.

Labels: all nine go. The **Rule.** at 1285 heads a ruling bold elsewhere, so
its sentence becomes a plain context sentence. The **Why.** paragraphs (1263,
1445, 1489) follow their rules with a plain connective. The **Example.** at
1449 becomes a plain sentence ("In the aircraft, …").

Bold lead-ins that act as bullet headings in "What the explicit form buys"
(1414, 1418, 1421, 1424) lose their bold except 1424's, which is a ruling
(D-037 ruling 3). The bullets keep their topic sentences. The bound check's
lead-in (1287) and the term bolds *total* (if q4 rules (b)), *walk-compatibility
clause*, *failure asymmetry* and *not* go.

### Rewrite units

| unit | lines (original) | moves in | moves out | words |
|---|---|---|---|---|
| A | 1221–1282: chapter opening, §6.1 context, "How far a path may reach" | M3, M5, M6 (`UnknownPort`, `PathResolution`) | — | 501 plus the declared clauses |
| B | 1283–1358: "Type-checking a wire", "Fan-out and fan-in", "Unconnected ports" | M1, M2, M4, M6 (`TwoProducers`, `UnconnectedInput`) | — | 656, about 590 after M1 and M2 |
| C | 1359–1509: §6.2 whole | M7, M8 | M9 to `migration_outline.md` | 1,024 |

Total 2,181 words. Three units, cut by content: A is the path rule and its
reasons, B what the build checks on a wire and on each input, C aggregation.
Chapter 7 used four for 3,252 words; here B is the hardest (the overlap with
§8.2 and §9.1, the carried bold, five kinds, two superseded or Rationale-only
citations) and is kept small on purpose. C at 1,024 is chapter 7's unit C
size; its Flight.jl names (q3) and its seven bolds are its own work. A's
roadmap sentence (1233–1235) names B's labels, so if q6 merges them, A's
rewriter follows the ruling, not B's text.

Splitting C at 1436 into C1 (1359–1435, 512) and C2 (1436–1509, 512) is
possible; M7 then crosses the split (1469 → after 1397), so C1 would take the
library-seed paragraph as a move in. Part G q11 offers it.

Each move stays inside one unit. M9 produces a `units/C/companion_addition.md`
for `migration_outline.md`, which `EXTRA` in `chapter.sh` names for the PDF.

### Code blocks

Three `julia` blocks and two inline code sketches. No tables, no display math.
Every runnable one was run against the package (`scratch_survey/probe.jl`,
output `scratch_survey/probe_out.txt`).

- **1256–1261, the one-level routing excerpt.** Not runnable verbatim: an
  excerpt with `…`. A complete analog (`Cessna`, `Sys1`, `Ldg` with three
  `Strut` leaves taking `trn_field`) builds, with one root input `trn`. The
  same tree with `"trn" => "systems/ldg/trn"` at the top raises
  `PathResolution` (`reaches past systems … declared level by level (§6.1)`)
  plus `UnconnectedInput` for the three legs; with `"systems/trnn"` it raises
  `UnknownPort` (`names no trnn on systems — its faces are trn`). Matches
  §6.1's text and §8.6 3142–3146.
- **1373–1384, the `Junction` block.** Runnable verbatim (in its own module
  importing `AbstractComponent` and the four declarations): passes.
  `SumJunction{Wrench{Float64}, 3}(+)` in the `Systems` tree builds and its
  `out` equals the contributors' sum; the library's version also builds a
  `LinearizeDual` activation. The block is `src/blocks.jl` 32–34, 43 and 77–81
  line for line, comments aside. One mismatch: `src/blocks.jl` 35 adds the
  inferring constructor `(::Type{Junction{In, Out, N}})(f)`, which 1389's
  "`Junction{In, Out, N}(f)`" relies on and the block does not show. Verbatim,
  `Junction{Float64, Float64, 2}(max)` is a `MethodError`; with `src`, it
  builds. Options in q10 (add the line, or leave the block as an excerpt and
  say the constructor infers `F`, as D-311 bullet 1 does).
- **1403–1410, `local_wires(::Systems)`.** Runnable with stub children
  (`Contrib` contributors publishing `wrench::Wrench{Float64}`, a `Dyn`
  consumer of `wr_ext`): passes with `SumJunction{Wrench{Float64}, 3}`. The
  bullet claims at 1414–1416 hold: at arity 4 with three wires the build
  raises `UnconnectedInput` naming `wr_sum.in4`; wiring two contributors to
  `in1` raises `TwoProducers` (and `UnconnectedInput` for the empty `in2`).
  With 1400's `SumJunction{Wrench, 3}` the build fails: `WireTypeMismatch`,
  "`dynamics`.wr_ext declared Wrench{Float64}, fed from `wr_sum`.out::Wrench"
  (F1).
- **1431–1432, `u_types(::VehicleWrenchSum) = (aero = …, …)`.** An inline
  excerpt with `…`; not runnable. `VehicleWrenchSum` exists nowhere (not in
  `src/`, not in Flight.jl); the bullet introduces it as an example.
- **1487, `Constant(Wrench())` → `dynamics/wr_ext`.** Arrow notation, not
  Julia. Its analog (`Constant(Wrench())` as a child, the wire in
  `local_wires`) builds, and builds a `LinearizeDual` activation: the pinned
  `out` (D-312) feeds the tolerant entry. Without it the build raises
  `UnconnectedInput` for `dynamics.wr_ext`.
- **Claims run besides the blocks.** Fold order is positional
  (`Junction{Float64, Float64, 3}((x, y, z) -> 100x + 10y + z)` gives 123.0).
  A walking producer into a `Pinned` entry of a continuous consumer raises
  `WalkingFaceAtFrozenEntry`, whose message carries both remedies; through
  `Freeze{Float64}` it builds; a `Constant` into the same entry builds. A
  walking producer into a discrete consumer's plain entry builds. A `Float64`
  producer into an `Int` entry raises `WireTypeMismatch`. A child input fed by
  a local wire and handed up through `input_wires` raises `TwoProducers`
  ("across levels included (§6.1)"). An input neither wired nor handed up, and
  one handed up to a non-root level and fed nowhere, raise
  `UnconnectedInput`, the second with its chain. Unconnected outputs build
  with an empty warning list. The opaque-leaf admission (D-264) was not run
  here; `test/test_build.jl` 708 and `test/test_leaves.jl` 362 test it.

Carry the three blocks verbatim, each as one claim, unless q10 rules the
constructor line. No new display blocks are needed.

## D. Inbound citations

The full list is `inbound.tsv` (beside this file): 131 rows, one per "§6",
"§6.1" or "§6.2" occurrence outside chapter 6 (1221–1509) and outside the
Contents block, in `spec.md`, `decisions.md`, `extensions.md`,
`implementation.md`, `pending.md`, `docs/design/companions/*.md` and the
repository `README.md`; for `decisions.md` rows the `entry` and `field`
columns are filled. Link definitions and everything after a file's
`<!-- citation link definitions` marker are excluded. The script is
`scratch_survey/inbound.py`, chapter 7's with the targets and the file list
changed (no briefs, no tool tables). It also searches `#6N-…` anchors; there
are none.

By file: `spec.md` 51, `decisions.md` 67 (Spec 37, Rejected 11, Position 11,
Rationale 8), `implementation.md` 5, `companions/flight_case_studies.md` 2,
`companions/handle_walk_walkthrough.md` 2, `companions/library_inventory.md`
2, `companions/migration_outline.md` 1,
`companions/inbound_periphery_walkthrough.md` 1. `extensions.md`, `pending.md`
and `README.md` cite none. By target: §6 4, §6.1 93, §6.2 34.

`src/` and `test/` cite §6.1 or §6.2 on 56 lines (`rg -n '§6\.[12]|§6\b' src
test`: `src` 30, `test` 26). They are not in `inbound.tsv`, as in chapters 7
and 8; the ones that matter are listed below. Six of them quote §6.1's words
in messages a user reads: `src/diagnostics.jl` 346 ("every input is fed
exactly once, by a local wire or by an `input_wires` chain ending at a root
input face (§6.1)"), 361 ("every input takes exactly one connection, across
levels included (§6.1)"), 396 (the two remedies), 473 ("declared level by
level (§6.1)") and 475, and 751 (D-212).

### Citations relying on moved or trimmed content

M1 and M2, the type-checking trims:

| file:line | fact relied on | after |
|---|---|---|
| spec 2430 (§8.2) | "§6.1 names the bound check's kind too, and gives the remedies this violation's message carries" | holds only if §6.1 keeps `WireTypeMismatch` and the remedies of `WalkingFaceAtFrozenEntry`. Neither trim touches them; the rewriter must not move the remedies to a pointer at §8.2, which points back (lesson 16) |
| spec 2511 (§8.2), 10071 (§13.7); `handle_walk_walkthrough.md` 4, 64 | the walk clause stated in §6.1 ("a walking producer needs an unpinned entry", "a frozen arrival at a tolerant entry is the producer's cell") | holds: M1 keeps the clause and its tier scope in plain sentences; the opaque leaf stays |
| log 8845 (D-236 Position), 10386 (D-263 Position); `src/build.jl` 853, 856 ("The marker scalar (§6.1, §9.1)") | both clauses of §6.1, decided at a marker scalar | holds if M2 keeps "a marker scalar" in §6.1's sentence; the pointer to §9.1 goes beside it |
| log 12483 (D-295 Spec); log 6048 (D-168 Rejected, "the exact failure §6.1's clause exists to prevent"); `test/test_linearize.jl` 334 | the tier scope and the clause's purpose | hold: M1 keeps one sentence with D-295 |
| `test/test_build.jl` 567 ("§6.1's failure asymmetry"), 681 ("the walk clause fails at the first nominal build (§6.1, §8.2, D-236)"); spec 2396 (§8.2, "a named wiring error at build (§6.1)"), 11546 (§14.10, "enforced at the wire (§6.1)") | the input side fails at the first nominal build, at the wire | holds: row 23 stays, with "failure asymmetry" and "first nominal build" word for word |

M4, the merged labels: no row names a `####` label. `src/assembly.jl` 959
and 979 and `test/test_assembly.jl` 751 name "the obligation model" and "the
obligation chain"; spec 3203 (§8.6) names "the whole-tree obligation model
(§6.1)". The merged text keeps "whole-tree", "obligation" and "obligation
chain".

M8, the census cut: log 1203 (D-037 Rejected annotation) records that the
census migrated "from §6.2's inline treatment". It stays true as history,
and the cut finishes that migration.

M9, the C172 count: no row relies on it. `migration_outline.md` 18 (the
contributor-survey row, citing §6.2) is its destination;
`flight_case_studies.md` 30 (the tree-walk row) holds whatever M9 decides.

The factual corrections (part E) touch these rows:

| file:line | relied on | after |
|---|---|---|
| spec 2063 (§8.1) | `SumJunction{Wrench{Float64}, 3}` (§6.2) | holds: 1387 keeps it, and F1 makes 1400 agree |
| log 2184 (D-073 Position) | "§6.2's `SumJunction` dispatches on its unparametrized type constructor" | already stale: D-311 bullet 3 (log 13024–13026) rules the nominal type, "never an unparametrized constructor". 1400's `SumJunction{Wrench, 3}` is the last trace, and F1 removes it. Track 2: annotate D-073 |
| log 11789 (D-279 Rejected) | "`sibling_connections`: §6.1's own adjective for these wires" | history; stays true as history after F4 |
| log 1199 (D-037 Rejected), 4874 (D-143 Rationale) | "FlightCore tree walks", "FlightCore's silent identity methods" | the walk and the identity methods are FlightPhysics' (`Dynamics` `get_wr_b` etc., `dynamics.jl` 328–380; `aircraftbase.jl` 31–33). Log wording; track 2, after F7 |

### Citations that already rely on content chapter 6 does not hold

The inbound check will flag these whatever the rewrite does; they belong to
track 2, to q2, or to another chapter's rewrite.

| file:line | claim | what chapter 6 says |
|---|---|---|
| spec 10330 (§14.2, "The locality law here is the one §6.1 states for connections, now in its third instance"), 10550 (§14.4, "the locality law (§6.1)"), 10827 (§14.7, "the locality scopes (§6.1)"); log 1912–1913 (D-065 Position, "locality law = §6.1's, third instance"); log 1814 (D-060 Rejected, "§6.1's knowledge rule applied to reads") | §6.1 states a "locality law" (a "knowledge rule") | §6.1 never names one. Its content is 1252's clause, "each assembly speaking only of its own children". `tools/coinage_inventory.md` 85 lists *locality law* as a low-frequency coinage, inline gloss only. q2 |
| spec 10342–10345 (§14.2) | "The enforcement status carries over from §6.1 as well. The law is convention. … available and idiomatic rather than machine-checked." | §6.1 1279–1281: the one-level rule is enforced in `resolve`, and paths are validated at build (D-207, D-061, D-130 Positions). The §14.2 sentence predates D-207 (D-065 Rejected, log 1927: "Machine-enforced ownership: not build-visible; same convention status as §6.1"). Already wrong; a Position settles it, so not serious. Chapter 14's rewrite, and a D-065 annotation in track 2 |
| log 1822 (D-061 Position, "enforcing §6.1's generic-boundary rule at the primitive"), 1834–1835 (D-061 Rejected, "§6.1 unenforceable where paths are actually resolved"), 6195 (D-172 Rejected, "§6.1's generic-seam rule"); spec 12750 (glossary *generic holding*, cites §8.8 and §6.1) | §6.1 states a generic-boundary or generic-seam rule, or generic holding | since D-207 the generic-seam stop is the universal one-level rule (D-207 Position bullet 1), and generic holding lives in §8.8 3719–3725 and §13.3 9382–9393. D-061's Position is live and stale; track 2 annotates it. The glossary row retargets to §8.8 (Appendix D's rewrite or track 2) |
| spec 2521 (§8.2, "traced through the face chain (§6.1, §11.3)"), 9435 (§13.3, "the face chain is the route (§6.1)") | §6.1 names a "face chain" | §6.1 says "face graph" (1266) and "obligation chain" (1356). VAGUE; holds in substance |
| spec 3760–3762 (§9.1) | "cross-level two-producers detection are global. They are decidable only at the root … (§6.1)" | §6.1 says the single-connection rule spans levels (1342) and that the unconnected-input error fires at the root build (1355); it does not say two-producers detection waits for the root. D-048 Rejected (log 1500–1501) says it. VAGUE; M4's merged text could say both checks are whole-tree, citing D-048, as a declared addition (q6) |
| spec 12760 (glossary *local wire*) | a local wire "stands against an input wire and an output wire, each of which has one end on the boundary (§6.1, D-303, D-314)" | §6.1 1240–1245 names the three declarations, not "one end on the boundary"; D-314 Rationale (log 13200–13202) does. VAGUE |
| spec 2064 (§8.1) | "Arity is spelled in the type, at the price §6.2 states openly" | §6.2 1416–1417 ("A stale arity surfaces as one or the other … ceremony, never silence") and 1430–1431 ("at the price of hard-coding it into a type"). VAGUE; holds while both stay |
| spec 12836 (glossary *constant source*) | "Its value is instance data, never a default (§13.7, §6.2)" | §6.2 1493–1496 says the `Constant` is the banned default's opposite; "instance data" is §13.7's (10099) and D-143 (ii)'s. VAGUE; holds |
| `companions/inbound_periphery_walkthrough.md` 159 | "# no checks — see §6" in a code comment | the walkthrough's own section 6 ("The write-surface rule"), not the spec's. spec_style reserves `§` for spec citations. Outside the chapter; a one-word fix ("see section 6") in track 2 |
| `test/test_build.jl` 764 ("a bundle's field names are part of the entry's type (§6.1, D-238)"); `src/build.jl` 511 ("`probe_value` (§6.1, §9.3, §11.3)") | §6.1 states these | it states neither; §9.5 4636 (D-238) and §9.3 do. Implementation side, track 2 |
| spec 11544 (§14.10), also 11382 and 11425 | "The input half is D-167" | cites a superseded entry; D-295 bullet 2 and D-263 bullet 2 rule it now. Chapter 14's rewrite |

Rows that record history and stay true as history: log 4042–4043 (D-131
Rationale, the retarget of a stray §6.2 to a walkthrough's own §6), 1203
(D-037's migrated census), 11789 (D-279's "sibling"), 12740–12741 (D-303's
"inner wire", annotated by D-314).

Quoted phrases the rewrite must keep word for word, because a row outside the
chapter or a message in `src/` quotes them: "immediate child and one of its
faces" (spec 3127, 9383–9384, `src/assembly.jl` 282, 350); "level by level"
(`src/diagnostics.jl` 473); "one-level" as the rule's name (spec 3634, 9382,
11824, `library_inventory.md` 31; log 9099 D-242); "the face graph is total"
(spec 10335, 4038); "the walk-compatibility clause" and "the walk clause"
(spec 2511, 10071; `handle_walk_walkthrough.md` 64); "for a continuous
consumer only" or its sense (the carried item); "failure asymmetry" and
"first nominal build" (`test/test_build.jl` 567, 681); "exactly one
connection" (spec 7653 "exactly one source"; `src/diagnostics.jl` 361); "two-producers" (spec 3161, 3258,
3581; Appendix C); "whole-tree" and "obligation" (spec 3203, 3813;
`src/assembly.jl` 959, 979); "unconnected-input error" (spec 2412, 2882);
"no silent defaults" or "silent defaults" (log 1553 D-051, 4867 and 4888
D-143, "§6.1's ban"); "the banned default … in component clothing" (log 4850
D-143 Position); "made every sum an ordered junction entry" (spec 4873; log
5688 D-163) relies on "Fold order is author-visible … positional order";
"There is no framework aggregation mechanism" (glossary 12910);
"arbitrary stage-2" aggregation (log 13034 D-311).

### Log entries whose Spec field would change

- Under the moves: none. M9 sends Flight.jl text to a companion, which has no
  Spec field.
- New citations the rewrite adds (part E, "Entries to cite at the rule") give
  these entries a §6 section their Spec field lacks: D-048 (§6.1; Spec lists
  §9.1 only), D-078 (§6.1; Spec §4.4, §8.2, §9.1), D-085 (§6.1), D-130
  (§6.1), D-208 (§6.1), D-286 (§6.1), D-062 (§6.2; no Spec field at all),
  D-313 (§6.2; Spec §13.7 only), D-312 (§6.2, if cited for the pinned
  `Constant`). D-143, D-170, D-211, D-295, D-311, D-314 already list theirs.
- D-007 (superseded) and D-167 (superseded) keep their Spec fields; the
  chapter stops citing them (F9, F10). Spec 11382, 11425 and 11544 (§14.10)
  still cite D-167. D-007's only spec citations are 1503 and 1505, so
  dropping them shrinks `check_rows.jl`'s coverage: rebaseline at landing, as
  the recipe's step 7 says.

The recipe updates the Spec fields at landing (step 7.3).

## E. Log repairs and factual problems

Log repairs go to the second track, after landing (recipe step 8). The rewrite
only adds citations; it states no repair. Factual problems stay as written and
go to the units' `rulings.md`, unless part G pre-rules them.

### Entries to cite at the rule

From part A's U and B rows, by entry: D-037 (27, 37, 46, 52, 54, 60), D-048
(28, 31, 32, 34), D-061 (11), D-062 (38, 61), D-065 (6, if q2 names the
locality law), D-078 (13), D-085 (4), D-130 (11), D-143 (62–66), D-170 (24,
26, 28), D-207 (6, 9), D-208 (35), D-211 (5), D-236 (12, 14, 19), D-263 (12,
14, 19, 43, 44), D-266 (20, for `Freeze`), D-286 (23, output half), D-295 (14,
22), D-311 (45), D-313 (61), D-314 (3).

Cited nowhere in the chapter, though each rules a block of it: **D-143** (the
whole zero-contributor subsection, its rule and its clarification), **D-170**
(the single-connection rule), **D-048** (the whole-tree check), **D-078** (the
bound check) and **D-295** (the tier scope, now cited through superseded
D-167).

Lesson 16 hazards: D-051 Rejected (log 1553) and D-143 Rejected (log 4888)
and Rationale (4867) state "no silent defaults" only as "§6.1's ban". §6.1
must not cite either for that ban, or the entry points back at the section.
D-065 Position (log 1912–1913) defines the locality law as "§6.1's"; if q2
names it in §6.1, cite D-065 for the name and the third instance, and keep
1252's clause stated in §6.1's own words.

### Superseded and half-superseded citations

- **D-167** (cited 1326): superseded → D-263 (log 5934). D-167's annotation
  (log 5988–5991) says the tier scope stands, and D-295 bullet 1 states it in
  a Position. Cite D-295 (F10).
- **D-007** (cited 1503, 1505): superseded → D-037 (log 447). D-037 Rejected
  bullet 1 carries the reduce-ports verdict ("canonical-fold, multi-connection
  legality and identity-element machinery all retired"; "the aggregate wasn't
  even observable"). Cite D-037 alone (F9). D-007 Rejected bullet 2's
  "objection dissolved by §8's loud declarations", the ground of row 48, has no
  live equivalent; D-037 Rejected bullet 2 ("silent omission") is the nearest.
- **D-303** (cited 1245): ratified, annotated by D-314 (log 12793–12796),
  which renames `inner_wires` and makes "local wire" the prose term. The
  chapter's "local wire" is D-314's; cite both.
- **D-037** (cited 1428, 1464, 1484, 1503, 1506): its Position says "totals
  exported across generic boundaries" (log 1187). Since D-207 every boundary
  routes one level, so every owner exports (the chapter says "every boundary",
  1446). No annotation records it.
- **D-264** (cited 1302): ratified, current.
- **D-236** (cited 1319): ratified; its "Stratum A" is the structure step since
  D-259, annotated for D-263 (log 8885–8887). Never import "stratum".

### Rulings that need an entry stating them in a Position

1. **Parallel routes threading many boundaries are the signal to gather them
   into a component** (row 10): D-207 Rationale log 7582–7584.
2. **A handle's pin is a property of its chain** (row 18): D-264 Rationale log
   10569–10573.
3. **The failure asymmetry, input side** (row 23): D-167 Rationale (log
   5969–5972, superseded), restated in D-263 Rationale (log 10432–10436) and
   D-236 Rationale (log 8878–8881). Tests cite it by name.
4. **The walk violation's payload and both remedies** (row 20): D-167
   Rationale (log 5958–5960, superseded) only. Appendix C 12301–12305 states
   them normatively, so the spec is not short; the log is.
5. **No auto-bubbling** (row 29): D-043 Rejected log 1343–1344.
6. **Unconnected inputs are a build error, with no silent defaults** (row
   31): no Position. D-048 Position bullet A names "obligations"; D-051 and
   D-143 Rejected point back at §6.1.
7. **The obligation check is whole-tree, decided at the root** (row 32):
   D-048 Rejected log 1500–1501.
8. **No framework aggregation mechanism: no multi-connection ports, no fold
   ops, no identity elements** (rows 38, 63, 68): D-037 Rejected bullet 1;
   D-143 Rejected bullet 1.
9. **What the explicit form buys: loud mistakes, an observable aggregate,
   arbitrary stage-2 folds** (rows 48–50): D-007 Rejected (superseded), D-037
   Rejected bullets 1–2, D-311 Rationale log 13033–13035.
10. **Do not bundle ragged contributions** (row 59): D-037 Rejected bullet 3
    and its annotation log 1201–1207.
11. **The cost: a contributor from another subtree edits every level between**
    (row 67): D-037 Rejected bullet 2; D-207 Rationale.

### Rulings with no entry at all

- §6.1: local fan-out is free (row 24, the half D-170 does not state).
- §6.2: "Contributors publish in the common body frame, applying their own
  mounting transforms at source" (row 58). It reads as Flight.jl's convention
  ("Frame responsibility is unchanged"), not as a framework rule; q3 offers
  it to the companion with the C172 count.

Some are descriptions of an inherited status quo: the tree walk and "today"
(row 36), the C172 count (row 57), the body frame (row 58). They record what
FlightPhysics and FlightApps do, not rulings, and go to the owner only if
someone wants them ruled (recipe step 8, lesson 17).

### Stale entry text and Spec fields

- D-061 Position (log 1821–1822): "enforcing §6.1's generic-boundary rule at
  the primitive". §6.1 has stated no generic-boundary rule since D-207; D-130
  amended D-061's client scope. No annotation. Spec field lists §6.1 only;
  `resolve` lives in §13.3.
- D-065 Position and Rejected (log 1912–1913, 1927): "locality law =
  §6.1's" and "same convention status as §6.1". D-207 bullet 2 amended its
  deep-`at` clause; nothing records that §6.1's wiring rule is now
  machine-checked. Spec 10342–10345 repeats the stale status (part D).
- D-073 Position (log 2184–2185): "§6.2's `SumJunction` dispatches on its
  unparametrized type constructor", against D-311 bullet 3. No annotation.
- D-143 Position (log 4847, 4858): `output_types(::Constant{V}) = (out = V,)`
  and "a stateless `h_xu`". D-312 bullet 1 made the port `Pinned{V}`, and
  D-220/D-267 renamed the declarations. No annotation.
- D-062 Position bullet 3 (log 1847–1849): "summing junctions, Bool gates …
  demand-driven". D-311 folded them into one `Junction`, and D-313 replaced
  demand with judgement. No annotation, and no Spec field.
- D-037 Position: "across generic boundaries" (above).
- D-037 Rejected (log 1199) and D-143 Rationale (log 4874) attribute the tree
  walk and the identity methods to FlightCore; both are FlightPhysics' (F7).
- D-303 Position bullet 3 says "inner wire"; D-314's annotation covers it.

### Factual problems in chapter 6

None meets the recipe's test for **serious**. No two authoritative sources
contradict each other with no Position settling which is right, and no fix
changes what the framework does. F2 comes closest: the chapter claims every
silence is inverted, and D-084's Position keeps one silence on purpose. D-084
settles it, so it is a prose overclaim. F1 is a defect in an example, proven by
running it. The rest are prose, vocabulary, citation or pointer problems, and
the Flight.jl names q3 handles. Each correction below was grepped for every
instance in 1221–1509 (lesson 19).

- **F1. `SumJunction{Wrench, 3}` is unparametrized** (1400). D-311 bullet 3
  (log 13024–13026): "The type parameter is the nominal type,
  `SumJunction{Wrench{Float64}, 3}`, never an unparametrized constructor".
  The same section writes the nominal form at 1387. Run in the `Systems`
  example, the unparametrized junction fails the build: `WireTypeMismatch`,
  "`dynamics`.wr_ext declared Wrench{Float64}, fed from `wr_sum`.out::Wrench"
  (`scratch_survey/probe_out.txt`). Correction:
  `wr_sum::SumJunction{Wrench{Float64}, 3}`. One instance (grep `Wrench, 3`:
  1400 only). Clear.
- **F2. "Every mistake is loud" and "every silence inverted"** (1414–1415,
  1502–1503). A contributor added to an assembly whose output nobody wires is
  silent: unconnected outputs are legal with no warning (D-084 Position, log
  2543–2546; §6.1 1348–1349; the probe's empty warning list). The `in4`
  example holds only when the junction's arity already counts the forgotten
  contributor (probe: arity 4, three wires → `UnconnectedInput` naming `in4`).
  D-084 Rationale (log 2551–2553) places "a wire someone meant to draw" at the
  consumer's unconnected-input error, which presumes the slot. Two instances.
  Options in q8.
- **F3. "An `local_wires` pair"** (1241). Correction: "A `local_wires` pair".
  One instance. Clear.
- **F4. "sibling wire"** (1342, 1354). D-314 Position (log 13184–13185): the
  child-to-child kind of wire is a "local wire" in prose; D-303 bullet 3 made
  the rule. Correction: "local wire" at both. Two instances (grep `sibling` in
  1221–1509: 1342, 1354 only). Clear.
- **F5. One face, two names** (1439, 1449 `wr_b`; 1405–1407 `wrench`). The
  code block and §8.8 (3627, 3680) name the face `wrench`; `wr_b` is
  Flight.jl's suffix (`get_wr_b`). Correction: `wrench` at 1439 and 1449. Two
  instances (grep `` `wr_b` ``: 1439, 1449; `get_wr_b` at 1363 is a Flight.jl
  name and stays). Clear.
- **F6. The two sketches of the hierarchy disagree** (1403–1410 against
  1441–1451). The code has `Systems` wire its own total into a `dynamics`
  child; the idiom has each owner export its total and "the vehicle" wire the
  systems totals into Newton–Euler. FlightPhysics' `Vehicle` holds `systems`
  and `dynamics` as siblings (`aircraftbase.jl` 49–54). Both shapes are legal
  assemblies, so nothing is false; the example just does not show the idiom
  it sits beside. Leave as written, flag; q10 offers a one-clause bridge.
- **F7. "FlightCore's tree walk"** (1453). The generated
  `get_wr_b`/`get_mp_b`/`get_hr_b` are FlightPhysics' (`Dynamics`,
  `FlightPhysics/src/dynamics.jl` 15, 328–380), `@generated` functions summing
  over a FlightCore `Model`'s submodels. Correction: "FlightPhysics' tree
  walk". One instance (grep `FlightCore` in 1221–1509: 1453 only). Clear
  (lesson 25).
- **F8. "the admission rule §13.7 states"** (1472). D-313 Position (log
  13125–13130): a block joins "by judgement against three guidelines, none of
  them a requirement". Correction: "the inventory grows by the judgement
  against three guidelines that §13.7 states". One instance. Clear.
- **F9. D-007 cited** (1503, 1505). Superseded → D-037. Correction: drop
  D-007; D-037 stands alone at both. Clear (spec_style: never cite a
  superseded entry).
- **F10. D-167 cited** (1326). Superseded → D-263. Correction: cite D-295
  (and D-263). Clear.
- **F11. Reader-cold names and "today"** (1252–1260, 1363, 1418–1420,
  1449–1456, 1462–1463, 1478–1479). Part F lists each name with its owner;
  q3 rules them.
- **F12. Four Appendix C kinds unnamed** (§6.1). `PathResolution` (1279–1281),
  `TwoProducers` (1343), `UnconnectedInput` (1349–1357), and `UnknownPort`,
  whose condition §6.1 never states. Appendix C 12286–12310 cites §6.1 for all
  six. q7.
- **F13. The failure asymmetry's input side is conditional** (1329–1331). "A
  pin written at an entry whose consumer really promotes fails at the first
  nominal build" holds when a walking producer feeds the entry. Fed by a
  `Constant`, a discrete producer or a root input, the needless pin builds
  (probe: `Constant` into a `Pinned` entry builds). D-263 Rationale (log
  10434–10436) words it as a wire check "only when written". Leave as
  written, flag: the rewriter must neither sharpen nor drop the implied
  condition.
- **F14. "A pinned producer leaf, one declared `Pinned`"** (1294–1295).
  *Pinned* also covers `Int`/`Bool`/enum leaves and every discrete producer
  leaf (D-286 bullet 1; D-263 bullet 1; glossary *walked / pinned*). The gloss
  narrows by example only. Leave, flag.
- **F15. Glossary words in another sense.** "if the freeze is genuine"
  (1313): the glossary's *the freeze* is the roster freeze (spec 13728,
  `#g-the-freeze`), but the phrase is the `WalkingFaceAtFrozenEntry`
  message's (Appendix C 12304; `src/diagnostics.jl` 396). "awaiting a claim
  from above" (1353): the glossary's *claim* is a device's claim. "A bundle
  forces zero-filled identity noise" (1463): the glossary's *bundle* is a
  stage's argument `NamedTuple`. Bare "entry" (1288–1329): the glossary says
  *entry* is "never used bare", though rewritten §8.2 uses it bare in its
  input-contract context. Corrections: quote the two remedies verbatim as the
  message's text; "awaiting a wire from above"; "a bundled contribution
  struct"; "input entry" at first use in "Type-checking a wire". Clear.
- **F16. "governs a store, never a wire"** (1304). "store" is §9.5's write
  into a cell (D-264 Rationale log 10536–10543), not the glossary's *store*.
  Leave; do not link `#g-store` there.
- **F17. "Fan-out is free"** (1337). A root input's fan-out requires its
  consumers' concrete entries to agree at `Float64` (`RootInputTypeConflict`,
  D-236 bullet 3) and combines tolerance by a meet (D-168). The sentence is
  about producers. Leave, flag: do not generalize it.
- **F18. "the activation walk"** (1393). The glossary term is *leaf walk*
  (`#g-leaf-walk`, 2 body links), which §8.2 and §8.6 use. Correction: "the
  leaf walk". One instance (grep `activation walk`: 1393 only in the spec).
  Clear, low stakes.
- **F19. "(§3.3)" for exporting `out`** (1443). §3.3 (354–362) says an
  assembly holds boundary faces; it never mentions exporting a port. §8.6
  declares `output_wires`. Correction: "(§8.6)". Clear, low stakes.
- **F20. `wr_sum.out`** (1418). A dotted port path; §8.6's paths are
  slash-separated and dotted paths were rejected (D-040 Rejected: "false
  Julia-property affordance"). The code block writes `"wr_sum/out"` (1408).
  Correction: `"wr_sum/out"`. One instance. Clear.

Not problems, checked: the `Junction` block equals `src/blocks.jl`; the walk
violation's message carries both remedies as 1312–1313 says
(`src/diagnostics.jl` 393–396); `TwoProducers` fires across levels, as 1342–1344
says; the one-level rejection's message says "declared level by level (§6.1)";
`Constant` declares `out` pinned (D-312; `src/blocks.jl` 138), so 1487's wire
builds under a `Dual` activation; §8.6's fan-out example uses the same `trn`
faces as 1259–1260.

## F. Difficulty per section

| unit | difficulty | reason |
|---|---|---|
| A (opening, §6.1 context, paths) | medium | M3's reorder puts the declarations before the rule; M5 and M6 are declared additions (the locality law's name, `UnknownPort`, `PathResolution`); five reader-cold names in one example (q3); two bolds on one entry (D-207 sentence 1 and bullet 2, q4); F3; the **Why.** label and the term bold *total* to fold |
| B (type-checking, fan-in, unconnected ports) | high | the heaviest overlap in the chapter (§8.2 and §9.1 state and bold most of it); M1 and M2 trim without losing the phrases §8.2, tests and `src/` cite; the carried bold; M4's merge; two kinds to name; five bolds (D-236 bullet 1, D-264 twice, D-170, D-084); a superseded citation (F10) and three Rationale-only rulings; F13–F17's reserved-word and scope traps |
| C (§6.2) | medium-high | seven bolds over three entries, D-143 never cited before; five labels and four bold lead-ins to fold; the most Flight.jl names in the chapter (q3) and a companion addition (M9); M7 and M8; F1, F2 (q8), F5–F9, F18–F20; the code block's constructor gap (q10) |

Warnings for the rewriters:

- **Terms of art stay verbatim**: immediate child and one of its faces;
  one-level; level by level; the only currency; face graph; total; ceremony;
  re-export; generic seam; computed rather than typed; authored feed list;
  bound check; walk-compatibility clause, walk clause; walking, pinned,
  unpinned, tolerant; embed upward; opaque leaf; the producer's cell; gathered
  as stored; identity rule; marker scalar; declaration reading; failure
  asymmetry; first nominal build; build-time counterparty; lurks loudly, never
  silently; tier scope; correctness rule, not tidiness; fan-out; two-producers;
  double-feed; auto-bubbling; whole-tree; obligation, obligation chain;
  terminus; root input; junction, summing junction; fold; instance data;
  nominal port types; ownership boundary; owns contributors; exports the total;
  first-class signal; author-visible; positional order; named site-specific;
  configuration-variable; manifest; ragged; identity noise; "silently sum
  nothing"; guarded-addition sugar; zero-contributor; banned default;
  component clothing; declared structure.
- **Distinctions the log fought for.** "a store, never a wire"; "silent and
  consumer-declared" against "loud and assembly-declared"; "computed rather
  than typed"; "a whole-tree property, not a per-declaration one"; "the
  tolerant form a promoting consumer writes"; "ceremony, never silence";
  "strictly more explicit than a framework-canonical order"; "at *every*
  boundary rather than only at generic ones". A paraphrase that drops one half
  changes the rule.
- **Phrases quoted from outside** (part D's last list): keep each word for
  word. Most at risk: the two remedies and `WireTypeMismatch` (§8.2 2430
  points to §6.1 for them), "failure asymmetry" and "first nominal build"
  (tests), "marker scalar" (D-236, D-263 and `src/build.jl` cite §6.1 for it),
  and "obligation chain" (`src/assembly.jl`).
- **Lesson 16.** §8.2 2430 sends the reader to §6.1 for the bound check's kind
  and the remedies: §6.1 must state both, not point back to §8.2. §8.6 3203
  and §9.1 3760 send the reader to §6.1 for the obligation model: it stays
  stated. D-051 and D-143 call the silent-default ban "§6.1's": §6.1 must not
  cite them for it. D-065 calls the locality law "§6.1's": if q2 names it,
  §6.1 states it in its own words and cites D-065 for the name only.
- **The carried item.** "for a continuous consumer only" (1292) and the tier
  scope (1321) lose their bold; §8.2 2433 holds D-295 bullet 1's. Cite D-295,
  never D-167.
- **Antecedent hazards.** 1265 "The second consequence" needs the first
  (substitutability at every boundary, 1263–1264) before it after M3. 1271
  "The ceremony this costs" points at one-level routing; keep it after the
  reasons. 1298 "on the same terms" and 1316 "the clause" point at the walk
  clause: after M1 and M2 they must still follow it, not the tier-scope or
  run sentence. 1308 "Both sides" loses its antecedent when M2 moves the
  sentence: restate "the producer's declaration and the entry". 1328 "The same
  clause" must still read as the walk clause after M1's trim. 1342 "The rule
  spans levels" must follow the single-connection rule in M4's merged text.
  1438 "This is what replaces the tree walk" and "these ports" change
  antecedent if row 53 moves after the example; rewrite the sentence, do not
  move it bare. 1455 "They read as a manifest" points at "four junctions and
  fifteen wires": if M9 moves the count, the manifest sentence needs a new
  subject ("The junctions read as …"). 1476 "Ragged contributors" needs
  1462's "Contributors are ragged", which M8 keeps. 1493 "This is not the
  banned default" points at the `Constant` wire of 1486–1487.
- **Citations covering several clauses.** 1302's D-264 covers rows 15–16 only;
  row 17 needs D-264 in its own sentence once bold. 1319's D-236 covers the
  abstract case only. 1245's D-303 covers "wire"; "local wire" needs D-314
  beside it. 1428's D-037 covers the fold-order bullet only; rows 37, 54 and
  60 need D-037 in their own sentences. 1464's and 1484's D-037 cover
  Rejected-list content; 1486 and 1493 need D-143. 1349's D-084 covers the
  output half only.
- **Bold that duplicates another chapter's bold.** Today §6.1 bolds three
  rulings §8.2 or §9.1 already bold (the tier scope twice, the bound check's
  lead-in) and §6.2 bolds D-311, which §13.7 also bolds. `check_bold.jl` sees
  chapter 6 only once it joins `REWRITTEN` at landing; grep chapters 7–10 for
  `**` beside the entry before bolding (`scratch_survey/bold_rewritten.txt`).
- **The log's vocabulary is old.** D-207 says `child_connections`,
  `input_connections`, `output_connections`; D-170 `child_connections`; D-303
  `inner_wires` and "inner wire"; D-143 `output_types` and `h_xu`; D-167
  `input_types` and "root slot"; D-236 "Stratum A" and `init_x`; D-062
  `faces`; D-037 "generic boundaries". Never import them when citing an
  entry.
- **Reserved words** (Appendix D): bare "tier" means only the continuous or
  discrete side (the chapter's uses at 1292, 1321, 1324 and the code comment
  1379 hold); bare "cell" means only a signal-table entry (1300, 1324 hold);
  *seam*, *activation*, *nominal*, *contract*, *face* hold where used. "entry"
  is "never used bare" (F15); "claim", "bundle" and "the freeze" have glossary
  senses the chapter does not mean (F15); "store" at 1304 is §9.5's sense
  (F16). "first nominal build" (1330) is quoted by tests; keep it.
- **The `Model` vocabulary** (spec_style "Terms", D-317). The chapter says
  "the root build" (1355), "the root component" (1357), "configuration" (1427,
  1433, 1476, 1490) and "real models" (1467). None breaks the rule:
  "configuration" names an authored arrangement of the component tree, and
  "real models" names modeled systems at large. Do not turn "configuration"
  into "model", and say "the root" or "the component tree" for anything
  declared, wired or checked.
- **Glossary links reset per section.** One link per term per section, at
  first use. §6.1 links `#g-face` twice (1240, 1263): keep the first. Keep
  `#g-summing-junction` (its only body link in the spec), `#g-nominal` (one of
  two) and `#g-container-children` (one of three). First-use links to add:
  `#g-assembly` and `#g-root-input` in §6.1, `#g-abstract-entry` at 1316,
  `#g-guarded-addition` at 1467, `#g-constant-source` at 1486 (one other body
  link), `#g-leaf-walk` at 1393 if F18 is applied.
- **Flight.jl names** take one introducing clause that claims nothing beyond
  its source (lesson 14). Owners checked in
  `/Users/miguel/.julia/dev/Flight.jl/lib/`:

  | name | lines | owner, source | what a clause may say |
  |---|---|---|---|
  | `Cessna172` | 1252, 1257 | FlightApps, `c172/c172.jl` 763 (`const Cessna172 = Aircraft`, FlightPhysics' `AircraftBase.Aircraft{<:Vehicle}`) | an aircraft assembly named after FlightApps' Cessna 172 type. Not that it holds `systems` directly: in Flight.jl a `vehicle` level sits between |
  | `Systems` | 1253, 1258, 1400, 1404 | FlightApps, `c172.jl` 678 (fields `afm`, `aero`, `ldg`, `fuel`, `pld`, `pwp`, `act`) | the aircraft's systems assembly; §8.8 3624 says "an assembly whose children include `aero` and `ldg`" |
  | `Ldg`, its three legs, struts | 1253, 1259, 1439, 1449 | FlightApps, `c172.jl` 435 (`left`, `right`, `nose`, each a landing-gear unit with a `Strut`) | the landing-gear assembly, three legs, a strut each |
  | `trn`, `trn_field` | 1252–1260 | not Flight.jl names: Flight.jl passes terrain as an argument (`flight_case_studies.md` 33). `trn` holds a terrain field handle in `trim_environment_walkthrough.md` 303–311 | a terrain field handle (§4.4); `trn_field` is each leg's input entry |
  | `pwp`, `aero`, fuel | 1405–1407, 1450, 1462 | FlightApps, `Systems` fields: `pwp::P <: PistonThruster`, `aero::Aero`, `fuel::Fuel` | the powerplant, the aerodynamics, the fuel system |
  | `Wrench` | 1387, 1394, 1400, 1487 | FlightPhysics, `dynamics.jl` 114 (a force `F` and a torque `τ`, `Float64` there); walked under the parametrization pass (`migration_outline.md` 39) | FlightPhysics' force-and-torque pair, written at `Float64` and walked |
  | `get_wr_b`/`get_mp_b`/`get_hr_b`, "today", "the tree walk" | 1363, 1438, 1453 | FlightPhysics, `Dynamics` (`dynamics.jl` 15, 328–380): `@generated` functions summing over a FlightCore `Model`'s submodels | FlightPhysics' generated functions that sum wrench, mass properties and internal angular momentum over a model tree. Not FlightCore's (F7). `flight_case_studies.md` 30 holds the tree-walk → junction row |
  | "the C172" | 1454 | FlightApps' Cessna 172 models (`c172/`) | Flight.jl's Cessna 172 model; the count is its status quo (M9) |
  | `Vehicle{NoVehicleSystems}`, "bare-propagation" | 1478 | FlightPhysics, `aircraftbase.jl` 27–33, 49–54 (`get_wr_b` returns `Wrench()`, `get_hr_b` zeros: the identity methods of 1491) | FlightPhysics' vehicle with no systems, only kinematics and dynamics; D-143 Rationale (log 4864–4871) cites it with `aircraftbase.jl:27-35` |
  | `VehicleDynamics` | 1479 | FlightPhysics, `dynamics.jl` 406 | the vehicle's rigid-body dynamics component |
  | Newton–Euler | 1451 | — | the rigid-body equations of motion; §7.4 1891 uses the word bare |
  | loads monitor | 1420 | — (no source) | a component that monitors structural loads; claim nothing more |
  | `VehicleWrenchSum`, `sum_ports!` | 1431, 1466 | none: made-up example names | already introduced by their own sentences |
  | FlightCore | 1453 | the predecessor | needs nothing; but 1453's owner is wrong (F7) |

- **Code.** Three blocks, carried verbatim. F1 edits inline code in prose
  (1400), not a block. The `Junction` block's missing constructor waits on
  q10.

## G. Decisions at checkpoint 1

Settled for every chapter and not asked again: log repair rides track 2, and
bold marks one headline clause per ruling (recipe step 1, checkpoint 1).

**q1. "Type-checking a wire" against §8.2 and §9.1, and the carried bold.**
§8.2 2417–2446 states both clauses, the opaque leaf and the tier scope, and
bolds three of them; §9.1 3826–3835 bolds the bound check and the run. §6.1
repeats all of it, bolds two of the same rulings, and adds the abstract-entry
formula, the kinds, the remedies and the failure asymmetry. Options: (a) keep
the clauses stated plain in §6.1 (bound check with `WireTypeMismatch`; walk
clause with one tier-scope sentence citing D-295, M1; the run in one sentence
pointing to §9.1, M2), keep the abstract entry and the opaque leaf as the
section's own bolds, keep the violation, its remedies and the failure
asymmetry; (b) reduce the subsection to a pointer paragraph to §8.2 and §9.1,
keeping only the kinds, the remedies and the opaque leaf; (c) change nothing
but the duplicate bolds. Recommendation: (a). The Part I roadmap (spec
135–136) says Part I cites later parts for spellings only, which argues for
less mechanism; but §8.2 2430, 2511, 10071, `handle_walk_walkthrough.md` 64,
two tests and `src/build.jl` cite §6.1 for the clauses, the remedies, the
failure asymmetry and the marker scalar, and (b) would strand them. (c) keeps
a 64-word near-verbatim double of §8.2 2433–2439. Under (a) the carried item
is settled: "for a continuous consumer only" and the tier-scope sentence lose
their bold, and §8.2 2433 keeps D-295 bullet 1's. Remove the chapter-6 line
from README's "Carried to later chapters" at landing.

**q2. The locality law.** Four spec rows (10330, 10550, 10827; 9410 by way of
§14.2) and D-065's Position read "the locality law" as §6.1's; §6.1 never
names it. Options: (a) one declared clause at 1251–1252 naming "each assembly
speaking only of its own children" the locality law, citing D-065 for the
name and pointing to §14.2 for its other instances; (b) leave §6.1 as is and
let the inbound check mark the rows VAGUE for chapter 14 and track 2.
Recommendation: (a). The name and its "third instance" are recorded in a
Position (D-065, log 1912–1913), so the clause claims nothing new.
`tools/coinage_inventory.md` 85 lists *locality law* as a one- or two-use
coinage; with §6.1 naming it, it has five uses, past spec_style's
three-place threshold for a glossary entry. That entry is track 2, not the
rewrite.

**q3. The Flight.jl material.** spec_style: "Flight.jl machinery used as if
known moves to a companion, or the spec says what it is." Per item (owners
in part F's table):

| item | lines | proposal | why | destination holds it? |
|---|---|---|---|---|
| `Cessna172`, `Systems`, `Ldg`, legs, `trn`, `trn_field` | 1252–1260 | keep, one introducing clause: an aircraft assembly named after FlightApps' Cessna 172, its systems assembly and its three-legged landing gear, routing a terrain field handle `trn` (§4.4) | the example is the one-level rule's only illustration; §8.6 3145 reuses `trn` | — |
| `get_wr_b`/`get_mp_b`/`get_hr_b`, "today" | 1361–1364 | keep one clause: "In Flight.jl these are FlightPhysics' generated `get_wr_b`/… functions, which sum each quantity over a model tree" | context for "the tree walk" at 1438 and 1453 | `flight_case_studies.md` 30 holds the mapping row; it stays |
| "FlightCore's tree walk" | 1453 | "FlightPhysics' tree walk" (F7) | owner checked in the source | — |
| the C172 count | 1454–1455 | move to `migration_outline.md`, expanding the row "The contributor survey feeding the aggregation chains" (18) (M9); §6.2 keeps "one visible junction at the level that owns the contributors" and the manifest sentence with a new subject | a Flight.jl status-quo measurement used as if known | no: row 18 records only "mechanical to extract from today's trait implementations" |
| the body frame | 1458–1459 | keep, "unchanged" → "as in Flight.jl" | a sum of wrenches is meaningful only in one frame, so the sentence says what the idiom needs | — |
| `pwp`, `aero`, fuel | 1405–1407, 1450, 1462 | gloss `pwp` at first use ("the powerplant"); the census leaves under q9 | FlightApps field names | — |
| `Wrench` | 1387 on | gloss at first use in §6.2: FlightPhysics' force-and-torque pair, written at `Float64` and walked | spec 2063 uses it bare | — |
| `Vehicle{NoVehicleSystems}`, `VehicleDynamics`, "bare-propagation" | 1478–1479 | keep, one clause each: FlightPhysics' vehicle with no systems; its rigid-body dynamics component | D-143's grounding example | — |
| Newton–Euler, loads monitor | 1451, 1420 | one clause each (rigid-body equations of motion; a component monitoring structural loads) | aerospace examples | — |

Options: (a) as the table; (b) keep everything in place with introducing
clauses, moving nothing out; (c) move the whole tree-walk contrast (1361–1364,
1438, 1453–1459) to `flight_case_studies.md` section 1. Recommendation: (a).
(c) would leave §6.2's idiom with nothing to say what it replaces; the count
alone is status quo.

**q4. One-bold readings.** (i) D-207 bullet 2 joins "the face graph is
total" and "the `Build` retains it" with "and"; §9.2 4032 bolds the retention
(with D-315). Options: (a) two rulings, §6.1 bolds totality; (b) one ruling,
bold at §9.2, §6.1 plain. Recommendation: (a), the reading chapter 7's R4
gave D-231; record it in `brief.md`. (ii) D-048 bullet A is bold at §9.1 3787;
§6.1 1352 bolds the whole-tree check. Options: (a) plain in §6.1, citing
D-048; (b) read "global wiring + obligations" as its own ruling and bold it in
§6.1. Recommendation: (a). A dash list inside one bullet is one ruling by the
mechanical test, and the check's timing is §9.1's to bold. (iii) D-170's last
chained ruling ("every right side fed exactly once"), plain at §8.6 3156.
Options: (a) bold in §6.1 at the single-connection rule; (b) leave it plain
everywhere. Recommendation: (a): §6.1 states it as a rule, Appendix C and
`src/` messages cite §6.1 for it. (iv) D-264's two sentences: bold both in
§6.1. §8.2 2427 and §9.5 4634 state the wire half plain, the second pointing
to §6.1.

**q5. D-311's bold.** §6.2 1386 and §13.7 10004 both bold it. Options: (a)
§6.2 keeps the bold on bullet 3 (the nominal type and the arity); §13.7's goes
on README's carry list for chapter 13; (b) §6.2 plain, §13.7 the home.
Recommendation: (a). The junction is defined in §6.2; `src/blocks.jl` 15–41
and `test/test_blocks.jl` 414 cite §6.2 for it; D-311's Spec field lists §6.2
first. Chapter 13's rewrite also inherits the unbolded D-062 doctrine ("library
blocks are ordinary components", 9997, no citation).

**q6. Orders and labels.** (i) M3: the three declarations before the rule.
(ii) M4: merge "Fan-out and fan-in" (69 words) and "Unconnected ports" (108)
into one `####`, "One producer per input", since "exactly once" is at most
once (`TwoProducers`) and at least once (`UnconnectedInput`). Inside it, one
declared sentence may say both checks are whole-tree, decided at the root
(D-048 Rejected), which settles §9.1 3760's VAGUE row. (iii) §6.2: a roadmap
sentence in the opening; M7 (the library's seed beside the junction); row 53
after the example; shorter labels "Zero contributors" and "The cost". (iv)
M1 and M2's order inside "Type-checking a wire" (part C). Options: (a) all;
(b) only the define-before-use fixes (M2's position, M3, M7); (c) none.
Recommendation: (a). No row names a `####` label, and each order was checked
in part C.

**q7. Appendix C kinds** (lesson 20). Options: (a) name `PathResolution`
(1279–1281), `TwoProducers` (1343) and `UnconnectedInput` (1349–1357) where
their conditions are stated, and add one declared clause for `UnknownPort`
in "How far a path may reach": an endpoint naming no face of the child it
resolves to is `UnknownPort`, with that child's face list in hand (Appendix C
12286–12289; D-113 Position bullet 1, log 3437–3439); (b) the three only,
leaving `UnknownPort` to §8.4 w1, which Appendix C also cites; (c) none.
Recommendation: (a). Appendix C makes §6.1 an owning section of all six, and
the probe raised each on §6.1's condition. §6.2's two error mentions (1415–
1416) stay unnamed; §6.1 is their home.

**q8. F2, "every silence inverted".** Options: (a) scope both passages to the
junction's own bookkeeping: 1415 "A contributor the junction counts but
nobody wires is an unconnected-input error naming `in4`", 1503 "with every
silence in the aggregation's bookkeeping inverted into a warning or error",
and one plain sentence citing D-084 that a contributor output nobody wires
stays legal and silent, like any unconnected output; (b) leave both as
written, flagged, and send the owner a design question (should an unwired
contributor be detectable?); (c) leave as written. Recommendation: (a).
D-084's Position settles the fact and its Rationale already places the
information at the consumer; the correction narrows a claim and changes
nothing the framework does. (b) would ask the owner to reopen D-084.

**q9. Adversarial passages.** spec_style sends "why alternative X loses" to the
log. Candidates: 1462–1463, the raggedness census against bundling (D-037
Rejected and its annotation carry it word for word, migrated from §6.2 on
2026-08-15); 1369–1370, the absent mechanisms (D-037 Rejected); 1505–1506,
"Consumer-declared folds with multi-connection legality are closed" (one
verdict sentence, already reduced to its entry). Options: (a) cut the census
to D-037 (M8), keeping 1461's rule, "Contributors are ragged" and 1463–1464's
hazard clause; keep the other two; (b) keep all; (c) (a) plus cutting
1505–1506. Recommendation: (a). The census litigates a rejected design that
the log already holds, and cutting it removes `pwp` and fuel from the prose.
1369–1370 states what the design lacks, and 1505–1506 is already one cited
sentence.

**q10. Clear factual corrections, ruled before writing** (lesson 13; each
grepped for every instance, lesson 19):

1. F1 (1400): `wr_sum::SumJunction{Wrench{Float64}, 3}`. Evidence: D-311
   bullet 3; 1387; the probe's `WireTypeMismatch`.
2. F3 (1241): "A `local_wires` pair".
3. F4 (1342, 1354): "local wire" for "sibling wire". Evidence: D-314
   Position.
4. F5 (1439, 1449): `wrench` for `wr_b`. Evidence: 1405–1407; §8.8 3627, 3680.
5. F7 (1453): "FlightPhysics' tree walk". Evidence: `FlightPhysics/src/dynamics.jl`
   15, 328–380.
6. F8 (1472): "the inventory grows by judgement against the three
   guidelines §13.7 states". Evidence: D-313 Position.
7. F9 (1503, 1505): drop D-007; D-037 alone. Rebaseline `check_rows.jl` at
   landing.
8. F10 (1326, or its M1 successor): cite D-295 (with D-263), not D-167.
9. F15: the remedies quoted verbatim as the message's text (Appendix C
   12304); "awaiting a wire from above" (1353); "a bundled contribution
   struct" (1463); "input entry" at first use in "Type-checking a wire".
10. F18 (1393): "the leaf walk". F19 (1443): "(§8.6)". F20 (1418):
    `"wr_sum/out"`.
11. The `Junction` block and 1389's `Junction{In, Out, N}(f)`: (a) leave the
    block verbatim and add "which infers `F`" to 1389's sentence (D-311
    bullet 1); (b) add `src/blocks.jl` 35's constructor line to the block.
    Recommendation: (a). The block stays an excerpt of `src`, and the
    sentence carries the one fact the block lacks.

Leave as written, flagged: F6 (the two hierarchy sketches; a bridge clause
would describe the example, not correct it), F13 (the asymmetry's implied
walking producer), F14 ("one declared `Pinned`"), F16 ("a store" in §9.5's
sense), F17 ("Fan-out is free").

**q11. The units.** Three units as in part C: A 501 words (1221–1282), B 656
(1283–1358), C 1,024 (1359–1509). Options: (a) as proposed; (b) four, C split
at 1436 into C1 and C2 (512 each), with M7 crossing into C1; (c) two, A and B
joined (1,157). Recommendation: (a). B carries the chapter's hardest
overlap and stays small; C's moves are all inside it.

Carried out of the chapter at landing (README's "Carried to later chapters"
and track 2), whatever the rulings:

- **Chapter 13.** §13.7 10004 bolds D-311, which §6.2 bolds (q5); §13.7's
  "Two demonstrated needs admit `Constant` under the inventory's
  demonstrated-need charter" (10094–10095) predates D-313's judgement.
- **Chapter 14.** §14.2 10342–10345 says §6.1's law "is convention … rather
  than machine-checked"; §6.1 and D-207, D-061 and D-130 make the wiring rule
  machine-checked. §14.10 11382, 11425 and 11544 cite superseded D-167.
- **Appendix D.** *generic holding* (12750) cites §6.1, which no longer
  states it; *local wire* (12760) cites §6.1 for "one end on the boundary",
  which D-314's Rationale states.
- **Track 2.** Annotations to D-037 ("generic boundaries"), D-061, D-062,
  D-065, D-073 and D-143 (part E); Positions owed for part E's eleven
  Rationale-only rulings; a glossary entry for *locality law* if q2 rules
  (a); `inbound_periphery_walkthrough.md` 159's "see §6" → "see section 6";
  `test/test_build.jl` 764 and `src/build.jl` 511 cite §6.1 for what §9.5 and
  §9.3 state.
