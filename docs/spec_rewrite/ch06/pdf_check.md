# PDF check, chapter 6 rewrite

Checked: pypdf text of pp. 6-11 (rewritten half) in `scratch_pdf/`, read against `chapter_new.md`, plus a grep for `**`, `][`, backticks, `####`, HTML.

No problems found.

- No leaked markup. All citations (D-nnn, section refs, Appendix C) render as link text, none unresolved.
- Headings 6, 6.1, 6.2 and the nine `####` labels are present and in order.
- "What the explicit form buys" has five bullets, intact (p. 9-10).
- Three code blocks present. All three show the same glyph substitutions in the extracted text as in the original half: `=>` reads `:>`, `<:` reads `::`, `u...` reads `u::.`. The same substitutions occur in the old half, so this is a font/ligature extraction artifact, not damage in the PDF.
- No text missing or duplicated. The trailing `---` is a rule and has no text.
