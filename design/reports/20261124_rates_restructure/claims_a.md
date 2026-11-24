# Claims A: spec.md §10.5, lines 6778–7028

Claim inventory of spec.md §10.5, lines 6778–7028. The range runs through the first paragraph of the next subsection, "Simultaneous ticks" (7020–7027), so I included it as A-139 to A-143. I did not edit, create or commit any file.

All rows below carry marks only where a marker applies. A "–" in `marks` means none.

| id | line | kind | claim | cites | marks |
|---|---|---|---|---|---|
| A-001 | 6780 | ptr | A model runs several clocks at once: integrator steps up to `h_max` inside frames of `Δt_frame`. | – | – |
| A-002 | 6781 | ex | Examples of rates: an inner control loop at one rate, an outer loop at another, a receiver at a third. | – | – |
| A-003 | 6783 | law | Each rate's component must hold its outputs steady between its own firings. | – | – |
| A-004 | 6784 | ptr | Well-definedness needs three things fixed: the shared time lattice, the test deciding which components run at a boundary, the declaration surface. | – | G:boundary |
| A-005 | 6788 | ptr | The section fixes the three things in that order. | – | – |
| A-006 | 6792 | law | Every discrete component's period is an integer multiple of the base tick period `Δt_base`. | D-019 | B, G:component, G:tick |
| A-007 | 6794 | ptr | That integer-multiple lattice is the harmonic grid (definition). | – | G:harmonic-grid |
| A-008 | 6794 | law | `Δt_base` stands in no required ratio to `Δt_frame` or to `h_max`. | §9.2, D-445, D-449 | – |
| A-009 | 6798 | decl/mech | Frames are counted by frame index `k`; base ticks by tick index `n`, the base tick at `t₀ + n·Δt_base`. | – | G:frame, G:tick-index |
| A-010 | 6800 | law | The frame count and the tick count are independent. | – | – |
| A-011 | 6801 | ptr | A base tick at which some component is due is a due instant (definition). | – | G:due |
| A-012 | 6801 | law | Every due instant is a boundary. | D-445 | B |
| A-013 | 6802 | law | A base tick at which nothing is due is no boundary. | D-445 | B |
| A-014 | 6803 | mech/law | The loop ends an integration step at each due instant. | D-449 | – |
| A-015 | 6804 | law | A due instant ends a span, the stretch between two mandatory instants. | D-449 | G:mandatory-instant |
| A-016 | 6806 | law/why | Ticks land on boundaries, the only place anything discrete happens. | – | – |
| A-017 | 6807 | law | A boundary that is no due instant has no tick index. | – | – |
| A-018 | 6808 | ex | Such boundaries include a frame top or step end where nothing is due, and a `t*` event boundary. | §10.4, D-185, D-288 | – |
| A-019 | 6812 | law | However an author declares a rate, at any nesting depth, it reduces to two integers in base ticks per discrete component. | D-185, D-291 | B |
| A-020 | 6814 | mech | The build compiles a declaration to an anchor and two integers in the anchor's ticks, the triple `(a, Dₐ, Φₐ)`. | §9.1, D-283 | – |
| A-021 | 6816 | decl | The deployment binds `Δt_base`, and with it the base-tick pair. | §9.2 | – |
| A-022 | 6817 | law | The divisor `D₀` is the component's period in base ticks. | – | G:divisor |
| A-023 | 6818 | law | The phase `Φ₀` is the component's offset in base ticks. | – | G:phase |
| A-024 | 6819 | law | The pair is kept in canonical residue `0 ≤ Φ₀ < D₀`. | – | – |
| A-025 | 6820 | law | Hence a component's ticks fall at base-tick indices `Φ₀`, `Φ₀ + D₀`, `Φ₀ + 2D₀`, and so on. | – | – |
| A-026 | 6823 | law | A component is due at a boundary when `(n − Φ₀) % D₀ == 0`, with `n` the boundary's tick index. | D-185, D-291, D-479 | B, G:due |
| A-027 | 6825 | law | That subtraction and remainder are the whole admission test. | – | – |
| A-028 | 6825 | mech | The test costs one subtraction more than a phase-free test, over a lattice the deployment fixes. | – | – |
| A-029 | 6826 | ptr | The declaration surface below says where a component's `(D₀, Φ₀)` comes from. | – | – |
| A-030 | 6831 | law | A discrete component's `y_state`/`y_direct` run only at its own ticks. | D-019 | B |
| A-031 | 6832 | law | Its cells (entries in the signal table) hold in between. | – | G:cell, G:signal-table |
| A-032 | 6833 | ptr | This is zero-order hold (ZOH), stated in sweep terms; a sweep is one pass through the execution order. | – | G:sweep, G:execution-order |
| A-033 | 6835 | why | Re-running a discrete component's stages at every boundary would un-sample a sampled-data controller. | – | – |
| A-034 | 6839 | mech | Delivering the hold takes two statically distinct sweep variants, compiled from one entry list. | D-147 | B |
| A-035 | 6840 | why | Discreteness is a build-time fact, so the split is static, not a runtime test. | – | – |
| A-036 | 6843 | mech | The interior sweep walks continuous entries only. | D-147 | – |
| A-037 | 6844 | mech | RK stage evaluations and localization guard trial evaluations run the interior variant. | §10.3, §10.4 | G:guard, G:trial-evaluation |
| A-038 | 6845 | ptr | A trial evaluation is a value at a single instant inside the step (gloss). | – | – |
| A-039 | 6846 | law | The ZOH therefore holds mid-step by construction. | – | – |
| A-040 | 6846 | mech | Discrete entries are absent from the interior walk at compile time, not gated at runtime. | – | – |
| A-041 | 6847 | mech | The hot path carries no gating test at all. | – | – |
| A-042 | 6849 | mech | The boundary sweep walks the full list, with discrete entries gated by `(n − Φ₀) % D₀` against the boundary's `n`. | D-147 | B, G:boundary-sequence |
| A-043 | 6851 | mech | The boundary sweep is the variant the §10.6 macro-sequence runs. | §10.6 | G:boundary-sequence |
| A-044 | 6852 | mech | It is not one fixed list: different boundaries run different subsets of the execution order. | – | – |
| A-045 | 6855 | mech | The split applies to both sweep blocks. | D-147 | B |
| A-046 | 6856 | mech | The discrete tier's `y_state` entries are absent from the interior stage-1 walk, as its `y_direct` entries are from the interior stage-2 walk. | – | G:tier |
| A-047 | 6858 | decl | Interior phase bodies take no arguments; boundary bodies take the tick index. | §9.7 | – |
| A-048 | 6863 | mech | The due set is computed once per boundary and reused by every re-sweep of its quiescence iteration. | D-147 | B, G:quiescence |
| A-049 | 6864 | ptr | Quiescence is the fixed point where a round of handlers fires nothing. | §10.6 | – |
| A-050 | 6866 | law | The due set is a property of the boundary, not of the sweep call. | – | – |
| A-051 | 6866 | why | That holds because a due component is at its tick instant for the whole boundary, not one round of it. | – | – |
| A-052 | 6870 | ptr | Each kind of boundary has its own due set. | – | – |
| A-053 | 6872 | law | At a due instant the due set is every discrete component whose gate admits `n`, the `(D₀, Φ₀)` with `(n − Φ₀) % D₀ == 0`. | – | – |
| A-054 | 6874 | law | A due instant may be a frame top or an instant inside a frame. | – | – |
| A-055 | 6876 | law | At a frame top or step end that is no due instant the due set is empty. | D-185, D-445 | – |
| A-056 | 6877 | mech | Emptiness is by arity selection, not by a tick index whose every gate fails. | D-185, D-445 | – |
| A-057 | 6878 | why | No component is at a tick instant there. | – | – |
| A-058 | 6879 | law | At a `t*` boundary the due set is empty for the same reason. | – | – |
| A-059 | 6880 | why | A modulo test against the last tick's index would wrongly re-admit that tick's due set. | – | – |
| A-060 | 6881 | law | At boundary zero the due set is everything with `Φ₀ = 0`. | D-185, D-205, D-291 | G:boundary-zero |
| A-061 | 6882 | ptr | Boundary zero is the initialization boundary; it runs the ordinary macro-sequence with an empty integrate (gloss). | – | G:boundary-zero |
| A-062 | 6884 | why | At tick index 0 the gate reads `(0 − Φ₀) % D₀ == 0`, which under `0 ≤ Φ₀ < D₀` holds iff `Φ₀ = 0`. | – | – |
| A-063 | 6885 | mech | Nothing implements this rule; it falls out of the ordinary gate. | – | – |
| A-064 | 6886 | law | Dueness at boundary zero governs the `s_update` calls alone. | – | – |
| A-065 | 6887 | law | Output stages publish at boundary zero due or not. | D-205, §14.5 | – |
| A-066 | 6890 | law | An offset component's first tick is at `Φ₀·Δt_base`. | – | – |
| A-067 | 6891 | law | Until then its cells hold its boundary-zero publication. | – | – |
| A-068 | 6891 | law | Its output stages still run at `t₀`, evaluated from the authored world. | D-205, §14.5 | – |
| A-069 | 6893 | law | The probe's synthesized values reach no published cell. | – | G:probe |
| A-070 | 6894 | ptr | The probe is the build's single evaluation of a user function with real values. | §9.3 | G:probe |
| A-071 | 6895 | law | In a phase-free model every `Φ₀` is 0, so everything is due at boundary zero and the distinction is empty. | – | – |
| A-072 | 6898 | decl | A component dark until its first tick is a modeling decision, spelled by the author as a validity flag or a mode. | D-205 | – |
| A-073 | 6899 | law | The framework withholds no publication by default. | D-205 | – |
| A-074 | 6904 | law | The mandatory instants are the frame tops and the due instants. | §2.2 | G:mandatory-instant |
| A-075 | 6905 | law | A span runs from one mandatory instant to the next. | §2.2 | – |
| A-076 | 6905 | mech | The loop advances from mandatory instant to mandatory instant. | – | – |
| A-077 | 6906 | law | A fixed-step backend takes a span of exact length `l` in `N = ⌈l / h_max⌉` equal steps of `l / N`. | §9.2, D-449, D-479 | – |
| A-078 | 6908 | law | With no deployment bound, a span is one step. | §9.2, D-449, D-479 | – |
| A-079 | 6909 | mech | The seam integrates by whatever length a step has, as for the remainder step after `t*`. | §10.2, §10.4 | – |
| A-080 | 6910 | law | Since a span's steps are equal, the method never makes a short step of its own. | – | – |
| A-081 | 6913 | law | A proposing backend's step is shaped by the same rule over the distance to the next mandatory instant. | §10.2, D-460 | – |
| A-082 | 6914 | law | With `r` the distance and `p` the proposal, the `Model` takes `r / N`, `N = ⌈r / min(p, h_max)⌉`. | D-460 | – |
| A-083 | 6916 | law | `N` is capped at `⌊r / h_min⌋` and is at least 1. | D-460 | – |
| A-084 | 6917 | law | A fixed-step method is the same rule under an infinite proposal. | – | – |
| A-085 | 6917 | law | Division never cuts a step below the floor `h_min`. | – | G:floor |
| A-086 | 6918 | law | A distance shorter than the floor is one step. | – | G:floor |
| A-087 | 6919 | why | The rule leaves no sliver before a mandatory instant. | – | – |
| A-088 | 6920 | why | It never cuts a proposal to less than half, so the controller recovers in one step. | – | – |
| A-089 | 6921 | law | The cap can lengthen a step past its proposal near the floor; such an attempt is the floor's. | §10.2 | – |
| A-090 | 6923 | mech | The rule is recomputed at every step, from the clock. | – | – |
| A-091 | 6923 | mech | So a proposal that grows inside a span can cost one step. | – | – |
| A-092 | 6926 | mech | The loop compares mandatory instants as whole multiples of one exact unit, `Δt_unit`. | – | G:dt_unit |
| A-093 | 6927 | law | `Δt_unit` is `gcd(Δt_frame, Δt_base)`, or `Δt_frame` when no discrete component exists. | – | G:dt_unit |
| A-094 | 6928 | decl | The loop derives `Δt_unit`; no deployment keyword sets it. | D-479 | B |
| A-095 | 6929 | mech | Finding the next mandatory instant and testing coincidence are integer comparisons. | D-445 | – |
| A-096 | 6931 | mech | The next due instant is one modular computation per schedule row: the first base-tick index past the instant that the row's gate admits. | – | – |
| A-097 | 6933 | mech | The nearest next due instant is the minimum over the rows. | – | – |
| A-098 | 6934 | mech | The bound enters as an exact ratio to the unit, so a span's step count is one integer division rounded up. | – | – |
| A-099 | 6935 | mech | A step end inside a span has no position on the unit and needs none, as no mandatory instant lies inside a span. | – | – |
| A-100 | 6937 | law | Two due instants a unit apart make a span one unit long, a step of its own, never merged into a neighbour. | – | – |
| A-101 | 6940 | law | A step integrates by the float distance between its two clocks. | D-455 | B |
| A-102 | 6941 | mech | Where the end's clock is known beforehand (mandatory instant, step end in a span), the length is end clock minus start clock. | D-455 | – |
| A-103 | 6943 | mech | Where the length is chosen first (proposing backend), the step integrates by that length and the end clock is start plus length. | §10.2, D-452 | – |
| A-104 | 6946 | law | A model with localized events and one without integrate a step by one length, so an event finding no crossing moves no trajectory. | – | – |
| A-105 | 6947 | law | Under a fixed-step method a bound that divides the span steps by `h_max`, to the clock's round-off. | – | – |
| A-106 | 6949 | law | A step can exceed `h_max` by an ulp of the clock. | – | – |
| A-107 | 6951 | mech | The clock at a step's end is written once, from an index wherever the `Model` knows the instant exactly. | D-445 | – |
| A-108 | 6953 | mech | A frame top is `t₀ + k·Δt_frame`. | – | – |
| A-109 | 6953 | mech | A due instant off the frame tops is `t₀ + n·Δt_base`. | – | – |
| A-110 | 6954 | mech | A fixed-step method's step end inside a span is the span's exact start plus `i·(l / N)`, from count `i`, never accumulated. | §10.4, D-449 | – |
| A-111 | 6955 | law | Every instant the `Model` knows exactly takes the `Float64` nearest it as its clock. | D-456 | B |
| A-112 | 6957 | law | The origin is exact, so the rule holds from any origin. | D-457 | – |
| A-113 | 6958 | mech | The loop puts the origin and `Δt_unit` over one denominator where the origin is set. | – | – |
| A-114 | 6959 | mech | A clock is then one integer multiply-add and one division. | – | – |
| A-115 | 6960 | law | The division rounds once to nearest at every magnitude. | D-458 | B |
| A-116 | 6961 | law | Boundary zero's clock is the same formula's at position 0. | D-458 | B |
| A-117 | 6962 | mech | While both integers stay below `2⁵³`, one float division does it. | – | – |
| A-118 | 6963 | mech | Beyond that, an exact long division does it. | – | – |
| A-119 | 6964 | ex | A wall-clock float origin such as `time()` needs the exact long division from frame 0. | – | – |
| A-120 | 6965 | ex | At `Δt_frame = 3//10`, frame 3 reads `0.9`, so `Step(t_step = 0.9)` fires at that boundary, in one snapshot. | – | – |
| A-121 | 6968 | law | The step split follows the schedule, not the state. | – | – |
| A-122 | 6968 | law | A `Model` at a `Dual` takes the steps the `Float64` model takes, though its discrete tier is frozen. | §9.4, D-444 | – |
| A-123 | 6972 | decl/mech | The loop's positions are `Int`s, so a run is refused whose positions in `Δt_unit` would leave `Int`. | – | – |
| A-124 | 6973 | why | The clock bounds a run more tightly: positions are exact and ordered, but the clock has `Float64` resolution. | – | – |
| A-125 | 6975 | mech | Each boundary's clock is rounded from its own formula. | – | – |
| A-126 | 6976 | decl | A run is refused where two distinct boundaries could take clocks that are equal or out of order. | D-450 | B |
| A-127 | 6978 | why | Every index-written clock is the float nearest its instant `t`, within half an ulp. | – | – |
| A-128 | 6979 | why | Rounding to nearest keeps order, so two such clocks are never out of order. | – | – |
| A-129 | 6980 | why | Two clocks stay distinct while an ulp of `t` is below the gap between them. | – | – |
| A-130 | 6981 | law | Two consecutive boundaries lie at least a gap `δ` apart. | – | – |
| A-131 | 6982 | law | The gap `δ` is `Δt_unit` between two mandatory instants. | – | – |
| A-132 | 6982 | law | Between two equal steps `δ` is more than `h_max / 2`, since a span `l > h_max` takes `N = ⌈l / h_max⌉ < l / h_max + 1` steps. | – | – |
| A-133 | 6984 | law | Under a proposing method `δ` is the lesser of `Δt_unit` and `h_min`, since no shaped step is shorter than the floor. | D-460 | – |
| A-134 | 6986 | law | A run from `t₀` may reach an instant `t` only while `\|t₀\| + 2·(t − t₀) < 2⁵⁰·δ`. | – | code |
| A-135 | 6993 | why | The left side bounds `\|t\|`, and the clocks stay distinct while it is below `2⁵²·δ`. | – | – |
| A-136 | 6994 | why | The bound keeps a factor of 4 inside that, as margin for the float arithmetic computing the last frame. | D-458 | – |
| A-137 | 6995 | ex | With `Δt_unit` of 1 µs and no finer bound, a run from `t₀ = 0` resolves about 17 years. | – | – |
| A-138 | 6996 | ex | A base tick of `1e-17` seconds leaves no 10 ms frame resolved at all. | – | – |
| A-139 | 6997 | law | The refusal does not cover a `t*` boundary, which lies on no lattice and is located only to `localization_tol·Δt_frame`. | §10.4 | – |
| A-140 | 7001 | law | The two bounds give one last frame: the lesser of the last frame the lattices index in an `Int` and the last frame the origin's clock resolves. | – | – |
| A-141 | 7003 | decl | An advance that names a run past the last frame refuses it, by end time or by frame count. | §12.4, §12.6 | – |
| A-142 | 7004 | decl | `frame!` refuses such a frame too. | §12.4, §12.6 | – |
| A-143 | 7005 | decl | `init!` refuses an origin whose first frame is already past the last frame. | §14.5 | – |
| A-144 | 7006 | law | An unbounded run therefore ends at the last frame top, with that refusal as its loop error. | §13.6 | – |
| A-145 | 7009 | ex | Worked example setup: 20 ms frame, `RK4()`, 100 µs base grid, components at 0.1 s and 0.1001 s. | – | – |
| A-146 | 7010 | ex | The first component's ticks fall on frame tops; the second's fall one base tick later each period, so one frame splits into two spans. | – | – |
| A-147 | 7012 | ex | The two coincide at 100.1 s, a frame top. | – | – |
| A-148 | 7013 | ex | Over those 5005 frames, with no bound, 6000 steps: one per frame plus one in each of 995 frames with a due instant off its top. | – | – |
| A-149 | 7015 | ex | Under `h_max = 5 ms`, a frame with no interior due instant takes 4 steps of 5 ms. | – | – |
| A-150 | 7016 | ex | A frame holding a due instant takes its two spans in 4 or 5 equal steps between them; the run takes 21 000 steps. | – | – |
| A-151 | 7017 | ex | `show` reports 4 steps per unsplit frame and names the 0.1001 s component as splitting frames. | §9.2 | – |
| A-152 | 7022 | law | Several components can be due at one boundary, and settled machinery already orders them. | – | – |
| A-153 | 7023 | law | All due components run their output stages in topological order within the sweep. | – | – |
| A-154 | 7024 | law | All due `s_update` calls run after quiescence, in any order. | – | – |
| A-155 | 7025 | law | Each `s_update` reads the table and writes only its own `s` store. | – | – |
| A-156 | 7026 | law | The intra-tick ordering of a flight control system (FCS) cascade, outer loops feeding an inner loop, is a sweep property, not an update-order property. | – | – |

