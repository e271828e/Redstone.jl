# Unit B: claims deleted by ruling

Each claim below is copied from `old.md`, normalized. Its inventory entry maps
here with its ruling.

- R6 (F2), the paragraph on `resolve_terminal`'s clients, false against the
  code (`src/assembly.jl` 547, 573: two wiring callers):

`resolve_terminal` is first-class because five clients share it across the
three rules.

Device-binding validation (§11.2) and snapshot inspection are inspection
clients.

The result is one splitter and one did-you-mean site.
