# Appendix A: the merged candidate list

The three harvests folded into one list, duplicates merged, for the owner
to pick from. Each row names its harvest file and candidate so the full
evidence is one lookup away. "Both" means two agents found it from
independent sources, which is the strongest signal the harvest gives.

## Component authors

| # | lead-in | owners | status | found by |
|---|---|---|---|---|
| 1 | Never cache `Δt` | §10.5; D-019, D-291 | new | 1 and 2 |
| 2 | Guard predicates: σ = 0 holds, so a release predicate gates on the strict comparison; and `Bool` detection is exact only over modes, root inputs and held discrete outputs | §2.3, §10.4; D-290, D-365 | amends "Guard predicates, edges and priors", whose "positive meaning holding" is wrong at σ = 0 | 1 and 2 |
| 3 | No mutable cache in a field handle; referenced bulk data stays read-only | §4.4, §4.1; D-344 | new | 3, pointed at by 1 |
| 4 | Contracts follow the type, never field values | §8.1, §9.7; D-297 | new | 1 |
| 5 | Stripping partials declares a zero coupling | §13.7, §14.10, §9.5; D-266 | new | 2 |
| 6 | A unit delay is a modeling decision | §5.5, §13.7; D-348 | new | 2 |
| 7 | An unwired contributor drops out of the total | §6.2; D-084, D-323 | new | 1 |
| 8 | Between ticks a discrete store holds `s_{k+1}` | §14.5, §3.1 | amends "Interval alignment"; the spec implies it across two sentences rather than stating it | 3 |

## Periphery authors and consumers

| # | lead-in | owners | status | found by |
|---|---|---|---|---|
| 9 | Boundaries are publications, not frames; never derive time or an index from a wake count | §12.3, §10.4; D-028, D-230 | new | 3 |
| 10 | Conditioning upstream, aircraft semantics in-model | §11.4; D-045 | new | 3 |
| 11 | `shutdown!` also runs twice, and with no `init!` | §11.6, §12.4; D-268 | amends "`shutdown!` closes only what is open" | 3 |

## Service users (a group A does not have)

| # | lead-in | owners | status | found by |
|---|---|---|---|---|
| 12 | Trim checks: the residuals cannot see the operating point | §14.7, §14.9; D-262, D-139, D-417 | new | 1 and 2 |
| 13 | `linearize` holds the discrete tier | §14.10, §8.2 | new | 2 |
| 14 | What-if replay starts from your own `init!` | §12.7; D-274 | new | 1 |
| 15 | Deep service paths are bound to one build; an equation meant to survive substitution reads a face | §14.2, §14.7; D-414, D-065 | new, or widens "The two observation sides" | 3 |

Next in line, dropped by agent 1 only for the cap: the anchor doctrine,
"how silently an offset edit rewires a coincidence structure" (§10.5 line
6345; D-186, D-291).

## No home: lessons with no spec sentence

Not candidates until the spec states them. Each is a possible spec addition
for the owner to rule on.

- **A closed-loop trim must seed every integrator whose trim value is not zero.** Found by agents 2 and 3 independently (`longitudinal_aircraft.md:197–219`, `notes_increment_75.md:53–56`). The nearest spec sentence is the overlay base rule at line 11353.
- **A condition copied from a checkpoint runs one tick ahead**, since the store at rest holds `s_{k+1}` (D-273's Rationale). A natural facet of "Interval alignment" once stated; it is row 8's hazard seen from the condition side.
- **A switch on a continuous quantity is an undeclared mode** (`pid_anti_windup.md:51–56, 108–117`; `lqr_tracker.md:221–223`). §10.2's claim 2 is only about smoothness.
- **A hit guard stays ungated** (`limited_integrator_variants.md:40–46`). §10.4 covers only the release half.
- **A discrete law must be stable at every period** (`pid_anti_windup.md:379–402`). The spec has the never-cache rule but not the stability obligation.
- **A scheduled gain fed from seeded state carries partials into `A`**, and §1's "holds unseeded gain inputs constant" (line 1392) can be read the other way (`pid_anti_windup.md:490–493`; `lqr_tracker.md:181–184`).
- **A check on a quantity the condition writes directly is always zero** (`trim_environment_walkthrough.md:794–800`).
- **A startup hole is the author's to model** (D-205's Rationale; §10.5 lines 6146–6149 state the behavior only).

Dropped from the gaps as not the spec's: a standby tracker's lag with `Tt` (library design), and a test pin on a rate-limited signal (test practice, already in the delegation notes).

## Rulings, 2026-10-20

The owner's picks on this list, made in the session that ran the harvest,
so the A session starts from them:

- **All fifteen candidates are taken.** Rows 8 and 15 land as amendments to
  "Interval alignment" and "The two observation sides" rather than as new
  entries. The third group, "For service users", exists.
- **All eight gaps are grounded**, one sentence each in the owning section,
  as one docs commit before A's unit rewrite. Each sentence is a consequence
  of settled rulings and gets no log entry; each cites the ruling it
  follows from. Grounded, they become: two new entries (the switch on a
  continuous quantity, sibling of the reset-is-an-event entry; the startup
  hole), and facets of rows already listed (the hit guard joins row 2, the
  stable-at-every-period rule joins row 1, the seeded-gain partials join
  row 5 or 13, the check-on-a-written-quantity joins row 12).
- **The checkpoint-copied condition** is grounded by one sentence in §14.5
  beside the interval-alignment table, citing D-273: a store read at rest
  holds the state its next due tick decodes. It becomes a facet of
  "Interval alignment", merged with row 8, which is the same fact from the
  reader's side. The full account is
  `docs/design/companions/store_at_rest_walkthrough.md`; its section 7
  designs the `overlay!` door, a separate increment in `pending.md`, which
  the facet cites if the increment lands first ("a continuation is a
  restore, a what-if is an overlay").
- **The closed-loop trim seeding** is grounded by one sentence in §14.7's
  formulation subsection beside "filter and actuator equilibria imposed by
  construction", citing D-213 and D-063: the discrete tier is held during
  the solve, so a controller's stores are never decisions, and the values
  that keep the loop at rest are the author's to derive and write. Its pin
  is `examples/test/runtests.jl:117`. It merges with row 13 into one
  service-user entry, "the services hold the discrete tier", with both
  consequences. The framework offering help (a decision over discrete
  stores, a post-solve fixed-point hook) was raised and declined: the
  equilibria stay user math, as D-069 kept them.
- **Two probes before the sentences land**: the gated hit guard's re-fire
  on the gate's edge, the only gap whose claim is behavioral and rests on
  one companion; and the counter check for the rest reading, which D-273's
  Rationale and increment 65's notes already observed, so the probe is
  confirmation.
- **Order**: the `overlay!` increment is taken before A's rewrite, so the
  §14.5 sentence lands with its docs commit and A's facet cites the door.
