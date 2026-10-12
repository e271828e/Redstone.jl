# Chapter 6: inbound-citation check — 2026-10-12

The check judged all 131 rows of `inbound.tsv` against `chapter_new.md`, at
the base `b08afca`. Each row's verdict and note are in `inbound_check.tsv`.
Line numbers marked "new" are lines of `chapter_new.md`. Spec and log line
numbers are at the base.

## Counts

| verdict | rows | pre-existing |
|---|---|---|
| OK | 117 | 6 of them pre-existing problems the rewrite fixed |
| VAGUE | 9 | 9 |
| MISSING | 3 | 3 |
| RETARGET | 2 | 2 |
| COMPANION | 0 | 0 |
| **LOSS** | **0** | — |

The rewrite causes no new non-OK row. Every non-OK row was already wrong
against the old chapter (survey part D), except log 3859 (D-125 Rejected).
The survey missed that row, but it was equally wrong against the old text.

## Pre-existing rows the rewrite fixed

- spec 3762 (§9.1, "decidable only at the root … (§6.1)"). This was VAGUE.
  R5's added sentence fixes it (new 154–156): "Both this check and the
  two-producers check are decided at the root, since neither is decidable
  below it (D-048)".
- spec 10330 (§14.2, "the locality law … §6.1 states"), spec 10550 (§14.4),
  spec 10827 (§14.7, "the locality scopes") and log 1913 (D-065 Position,
  "locality law = §6.1's"). These were MISSING. R2 fixes them (new 41–44).
  §6.1 now names the locality law, cites D-065 for the name and points to
  §14.2.
- spec 12836 (glossary *constant source*, "instance data, never a default").
  This was VAGUE. Two §6.2 sentences now carry it: "publishes a value its
  instance holds" (new 314–315) and "not the banned default … but its
  opposite" (new 321–322).
- Appendix C rows for `UnknownPort`, `UnconnectedInput`, `TwoProducers` and
  `PathResolution` (spec 12286, 12290, 12294, 12306). R6 now names each kind
  where §6.1 states its condition (new 31–32, 159, 149, 80–81). These rows
  were OK in substance before.

## Non-OK rows

### MISSING (3, all pre-existing, none a LOSS)

1. **spec 10342 (§14.2)**: "The enforcement status carries over from §6.1 as
   well. The law is convention … available and idiomatic rather than
   machine-checked."
   - Evidence: §6.1 says the rule is enforced in `resolve` and that an
     endpoint reaching past the immediate child is a `PathResolution` error
     (new 78–82). The old text said the same (old 59–61).
   - The rewrite sharpens the contradiction. New 41–43 now calls the
     enforced rule "the locality law", so §14.2 says the law named in §6.1 is
     not machine-checked, while §6.1 says it is.
   - Fix at the citing site, in chapter 14's rewrite. One possible wording:
     "Wiring's instance of the law is enforced in `resolve` (§6.1). This
     instance is convention, because ownership is a fact about who maintains
     the code, and the build cannot see it." No chapter 6 edit.
2. **log 1927 (D-065 Rejected)**: "*Machine-enforced ownership:* not
   build-visible; same convention status as §6.1."
   - Evidence: as row 1. §6.1 now cites D-065 (new 43), so a reader
     following that citation meets this bullet.
   - The bullet is about fragment ownership, and the claim §6.1 cites D-065
     for (the name) is in the Position. So this is no lesson-16 loop.
   - Fix: track 2 annotates D-065. The survey's part D already plans this.
3. **log 2184 (D-073 Position)**: "§6.2's `SumJunction` dispatches on its
   unparametrized type constructor."
   - Evidence: D-311 bullet 3 rules the nominal type, "never an unparametrized
     constructor". F1 (R9) removed the last trace (old 180,
     `SumJunction{Wrench, 3}`). New 197 and 225 both read
     `SumJunction{Wrench{Float64}, 3}`.
   - This is a ruled correction, not a LOSS.
   - Fix: track 2 annotates D-073.

### VAGUE (9, all pre-existing)

