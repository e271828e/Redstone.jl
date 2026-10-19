import sys; sys.path.insert(0, "ch13/scratch_step5/fix1")
from claims_edit import C
c = C("B")
def addnew(old, new, *rest):
    c.rep(old, old, new, *rest)
def gl(line, g): c.after(line, f"added: {g}")

c.rep('note: "entries" kept, per survey part E\'s carried item (Appendix D\'s fix)',
      'new: For an assembly they return the face names of `input_wires(c)` / `output_wires(c)`.',
      'note: step 5 (P1-14): bare "entries" becomes "the face names"; D-061\'s Position, "`input_faces`/`output_faces` return declaration-ordered face-name strings"')
n = "new: Resolving to a generic child is legal, as access at the level of a port (one declared input or output)."
addnew("old: Resolving to a generic child is port-level access and legal.", n); gl(n, "(one declared input or output)")
c.rep("new: | service | condition entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, taps, device read bindings, log extraction by `series` (§14.3, §14.7, §14.10, §11.2, D-406, D-407) | strict: no traversal past a generic child, checked at the authoring or mount level |",
      "new: | service | condition entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, taps (the selector lists linearization seeds and reports), device read bindings (the values passed at `attach!` that make a device framework-legible), log extraction by `series` (§14.3, §14.7, §14.10, §11.2, D-406, D-407) | strict: no traversal past a generic child, checked at the authoring or mount level |")
gl("old: | service | condition entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, taps (§14.3, §14.7, §14.10) | strict: no traversal past a generic child, checked at the authoring or mount level |",
   "(the selector lists linearization seeds and reports)")
c.after("added: (the selector lists linearization seeds and reports)", "added: (the values passed at `attach!` that make a device framework-legible)")
c.rep("new: | inspection | snapshot and log inspection (D-310) | the instance walk |",
      "new: | inspection | snapshot (the immutable per-boundary publication) and log inspection (D-310) | the instance walk |")
gl("new: | inspection | snapshot (the immutable per-boundary publication) and log inspection (D-310) | the instance walk |", "(the immutable per-boundary publication)")
n = "new: A generic seam (a narrow, named interface kept deliberately thin) is not an error for a client that never claimed substitutability."
addnew("old: A generic seam is not an error for a client that never claimed substitutability.", n); gl(n, "(a narrow, named interface kept deliberately thin)")
c.rep("new: Which of the three rules a client resolves under is internal framework fact, never user-facing API (D-130).",
      "new: Which of the three treatments a client resolves under is internal framework fact, never user-facing API (D-130).")
c.rep("added: A runtime failure of model code is a throw inside a frame (one iteration of the loop) or inside boundary zero,",
      "added: A runtime failure of model code is a throw inside a frame (one iteration of the loop) or inside boundary zero.")
c.rep("new: the initialization boundary, which runs the ordinary macro-sequence with an empty integrate.",
      "new: Boundary zero is the initialization boundary (a published consistency point), and it runs the ordinary boundary macro-sequence with an empty integrate.")
gl("new: Boundary zero is the initialization boundary (a published consistency point), and it runs the ordinary boundary macro-sequence with an empty integrate.", "(a published consistency point)")
c.rep("added: The framework catches it at one site, records where execution stood, and names how to reproduce it.",
      "added: The framework catches the failure at one site, records where execution stood, and names how to reproduce it.")
c.after("added: The framework catches the failure at one site, records where execution stood, and names how to reproduce it.",
        "added: The code inside the `Model`'s `try` is the guarded sequence.",
        "added: Ticks are the instants at which discrete leaves run their stages and update.")
c.rep("new: `frame!` never wraps per stage or per component (D-059).",
      "new: `frame!` never wraps per stage or per component (the unit of modeling, a leaf or an assembly of components) (D-059).")
gl("new: `frame!` never wraps per stage or per component (the unit of modeling, a leaf or an assembly of components) (D-059).", "(the unit of modeling, a leaf or an assembly of components)")
addnew("old: Framing information does not need to be caught into existence.", "new: Where execution stood does not need to be caught into existence.",
       "note: step 5 (P1-21): \"framing\" keeps its §13.2 sense (R7)")
c.rep("new: The second is which function is running, one of `y_state`, `y_direct`, `x_deriv`, `s_update`, a guard, a handler, or `x_projection`.",
      "new: The second is which function is running, one of `y_state`, `y_direct`, `x_deriv`, `s_update`, a guard (the declared function defining an event's predicate), a handler, or `x_projection`.")
