# PDF check, chapter 11 rewritten

Extractor: pypdf (`/usr/bin/python3`, user site; fails under `-I`). Pages 26-56 of 56, text in `scratch_final/pdf/` (`p026.txt`..`p056.txt`, joined in `rewritten.txt`). The PDF has no images, so no visual check.

Headings: 57 in `chapter_new.md` (8 `###`, 49 `####`). All 57 found in the extracted text, none missing. Extraction shows them as plain lines, not `#`.

Raw markdown: none. No `**`, backticks, `[text][ref]`, `[text](#anchor)` or leading `####`. Remaining `*` are `t*` in prose (pp. 26-27) and `*declared*` inside a code block, which matches the source.

Tables: the port-view table (11.7) has all 5 rows and 4 columns, cells in order. Numbered list 1-5 (11.1) and bullets intact.

Problem (likely extraction only): in monospace text, `<:` and `::` extract as `=:` (for example `MyDevice =: AbstractDevice`, `struct T16000MBinding =: AbstractBinding`, `dev=:T16000M`), pp. 38-40 and 52. Some `::` extract correctly (`mask :: NTuple`, `::AbstractDevice`), so this looks like a glyph-mapping quirk of the code font. Check by eye on those pages.

## Orchestrator note

The `=:` for `<:` is the code font: the original chapter's pages extract the same way (12 times, with no `<:` extracted). Checkpoint 4 approved.