1. **spec 2064 (§8.1)**: "Arity is spelled in the type, at the price §6.2
   states openly."
   - Evidence: §6.2 states this price only indirectly. A stale arity surfaces
     as an unconnected-input or single-connection error, and "the bookkeeping
     is ceremony, never silence" (new 239–242). "At the price of hard-coding
     it into a type" (new 258) is the price of the named site-specific
     junction.
   - Fix at the citing site (chapter 8's carry list): "Arity is spelled in
     the type, and a stale arity fails loudly at build (§6.2)."
2. **spec 2521 (§8.2)** "traced through the face chain (§6.1, §11.3)" and
   **spec 9435 (§13.3)** "the face chain is the route (§6.1)".
   - Evidence: §6.1 says "face graph" (new 64) and "obligation chain" (new
     160). It never says "face chain". The substance holds.
   - Fix at the citing sites. For 2521: "each traced down its chain of
     `input_wires` entries (§6.1, §11.3)". For 9435: "because the face graph
     is the route (§6.1)". No chapter 6 edit, because "face chain" would be a
     third name for things the chapter already names.
3. **spec 12760 (glossary *local wire*)**: "an input wire and an output wire,
   each of which has one end on the boundary (§6.1, D-303, D-314)".
   - Evidence: §6.1 names the three declarations (new 22–28). "One end on the
     boundary" is D-314 Rationale's phrase, not the chapter's. The substance
     holds: an `input_wires` entry routes the assembly's own face to a
     child's face.
   - Fix at the citing site (Appendix D or track 2): keep the citations as
     they are, or move §6.1 after D-314. The chapter needs no new claim.
4. **log 1814 (D-060 Rejected)**: "§6.1's knowledge rule applied to reads".
   - Evidence: "knowledge rule" is no name in §6.1. Since R2, §6.1 names its
     content, "each assembly speaking only of its own children", the locality
     law (new 41–43). This is improved but not fixed.
   - Fix: none needed. It is the log's vocabulary of the day. Track 2 may
     annotate it.
5. **log 1822 (D-061 Position)** "enforcing §6.1's generic-boundary rule",
   **log 1834 (D-061 Rejected)** "§6.1 unenforceable where paths are actually
   resolved", and **log 6195 (D-172 Rejected)** "§6.1's generic-seam rule".
   - Evidence: since D-207, the generic-seam stop is the universal one-level
     rule (new 30–33), and generic holding is §8.8's and §13.3's.
   - The new §6.1 cites D-061 (new 80) for the walk over declared field
     types, which D-061 states itself. So there is no loop.
   - Fix: track 2 annotates D-061 (the survey already plans this). The D-172
     bullet is history.
6. **log 3859 (D-125 Rejected)**: "§6.1 forbids the traversal even where the
   concrete instantiation would resolve it". The survey did not list this
   row.
   - Evidence: the bullet is about *service* deep paths past generic seams.
     §6.1 governs wiring endpoints. The rule against traversal for service
     paths is §13.3's generic-holding rule. The old chapter was equally
     silent on it.
   - Fix: track 2 annotation pointing to §13.3, or leave as history. It
     belongs to the same family as item 5.

### RETARGET (2, both pre-existing)

1. **spec 12750 (glossary *generic holding*)**, citing §8.8 and §6.1.
   - Evidence: generic holding is §8.8's (3719–3725) and §13.3's
     (9382–9393). §6.1 only says that faces are the only currency crossing a
     boundary (new 60–62).
   - Fix at the citing site: drop §6.1. §8.8 is already the first citation.
     This belongs to Appendix D's rewrite or track 2.
2. **`companions/inbound_periphery_walkthrough.md` 159**: "# no checks — see
   §6" in a code comment.
   - Evidence: the comment means the walkthrough's own section 6, "The
     write-surface rule", not the spec. spec_style reserves `§` for spec
     citations.
   - Fix at the citing site: "see section 6" (track 2).

## Lesson 16 checks

- **§8.2 at spec 2430** sends the reader to §6.1 for the bound check's kind
  and the walk violation's remedies. §6.1 states both:
  - `WireTypeMismatch` (new 93).
  - Both remedies, quoted word for word from Appendix C (new 128–130):
    "remove the entry's `Pinned` if the consumer promotes; feed it from a
    non-walking source if the freeze is genuine".

  The rewrite cut the tier scope's reason to a pointer at §8.2 (new 99–101).
  §8.2 states that reason itself at 2433–2439 ("A discrete stage reads
  exclusively at real ticks … A `Dual`-carrying cell exists only inside
  activations discrete stages never run in"). The pointer does not loop.
- **D-065** (new 43). §6.1 cites it for the name "locality law" only, and
  states the rule itself under D-207. D-065's Position points back with
  "locality law = §6.1's" and gives the content. The rule is stated at §6.1,
  so the reader is not sent round in a circle. D-065's Rejected bullet
  contradicts §6.1 (MISSING item 2 above).
- **D-143** (new 313, 322). It points to "§6.1's banned default". §6.1
  states the ban plain at new 153 and does not cite D-143. No loop.
- **D-061, D-062, D-236, D-263, D-311 and D-037**: each mentions §6.1 or
  §6.2, but never as the only home of the claim the chapter cites it for.
  The other new citations do not mention chapter 6 outside their Spec field:
  D-048, D-078, D-085, D-113, D-130, D-208, D-211, D-286 and D-313.

## `src/` and `test/` phrase check

I ran `rg -n '§6\.[12]|§6\b' src test` on the working tree. It found 56
lines: 30 in `src`, 26 in `test`.

### Messages a user reads

Every phrase these messages quote survives in the new chapter.

| site | quoted phrase | new chapter |
|---|---|---|
| `src/diagnostics.jl` 346 | "every input is fed exactly once, by a local wire or by an `input_wires` chain ending at a root input face (§6.1)" | a paraphrase, held in substance at new 144, 157–162. "Either a local wire or an `input_wires` entry" (new 157–158) now matches the message's "local wire", which F4 restored (the old text said "sibling wire") |
| `src/diagnostics.jl` 361 | "every input takes exactly one connection, across levels included (§6.1)" | "exactly one connection" word for word (new 144). "The rule spans levels" (new 147) |
| `src/diagnostics.jl` 396 | "remove the entry's `Pinned` if the consumer promotes; feed it from a non-walking source if the freeze is genuine (§6.1, §8.2)" | word for word at new 129–130. The old text paraphrased it; R9's F15 made the match exact |
| `src/diagnostics.jl` 473 | "a connection endpoint names an immediate child and one of its faces … declared level by level (§6.1)" | "immediate child and one of its faces" (new 30). "Level by level" (new 41) |
| `src/diagnostics.jl` 475 | "one child segment, plus the key segment where the child is a container element, and nothing further (§6.1, §13.3)" | a paraphrase, held at new 34–37 ("keep their key segment … one level and not two") |
| `src/diagnostics.jl` 751 | "the segment grammar that reaches those children … (§8.5, §6.1, D-212)" | held at new 34–37, as before |

### Comments and test names

All of these hold.

- `src/assembly.jl` 282 and 350: "immediate child and one of its faces", "one
  level, not two".
- `src/assembly.jl` 959 and 979: "obligation model" and "obligation chain".
  "Obligation chain" is at new 160. "Obligation model" was never a chapter
  phrase.
- `src/assembly.jl` 1205: "the rule spans levels" (new 147).
- `src/build.jl` 856: "The marker scalar (§6.1, §9.1)" (new 105).
- `test/test_build.jl` 567: "§6.1's failure asymmetry" (new 134).
- `test/test_build.jl` 681: "the walk clause fails at the first nominal build"
  (new 104, 135).
- `test/test_leaves.jl` 344: "§6.1's bound check" (new 87).
- `test/test_assembly.jl` 1015: "an unconnected output, and legal" (new 164).
- `src/blocks.jl` 20: "positional order", "weighted blend or a
  mass-properties composition, is written at the site" (new 200–202, 251).
- `test/fixtures.jl` 157: "an explicit, ordered entry".

### Pre-existing mismatches

None comes from the rewrite. All belong to the implementation side, in track
2.

- `src/build.jl` 511 cites "`probe_value` (§6.1, …)", and `test/test_build.jl`
  764 cites "a bundle's field names are part of the entry's type (§6.1,
  D-238)". §6.1 states neither, in the old text or the new. The survey's part
  D lists both.
- `test/test_linearize.jl` 334 says "a discrete consumer's entries pin
  wholesale (§6.1, §8.2)". Neither the old §6.1 nor the new one says this.
  §6.1 says "pins wholesale" only of a discrete *producer* of a handle (new
  121). The tier scope sits at new 99–101, and its reason at §8.2.
  - The comment also cites §8.2, so it stays usable.
  - The survey judged this row "holds". Under the strict reading it is loose.
- `test/test_blocks.jl` 449 cites §6.2 for the `Pack` junction. §6.2 never
  mentions `Pack`, before or after the rewrite. It is §13.7's.

## Proposed edits to the chapter itself

None is required. One is optional:

- **New 159**: "The error, `UnconnectedInput`, fires at the root build" would
  become "The unconnected-input error, `UnconnectedInput`, fires at the root
  build".
  - Spec 2412 and 2882 cite "the §6.1 unconnected-input error". Today that
    phrase appears only in §6.2 (new 240). The old §6.1 lacked it too.
  - The edit is wording only and adds no claim.
