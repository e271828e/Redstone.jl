# Chapter 13 PDF check

No damage found.

## What I could check

`pdftoppm`, `pdftotext` and the common Python PDF libraries are absent, so the
read ran on text extracted with Swift PDFKit (`scratch_pdf/chapter.txt`). It
covers markup leaks, tables, list numbering, heading order, links and missing
text. It does not cover spacing or page layout.

The PDF has 43 pages. Pages 1-20 hold the old chapter and the rewrite starts
on p. 21 (heading "13. Error discipline"). I compared pages 21-43 with
`chapter_new.md`.

## Findings

- Leaked markup: none. No stray `**`, `](#`, `<a id`, `[ref]` or `[ref]:`
  syntax anywhere in the text, old part included. No backticks survive.
- Links: all render as plain text (D-numbers, section marks, glossary
  terms); none as literal reference syntax.
- Headings: the eight `###` headings (13.1 to 13.8) appear in source order,
  on pp. 21, 22, 25, 27, 31, 35, 36 and 41. The `####` subheadings sit
  between them, in order.
- Section 13.3 clients table (`chapter_new.md` lines 314-318, PDF p. 25): 3
  columns, header and 3 rows (wiring, service, inspection) intact, with the
  long service cell wrapped inside its column.
- Lists: the source has no numbered lists. The bullets are all present.
- Missing text: a word-level diff of the source (code blocks removed, link
  syntax reduced to its text) against the PDF found no dropped prose. The
  only differences are the code blocks, which the PDF keeps, and
  tokenization of punctuation.

## What the text read cannot see

Column widths, row heights, wrapped long code lines, page breaks inside
tables or code, and whether links are clickable.