Notes on the table.
- The "Simultaneous ticks" rows (A-152 to A-156) start at line 7022, inside the requested range.
- Line numbers are the line where the claim starts. Where a sentence wraps, the claim's first word is on the line given.
- I wrote `\|` inside the A-134 and A-135 claims only to keep the markdown table intact. The spec text uses a plain `|`.

## Ambiguous claims

1. **A-009.** I could not tell whether "frame index k, tick index n" is a definition or a pointer. Part I (§2.1) may already define both. The kind could be `decl`, `law` or `ptr`.
2. **A-016.** "Ticks therefore land on boundaries, which is the only place anything discrete ever happens" is both a law and a consequence of A-012. The "therefore" demotes it per the "Rule first, reason after" rule.
3. **A-014 and A-015.** Both restate §2.1's "no integration step crosses a mandatory instant". Whether "the loop ends a step at each due instant" is `mech` or `law` depends on whether Part I owns the no-crossing law.
4. **A-025.** The tick-index list is a consequence of A-024, so it is arguably a separate `ex`.
5. **A-039.** "ZOH holds mid-step by construction" is a law, but it is derived from the mechanism in A-036 and A-040. The coordinator should check that it is not demoted by the "by construction" wording.
6. **A-056 and A-063.** Both say how the empty set or the boundary-zero rule is realized ("arity selection", "nothing implements this rule"). They are `mech` statements about absence of machinery. Keep them with the law they support.
7. **A-064 and A-065.** "Dueness governs `s_update` alone, outputs publish due or not" is a law. The bold D-205 ruling sits in §14.5, and this section only restates it.
8. **A-072.** "Dark until first tick is a modeling decision, spelled as a validity flag or a mode" mixes a law (A-073, no default withholding) with authoring doctrine. I split it into two rows.
9. **A-079.** "The seam integrates by whatever length a step has" uses the term "seam", which is not defined in this range.
10. **A-088.** "Never cuts a proposal to less than half" is stated as a rationale (`why`). It is also a checkable law about step lengths. It could be `law`.
11. **A-104.** "Localized event finding no crossing moves no trajectory" is `law`. It is stated as a consequence of the single-length rule (D-455). Part I §2.2 repeats it (see below).
12. **A-123.** "A run is refused whose positions would leave `Int`" is enforcement (`decl`). It is also a law that bounds the run. Part I's "Laws, not enforcement" rule says the law goes in Part I and the refusal stays where the check runs.
13. **A-124 to A-133.** The bound derivation (A-127 to A-133) is `why` for the bold ruling A-126. It is long, and it may count as adversarial or mechanism material. A-130 to A-133 also state `δ` as laws, since the bound `2⁵⁰·δ` depends on them.
14. **A-134.** The inequality is a law (it decides which runs are refused). Its `2⁵⁰` form carries a mechanism choice, the factor-4 margin (A-136).
15. **A-137 and A-138.** These are `ex`. Under the worked-example exemption they stay at full resolution.
16. **A-140 to A-144.** These are `decl`: which entry point refuses. The only law is "the run ends at the last frame". Cites to §12.4, §12.6, §13.6 and §14.5 are forward pointers.
17. **A-151.** "`show` reports…" is `ex` and also a `decl`-side fact about a diagnostic. It could be `ptr`.
18. **Bold ruling clause A-015.** The "due instant ends a span" clause carries D-449 but has no bold. It sits inside the bold sentence's neighbour, so the bold test needs a check after the move.
19. **Bold A-111.** "Every instant the `Model` knows exactly takes the `Float64` nearest it" has a Part I twin, §2.1 line 289 (see below). The bold may belong in only one place.

