# Citations of §10.5 in the design documents

All 177 citations of §10.5 are listed below with a tag each. I edited, created and committed nothing. Scratch copy of the rows: /private/tmp/claude-501/s/t.txt (pipe-separated).

Searched: spec.md (outside §10.5), log.md, companions/, code_map.md, pending.md, rules/ and the live Inspector files.
- Skipped as non-citations: the contents line spec.md:64 and the link-definition lines (spec 17671, log 21717, companions).
- `design/rules/*.md` has 0 hits.
- The Inspector repo has 1 live hit. Its only other hit is in a frozen `increments/` notes file, which I skipped.
- Tags were assigned from one line of context, so tagging is shallow wherever confidence is `l`.
- Log "Spec:" list lines are tagged by the entry's topic, at `l`. Pure long lists are `whole`.

Row format: `| line | section or entry | sentence | tag | conf |`

## spec.md
| line | section | sentence | tag | c |
|---|---|---|---|---|
| 173 | Capabilities | multi-rate discrete dynamics held zero-order between ticks | zoh | h |
| 286 | §2.1 | base ticks are the lattice for every discrete schedule | grid | h |
| 344 | §2.1 | clock that cannot separate lattice instants is refused (D-450) | clock | h |
| 491 | §2.2 | tick instants known in advance and scheduled | due | l |
| 764 | §3.2 | discrete runs at boundary zero or a later step end | due | l |
| 812 | §3.3 | assemblies serve as declaration-level rate scopes | scopes | h |
| 822 | §3.3 | assembly ends with one period and phase on the base grid (D-291) | compose | h |
| 1181 | §5.2 | Δt same in both output stages; phase never changes it | bundle | h |
| 1404 | §5.3 | discrete eval serves integration/root-finding via sweep variants (D-147) | zoh | l |
| 1433 | §5.3 | due updates run after quiescence, each writes own s (D-020) | simul | h |
| 1526 | §5.3 | ZOH holds outputs constant between ticks | zoh | h |
| 3425 | §7.x | assemblies have no state: no-atomic-assemblies rule | scopes | h |
| 3955 | §8.x | Δt arrives from the deployment Schedule, single source | bundle | h |
| 3993 | §8.x | due sampler's stages are gated into the sweep | zoh | l |
| 4010 | §8.x | semantics of §10.5 and §10.6 stated in author terms | whole | l |
| 4052 | §8.7 | the two forms §10.5 defines (D-185) | forms | h |
| 4056 | §8.7 | §10.5 holds wrappers' definitions and validation | forms | h |
| 4058 | §8.7 | unlisted discrete child defaults to Relative(1) | forms | h |
| 4075 | §8.7 | continuous bundle carries no Δt | bundle | h |
| 4083 | §8.7 | sample time is design ratio or instrument's intrinsic rate | library | h |
| 4462 | §9.1 | per-entry validity: wrapper-typed, Dₛ≥1, 0≤Φₛ<Dₛ | forms | h |
| 4484 | §9.1 | canonical residue holds in each anchor's subtree by induction | compose | h |
| 4712 | §9.2 | Δt_base is the discrete tier's lattice | grid | h |
| 4713 | §9.2 | h_max is the longest step, under every method | clock | h |
| 4740 | §9.2 | fixed-step takes span in fewest equal steps | clock | h |
| 4758 | §9.2 | lattices, step counts, coincidences decided on exact values | clock | h |
| 4797 | §9.2 | Δt_unit is the exact unit the loop counts in | clock | h |
| 4849 | §9.2 | Δt_frame and base tick each at least one Δt_unit | clock | h |
| 4871 | §9.2 | divisor leaving Int is refused (D-445, D-459) | clock | l |
| 4873 | §9.2 | h_max too fine to count one frame's steps in Int, refused | clock | h |
| 4898 | §9.2 | Schedule is single source of truth for Δt | bundle | h |
| 4902 | §9.2 | example worked in §10.5, three components under two scopes | example | h |
| 4994 | §9.x | Δt_unit is the unit the loop counts in | clock | h |
| 5059 | §9.x | scope finer than fastest member buys stagger room | stagger | h |
| 5658 | §9.5 | interior bodies hold no discrete entries to test | zoh | h |
| 5702 | §9.5 | arities follow the interior/boundary split | zoh | h |
| 5717 | §9.5 | zero-arg arities hold no discrete entries | zoh | h |
| 6013 | §10 intro | map line: §10.5 multi-rate tick scheduling | whole | h |
| 6031 | §10.1 | a tick falls at its own instant in the frame | due | l |
| 6081 | §10.2 | seam divides span between instants into equal steps (D-449) | clock | h |
| 6121 | §10.2 | fixed-step takes span in equal steps ≤ h_max | clock | h |
| 6123 | §10.2 | proposal clamped to [h_min,h_max]; equal steps to the instant | clock | h |
| 6140 | §10.2 | doors refuse a run whose clock cannot resolve the floor | clock | h |
| 6281 | §10.2 | fixed-step takes each span in fewest equal steps | clock | h |
| 6320 | §10.2 | h_max subcycles the stepper inside each span | clock | h |
| 6331 | §10.3 | interior sweep is the continuous-entries-only variant | zoh | h |
| 6385 | §10.4 | a due instant is where a discrete component is scheduled | due | h |
| 6429 | §10.4 | held discrete outputs change only at ticks, on boundaries | zoh | l |
| 6485 | §10.4 | RHS lives under interior-sweep rule; trial is mid-step | zoh | h |
| 6554 | §10.4 | discrete cells hold under ZOH; interior sweep excludes them | zoh | h |
| 6582 | §10.4 | remainder from t* is clock distance to step end (D-455) | clock | h |
| 6670 | §10.4 | instant = start + i·exact step, never accumulated (D-449) | clock | h |
| 6673 | §10.4 | step end's clock = start clock + step length (D-455) | clock | h |
| 6674 | §10.4 | tick gating is counter-modulo in same spirit | due | h |
| 6699 | §10.4 | discrete cells ZOH-hold; due sets give the full reason | due | h |
| 6766 | §10.4 | three grid-independent constants enter no harmonic-grid check | grid | h |
| 7534 | §10.6 | boundary sweep against a due set fixed for the iteration | due | h |
| 10223 | §12.5 | Dₛ is the multiplier in Relative(D) | forms | h |
| 11384 | §13.4 | boundary with nothing due runs no ticks block (D-445) | due | h |
| 11680 | §13.x | assemblies virtual, rate scopes touch discrete children only | scopes | h |
| 11683 | §13.x | sweep walks full execution order topologically (D-147) | simul | l |
| 11821 | §13.x | range past the lattices is a fault preceding the frame | clock | l |
| 12195 | §12.x | Freeze holds value between ticks, changes the model | zoh | h |
| 13295 | §14.5 | offset component is not due at boundary zero | due | h |
| 13367 | §14.5 | run past last frame clock resolves is refused (D-450) | clock | h |
| 14531 | App A | boundary sampling teaching item (§10.5/§10.6) | zoh | l |
| 14538 | App A | the startup hole (D-205) | due | l |
| 14638 | App A | never cache Δt (D-019, D-291) | bundle | h |
| 14862 | App B | Relative/Absolute accept integer or Rational counts | forms | h |
| 14944 | App B | h_max step bound, recorded as min with Δt_frame | clock | h |
| 14945 | App B | h_min step floor, refused above half h_max | clock | h |
| 14981 | App B | frame k settles every boundary, frame top last | clock | l |
| 15484 | App C | RatesViolation error kind | forms | l |
| 15619 | App C | steps of one frame not countable in Int (D-445, D-449) | clock | h |
| 15800 | App C | ArgumentInvalid, one of many citing sections | forms | l |
| 15812 | App C | :range; Relative refuses a count Int cannot hold | forms | h |
| 15819 | App C | last frame the lattices index in Int / clock resolves (D-450) | clock | h |
| 16071 | D.1 | component timing bound to one (D₀,Φ₀) in base ticks | compose | h |
| 16143 | D.2 | `sample_times` glossary entry | forms | h |
| 16287 | D.3 | sweep gates in due discrete entries | due | h |
| 16299 | D.4 | relative declarations compose against pool as against root grid | compose | h |
| 16348 | D.4 | Δt(i)=D₀(i)·Δt_base, composed down the tree (D-478) | compose | h |
| 16354 | D.4 | every period is an integer multiple of Δt_base | grid | h |
| 16368 | D.4 | least gap between instants is one Δt_unit (D-479) | clock | h |
| 16372 | D.4 | boundary gate (n−Φ₀)%D₀==0 | grid | h |
| 16375 | D.4 | due instant is a mandatory instant, ends the step | clock | h |
| 16378 | D.4 | event iteration given per kind of boundary | due | l |
| 16398 | D.4 | spent attempt budget takes next attempt at due instant | clock | l |
| 16422 | D.4 | each instant indexed on its own lattice, never accumulated | clock | h |
| 16449 | D.4 | span in fewest equal steps ≤ h_max | clock | h |
| 16472 | D.4 | gate (n−Φ₀)%D₀==0; phase shifts instants, not period | grid | h |
| 16502 | D.4 | Schedule is single source of Δt, substrate of GridUtilization | bundle | l |
| 16521 | D.4 | a boundary only where some component is due | due | h |
| 16527 | D.4 | nothing-due and t* boundaries have no due instant | due | h |
| 16539 | D.4 | time event is scheduled on the grid, not detected | grid | l |

