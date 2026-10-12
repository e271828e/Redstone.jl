# PDF check, chapter 5

Method: no pdftotext or pypdf on this machine. I wrote a small Python extractor (Typst PDF, ToUnicode maps) and compared the text with chapter_new.md. Scratch output is in scratch_pdf/.

Result: no damage found in the rewritten text (PDF pages 11 to 21).

- Leaked markup: none. No `**`, `[..](..)` or `[..][..]` links, `#g-` anchors, backticks or `$` in pages 11-21.
- Headings: 5.1 to 5.6 and all 16 `####` labels are present, in order.
- Tables: the bundle-law table (p12-13, header repeats after the page break) has all nine rows (x, s, m, ws, u, y, y_x / y_s, t, Δt). The symbol/declaration table (p14) has all four rows.
- Blockquote (p17, "integrate → project → [ sweep ... ]") present. Math: the chapter has only inline math (lines 284-286, 570), all rendered. The three code fences (lines 30, 397, 461) are present.
- Missing sentences: none. Every sentence of chapter_new.md was found in the extracted text, ignoring line and page breaks.

Observation, not damage: chapter.pdf holds 21 pages. Pages 1-10 are the old chapter ("Chapter 5: the spec at b08afca"). Pages 11-21 are the rewrite ("Chapter 5: rewritten").
