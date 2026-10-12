"""Builds inventory.json for unit C. Scratch helper; run from this directory."""
import json

S = []  # (old, new, cites, newcites or None, tag, ruling or None)


def c(old, new=None, cites=(), newcites=None, tag="F", ruling=None):
    S.append((old, old if new is None else new, list(cites), newcites, tag, ruling))


c("## 3. Component taxonomy")
c("There are three classes.",
  "The taxonomy has three categories of component (D-003).",
  newcites=["D-003"], tag="R", ruling="R6")
c("Two of them are leaves with crisp, closed semantics, and one is pure composition.")
c("### 3.1 Continuous component (the hybrid primitive)")
c("A continuous component is a classical hybrid automaton.")
c("It has these facets.")
c("Continuous state `x`, an isbits struct of real scalars (§7).",
  "Continuous state `x`, a NamedTuple whose leaves are real scalars and `SArray`s (§7.1, D-094, D-247).",
  cites=["§7"], newcites=["§7.1", "D-094", "D-247"], tag="R", ruling="R5")
c("Mode variables `m`. These are piecewise-constant values (enums, integers, flags) that parametrize the flow and change only through event handlers.")
c("Flow $\\dot{x} = f(x, m, u, t)$.")
c("Two output stages (§5.2).", cites=["§5.2"])
c("Events, each a guard plus a handler.",
  "Events, each a guard (the declared function defining an event's predicate) plus a handler.")
c("A handler may update `m` and may reset the component's own `x`.",
  "A handler may update `m` and may reset the component's own `x` (D-090).",
  newcites=["D-090"], tag="C")
c("Both guard and handler read the fresh boundary signal table (§5.3).",
  "Both guard and handler read the fresh boundary signal table (§5.3, D-154).",
  cites=["§5.3"], newcites=["§5.3", "D-154"], tag="C")
c("An optional projection.",
  "An optional projection (the per-component hook `x_projection`).")
c("Any facet may be empty.")
c("In particular, a component with no continuous state, only modes, events and mode-valued outputs, is an FSM.",
  "In particular, a component with no continuous state, only modes, events and mode-valued outputs, is a finite-state machine (FSM).")
c("A single primitive therefore supports both factorings of mode logic.",
  "A single primitive supports both factorings of mode logic (D-003).",
  newcites=["D-003"], tag="R", ruling="R6")
c("Internal modes suit tightly coupled cases, such as stall hysteresis inside the aero component.")
c("They preserve cohesion and enable reset maps.",
  "They preserve cohesion and enable reset maps (D-003).",
  newcites=["D-003"], tag="C")
c("An external FSM component feeding modes through a port gives maximal purity, independent testability and swappable supervision logic.",
  "An external FSM component feeding modes through a port (the addressable unit of the model) gives maximal purity, independent testability and swappable supervision logic.")
c("Rule of meaning.",
  "The rule of meaning separates a command from a detection.",
  tag="R", ruling="R7")
c("A supervisor commanding a mode change is an ordinary input.")
c("A component detecting its own transition is an event.")
c("The two mechanisms carry two meanings and do not overlap.")
c("### 3.2 Periodic discrete component")
c("A periodic discrete component has these facets.")
c("Discrete state `s`, any isbits value (§7).",
  "Discrete state `s`, a NamedTuple whose fields are each isbits or a `Symbol` (§7.3, D-231, D-247).",
  cites=["§7"], newcites=["§7.3", "D-231", "D-247"], tag="R", ruling="R5")
c("Update $s^{+} = g(s, u, t)$ at a declared rate.")
c("Two output stages, with feedthrough applying at update instants.",
  "Two output stages, with feedthrough (an instantaneous input→output dependence) applying at update instants.")
c("A proportional path is direct feedthrough.")
c("A state-only output is not.")
c("Each tier carries its own state letter.",
  "Each tier carries its own state letter (D-195).",
  newcites=["D-195"], tag="M")
