"""Builds inventory.json for unit A. Scratch; run from this directory."""
import json

O_CODE = [
    "# continuous component — maximal legal view set of each bundle in comments y_x = y_state(comp, args) # x, m, t [, ws] — no-feedthrough stage y_xu = y_direct(comp, args) # x, m, u, y_x, t [, ws] ẋ = x_deriv(comp, args) # x, m, y, u, t [, ws]",
    "# discrete component — the same two stage names over its own state letter y_s = y_state(comp, args) # s, t, Δt [, ws] y_su = y_direct(comp, args) # s, u, y_s, t, Δt [, ws] s⁺ = s_update(comp, args) # s, y, u, t, Δt [, ws]",
    "# every output stage returns its port NamedTuple — the return law below",
    "# event system (continuous side only) — same fresh table, same state views: σ = guard(comp, args) # x, m, y, u, t [, ws] — Bool or scalar sign value (§2.1) (; x, m) = handler(comp, args) # x, m, y, u, t [, ws] — keys by the return law below (§9.5) x⁺ = x_projection(comp, x) # manifold projection; positional (below)",
]

# (old, new, tag, extra)
C = [
 ("## 5. Evaluation order and feedthrough", "## 5. Evaluation order and feedthrough", "X", {}),
 ("### 5.1 The ordering problem", "### 5.1 The ordering problem", "X", {}),
 ("At every evaluation instant, all signals must be computed consistently.",
  "At every evaluation instant, all signals must be computed consistently.", "F", {}),
 ("Every consumer reads values already produced at that instant.",
  "Every consumer reads values already produced at that instant.", "F", {}),
 ("The build constructs the directed graph of wiring edges and intra-component feedthrough relations.",
  "The build constructs the directed graph of wiring edges and intra-component feedthrough relations (instantaneous input→output dependences).", "F", {}),
 ("If the graph is acyclic, a topological sort yields a static execution order, computed once at build time.",
  "If the graph is acyclic, a topological sort yields a static execution order (the order in which the stage functions run), computed once at build time (D-048).", "C", {"newcites": ["D-048"]}),
 ("The hot loop runs a flat list of `(component, stage)` entries, with no runtime graph logic.",
  "The hot loop runs a flat list of `(component, stage)` pairs, with no runtime graph logic (D-086).", "C", {"newcites": ["D-086"]}),
 ("### 5.2 Two-stage outputs: signatures, bundles and the hand-off laws",
  "### 5.2 Two-stage outputs: signatures, bundles and the hand-off laws", "X", {}),
 ("Every component provides exactly two output stages.",
  "Every component provides exactly two output stages (D-006).", "C", {"newcites": ["D-006"]}),
 ("Feedthrough is declared structurally, by function signature.",
  "Feedthrough (an instantaneous input→output dependence) is declared structurally, by function signature.", "F", {}),
 ("There are no dependency annotations anywhere in the design.",
  "There are no dependency annotations anywhere in the design (D-006).", "C", {"newcites": ["D-006"]}),
] + [
 (c, c, "F", {}) for c in O_CODE
] + [
 ("The laws that govern that surface follow.", "The laws that govern that surface follow.", "F", {}),
 ("They fix how a function receives its arguments, which names it receives, what an output stage returns, and what a handler returns.",
  "They fix how a function receives its arguments, where each view comes from, which names it receives, what an output stage returns, and what a handler returns.", "R", {"ruling": "R2"}),
 ("#### The hand-off: one component, one bundle", "#### The hand-off: one component, one bundle", "X", {}),
 ("Rule. Every function receives exactly two arguments, the component and one NamedTuple bundle of zero-copy views.",
  "Every function receives exactly two arguments, the component and one NamedTuple bundle of zero-copy views (D-074).", "C", {"newcites": ["D-074"]}),
 ("From that bundle the author destructures by name only what the body reads, as in `x_deriv(c::LowPassFilter, (; x, u)) = …` and `y_direct(c::PID, (; s, u, Δt)) = …`.",
  "From that bundle the author destructures by name only what the body reads, as in `x_deriv(c::LowPassFilter, (; x, u)) = …` and `y_direct(c::PID, (; s, u, Δt)) = …`. Here `PID` names a proportional-integral-derivative controller.", "F", {}),
 ("Why. The executor (the compiled form of the stage execution order) issues one fixed call shape, `fn(comp, args)`.",
  "The rule exists so that the executor (the compiled form of the stage execution order) issues one fixed call shape, `fn(comp, args)`.", "F", {}),
 ("Language semantics ignore unread fields.", "Two more reasons support it. Language semantics ignore unread fields.", "F", {}),
 ("Argument order cannot be confused, because there is no order.",
  "Argument order cannot be confused, because there is no order.", "F", {}),
 ("Positional, `kwarg_decl`-reflected and slurping-keyword spellings are all closed (D-074).",
  "Positional, `kwarg_decl`-reflected and slurping-keyword spellings are all closed (D-074).", "F", {"note": "kept under R11"}),
 ("`x_projection` alone stays positional.",
  "`x_projection` alone stays positional (D-074).", "C", {"newcites": ["D-074"]}),
 ("It takes one store in and returns the same store out, so there is nothing to select.",
  "It takes one store in and returns the same store out, so there is nothing to select.", "F", {}),
 ("#### What the views are", "#### What the views are", "M", {"ruling": "R2"}),
 ("The views themselves are unchanged in meaning.",
  "The views come from the sources below.", "R", {"ruling": "R3, corrected by R14"}),
 ("- Own state. On the continuous tier `x` comes from the flat buffer and `m` from the mode stores.",
  "- Own state. On the continuous tier (the continuous side of the hybrid formalism), `x` comes from the flat buffer and `m` from the mode stores.", "M", {"ruling": "R2"}),
 ("On the discrete tier `s` comes from its store.",
  "On the discrete tier, `s` comes from its store.", "M", {"ruling": "R2"}),
 ("- Own published signals. `y` is gathered from the component's own table cells (the declared ports, §8.2).",
  "- Own published signals. `y` is gathered from the component's own cells (concretely typed entries, one per output port) in the signal table. Those cells are the declared ports (§8.2).", "M", {"ruling": "R2; cell link per R13"}),
 ("- Inputs. `u` is gathered from foreign cells through the wiring's name binding.",
  "- Inputs. `u` is gathered from foreign cells through the wiring, by name.", "M", {"ruling": "R2"}),
 ("- The clock. `t`, and `Δt` (§10.5).", "- The clock. `t`, and `Δt` (§10.5).", "M", {"ruling": "R2"}),
 ("- Scratch. `ws` (§7.3).", "- Scratch. `ws` (§7.3).", "M", {"ruling": "R2"}),
 ("The signal table holds only produced signals, never transported ones.",
  "The signal table holds only produced signals, never transported ones (D-035).", "C", {"newcites": ["D-035"], "note": "moved by M1 (R2)"}),
 ("Each datum has exactly one home.", "Each datum has exactly one home.", "M", {"ruling": "R2"}),
 ("The buffer holds `x`, the `s` and `m` stores hold `s` and `m`, and the table holds signals.",
  "The buffer holds `x`, the `s` and `m` stores hold `s` and `m`, and the table holds signals.", "M", {"ruling": "R2"}),
 ("No store mirrors another.", "No store mirrors another.", "M", {"ruling": "R2"}),
 ("Every bundle field earns its place as a view genuinely readable, and no minimization of the set survives without introducing a copy (D-035).",
  "Every bundle field earns its place as a view genuinely readable. No minimization of the set survives without introducing a copy (D-035).", "M", {"ruling": "R2"}),
]