## Duplicates of Part I (§2–§7)

I checked §2.1 (lines 285–335) and §2.2 (lines 366–400). I did not sweep §3–§7 beyond a keyword search.

| This section | Part I statement |
|---|---|
| A-006 to A-007, harmonic grid | §2.1 line 285 states the base ticks as the lattice for every discrete schedule. |
| A-012 and A-013, due instant is a boundary, tick-free is none | §2.1 lines 318–319 (D-445) restate both. |
| A-015 and A-074 to A-075, mandatory instants and span | §2.1 lines 299–301 define the mandatory instants and state "No integration step crosses one" (D-449). §2.2 line 375 repeats the definition. |
| A-107 to A-112 | §2.1 lines 289–291 state that each instant is computed from its own index, never accumulated, and that the clock is the nearest float (D-445, D-456, D-457, D-458). |
| A-110 | §2.1 lines 326–329 state the fixed-step step-end rule (D-449). |
| A-077 to A-080 | §2.2 lines 372–381 state `N = ⌈l / h_max⌉`, equal steps `l / N`, and the one-step case (D-449). They give "equal unless a localized event splits one" in place of A-080. |
| A-081 to A-089 | §2.2 lines 383–388 state the proposing-backend rule and the floor (D-460, D-461). They do not give the formula with `N = ⌈r / min(p, h_max)⌉` or the cap `⌊r / h_min⌋`. |
| A-101 to A-104, step by clock distance | §2.2 lines 392–396 state this in prose and cite D-455, with the localized-event consequence of A-104. |
| A-092 to A-093, `Δt_unit` | §4796 and §4993 are in Part II. §4993 gives `Δt_unit` as `gcd(Δt_frame, Δt_base)` (D-471). Part I may not state it. |
| A-030 to A-033, ZOH | §1525 and §4027 use "zero-order hold" in passing. §845 mentions the ZOH plus `z⁻¹` delay. I did not check whether Part I states it as a law. |
| A-026, the gate | §4985 (Part II) states the gate `(n − Φ₀) % D₀ == 0` and cites §9.7. |

The A-077 to A-089 and A-101 to A-104 rows will need a content-preservation check on whichever side keeps the formulas. Part I (§2.2) does not state the `r / N` proposal rule or the `h_min` cap in full.