c("`x` is the argument of the flow map under `f`, and `s` is the argument of the jump map under `g`.")
c("The two are different objects.")
c("`x` has a derivative and lives in the flat buffer.")
c("`s` has none and is latched in a store between ticks.",
  "`s` has none and is latched in a store (the framework-owned home of a state letter) between ticks.")
c("So they are spelled differently (D-195).",
  "Each tier carries its own state letter (D-195).",
  cites=["D-195"], tag="M")
c("Nothing is lost by the split, because a leaf is strictly one tier (D-056) and no component ever reads another's state.",
  "Nothing is lost by splitting the letter, because a leaf is strictly one tier (D-056) and no component ever reads another's state.",
  cites=["D-056"])
c("A discrete component's `s` influences continuous dynamics only through signals.",
  "A discrete component's `s` influences continuous dynamics only through signals (D-056).",
  newcites=["D-056"], tag="C")
c("Those outputs are held zero-order between ticks.",
  "Those outputs are held zero-order between ticks (D-019).",
  newcites=["D-019"], tag="C")
c("`m` is continuous-only.",
  "`m` is continuous-only (D-231, D-249).",
  newcites=["D-231", "D-249"], tag="R", ruling="R6")
c("A discrete component has no mode store.")
c("Its FSM enums, flags and counters are ordinary `s` fields.",
  "Its finite-state machine (FSM) enums, flags and counters are ordinary `s` fields.")
c("Why.",
  "`m` exists on the continuous side because modes must change between flow evaluations",
  tag="X")
c("`m` exists on the continuous side because modes must change between flow evaluations, which is what handlers do.")
c("On the discrete side `g` already runs at the only instants at which anything may change.")
c("A second store would duplicate the discrete tier's own state semantics under another name.")
c("### 3.3 Assembly")
c("An assembly is pure composition.")
c("It holds submodels, local wires and boundary faces.",
  "It holds child components, local wires and boundary faces (the names ports wear on a component's boundary).")
c("It has no dynamics of its own.")
c("Hybridness emerges at the assembly level.")
c("An aircraft is continuous vehicle parts plus discrete avionics parts.")
c("The two-leaf split was upheld against the integrate-and-dump challenge (§3.4, D-056).",
  cites=["§3.4", "D-056"])
c("Assemblies are flattened away for ordering.",
  "Assemblies are flattened away for ordering (D-019).",
  newcites=["D-019"], tag="C")
c("They are retained as the navigation and introspection hierarchy (GUI, logging, paths) and as declaration-level rate scopes (§10.5).",
  "They are retained as the navigation and introspection hierarchy (GUI, logging, paths) and as declaration-level rate scopes (§10.5, D-019).",
  cites=["§10.5"], newcites=["§10.5", "D-019"], tag="C")

ADDED = [
    "§3.1 describes the continuous component, §3.2 the periodic discrete component and §3.3 the assembly, and §3.4 justifies the two-leaf split.",
    "the declared function defining an event's predicate",
    "the per-component hook `x_projection`",
    "finite-state machine",
    "the addressable unit of the model",
    "The rule of meaning separates a command from a detection.",
    "On the continuous tier, a commanded reset of state, whose condition arrives as an input, still lands through an event whose guard reads that input (§5.3, D-141).",
    "an instantaneous input→output dependence",
    "the framework-owned home of a state letter",
    "the names ports wear on a component's boundary",
]

claims = []
for i, (old, new, cites, newcites, tag, ruling) in enumerate(S, 1):
    d = {"id": f"C-{i:03d}", "old": old, "new": new, "where": "new", "cites": cites}
    if newcites is not None:
        d["newcites"] = newcites
    d["tag"] = tag
    if ruling:
        d["ruling"] = ruling
    claims.append(d)

with open("inventory.json", "w") as f:
    json.dump({"claims": claims, "added": ADDED}, f, indent=1, ensure_ascii=False)
    f.write("\n")