gl("new: The second is which function is running, one of `y_state`, `y_direct`, `x_deriv`, `s_update`, a guard (the declared function defining an event's predicate), a handler, or `x_projection`.", "(the declared function defining an event's predicate)")
c.rep("new: Those are the RHS evaluations at interior RK stage points and the guard evaluations at the trial points of ITP or Brent root-finding (§10.4).",
      "new: Those are the evaluations of the RHS (the continuous derivative function) at interior RK stage points and the guard evaluations at the trial points of ITP or Brent root-finding (§10.4).")
gl("new: Those are the evaluations of the RHS (the continuous derivative function) at interior RK stage points and the guard evaluations at the trial points of ITP or Brent root-finding (§10.4).", "(the continuous derivative function)")
c.rep("new: They are the cursor frame (the copy of the cursor a `StepError` carries), the time, the frame-entry boundary index, the host of the catch, and the original exception as `cause`.",
      "new: They are the cursor frame (the cursor's copy at the catch), the time, the frame-entry boundary index, the host of the catch, and the original exception as `cause`.")
n = "new: The pointer names the frame-top boundary at which the failing frame began."
addnew("old: It names the frame-top boundary at which the failing frame began.", n); gl(n, "Replay is the ordinary loop re-driven from a recorded trace.")
addnew("old: A bare value thrown deliberately by model code is neither, and the constructor refuses it unframed.",
       "new: A bare value thrown deliberately by model code is neither, and the constructor refuses it, so it leaves the catch unwrapped.",
       "note: step 5 (P1-21): \"unframed\" is D-225's word for leaving the catch with no `StepError`; *frame* keeps R7's senses")
c.rep("added: The cursor frame and the pointer are then lost, and the lifecycle does not move as it does on the framed path.",
      "added: The cursor frame and the pointer are then lost, and the lifecycle does not move as it does when the catch builds a `StepError`.")
addnew("old: With the boundary masking in force (§12.4) a single interrupt never reaches the branch.",
       "new: With the boundary masking in force (§12.4) a single interrupt never reaches the interrupt branch.")
n = "new: `run!` and `replay!` discriminate the two by the roster (the list of attached device entries) (D-268)."
addnew("old: `run!` and `replay!` discriminate the two by the roster (D-268).", n); gl(n, "(the list of attached device entries)")
c.rep("new: Its cursor frame comes from the cursor, its time is `t₀`, and the species rule applies.",
      "new: Its cursor frame comes from the cursor, its time is `t₀`, its pointer is `0`, and the species rule applies.")
addnew("old: The pointer is `0`.", "new: its pointer is `0`", "note: step 5 (P1-26): moved into the sentence on the boundary-zero `StepError`'s fields, which it describes")
n = "new: The reproduction of a boundary-zero failure is `init!` under the same condition (the path-addressed sparse overlay that sets a build's state) (D-274)."
addnew("old: The reproduction of a boundary-zero failure is `init!` under the same condition (D-274).", n); gl(n, "(the path-addressed sparse overlay that sets a build's state)")
n = "new: No termination record (the stopped-sim value naming how the run ended) is written."
addnew("old: No termination record is written.", n); gl(n, "(the stopped-sim value naming how the run ended)")
c.rep("new: An `isfinite` pass over the flat state buffer, run by the model after every return from the integrator backend, fails fast as `NonfiniteState`, a `StepError` species naming the component, the state leaf and the frame-entry boundary.",
      "new: An `isfinite` pass over the flat state buffer (the contiguous vector backing all continuous state), run by the model after every return from the integrator backend, fails fast as `NonfiniteState`, a `StepError` species naming the component, the state leaf and the frame-entry boundary.")
gl("new: An `isfinite` pass over the flat state buffer (the contiguous vector backing all continuous state), run by the model after every return from the integrator backend, fails fast as `NonfiniteState`, a `StepError` species naming the component, the state leaf and the frame-entry boundary.", "(the contiguous vector backing all continuous state)")
c.rep("note: the italic label becomes a plain topic sentence",
      "new: and that placement is the whole of its value.",
      "note: the italic label became a plain topic sentence; step 5 (P1-28) joins it to the bold, which now heads the paragraph")
c.rep("new: The pass is the boundary's first act (D-157).", "new: The pass is the boundary's first act (D-157),")
addnew("old: It runs immediately after integrate returns, before `x_projection` and before the boundary sweep.",
       "new: The pass runs immediately after integrate returns, before `x_projection` and before the boundary sweep.")
n = "new: That is the inversion of error locality (the property that a mistake fails at the site of the mistake) (§8.4), designed out of the build and quietly reintroduced at runtime."
c.rep("new: That is the error-locality inversion (§8.4), designed out of the build and quietly reintroduced at runtime.", n); gl(n, "(the property that a mistake fails at the site of the mistake)")
c.save()