import re
CITE = re.compile(r'§\d+(?:\.\d+)?|D-\d{3}|Appendix [A-D]')
claims = []
for i, (o, n, tag, extra) in enumerate(C, 1):
    c = {"id": f"A-{i:03d}", "old": o, "new": n, "where": "new",
         "cites": sorted(set(CITE.findall(o)))}
    nc = extra.pop("newcites", None)
    if nc is not None:
        c["newcites"] = sorted(set(c["cites"]) | set(nc))
    c["tag"] = tag
    c.update(extra)
    claims.append(c)

added = [
 "This chapter fixes two output stages per component, what each stage may see, and how those signatures alone yield a static execution order.",
 "The build derives that order from declared feedthrough and rejects algebraic loops by naming the cycle.",
 "§5.1 states the ordering problem; §5.2 the two output stages, their signatures, bundles and the hand-off laws; §5.3 the stage roles, the execution order and step boundaries; §5.4 artificial loops and the escape hatch; §5.5 the policy that rejects algebraic loops at build time; and §5.6 diagnostics through feedthrough tracing.",
 "(instantaneous input→output dependences)",
 "(the order in which the stage functions run)",
 "A cyclic graph is the subject of §5.5.",
 "(an instantaneous input→output dependence)",
 "where each view comes from,",
 "The rule exists so that",
 "Two more reasons support it.",
 "Here `PID` names a proportional-integral-derivative controller.",
 "(concretely typed entries, one per output port)",
 "A `kwarg_decl`-reflected spelling takes keyword arguments whose names the framework reads through Julia's internal `Base.kwarg_decl`.",
 "A slurping-keyword spelling takes keyword arguments and ends its keyword list with a `_...` slurp.",
 "The views come from the sources below.",
 "(the continuous side of the hybrid formalism)",
]
json.dump({"claims": claims, "added": added}, open("inventory.json", "w"),
          ensure_ascii=False, indent=1)
