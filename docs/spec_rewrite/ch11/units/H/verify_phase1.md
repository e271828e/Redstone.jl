# Unit H, phase 1 (blind): assertions in new.md

Intro (1–7)
- V1 §11.7 specifies how a GUI widget resolves its port to the root input behind it, when it is live, what it displays, when it stages, and the framework's half of the panel convention. (scope pointer)
- V2 Port = addressable unit, one declared name; root input = the only thing the periphery may write. (glosses)

Port resolution (11–30)
- V3 Panels remain per-component extensions in FlightCore's style, e.g. `GUI.draw!(ctx, ::LowPassFilter)`.
- V4 Panels are discovered by walking the assembly. (assembly gloss: pure composition, component-typed fields are children)
- V5 **Widgets name the component's own ports, never root inputs.** [D-026] (bold)
- V6 Build-time wiring answers statically and exactly: is this port transitively driven by a root input, and which one.
- V7 Every input port has exactly one source [§6.1]; so resolution is total, two outcomes.
- V8 Root-driven within the GUI's claim -> live; peeks and stages the resolved root input through the GUI's own staging cell. (claim gloss: set of root inputs a device may write; staging cell gloss: per-device atomic holding place for pending writes; peek: GUI display rule)
- V9 Component-driven, or root-driven under another device's claim -> read-only rendering; displays driven value from the snapshot, visually distinct, with its source label ("driven by `avionics/throttle_cmd`", canonical slash form [§8.6]).

Dead slider (32–44)
- V10 This retires FlightCore's dead-slider convention, replaced by checked structure.
- V11 **A widget is live exactly when the underlying input is yours to command in this configuration.** [D-045] (bold)
- V12 The dead slider is the throttle of `Cessna172Xv1`, first variant of FlightApps' Cessna 172X model; engine panel slider visually live, avionics silently overwrite it every cycle; who commands what lives in user's head.
- V13 User-commandability is a wiring decision made where configurations are made.
- V14 Command-plus-manual-override is a mux component with a root-wired select; explicit structure, not two writers racing (same race as drag phase in §11.4 worked example, ruled out the same way).
- V15 One obligation on the GUI: read-only rendering is first-class, not an error state, because the author of `input_slider!` cannot know at authoring time whether it will be live. [D-026]

Derived liveness (46–64)
- V16 Liveness is a derived property; resolution is transitive. [D-045]
- V17 Live iff feed chain terminates in a root input AND that root input lies inside the GUI's own claim [D-174] in the run's frozen surface partition (root-input exclusivity, §11.3).
- V18 Feed chain walked through local wires and interface connections across all levels, not just local assembly.
- V19 Claim may have been computed from the unclaimed complement under `is_greedy`, or enumerated by a partial-claims binding (value passed at `attach!`, §11.6), one face at a time. Either way "live" reads "inside the surface I declared for".
- V20 Roster (attached devices with claims) frozen for a run since `attach!`/`detach!` are stopped-sim operations [§11.3].
- V21 Liveness is a static fact of the run, baked once with port resolution at run start, never consulted against mutable claim state at render.

No marking (66–80)
- V22 No per-port "GUI-controlled" marking anywhere; export chain is the marking, written by the one author entitled to write it.
- V23 A component's ports become GUI-commandable exactly when assemblies above surface them.
- V24 The switch between own-panel and external-provider driving is therefore automatic: at build time follows wiring archetype (scripted `World` wires a scenario component into the same faces interactive `World` exports to root); at run start follows roster claim state.
- V25 `World` names the example assembly of pure composition introduced in §8.8. (introducing clause)
- V26 Nominally-connected ports with a GUI override channel are rejected. [D-045]
- V27 **Unexported ports are unpokeable.** [D-045] (bold) "The honest cost stands."
- V28 FlightCore's poke-any-`u` workflow deliberately does not survive the contract visibility rule [§8.3].

Peek and staging (82–113)
- V29 **A widget displays its own pending write if any, else the snapshot value.** [D-026] (bold)
- V30 It peeks its own staging cell only; another device's pending write is invisible by design.
- V31 Another device's applied value arrives via the snapshot one frame later; cross-device peek is rejected. [D-026]
- V32 While paused, staged edits display indefinitely and apply at the un-pause drain (frame-top swap applying staged device writes to root inputs).
- V33 Fan-out consistent for free: widgets on ports resolving to same root input peek same pending value.
- V34 **Widgets stage on interaction events only.** [D-047] (bold)
- V35 Staging contract = stage-on-interaction (on edit or activation, never per render pass).
- V36 Value widgets (sliders, drags) stage new absolute level on edit; edge widgets (buttons) stage on activation a level computed from the peek; flaps button peeks `k`, stages `k+1`.
- V37 Levels doctrine makes this safe by construction: repeated staging of same level within a drain window is idempotent; no repeat-increment hazard.
- V38 Multi-click within one window counts correctly via own-pending-first peek.
- V39 Held buttons do not re-stage; otherwise after drain and snapshot catch-up, re-staging from peek would auto-repeat at frame rate. Activation edge is the intent.
- V40 Staging on every render pass is rejected [D-026]; under exclusivity [§11.3] no motivation; as insurance it would mask invariant violations at render rate [D-026].
- V41 Side benefit: staging traffic and trace noise drop from render-rate-while-grabbed to actual edits.

