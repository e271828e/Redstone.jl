# Chapter 14 escalations

Findings that might involve a real design decision (recipe section 2), for
the owner when the chapter closes.

## E1. A struct root input without `convert` crashes `linearize`'s default point

Source: survey 2, part C, "Claims checked in passing", last item. Met
outside any spec claim.

A walked struct root input whose type has no `convert` method between its
scalar instances (the survey's `Duo{Float64}` to `Duo{Dual}`) makes the
default operating point of `linearize` die in a raw `MethodError` from
`convert`, raised in the root-input loop of `src/linearize.jl` (191–195 at
`c3d29fb`). §14.3's "the type's ordinary `convert`/constructor methods"
covers condition writes. Nothing states the obligation for this copy, and
no diagnostic names it.

The code is silent here in the sense that matters: it neither refuses the
type at build nor names the missing method. Two answers change the code.

- **(a) State the obligation and leave the raw error.** One sentence in
  §14.10 extends §14.3's `convert` obligation to the default point's copy.
- **(b) State it and diagnose it.** The same sentence, plus a refusal with a
  kind that names the type and the missing method, raised before the first
  evaluation.

Recommendation: (b), as a loose increment after the chapter lands. §13's
discipline gives every framework-detected failure a kind, and the failure
here is detectable from the types alone.
