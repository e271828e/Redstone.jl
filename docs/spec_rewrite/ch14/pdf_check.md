# Chapter 14 PDF check

No damage found.

## Method

`pdftotext` and `pdftoppm` are absent. Text came from Swift PDFKit
(`scratch_pdf/x.swift` -> `scratch_pdf/chapter.txt`). The PDF has 53 pages.
Pages 1-24 hold the old chapter; the rewrite runs from p. 25 (heading
"14. Stopped-sim services", under a "Chapter 14: rewritten" banner) to p. 53.
I checked p. 25-53 against `chapter_new.md`.

## Counts

- Raw markup (`**`, backtick, `](`, `<a id`, `[x][y]`, `[ref]:`): 0 hits in the
  whole text. `chapter_new.md` has 0 `<a id` anchors and 0 reference
  definitions to leak.
- Unresolved reference links: 0. Section and D-number links print as plain
  text; glossary links print as their link text.
- Headings: 1 chapter heading (p. 25) + 10 numbered, in order: 14.1 p. 26,
  14.2 p. 27, 14.3 p. 29, 14.4 p. 31, 14.5 p. 34, 14.6 p. 36, 14.7 p. 37,
  14.8 p. 40, 14.9 p. 46, 14.10 p. 48. All 25 `####` labels appear once each
  in the new part, in source order.
- Tables: 5 of 5 intact (header, all rows, no cells run together). They are
  the lifecycle table in the chapter intro (`chapter_new.md` lines 33-40,
  p. 25-26, header repeats across the break); the 14.3 converter table
  (lines 320-323, p. 30); the 14.4 selector table (lines 509-515, p. 33); the
  tier table inside a list item in 14.5 (lines 592-595, p. 35); the 14.10
  seeded/frozen table (lines 1526-1534, p. 50-51, header repeats). The brief
  listed 14.5 but the tables sit in 14.3, 14.4, 14.5 (list item) and 14.10.
- Math: `$...$` and `$$...$$` spans all render (no `\mathit`, `\sum`, `$` left).
- Missing prose: a word-multiset diff (fences removed, links reduced to text)
  leaves only LaTeX command names that the PDF shows as symbols.

## Problems

None.

## Not covered

Column widths, spacing, page breaks inside code, clickable links.
