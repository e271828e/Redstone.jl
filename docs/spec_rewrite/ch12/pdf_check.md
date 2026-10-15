# Chapter 12 PDF check

No damage found.

## What I could check

`pdftoppm`, `pdftotext` and the common Python PDF libraries are absent, so the
read ran on text extracted with Swift PDFKit (`scratch_pdf/chapter.txt`). It
covers markup leaks, tables, list numbering, heading order and links. It does
not cover spacing or page layout.

The PDF has 39 pages. Pages 1-18 hold the old chapter ("the spec at 17ad42d").
Pages 19-39 hold the rewrite, which I compared with `chapter_new.md`.

## Findings

- Leaked markup: none outside code blocks. No stray `**`, `](#`, `<a id`,
  `[ref]` or `[ref]:` syntax. Backticks appear only inside code comments
  (old part, not the rewrite).
- Links: all render as plain text (D-numbers, section marks); none as
  literal reference syntax.
- Headings: all `##`, `###` and `####` headings of `chapter_new.md` appear,
  in source order.
- Section 12.4: steps 1-7 keep their numbers (pages 23-24; step 1 on p. 23,
  steps 2-7 on p. 24). Source lines 272-.
- Section 12.6 lifecycle table (`chapter_new.md` lines 795-801, PDF p. 31):
  4 columns, header and 5 rows intact, in source order.
- Section 12.7 dispositions table (`chapter_new.md` lines 1234-1241, PDF
  pp. 38-39): header and 6 rows intact. It splits across the page break and
  the header repeats on p. 39. That is layout.
