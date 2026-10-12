# Unit A, phase 1 (blind read of new.md)

Purpose
- V1 Redstone is a framework for modeling and simulating hierarchical hybrid causal systems. [glossary g-hybrid-causal-system]
- V2 Gloss: hybrid causal systems mix continuous dynamics, periodic discrete dynamics and events, and exchange values through directed ports.
- V3 Its home domain is aircraft GNC: vehicle dynamics, sensors and avionics.
- V4 Simulated offline or interactively in real time.
- V5 The formalism itself is domain-neutral.

Capabilities
- V6 An author writes a tree of components in plain Julia. [g-component]
- V7 Gloss: components are the units of modeling.
- V8 The build checks the tree.
- V9 A simulation runs a `Model`. [§9]
- V10 Gloss: a `Model` is the tree compiled at one scalar type, ready to step. [g-model, §9]
- V11 Continuous dynamics with algebraic outputs, integrated on a fixed step. [§2, §10]
- V12 Events either located by root-finding or checked at step boundaries. [§2, §10]
- V13 Multi-rate periodic discrete dynamics at declared sample times. [§3.2, §10.5]
- V14 Held zero-order between ticks. [§3.2, §10.5]
- V15 The build derives execution order from declared feedthrough. [§5, §9]
- V16 The build rejects algebraic loops, naming the cycle. [§5, §9]
- V17 A runtime periphery writes by staging and reads by snapshot. [§11, §12]
- V18 Gloss: the periphery is the devices, GUI and scripts that exchange data with a running simulation. [g-periphery]
- V19 An input trace replays any run bit-identically. [§11.5]
- V20 Stopped-sim services for initialization, trim and linearization. [§14]
- V21 Linearization (or the services) use exact AD Jacobians. [§14]

Design criteria
- V22 The design answers to five criteria.
- V23 It weighs each guarded addition against them. [g-guarded-addition]
- V24 Gloss: a guarded addition is a capability the design admits but does not build.
- V25 Zero-allocation stepping and type stability is a criterion.
- V26 The phase bodies the stepping loop runs allocate nothing. [§7.5, §9.7]
- V27 CI asserts it. [§7.5, §9.7]
- V28 Real-time interactive operation: a simulation runs paced against the wall clock. [§10.7, §11]
- V29 With devices and a GUI attached. [§10.7, §11]
- V30 Live introspection: every published signal can be inspected by path, during a run and after it. [§11.2]
- V31 Components compose hierarchically. [§6, §8]
- V32 A component substitutes for another behind the same declared contract. [§6, §8]
- V33 Structure is declared and checked at build time. [§8.4, §13]
- V34 So a mistake fails where it was made, with a diagnostic naming it. [§8.4, §13]
- V35 Components are plain Julia with no macro DSL. [§8.1]
- V36 So debugging, tooling and comprehension work on the language's own terms. [§8.1]

Origins
- V37 Redstone began as a replacement for FlightCore, the simulation core of Flight.jl.
- V38 Flight.jl also holds FlightPhysics (physics library) and FlightApps (applications).
- V39 The early design read those two packages as its requirements.
- V40 Every capability they demonstrated had to survive; none of their interfaces had to.
- V41 Older entries in decisions.md reason against FlightCore and cite that code.
- V42 Case studies that tested the design against that code live in companions/flight_case_studies.md.
- V43 Redstone does not depend on Flight.jl.

Scope
- V44 This document is the normative statement of the design. [g-normative]
- V45 It states what the framework is, in the present tense.
- V46 Part I: formalism and component model. Part II: authoring and build. Part III: execution and runtime periphery. Part IV: failure handling and stopped-sim services.
- V47 Appendices index author-facing contracts, API, diagnostic kinds, vocabulary.
- V48 pending.md records what the implementation still owes, and open design questions.
- V49 It also lists release work this document does not ask for.
- V50 Explainers in companions/ are not normative; this document wins on disagreement.
- V51 Decision rationale lives in decisions.md, including alternatives considered and reasons rejected.
- V52 This document cites it as linked D-nnn entries, one entry per settled decision.
- V53 Entry numbers are stable and never reused, so a citation always names the same entry.
