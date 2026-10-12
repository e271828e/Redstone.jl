# Chapter 5: findings for the owner

Serious findings, or gaps between the design and `src/` that the rewrite
does not settle. The text stays as written; each goes to the owner when the
chapter closes.

- **The quoted cycle diagnostics differ from `src`'s text** (survey F9).
  §5.4 (old 1097–1098) quotes "cycle through `systems/aero` is artificial at
  port level — split the component, or narrow the neighbor's contract", and
  §5.6 (old 1138) says a genuine cycle gets "insert a state". `src/diagnostics.jl`
  920–948 at `b08afca` renders "algebraic loop among …: … — artificial at port
  level: …; split `m`, or narrow the neighbor's contract if `f` is consumed
  only in a fallback branch (§5.4)", and for a real loop "break it with a
  state, a stage-1 (`y_state`) port, or a `UnitDelay` …". The code's text is
  richer and agrees with the spec in substance. Recommendation: rule the
  spec's quotes illustrative rather than verbatim, or conform the spec to
  `src`'s wording, as a `pending.md` deviation bullet. The rewrite carries the
  quotes verbatim.
- **§5.2's example diagnostic differs from `src`'s text** (unit B, same
  class as the item above). Old 752–754 quotes "`x_deriv` of `Foo`
  destructures `m`, but `Foo` declares no `m_init`"; the survey's run of
  `src` printed "`x_deriv` destructures `m`, but the root component declares
  no `m_init` — the bundle carries {x, y, t} (§5.2)". Same recommendation.