## log.md
| line | entry | sentence | tag | c |
|---|---|---|---|---|
| 746 | D-015 | Spec list | zoh | l |
| 871 | D-019 | Spec list (harmonic grid, virtual assemblies, scopes) | grid | l |
| 4164 | D-121 | Spec long list | whole | l |
| 4668 | D-133 | constants grid-independent, outside harmonic-grid check | grid | h |
| 4682 | D-133 | Spec list | grid | l |
| 5724 | D-147 | pre-existing mechanism, now scoped to boundaries (gating) | zoh | h |
| 5745 | D-147 | Spec list | zoh | l |
| 5767 | D-147 | §10.5's own rejected alternative names the cost | zoh | l |
| 7379 | D-185 | Spec list | forms | l |
| 7411 | D-185 | §10.5 states the residue induction itself | compose | h |
| 7459 | D-186 | Spec list | anchors | l |
| 7498 | D-186 | superseded §10.5 root-only absolute clause | anchors | h |
| 7521 | D-187 | Spec list | bundle | l |
| 7780 | D-194 | not-due producer under §10.5 gating | zoh | h |
| 8221 | D-205 | Spec list | due | l |
| 8229 | D-205 | §10.5's content defense of the tick | zoh | l |
| 8934 | D-220 | Spec long list | whole | l |
| 9572 | D-234 | Spec list (N_base rename) | grid | l |
| 9938 | D-242 | Spec long list | whole | l |
| 10590 | D-254 | Spec list | bundle | l |
| 10869 | D-258 | Spec list (Schedule = tick timing) | bundle | l |
| 10875 | D-258 | Schedule term; first sweep | bundle | l |
| 11650 | D-267 | Spec long list | whole | l |
| 12896 | D-283 | Spec list (Δt_base vs anchor-relative) | compose | l |
| 13136 | D-288 | Spec list | zoh | l |
| 13349 | D-291 | "Five rate rulings that §10.5 states are fixed here" | compose | l |
| 13372 | D-291 | Spec list | compose | l |
| 14416 | D-316 | one leaf sits anywhere in the tree (D-019) | scopes | h |
| 14417 | D-316 | detector sees the tick at its own boundary (D-147) | simul | l |
| 18619 | D-443 | Spec list (frame period) | clock | l |
| 18675 | D-444 | Spec list | clock | l |
| 18702 | D-444 | §10.5's cost of an offset: finer base grid | stagger | h |
| 18739 | D-445 | Spec list | clock | l |
| 18767 | D-445 | rejected: every base tick a boundary; §10.5 names the price | stagger | h |
| 18920 | D-449 | Spec list | clock | l |
| 19004 | D-450 | Spec list | clock | l |
| 19262 | D-453 | Spec list | whole | l |
| 19360 | D-455 | Spec list | clock | l |
| 19411 | D-456 | Spec list | clock | l |
| 19465 | D-457 | Spec list | clock | l |
| 19512 | D-458 | Spec list | clock | l |
| 19594 | D-459 | Spec list | forms | l |
| 19764 | D-460 | Spec list | clock | l |
| 20074 | D-464 | Spec list | compose | l |
| 20087 | D-464 | scope phase was already φ in §10.5 | compose | h |
| 20122 | D-465 | Spec list | forms | l |
| 20555 | D-469 | Spec list | forms | l |
| 20692 | D-471 | Δt_unit is the unit the loop already counts in | clock | h |
| 21137 | D-478 | Spec list | compose | l |
| 21217 | D-479 | Spec list | compose | l |
| 21219 | D-479 | §10.5 used n as base tick index, then reused it | grid | h |

