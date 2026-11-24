# The rates restructure, 2026-11-24

The record of moving the multi-rate material out of Part III. The semantic
laws of the old §10.5 went to a new Part I §6.3, its declaration rules to
§8.7, and its execution mechanics stayed in a slimmed §10.5. Line numbers in
the inventories refer to the spec before the move.

| File | What it holds |
|---|---|
| `claims_a.md` | claims of the old §10.5, lines 6778–7028 |
| `claims_b.md` | claims of the old §10.5, lines 7020–7288 |
| `claims_c.md` | claims of the passages that merged or moved: §2.1, §2.2, §3.2, §3.3, §5.2, §5.3, §6's intro, §8.7, §9.2's notation |
| `citations_docs.md` | every §10.5 citation in the design documents before the move |
| `citations_code.md` | every §10.5 citation in `src/`, `test/` and `examples/`, still to re-point |
| `destination_map.md` | the coordinator's map of each claim to its destination, its outline and its judgment calls |
| `review.md` | the independent review against the claim list |

The review's fixes 1 to 9, 11 and 12 landed with the move. Its finding 14
is a `pending.md` bullet. The code citations in `citations_code.md` are
owed by a code commit of their own.
