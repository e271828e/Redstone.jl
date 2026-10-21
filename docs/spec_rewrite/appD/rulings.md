# Appendix D: the rulings

The three checks of `../appendices.md` ("Appendix D: citations, gaps and
length"), run at `4004522` on 2026-10-21.

## Method

1. **Citations and length.** Seven read-only Opus agents over the ten
   groups, one TSV row per citation, one accuracy row per entry and one
   length row per entry over the cap (`survey_brief.md`). The rows are in
   `survey/S1.tsv` to `survey/S7.tsv`, each with a proposals file of
   replacement entries.
2. **Gaps.** Five read-only Sonnet agents over chapters 1 to 14, one TSV
   row per candidate term (`gaps_brief.md`), in `survey/G1.tsv` to
   `survey/G5.tsv`. I triaged every `C` and `sense` row.
3. **Assembly.** One Opus agent assembled the new appendix from the
   proposals and these rulings (`survey/changes.tsv`): 69 entries replaced,
   20 added, 8 given sub-terms, 2 moved. It rejected four proposals, each
   for a claim the frozen spec words otherwise.
4. **Body links.** `check_glossary.jl --strict` needs every anchor linked
   from the body. `survey/sites.py` listed each new term's first use per
   section, and one Opus agent linked 143 of them and glossed 38
   (`survey/links.tsv`). It skipped 17 hits where the word had another sense.
5. **Verification.** A fresh Opus verifier checked every changed or added
   sentence and every dropped clause against the frozen spec
   (`survey/verify.tsv`). It found one wrong claim (*read set* has two
   senses), three miscitations and three entries out of order, two of them
   at the base. All seven are fixed.

## Rulings

- **R1. The cap is 60 rendered words.** That is about the 75th percentile
  at the base, so 38 of 175 entries went over it. Words are counted with
  the anchor, the citations and the link markup dropped. A clause left
  only where its owning section states it. The definition never went.
- **R2. A usage note stays where it is true of the text.** The glossary is
  the place to say how the spec uses a word: *entry* in its compounds,
  bare *tier*, *frame* in the aircraft sense, *primitive* and *leaf* as
  synonyms. A note about the log's own conventions went with `g-row`'s
  second sentence, since `decisions_style.md` is its home.
- **R3. An entry follows its owning section, and the log is no home.**
  Where only a log entry states a claim, the claim went: `g-structure`'s
  "with their types" (D-315 alone), `g-execution-order`'s "ordering names
  the activity" (D-258 alone, which still says `Dataflow`), and the history
  of `z` in `g-the-letters` (D-173 alone).
- **R4. Bold inside an entry marks a sub-term only.** The lead's "the
  owning section wins" and `g-bundle`'s "iff" lost their bold. Sub-terms an
  entry defines keep it, as *sweep* bolds interior sweep and boundary
  sweep.
- **R5. An entry sits in the group of its owning section.** `g-selector`
  and `g-leaf-address` moved from D.6 to D.8, since §14.4 owns both.
- **R6. A new entry needs a coined name used in three or more sections,
  one of which does not define it.** The coinage inventory's "three or more
  places" counts sections, not occurrences: a term repeated inside one
  section is that section's local coinage. Standard vocabulary
  (hyperperiod, integrate-and-dump, scatter and gather) and plain words in
  their plain sense (incumbent, didactic, side) take no entry.
- **R7. A candidate an existing entry already owns joins it as a
  sub-term.** *Frame top* joins *frame*, *event round* joins
  *quiescence*, *arrival sweep* joins *sweep*, *terminal snapshot* joins
  *snapshot*, *probe chain* joins *probe*, *nominal evaluation* joins
  *nominal*, the published-boundary ordinal joins *boundary counter*, and
  the wiring entry and the `sample_times` entry join *entry*.
- **R8. The arrival sweep is named, not classed.** §10.4 links it to
  *sweep*. The spec says it closes the integration step and runs before
  the boundary sweep refreshes any discrete cell. It never says which
  variant it is, and the entry does not either.
- **R9. *view* has two senses.** §5.2 calls every bundle field a view, and
  §7.1 and §5.3 call a state view a reconstruction of a store. The entry
  states both.
- **R10. A dropped log-only claim keeps a ruling's last spec citation.**
  D-258 is the ratified naming ruling for *execution order* and *schedule*,
  and the glossary was the spec's only citation of it. Both entries cite it
  again. D-173 lost its only citation with the history of `z`. It is
  superseded and the spec never cites a superseded entry, so the row
  baseline was regenerated without it.

## New entries

Each from the `G` rows, in the group of its owning section:

| term | group | defined at |
|---|---|---|
| auto-bubbling | D.1 | §6.1 |
| bound law / walk clause | D.1 | §6.1, §8.2 |
| branch-shape rule | D.1 | §8.3 |
| export chain | D.1 | §11.7 |
| locality law / one-level rule | D.1 | §6.1 |
| opaque leaf | D.2 | §4.3 |
| fused idiom | D.3 | §5.3 |
| hand-down | D.3 | §5.3 |
| hop / dead hop | D.3 | §5.4 |
| boundary sequence / macro-sequence | D.4 | §5.3, §10.6 |
| trial evaluation | D.4 | §10.4 |
| shadowing check | D.5 | §8.1 |
| door | D.6 | §12.6 |
| heartbeat | D.6 | §11.8 |
| inspection read / integration read | D.6 | §11.2 |
| levels doctrine | D.6 | §11.4 |
| tail | D.6 | §12.4, §13.6 |
| fingerprint | D.7 | §11.5 |
| read set | D.8 | §14.7 |
| stopped-sim | D.8 | §14 |

## Left out on purpose

- Local coinages, one section each or two at most, which keep their
  inline gloss: the gate form, blocked event, constraint pool, canonical
  residue, grid diagnostics, pairing by name, convert-on-write, store
  form, probe-scoped, deliberate stripping, hybrid sleep-then-spin,
  event registers, the FFI door, fan-out meet, step barrier, framing,
  service walk, guarded sequence, pre-sweep doctrine, probe-value barrier,
  committed-state residuals, shim, port view, unmask point, state what-if,
  tail residue, run's-end sweep, sticky stopped status, the epoch rule and
  the re-anchor. The remedy ladder and the granularity guideline have
  three uses each, too few to earn one.
- `g-guarded-addition`'s "recorded with its shape so adoption stays
  additive", which no section states. The spec says "additive" only of
  recorded-not-built extensions (§14.10).
- `D-276`'s Position calls the leaf address a selector's second argument,
  and its own example contradicts it. The log lags the spec, so the entry
  follows §14.4 and the log keeps its slip.

## Loose fixes in the chapters

- §9.2 cited §9.4 for the nominal activation being the only one that runs
  in real time; §9.5 states it, and the citation now points there.
- §13.1 glossed probes as "the build's single evaluations of a user
  function", the old entry's words, which §9.4 contradicts. The gloss now
  follows the new entry.
- `tools/coinage_inventory.md` mapped the epoch rule to *input epoch*,
  which §10.6 says it is not, and mapped the levels doctrine to an entry
  that did not exist. Both rows are corrected.
