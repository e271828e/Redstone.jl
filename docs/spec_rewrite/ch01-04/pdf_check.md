# PDF check: chapter.pdf, rewritten half (pages 10 to 20)

Verdict: no damage found.

Method: no pdftotext or pdftoppm on this machine, so I extracted text with pypdf (20 pages; original p1-9, rewrite p10-20) and checked text only, not pixels.

Checked:
- Raw markdown: no `**`, `][`, `](`, backticks, `$`, raw HTML or entities in either half.
- Headings: the rewrite shows 1. Introduction, 2. Formalism, 2.1, 2.2, 3., 3.1-3.4, 4., 4.1-4.4 in order, same numbering as the original. All 14 `####` subheadings render as text (Purpose ... Pre-sampling and substitutability).
- Lists: 50 `- ` items in chapter_new.md, 50 bullets in the PDF (original: 44 and 44).
- Inline math: the formulas in §2 (x-dot, s+), §3.1 (flow), §3.2 (s+) and the §3.4 interval integrals (theta_c, upsilon_c, q_c_cc, upsilon_c_sc) are present as math glyphs, with the same extraction as the original. Backticked `ẋ.ϑ_c` extracts as "x0.ϑ_c" in both halves, so it is a text-extraction artifact, not new damage.
- Missing text: a word-level diff of chapter_new.md (links, backticks, math stripped) against the PDF text shows no missing or extra words. Only differences are hyphenation at line breaks (pro ducing, conve nient, mecha nisms) and dash-joined compounds, all of which are justified-text hyphenation or extraction joins.
- Code blocks: both present (pp. 18-19 and p. 19); the first splits across pages 18/19, which is layout.
- Regressions vs the original: none found. "( §9)" style spacing after an open parenthesis appears in both halves (9 times in the original, 20 in the rewrite, in proportion to the link count); likely extraction of justified lines, not checkable without a rasterizer. Worth one look by eye at p. 10 line "(... ready to step) ( §9)".

Not checked: visual weight of heading levels, fonts, glyph rendering of the math (only text extraction was available).
