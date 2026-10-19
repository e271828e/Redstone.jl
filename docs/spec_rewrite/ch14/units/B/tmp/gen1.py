import json
S = json.load(open('tmp/S.json'))
E = []
def F(i, **k): E.append(dict(old=S[i], **k))
def C(old, **k): E.append(dict(old=old, **k))
def A(t): E.append(dict(added=t))

# §14.4
C("### 14.4 One plan, two ways to apply it", note="title kept (R9, F16)")
C("The paradigm-change tax feared at execution does not materialize.",
  new="A resolved condition (the path-addressed sparse overlay that sets a build's state) is applied two ways, because a one-shot service and an iterating one want different things from the same validated list of condition entries (D-066).",
  tag="R", ruling="R8", newcites="D-066",
  note="R8 and F28: the context paragraph replaces the aphorism; F28's wording, 'entry list' made 'list of condition entries' (R13, F29). The condition link and gloss move here, the section's new first use. D-066 Position: 'Two ways to apply one compiled plan'")
A("The section gives the two ways, then the read-selector family.")
A("#### Applying a plan")
C("All string work, validation and addressing are functions of the shape of the condition (the path-addressed sparse overlay that sets a build's state).",
  new="All string work, validation and addressing are functions of the shape of the condition.",
  note="link and gloss moved to the context sentence, the new first use")
F(2)
C("Execution is therefore resolve-once/execute-many, with two ways to apply one plan.",
  new="Execution is therefore resolve-once/execute-many. A valid list of condition entries compiles two ways, one for each way to apply it.",
  tag="R", ruling="R9",
  note="F16 amended wording, its first sentence, with 'entry list' made 'list of condition entries' (R13); the per-plan sentences sit in each bullet. Code: ConditionPlan and SpecializedPlan, src/conditions.jl 254-275, 640-707 (survey F16)")
C("- Specialized `apply!` serves the service that iterates, trim's per-evaluation write.",
  new="- Specialized `apply!` serves the service that iterates, trim's per-evaluation write (D-066). Its plan holds, per leaf, a lens (the compiled navigation step of a condition entry), a destination and a converter.",
  tag="R", ruling="R7", newcites="D-066",
  note="list label becomes the bold headline clause of D-066's first semicolon ruling, 'specialized apply! ... for iterating services'. The plan sentence is F16's amended wording (R9); lens linked and glossed at its first use, gloss from #g-lens")
C("It unrolls stores through the baked lenses and converters.",
  note="store linked at its first use, no gloss")
C("Those are the same machine operations as today's in-place writes: zero-alloc, no strings, no dispatch.",
  new="Those are the same machine operations as FlightCore's in-place state writes, with no allocation, no strings and no dispatch.",
  tag="R", ruling="R12",
  note="'today's' names FlightCore's in-place writes to a Model's state (checked ~/.julia/dev/Flight.jl/lib/FlightCore/src/modeling.jl, Model and f_init!/f_ode! extended in place); mid-sentence colon goes")
F(7); F(8)
C("A `===` sweep over the prefix strings closes the remainder.",
  new="A `===` comparison of each prefix string closes the remainder.",
  tag="R", ruling="R9", note="F17: sweep is reserved for a pass through the execution order")
F(10)
C("Shape drift (a tree of another type, or a prefix that differs at a position) is `ConditionShapeDrift` (Appendix C), a structured error rather than silent corruption.",
  new="Shape drift is a tree of another type, or a prefix that differs at a position. It is `ConditionShapeDrift` (Appendix C), reason `:tree_type` or `:prefix`, a structured error rather than silent corruption.",
  tag="R", ruling="R14",
  note="kind named with its reasons, src/conditions.jl 781, 785 (:tree_type, :prefix); one parenthetical per sentence")
C("The cost is Julia codegen once per condition shape, and it grows with the shape's writes.",
  new="The cost is Julia codegen once per condition shape, and it grows with the shape's writes (D-066).",
  tag="C", newcites="D-066",
  note="D-066 Position '~10-50 ms codegen once per shape' and its 2026-10-02 annotation, 'the codegen cost grows with the shape's writes'")
F(13)
C("That cost is noise against the model's own first-sweep warmup (seconds), and against the 10³–10⁴ optimizer evaluations the codegen amortizes over.",
  new="That cost is noise against the model's own first-sweep warmup (seconds). It is paid once per tree type per session, so it spreads over every evaluation of every trim of that shape, an envelope of trims included.",
  tag="R", ruling="R9", note="F18 amended: the 10³-10⁴ count is cut as unsupported against §14.7's ~5-15 evaluations")
C("- The dynamic walk serves the one-shot uses, `init!` and `linearize`'s operating condition.",
  new="- The dynamic walk serves the one-shot uses, `init!`, `linearize`'s operating condition and trim's setup write (§14.8, D-066).",
  tag="R", ruling="R9", newcites="§14.8 D-066",
  note="F19 adds trim's setup write (src/trim.jl 480-483; §14.8 12186-12187). List label becomes the bold headline of D-066's second semicolon ruling, 'dynamic entry-list walk ... for one-shot init' (R7)")
C("It executes the same validated entry list by runtime dispatch per write.",
  new="It executes the same validated condition entries by runtime dispatch per write, from a plan that holds the converted values themselves.",
  tag="R", ruling="R9", note="F29 (bare entry, R13) and F16's amended last sentence, 'The dynamic walk's plan holds the converted values themselves'")
F(17); F(18); F(19)
C("Rule. Which of the two a service uses is internal, never user-facing API.",
  new="Which of the two a service uses is internal, never user-facing API.",
  note="the Rule. label goes; stated plain, since no entry rules it for the two ways (D-130 assumes it as a precedent); §13.3 10283 and D-130 rely on the sentence")
F(22, tag="M", note="M4: moved down after the gather twin, where readers are defined"); F(23, tag="M", note="M4"); F(24, tag="M", note="M4")
C("#### The read-selector family", note="no file links this anchor")
C("The read-selector family is closed.",
  new="The read-selector family is closed (D-095).",
  tag="C", newcites="D-095",
  note="bold kept on D-095's one ruling, first in reading order ('spelled with a get_ prefix and completed'); the prefix sentence below cites it plain")
F(26); F(27)
C("Rule. `leaf` is a leaf address: the field or face name, followed by `.name` and `[k]` or `[k,l]` steps in any order, as in `\"pose.q_eb[2]\"`, `\"ω_eb_b[1]\"` or `\"J[1,3]\"`.",
  new="`leaf` is a leaf address (D-276). It is the field or face name (the name a port wears on its component's boundary), followed by `.name` and `[k]` or `[k,l]` steps in any order, as in `\"pose.q_eb[2]\"`, `\"ω_eb_b[1]\"` or `\"J[1,3]\"`.",
  tag="R", ruling="R7", newcites="D-276",
  note="Rule. label goes; bold headline of D-276's Position, 'The second argument of every read selector is a leaf address'; mid-sentence colon goes; face linked and glossed at its first use (late link fixed), gloss from #g-face")
C("A bare `Symbol` is the short form of a plain name, so `get_state(\"kin\", :θ)` reads `get_state(\"kin\", \"θ\")`.",
  new="A bare `Symbol` is the short form of a plain name, so `get_state(\"kin\", :θ)` reads `get_state(\"kin\", \"θ\")` (D-276).",
  tag="R", ruling="R19", newcites="D-276", note="bold headline of D-276 bullet 1, bold nowhere else in the frozen spec")
