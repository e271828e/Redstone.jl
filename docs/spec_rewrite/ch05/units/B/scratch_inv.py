"""Builds inventory.json for unit B. Run from docs/spec_rewrite."""
import json, os, re, sys
sys.path.insert(0, "checks")
from norm import norm, units
D = "ch05/units/B"
O = norm(open(f"{D}/old.md").read())
NU = units(open(f"{D}/new.md").read())
CITE = re.compile(r'§\d+(?:\.\d+)?|D-\d{3}|Appendix [A-D]')

TABLE_OLD = O[O.index("| bundle field"):O.index("| `Δt` | the component is on the discrete tier |") + len("| `Δt` | the component is on the discrete tier |")]
TABLE_NEW = [u for u in NU if u.startswith("| bundle field")][0]

# (old, new, tag, ruling or None, newcites or None)
C = [
 ("#### The bundle law: which names a component receives", "#### The bundle law: which names a component receives", "X", None, None),
 ("Rule. Under the bundle law, a name appears in a component's bundle iff the corresponding store or fact exists for that component.",
  "Under the bundle law, a name appears in a component's bundle iff the corresponding store or fact exists for that component (D-074).", "R", "R9", ["D-074"]),
 (TABLE_OLD, TABLE_NEW, "R", "R5", ["D-297"]),
 ("The stage-1 hand-down carries the stage-1 return.", "The stage-1 hand-down carries the stage-1 return (D-285).", "R", "R6", ["D-285"]),
 ("`y_x`, or `y_s` on the discrete tier, comes from the stage-1 probe's return (D-252).",
  "`y_x`, or `y_s` on the discrete tier, comes from the return of the stage-1 probe", "R", "R6", []),
 ("§9.3 already sources the rule.", "§9.3 already sources the rule.", "F", None, None),
 ("A component with no stage-1 ports has no `y_x`/`y_s` in its stage-2 bundle at all.",
  "A component with no stage-1 ports has no `y_x`/`y_s` in its stage-2 bundle at all.", "F", None, None),
 ("Undeclared stores are absent, never `nothing`-filled.", "Undeclared stores are absent, never `nothing`-filled.", "M", None, None),
 ("Destructuring a field that does not exist for the component fails at the probe, inside the §13.2 framing diagnostic.",
  "Destructuring a field that does not exist for the component fails at the probe with a `BundleFieldError` diagnostic (D-248). §13.2 describes the catch that recognizes it.", "R", "R5", ["D-248", "§13.2"]),
 ("The diagnostic carries did-you-mean (the offending name plus the list-in-hand it should have matched) against the legal field set.",
  "The diagnostic carries did-you-mean (the offending name plus the list-in-hand it should have matched) against the legal field set.", "F", None, None),
 ("An example is \"`x_deriv` of `Foo` destructures `m`, but `Foo` declares no `m_init`\".",
  "An example is \"`x_deriv` of `Foo` destructures `m`, but `Foo` declares no `m_init`\".", "F", None, None),
 ("One law covers tier facts, stage legality and declarations alike.", "One law covers tier facts, stage legality and declarations alike.", "F", None, None),
 ("The mechanism is structured, not textual.", "The mechanism behind the diagnostic is structured, not textual.", "F", None, None),
 ("Destructuring an absent field throws a `FieldError` carrying the type and the field name as data (Julia ≥ 1.12).",
  "Destructuring an absent field throws a `FieldError` carrying the type and the field name as data (Julia ≥ 1.12).", "F", None, None),
 ("The probe catches it matched against the bundle's own NamedTuple type",
  "The probe catches it matched against the bundle's own NamedTuple type.", "F", None, None),
 ("and synthesizes the framing diagnostic from the legal set.", "The probe synthesizes the `BundleFieldError` from the legal set.", "R", "R5", None),
 ("It classifies the field as an undeclared store, a wrong-tier fact, or a name illegal for this function family.",
  "It classifies the field as an undeclared store, a wrong-tier fact, or a name illegal for this function family.", "F", None, None),
 ("No message text is scraped, and the bundle stays a bare NamedTuple (D-074).",
  "No message text is scraped, and the bundle stays a bare NamedTuple (D-074).", "F", None, None),
 ("A getproperty-wrapper spelling is the recorded fallback, should type-matched interception prove insufficient.",
  "A getproperty-wrapper spelling is the recorded fallback, should type-matched interception prove insufficient.", "F", None, None),
 ("The wrong-tier class covers the state letters too (D-195).", "The wrong-tier classification covers the state letters too (D-195).", "F", None, None),
 ("`x` and `m` are continuous-only, and `s` and `Δt` are discrete-only,", "`x` and `m` are continuous-only, and `s` and `Δt` are discrete-only.", "F", None, None),
 ("so destructuring any of the four on the wrong tier lands in that bucket.",
  "So destructuring any of the four on the wrong tier is classified as a wrong-tier fact.", "F", None, None),
 ("The per-function name sets are closed, one set per function per tier.",
  "The per-function name sets are closed (D-074), one set per function per tier.", "R", "R9", ["D-074"]),
 ("The update laws carry their tier in the name, so `x_deriv` and `s_update` have one set each.",
  "The update laws carry their tier in the name, so `x_deriv` and `s_update` have one set each.", "F", None, None),
 ("The two output stages are shared machinery over both tiers (D-220), so `y_state` and `y_direct` have one set per tier.",
  "The two output stages are shared machinery over both tiers (D-220), so `y_state` and `y_direct` have one set per tier.", "F", None, None),
 ("On the continuous tier the sets are `x, m, t [, ws]` and `x, m, u, y_x, t [, ws]`.",
  "On the continuous tier the `y_state` and `y_direct` sets are `x, m, t [, ws]` and `x, m, u, y_x, t [, ws]`.", "F", None, None),
 ("On the discrete tier they are `s, t, Δt [, ws]` and `s, u, y_s, t, Δt [, ws]`.",
  "On the discrete tier they are `s, t, Δt [, ws]` and `s, u, y_s, t, Δt [, ws]`.", "F", None, None),
 ("Adding a name to any of them is a decision-log entry, not a convenience.",
  "Adding a name to any of them is a decision-log entry, not a convenience.", "F", None, None),
 ("The comments in the signature block above state each function's maximal legal set at each tier.",
  "The comments in the signature block above state each function's maximal legal set at each tier.", "F", None, None),
 ("A given component's bundle narrows that set to declared reality, and the destructuring narrows it further to actual reads.",
  "A given component's bundle narrows that set to declared reality, and the destructuring narrows it further to actual reads.", "F", None, None),
 ("That three-level funnel (stage name at its tier ⊇ bundle ⊇ reads) is worth teaching once, because a stateless component legitimately writes `y_direct` while owning neither `x` nor `m`.",
  "That three-level funnel (stage name at its tier ⊇ bundle ⊇ reads) is worth teaching once, because a stateless component legitimately writes `y_direct` while owning neither `x` nor `m`.", "F", None, None),
 ("#### The stage return law", "#### The stage return law", "X", None, None),
 ("Rule. An output stage returns its port NamedTuple, `y`, and nothing else.",
  "An output stage returns its port NamedTuple, `y`, and nothing else (D-194).", "C", None, ["D-194"]),
 ("`y` scatters into the component's declared cells as always, and every value a later function needs is one of those cells (§8.3).",
  "`y` scatters into the component's declared cells as always, and every value a later function needs is one of those cells (§8.3).", "F", None, None),
 ("Stages are discovered by method existence, and stage membership is a partition of the declared ports.",
  "Stages are discovered by method existence, and stage membership is a partition of the declared ports.", "F", None, None),
 ("An empty `y = (;)` is a `DeadStage` build error at the probe (§9.3).",
  "An empty `y = (;)` is a `DeadStage` build error at the probe (§9.3, D-285).", "C", None, ["§9.3", "D-285"]),
 ("A stage returning nothing at all computes nothing any consumer can read.",
  "A stage returning nothing at all computes nothing any consumer can read.", "F", None, None),
 ("That is the inert-component check (§8.1), applied to a single stage.",
  "That is the inert-component check (§8.1), applied to a single stage.", "F", None, None),
 ("#### The handler return law", "#### The handler return law", "X", None, None),
 ("Rule. A handler returns a NamedTuple carrying the stores it writes.",
  "A handler returns a NamedTuple carrying the stores it writes (D-090).", "C", None, ["D-090"]),
 ("A key is present iff the corresponding store exists on the component and the handler updates it.",
  "A key is present iff the corresponding store exists on the component and the handler updates it.", "F", None, None),
 ("That is the bundle law's iff shape, now governing the return side.",
  "That is the bundle law's iff shape, now governing the return side.", "F", None, None),
 ("A pure FSM (modes and events, no `x`) returns `(; m = (; phase = running))`.",
  "A pure FSM (finite-state machine, with modes and events and no `x`) returns `(; m = (; phase = running))`.", "F", None, None),
 ("An `x`-only reset map returns `(; x = (; x..., ω = 0.0))`.", "An `x`-only reset map returns `(; x = (; x..., ω = 0.0))`.", "F", None, None),
 ("A handler touching both returns both.", "A handler touching both returns both.", "F", None, None),
 ("Padding forms such as `((;), m⁺)` and `(x⁺, (;))` do not exist (D-090, on the argument-side ground of D-074).",
  "Padding forms such as `((;), m⁺)` and `(x⁺, (;))` do not exist (D-090, on the argument-side ground of D-074).", "R", "R11", None),
 ("The semantics per key are these.", "The return's semantics are per key (D-287).", "C", None, ["D-287"]),
 ("When `x` is present, the value is complete against the state field set.",
  "When `x` is present, the value is complete against the state field set.", "F", None, None),
 ("When `m` is present, the names-subset predicate applies.",
  "When `m` is present, the names-subset predicate applies (D-090).", "C", None, ["D-090"]),
 ("An unknown key gets did-you-mean against `{x, m}`.",
  "An unknown key gets did-you-mean against `{x, m}` in a `HandlerReturnKey` diagnostic.", "R", "R7", None),
 ("This is the same `FieldError`-shaped machinery §13.2 builds for bundles, now running in both directions (§9.5).",
  "This is the same `FieldError`-shaped machinery §13.2 builds for bundles, now running in both directions (§9.5).", "F", None, None),
]

ADDED = [
 "(the build's single evaluation of a user function with real values)",
]

claims = []
for i, (o, n, tag, ruling, newcites) in enumerate(C, 1):
    c = {"id": f"C-{i:03d}", "old": o, "new": n, "where": "new",
         "cites": sorted(set(CITE.findall(o)))}
    if newcites is not None: c["newcites"] = newcites
    c["tag"] = tag
    if ruling: c["ruling"] = ruling
    claims.append(c)
json.dump({"claims": claims, "added": ADDED}, open(f"{D}/inventory.json", "w"), indent=1, ensure_ascii=False)
print(len(claims), "claims")
