# Claim spans engine.py's edits cross or split, set by hand. Keys are the
# claim's old span, as a prefix.
MANUAL = {"A": {
 "A fourth stopped-sim service": dict(
  note="P1-2 writes `Model` plain here; its link joins its gloss in the lifecycle paragraph's `Model` form."),
 "Each row's service also has a form": dict(
  note="P1-2: the `Model` link now sits here, with its gloss."),
 "§14.1–§14.4 settle": dict(
  new="§14.1 settles the condition's representation, §14.2 its composition, §14.3 its resolution and §14.4 its application and the read selectors;",
  note="P1-1, §14.4's read selectors join its subject, one verb for §14.1 to §14.4."),
 "§14.5–§14.6 cover": dict(
  new="§14.5 covers the initialization sequence called boundary zero, §14.6 root-input totality (the requirement that an application establishing a complete world cover every root input) and `override`,",
  note="P1-1, one 'covers' and §14.6's `override` (its title's); P1-35, boundary zero glossed by 'the initialization sequence called', after #g-boundary-zero ('the initialization boundary: the ordinary macro-sequence'). root input stays linked inside the totality gloss, unglossed: a gloss there would nest."),
 "§14.7–§14.9 cover": dict(
  new="§14.7 the trim problem, §14.8 the trim service, §14.9 mounting",
  note="P1-1 drops 'which together cover the trim service in full': §14.9's mounting also relocates tap sets, so the three sections are more than the trim service; each keeps its subject."),
 "§14.10 covers linearization.": dict(new="and §14.10 linearization.", note="P1-1."),
 "The engine knows": dict(
  new="An engine component knows `n_eng → ω = n_eng·ω_rated`, and nothing above it should have to.",
  note="P1-6's `n_eng` clause is the added block below."),
 "Fragments are composed by pull": dict(
  new="Fragments are composed by pull from the structure's owner, here `C172XSystems` (the C172X aircraft's systems assembly, after FlightApps' `C172X.Systems`).",
  note="P1-6's `α_filt` clause is the added block below."),
 "Dispatch selects variant-specific methods": dict(
  new="Dispatch selects variant-specific methods, so the actuation split between Flight.jl's two Cessna 172 variants, c172s and c172x, costs no upstream edits.",
  note="P1-8 moves it to just after the `C172XSystems` block it comments on; P1-7 names the owner (both files sit in Flight.jl's lib/FlightApps/src/c172/)."),
 "The first case is trim's": dict(newcites="§14.2",
  note="P1-6, a pointer to §14.2's block, which sets `α_filt = α_a`."),
 "Resolution takes the root node": dict(
  new="It takes the root node plus a `Build` (the artifact `build(world)` produces).",
  note="P1-4's context sentence is the added block below; condition's link and gloss move to it from the flattening paragraph (P1-35)."),
 "That rejection is also why": dict(
  note="P1-11, rule first: the bold sentence leads and the rejection follows as its reason."),
}, "B": {
 "Execution is therefore resolve-once": dict(newcites="none",
  note="P1-15 drops the clause 'with two ways to apply the compiled plans (§14.3)': the context paragraph and the heading state the two ways, and each bullet keeps its §14.3 pointer."),
 "They do so within the scopes": dict(
  new="They do so within the scopes the locality law (§6.1) and fragment scoping (§14.2) describe.",
  note="P1-21: 'as authoring guidance (D-414)' folds into the paragraph's opening sentence, which carries D-414; fragment's gloss is the added block below."),
 "Output-device bindings, log extraction": dict(
  new="Bindings of an output device (an attached participant in the periphery) and log extraction by `series` take deep paths, `get_face` names and leaf addresses alike (D-406, D-407, D-414). Snapshot inspection reads a cell by path and port name instead (§11.2).",
  note="P1-35, device glossed from #g-device; P1-21 regroups the inspection reads into one paragraph."),
 "No published cell holds the probe's": dict(
  new="No published cell holds a synthesized probe value (a fabricated value a build-time probe runs on).",
  note="P1-35: the probe's synthesized values are probe values (#g-probe-value, 'the fabricated values a build-time probe runs on'), so the link moves there with that gloss, as P2-13 rules for §14.8's twin sentence."),
 "That is the §14.6 barrier extended": dict(
  new="That is the probe-value barrier of §14.6 extended from the root inputs to the whole table.",
  note="P1-35: §14.6 calls it the probe-value barrier."),
 "After the first snapshot `init!` takes": dict(
  new="After the first snapshot `init!` takes the trace header, the checkpoint (the `Model`'s state at a frame top as one value) of the state the sequence leaves (§11.5, D-274).",
  note="P1-35's glosses of the chain's terms are the added blocks below; the trace header keeps its appositive gloss."),
 "The trace header holds every root-input cell": dict(
  note="P1-35, trace header gloss from #g-trace-header; P1-34 spells the requirement out from §11.3 (frozen spec 7325-7326, 'a root input unfed by any device must hold a defined value from the first frame')."),
 "But the point the stores sit at": dict(newcites="§14.8",
  note="P1-32, the verdict named and pointed to §14.8, where 'The convergence verdict' is specified."),
}}

ADDED = {"A": [
 "A condition is the value an author writes to say which state a build starts from.",
 "`n_eng` is the engine speed as a fraction of its rated speed `ω_rated`.",
 "In the block, `α_filt` and `β_filt` are the aerodynamics' filtered airflow angles, set to the angle of attack `α_a` and the sideslip `β_a`.",
 "and `override`, the ordered, asymmetric layering combinator, builds a fourth node type (§14.6).",
 "Resolution turns a composed condition (the path-addressed sparse overlay that sets a build's state) into plans the services can apply.",
], "B": [
 "Both kinds of read resolve under the one service walk (§13.3).",
 "A fragment is the leaf node of the condition algebra, built by `set`.",
 "In the sequence, a sweep is one pass through the execution order against the current state, and a guard is the declared function defining an event's predicate.",
 "A due component is a discrete component whose schedule admits the boundary's tick index, and a snapshot is the immutable per-boundary publication.",
]}

DROP_ADDED = {"A": ["and `override` builds a fourth node type"],
              "B": ["Both reads resolve under the one service walk"]}