## companions/
| file:line | heading | sentence | tag | c |
|---|---|---|---|---|
| lqr_tracker.md:205 | LQR tracker | Δt is the component's own period | bundle | h |
| pid_anti_windup.md:509 | PID anti-windup | Δt is the component's own period | bundle | h |
| frozen_discrete_walkthrough.md:4 | header | cites §10.5 gated tick scheduling | whole | h |
| frozen_discrete_walkthrough.md:27 | walkthrough | stages run at B's tick times (gated scheduling) | zoh | h |
| longitudinal_aircraft.md:192 | aircraft | 10 Hz groups each declaring own rates | scopes | l |
| library_inventory.md:34 | inventory | sample_times declared like the others (§8.7) | forms | l |
| library_inventory.md:330 | inventory Delay | K ticks of the component's own period | bundle | l |
| frame_walkthrough.md:3 | header | spec cites §10.4, §10.5, §10.6 | whole | h |
| frame_walkthrough.md:77 | frame walkthrough | the frame/tick discrimination | zoh | l |
| frame_walkthrough.md:168 | frame walkthrough | done by structure, not a runtime test | zoh | l |
| frame_walkthrough.md:321 | frame walkthrough | Gated wrapper's run_at! is the §10.5 gate | grid | h |
| frame_walkthrough.md:378 | frame walkthrough | Φ₀=0 components due at boundary zero | due | h |

