
## 4. Notes

Greps (lesson 42). Each proposed bullet was grepped over every Position in
the working tree's log (`positions.txt` in `scratch_track2/2/`).

- Dropped, D-106's first clause: "All write-surface checks move to staging
  and the drain is pure application". D-044's Position already states it:
  "all checks run at staging and the drain checks nothing". D-374 leaves it
  out, and §11.4's "the drain is pure application" cites D-044 beside D-106
  (3.18) in place of D-374.
- Dropped, D-174's drain-last convention: D-096's Position states it, and
  B-21 settled that citation. D-370 has no bullet for it, and §11.3's
  drains-last bold gains no citation.
- Kept after the grep, with the near misses named in each Rationale: D-201
  (the terminal account's window) beside D-369; D-250 (where
  `EmptyGreedyClaim` lives) and D-310 bullet 2 (front ends attached by hand)
  beside D-370; D-216 (one case of `BindingContractMismatch`) beside D-371;
  D-030 (the predecessor's `should_close` path) beside D-373; D-068 (coverage
  enforced before writing) beside D-376. D-044's and D-045's Positions carry
  the derived interactive surface and "slot unclaimed", but D-174 superseded
  those halves and their annotations say so, so D-370's harness-surface and
  liveness bullets stand. D-109 is the only Position stating identity and
  admission, and it is superseded.

Sources citing the spec back (lesson 43). None dropped. D-138's "close only
what is open" is the obligation D-138 creates ("a new taught obligation",
§11.6 naming where it is taught), not a borrowed authority. D-177's empty
enumeration is stated in D-177's own words. D-310's survival sentence was
ruled a source in B-49.

Owner and orchestrator items, not applied:

- D-268's two tolerance bolds in §11.6 ("The same tolerance covers a repeated
  call", "…a call with no `init!` before it") cite D-268, whose Position takes
  "close only what is open" from §11.6. D-372 now records the phrase from
  D-138. Citing D-372 beside D-268 there would be a new pairing the prompt
  did not rule.
- §11.6's bold "`map_input`/`map_output` are, precisely, conventions of the
  author-owned loop idiom" cites D-177, and only D-177's Rationale states it.
  B-48 did not list it, so D-371 has no bullet for it.
- §11.4's renormalization paragraph ("The recompilation has one edge case")
  cites no entry. D-370's harness bullet states the seam, but the rule cites
  a new entry only beside its source, so it stays uncited.
- B-50's locator, "the frame index of its last drain", now reads "the frame
  index of the last drain on the live trace" after the landing. The
  sentence is unique, and D-260 went beside D-217 there (3.20).

Wording choices in the entries, each held to its source:

- D-369's take bullet says "the take on a quiet frame allocates nothing"
  where D-136 says "a quiet frame allocates nothing", because D-241 amended
  the status's allocation and the take's claim alone survives.
- D-370 and D-376 use "root input" for their sources' "root slot" and "slot",
  and say so in their Rationales.
- D-375 says "two-part check": D-109's three-part check less the affinity
  check that D-310 withdrew.
- D-376's Rejected items drop D-068's "§11.3" before "bare-types" rather
  than repeat or remap it: §11.3 now cites §8.2 for bare types.

Battery before the commit: `linkify.jl` (linked the citations, added the
Index rows and link definitions), then `check_refs.jl` OK (one standing
self-vs-spec advisory), `check_rows.jl` OK (D-367 to D-376 newly cited, no
coverage drop, no rebaseline), `check_glossary.jl --strict` OK (three
standing advisories), `check_bold.jl` OK (chapter 11: 78 bold spans), and
`linkify.jl` again a no-op (file hashes equal before and after).
