# Chapter 6: escalations for the owner

## E1. Is the locality law machine-checked or convention?

**Finding.** §6.1 says the one-level rule is enforced in `resolve`, paths are
validated at build time, and renames break loudly (D-207, D-061, D-130
Positions). The rewrite now names that restriction "the locality law"
(D-065), as four outside rows already did. §14.2 (spec 10342–10345 at the
base) says "The enforcement status carries over from §6.1 as well. The law is
convention. Ownership is a fact about who maintains the code, and the build
cannot see it, so the law is available and idiomatic rather than
machine-checked." D-065's Rejected list (log 1927) agrees: "Machine-enforced
ownership: not build-visible; same convention status as §6.1."

**Why it is not ruled here.** The wiring half is settled. D-207 made
one-level routing a build check, so §14.2's "carries over from §6.1" is
stale. The fragment half is not settled. D-207 bullet 2 makes an `at` prefix
stop at faces on every child, owned or not, which is a structural limit.
Whether the ownership part of the fragment law ("deep `at` only within owned
concrete subtrees", D-065 Position) still exists as a convention, or fell
with D-207's amendment, is a design question. No Position states it.

**Recommendation.** Rule that the locality law has two instances with
different enforcement. Wiring is machine-checked (D-207). The fragment law's
ownership clause is convention, if it survives D-207 bullet 2 at all. Then
annotate D-065 in track 2 and fix §14.2's sentence in chapter 14's rewrite.
§6.1 needs no change either way: it names the law for connections, where it
is enforced.