## code_map.md
| line | entry | sentence | tag | c |
|---|---|---|---|---|
| 340 | code_map | Relative refuses float/rational as :not_a_count (D-459) | forms | h |
| 383 | code_map | Lattice: index-to-time map from exact periods (D-445) | clock | h |
| 411 | code_map | h_max :range faults (D-445, D-449) | clock | h |
| 429 | deployment.jl | Spec list | whole | l |
| 555 | code_map | :range on Absolute (D-459, D-465) | forms | h |
| 599 | code_map | retired tokens :subcycling, :not_harmonic | clock | l |
| 679 | code_map | float distance between two clocks (D-455) | clock | h |
| 707 | frame.jl | Spec list §10.2–§10.5 | clock | l |
| 912 | code_map | grid: _grid_time, frame top k (D-445) | clock | h |
| 959 | code_map | run_ticks! selects ticks block by arity | due | l |
| 1361 | store.jl | Spec list | whole | l |
| 1386 | code_map | a rate whose check refused composes nothing (D-459) | forms | l |
| 1432 | structure.jl | Spec list | whole | l |
| 1514 | code_map | tick_alarmed stop request over TickAlarm | due | l |
| 1533 | test_adaptive.jl | Spec list | whole | l |
| 1563 | test_lattices.jl | Spec list | clock | l |
| 1610 | code_map | walked/gated entries per variant, gated count | zoh | h |

## pending.md
| 190 | Unordered | schedule row's Δt not the float nearest its exact period | bundle | l |

## RedstoneInspector.jl/design/
| deployment_overlay.md:790 | Answered questions | notation: anchor period Δtₖ, Absolute(Δt,τ), phase τ | anchors | l |

## Counts per file
spec.md 95, log.md 51, companions 12 (frame_walkthrough 5, frozen_discrete_walkthrough 2, library_inventory 2, lqr_tracker 1, pid_anti_windup 1, longitudinal_aircraft 1), code_map.md 17, pending.md 1, Inspector 1, rules/ 0. Total 177.

## Counts per tag
clock 48, zoh 24, due 18, forms 18, bundle 14, compose 13, grid 13, whole 13, scopes 5, anchors 3, simul 3, stagger 3, example 1, library 1, spiral 0, none for `stagger` beyond 3.

Confidence: h 101, l 76.

Notes for the re-pointing:
- The `clock` tag is the largest group. It covers spans, steps and the clock, h_max and Δt_unit. These stay in §10.5 as execution mechanics.
- `forms`, `anchors`, `library` and `compose` are declaration rules and will move to §8.7.
- `zoh`, `due`, `grid`, `simul`, `bundle` and `stagger` are semantic laws and will move to the new Part I section.
- Many `l` rows (log "Spec:" lists, and rows like spec 4871 and 16398) need a read of the surrounding entry before they are re-pointed.
- Spec 4052 and 4056 say "§10.5 defines the forms". Spec 4058 says "§10.5 gives the Relative(1) default". These probably become §8.7 self-references after the split.