Orphan (115–126)
- V42 No claim-transition policy exists, because no claim transition can occur mid-run (freeze, §11.3).
- V43 The one liveness-adjacent display rule is the orphan case: read-only widget whose claiming device's task died renders that in its source label ("claimed by `T16000M` — task dead"), heartbeat surfaced in place [§12.2].
- V44 `T16000M` is FlightCore's type for the Thrustmaster T16000M joystick. (introducing clause)
- V45 Beside that, the widget displays the ordinary snapshot value, the orphaned root input's last drained level; orphan widget is read-only like any other, never blanked.
- V46 Orphaned root input therefore visible where user is looking, not only in status panel.

Framework half (128–190)
- V47 **The framework's half is fixed here, and the GUI package's half is deferred.** [D-270] (bold)
- V48 A panel reaches the framework through three values: port view, device handle, snapshot.
- V49 Port view = this section's baked verdict, one per declared port of every component, input and output.
- V50 Handle supplies the two reads the peek composes and the one write, `stage!`.
- V51 Snapshot supplies every driven value and the writer status the orphan label reads.
- V52 Nothing a panel needs reaches into the loop. [D-270]
- V53 Block lists four functions: port_views(handle), pending(handle, slot), peek(view, handle, snapshot), incumbent_status(view, snapshot).
- V54 **`port_views(handle)` builds one view per port of every component**, keyed by `(path, port)`, from build's wiring, handle's claim, exclusivity index. [D-270] (bold)
- V55 A view carries: terminal producer (`("", face)` when root-driven), liveness verdict, position in handle's staging schema when live, producer's cell address, incumbent writer of a root-driven port the GUI does not command.
- V56 GUI loop body builds table once at its top; that is after roster freeze, so incumbents are the run's; nothing at render resolves a name.
- V57 Handle carries build's `Structure` and nominal `Layout` by reference for this; the two things the bake needs that the handle did not hold.
- V58 Output port's view is read-only with itself as producer; generated panel reads every face through one lookup.
- V59 Port-view table (4 rows: own claim yes/position/the GUI; other device no/none/that device; unclaimed no/none/the harness; other component's port or own output no/none/none).
- V60 **`pending(handle, slot)` reads the handle's own staging cell with one acquire load and never takes it** [D-270] (bold); returns `Some(value)` when slot touched else `nothing`.
- V61 Staged batch never mutated after publication into staging cell, so load sees complete batch or none.
- V62 `peek` composes that read with snapshot: live view returns own pending when touched, else producer's cell off snapshot; read-only view skips staging cell, reads producer's cell.
- V63 Two ports resolving to one root input share slot and address = fan-out consistency.
- V64 Peek rule's one visible consequence (rule's own): between frame-top drain taking the staging cell and that frame's snapshot publication, live widget finds nothing pending and shows previous snapshot value, at most one frame's compute. [D-270]
- V65 Click in that window peeks old level and stages an already-drained level; idempotent by levels doctrine.
- V66 No device task reads the loop's store, so no reading is more current.
- V67 **`incumbent_status(view, snapshot)` returns the incumbent's writer record** from snapshot status [§11.8], or `nothing` for a port no device writes [D-270] (bold).
- V68 On that record `orphaned` = task returned or crashed; `stale` = silent heartbeat [§12.2]. Record tells exited loop from crashed one; label may. Label text is GUI package's.

Deferred (192–202)
- V69 GUI package's half (`pending.md`) is deferred; built-in GUI's parking [D-310] assigns it to browser client over bridge.
- V70 That half covers what client receives beside the three values, how a panel scopes to a child, and widgets.
- V71 Constraints fixed here: panels name own ports by face-name string; resolution and liveness baked at run start, never at render; liveness and peek arrive through framework-supplied context, never reaching into loop; assembly panels compose children by path.

Bold count: 9 bold spans (V5, V11, V27, V29, V34, V47, V54, V60, V67).
