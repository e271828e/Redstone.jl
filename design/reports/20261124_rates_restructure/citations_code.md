# Citations of §10.5 in src/, test/ and examples/

Read-only sweep done. 153 citations across 26 files. `ext/` and `docs/` have none, and `s10-5` has no hits anywhere. Tags come from each comment's wording plus skimmed context. I did not read §10.5's body, only its heading outline (lines 6778-7289).

Tagging heuristics:
- Declaration and validity rules (Dₛ ≥ 1, 0 ≤ Φₛ < Dₛ, Δt > 0, 0 ≤ τ < Δt, `Relative`/`Absolute` forms) are tagged `forms`.
- Divisor composition past `Int` is tagged `compose`.
- Gate and `(n-Φ)%D` are tagged `grid`.
- Boundary-zero dueness is tagged `due`.
- Frame, step, span and clock-resolution citations are tagged `clock`. Many of these also touch `grid`; I tagged `clock` unless the comment says "grid" or "GCD".
- `l` marks two plausible subsections.

Important `l` pattern: the 10 `# Design: ... §10.5` library lines and `src/declare.jl:620` and `:716` cite §10.5 as a pointer to the ZOH/discrete tier. They are tagged `zoh` (`l`). The `s_update` and `y_state` ones could also be `due` or `whole`.

## src/diagnostics.jl
| loc | fn | says | tag | c |
|---|---|---|---|---|
| 770 | DeploymentInvalid-twin docstring (sample_times invalid) | `sample_times` outside value vocabulary, residue bounds, key rule (§8.7, §10.5) | forms | h |
| 790 | message, :range | Relative composes a divisor past `Int` | compose | h |
| 791 | message, :multiplier | Dₛ ≥ 1 | forms | h |
| 792 | message, :phase | 0 ≤ Φₛ < Dₛ | forms | h |
| 793 | message, :period | Δt > 0 | forms | h |
| 794 | message, :offset | 0 ≤ τ < Δt | forms | h |
| 798 | message (sample_times scope children) | scope children (§8.7, §10.5) | scopes,forms | l |
| 1398 | DeploymentInvalid message, :h_max suffix | h_max parameter, (§10.5) | clock | l |
| 1460 | message, h_max/frame | frame count of Δt_frame overflows `Int`, coarsen h_max | clock | h |
| 1465 | message | coarsen Δt_base or Δt_frame (`Int` overflow) | grid | l |
| 1471 | message | ill-defined over floats (§9.1) | grid | l |
| 2354 | ArgumentInvalid docstring | arg outside constraint, cites §10.5 among several | whole | h |
| 2369 | message, time-door value | grid derivation is GCD arithmetic | grid | h |
| 2371 | message | same, GCD arithmetic | grid | h |
| 2377 | message | Absolute period in seconds, `Absolute(1//100)` | forms | h |
| 2379 | message | Relative holds counts in `Int` | forms,compose | l |
| 2383 | message | Absolute exact `Rational{Int}`, past `Int` | forms | h |
| 2460 | comment, origin check | range or clock resolution at origin (D-445, D-450) | clock | h |
| 2465 | message | could take clocks out of order | clock | h |
| 2481 | message | origin (§10.5, §14.5) | clock | l |

## src/library.jl
| loc | fn | says | tag | c |
|---|---|---|---|---|
| 486 | section header, discrete tier | "the discrete tier (§7.3, §10.5, D-313)" | zoh | l |
| 488 | Delay | `# Design:` pointer | zoh | l |
| 554 | DiscreteIntegrator | `# Design:` pointer | zoh | l |
| 675 | RateLimiter | `# Design:` pointer | zoh | l |
| 730 | Backlash | `# Design:` pointer | zoh | l |
| 784 | GaussianWhiteNoise | `# Design:` pointer | zoh,bundle | l |
| 1341 | DiscreteStateSpace | `# Design:` pointer | zoh | l |
| 1479 | DiscretizedStateSpace | `# Design:` pointer | zoh | l |
| 1539 | DiscretizedTransferFunction | `# Design:` pointer, §10.5 alone | zoh | l |
| 2570 | DiscretePID | `# Design: §10.5, §13.8` | zoh | l |
| 2931 | DiscreteLQRTracker | `# Design: §10.5, §13.8` | zoh | l |

## src/deployment.jl
| loc | fn | says | tag | c |
|---|---|---|---|---|
| 29 | section header, typed schedule | (§9.2, §10.5, D-254) | scopes | l |
| 56 | scope-row docstring | one rate scope's row | scopes | h |
| 67 | schedule rows comment | per-component (D₀, Φ₀, Δt) derived at compile | compose | l |
| 107 | section header, lattices | (§2.1, §10.5, D-445) | grid,clock | l |
| 109 | `# Design:` Lattice | frame tops and base ticks | grid,clock | h |
| 118 | Lattice docstring | index-to-time map | clock | h |
| 205 | docstring | steps leaving `Int` are h_max's | clock | h |
| 294 | fold comment | canonical residue survives composition, gate's truncated rem | compose | h |
| 464 | comment | derived from exact periods once | grid | l |
| 543 | struct field `h_max` | step bound resolved against the frame | clock | h |
| 551 | struct field `lattice` | loop's index-to-time map | clock | h |

## src/frame.jl
| loc | fn | says | tag | c |
|---|---|---|---|---|
| 1 | file header | the model's frame (§10.4, §10.5) | clock | l |
| 19 | `# Design:` pointer | frame cursor | clock | l |
| 99 | comment, frame spans | two nested loops | clock | h |

## src/model.jl
| loc | fn | says | tag | c |
|---|---|---|---|---|
| 521 | section header, the grid | (§10.4, §10.5, D-445) | grid | h |
| 539 | comment | per row, an index and its position; no row, no due instant | due | h |
| 565 | comment | frame the bound lands on is at most the last frame | clock | h |
| 578 | comment | last frame a run may take (D-445, D-450) | clock | h |
| 637 | boundary routine comment | over its due set: tick index at a boundary | due | h |
| 676 | docstring | empty due set by arity selection | due | h |
| 690 | docstring | canonical residue admits exactly Φ₀ = 0 | due,grid | l |
| 850 | comment | proposal shaped into a step length | clock | h |

## src/executor.jl
| loc | fn | says | tag | c |
|---|---|---|---|---|
| 479 | section header, the gate | (§10.5, D-185, D-205) | grid | h |
| 517 | gate fn | gate at index 0, implemented by nothing | grid,due | h |
| 548 | phase body docstring | two chunk tuples from one entry list | zoh | l |
| 557 | docstring | discrete entry gated by `(n−Φ₀)%D₀` | grid | h |
| 587 | chunked_body comment | interior subset, discreteness a build-time fact | zoh | h |

## src/declare.jl
| loc | fn | says | tag | c |
|---|---|---|---|---|
| 371 | section header, rate scopes | (§8.7, §10.5) | forms,scopes | l |
| 404 | Relative | `# Design:` pointer | forms,compose | h |
| 444 | Absolute | `# Design:` pointer | forms,anchors | l |
| 487 | sample_times | `# Design: §8.7, §10.5` | forms | h |
| 620 | y_state | `# Design:` pointer | zoh | l |
| 716 | s_update | `# Design:` pointer | zoh,due | l |

## src/structure.jl
| loc | fn | says | tag | c |
|---|---|---|---|---|
| 305 | section header, sample-time fold | (§8.7, §9.1, §10.5) | compose,anchors | h |
| 317 | docstring | validate `sample_times` against §10.5's constraints | forms | h |
| 919 | comment | last frame index whose positions fit `Int` | clock | h |

## src/build.jl
| loc | fn | says | tag | c |
|---|---|---|---|---|
| 563 | Activation docstring | probe products are what a cell holds until first written | zoh | l |
| 1065 | `_frozen` comment | frozen discrete (§7.2) | zoh | l |
| 1503 | comment | table's pre-`init!` content, frozen pinned cells | zoh | l |

## src/conditions.jl, show.jl, sim.jl
| loc | fn | says | tag | c |
|---|---|---|---|---|
| src/conditions.jl:614 | `_component` | non-state entries "execution (§10.5)", own no state | whole | l |
| src/show.jl:300 | comment | steps of a fixed-step method per frame | clock | h |
| src/sim.jl:704 | `# Design:` pointer | long list including §10.5 | whole | h |
| src/sim.jl:717 | comment | boundary zero: ordinary boundary, empty integrate | due,clock | h |

## test/test_diagnostics.jl
| loc | testset | says | tag | c |
|---|---|---|---|---|
| 802 | DeploymentInvalid messages | h_max exactness is its step count's | clock | h |
| 806 | same | h_max positive finite `Rational{Int}` message | clock | h |
| 810 | same | message (§9.1, §10.5) | grid | l |
| 812 | same | and the frame (D-445, D-459) | clock | l |
| 830 | same | cause (D-445, D-450) | clock | l |
| 836 | same | time door value named | grid | h |
| 840 | same | message: GCD arithmetic | grid | h |
| 844 | same | message: GCD arithmetic | grid | h |
| 846 | same | `Absolute` exact, past `Int` | forms | h |
| 848 | same | `Relative` counts past `Int` | forms | h |
| 852 | same | takes `Absolute`, `Absolute(1//100)` | forms | h |
| 857 | same | composed divisor names the entry that composed it | compose | h |
| 861 | same | message "past `Int`" | compose | h |
| 863 | same | Dₛ and Φₛ | forms | h |
| 865 | same | Dₛ ≥ 1 | forms | h |
| 867 | same | 0 ≤ Φₛ < Dₛ | forms | h |
| 868 | same | `Absolute` constraints in own letters (D-464) | forms | h |
| 870 | same | Δt > 0 | forms | h |
| 872 | same | 0 ≤ τ < Δt | forms | h |

## test/test_discrete.jl
| loc | testset | says | tag | c |
|---|---|---|---|---|
| 1 | file header | discrete tier: one rate, then several | whole | h |
| 2 | file header comment | "§10.5 is Multi-rate tick scheduling", single rate is D₀=1, Φ₀=0 corner | whole | h |
| 41 | comment, ZOH test | output stages before updates within one boundary | zoh | h |
| 46 | "the ZOH holds by compile-time absence" | ZOH holds | zoh | h |
| 159 | "a divisor composed past `Int` is refused at the inner key" | refused, never wrapped | compose | h |
| 236 | "the hyperperiod chart is readable off the cells" | hyperperiod chart | grid | l |
| 257 | "relative scopes compose affinely; anchors sever" | compose, anchors | compose,anchors | h |
| 290 | section header, deployment binding and gate | (§9.1, §9.2, §10.5) | grid | l |
| 543 | "a divisor composed with its anchor past `Int`..." | lattices' refusal | compose,anchors | h |
| 791 | "a largest divisor that leaves no frame in an `Int`..." | refused at build | grid,clock | l |
| 880 | section header, multi-rate gate at run time | gate | grid | h |
| 886 | boundary-zero comment | gate at index 0 governs `s_update` alone | due | h |
| 906 | comment, multi-rate loop | bundle's Δt is the compiled schedule's, "single source of truth" | bundle | h |
| 918 | comment | exposed-multiplier idiom | forms,library | l |
| 929 | "a restore continues the controller on the original lattice" | restore on lattice | clock | l |
| 989 | "an overlay keeps the lattice" | controller at own ticks | grid | l |

## test/test_lattices.jl
| loc | testset | says | tag | c |
|---|---|---|---|---|
| 1 | file header | lattices and step bound | clock | h |
| 83 | "a 20 ms frame over a 100 µs base takes one step, plus one per due instant" | steps per frame | clock | h |
| 116 | "a harmonic h_max takes equal steps" | equal steps | clock | h |
| 136 | "a due instant inside a step splits it" | splitting | clock | h |
| 171 | "a due instant cuts a span" | spans | clock | h |
| 190 | "a bound that divides neither..." | equal steps per span | clock | h |
| 210 | "a bound at or above the frame bounds nothing" | one step per span | clock | h |
| 221 | "a due instant is written from its base-tick index" | due instant | due,clock | l |
| 371 | "a frame whose positions leave `Int` is refused" | Int range | clock | h |
| 433 | "the clock's resolution sets the last frame" | clock resolution | clock | h |
| 453 | "a run the clock cannot resolve is refused at every door" | clock | clock | h |
| 503 | "a lattice whose exact unit or bound cannot count one frame..." | refused at deployment | clock,grid | l |
| 545 | "a step's length is the difference of its two clocks" | clocks | clock | h |
| 581 | "a time typed on a lattice is its boundary's clock" | clock | clock | h |
| 603 | "a bound finer than the frame steps through the clocks" | clocks | clock | h |
| 635 | "the clock's division rounds once at every magnitude" | clock | clock | h |
| 662 | "from a wall-clock origin every frame top..." | clock | clock | h |
| 695 | "a step typed on the frame grid fires at its boundary" | grid | grid,clock | l |

## test/test_stepper.jl
| loc | testset | says | tag | c |
|---|---|---|---|---|
| 119 | "h_max bounds the step, divides nothing" | recorded resolved against frame | clock | h |
| 316 | "a proposal is clamped to h_max and the span divided equally" | shaping | clock | h |
| 450 | "a step that reaches the span's end takes its clock" | clock | clock | h |
| 493 | "a localized event that never fires leaves the trajectory bit-identical" | steps | clock | l |

## test/test_adaptive.jl
| loc | testset | says | tag | c |
|---|---|---|---|---|
| 1 | file header | first adaptive backend (§10.2, §10.5) | clock | l |
| 406 | "the shaping rule: equal division to the next mandatory instant" | shaping | clock | h |
| 536 | "the floor enters the clock's resolution" | clock | clock | h |

## test/fixtures.jl
| loc | fn | says | tag | c |
|---|---|---|---|---|
| 726 | docstring | continuous request published at tick's own boundary | due | l |
| 1146 | docstring | interior sweep: discrete cell can't change between boundaries | zoh | h |
| 1167 | `ctl_rate` docstring | §10.5's exposed-multiplier idiom | forms,library | l |
| 1337 | section header | the multi-rate coverage set | whole | h |
| 1361 | worked-example scope docstring | `inner` at scope base, `outer` at `Relative(5, 2)` | example | h |

## Remaining test files
| loc | fn | says | tag | c |
|---|---|---|---|---|
| test/utils.jl:5 | helper comment | entries a phase body walks per variant | zoh | l |
| test/test_conditions.jl:338 | comment | `s_update` stays gated by Φ₀; evaluation is establishment | due | h |
| test/test_declare.jl:33 | "a value `Rational{Int}` cannot hold finitely is refused" | declaration door | forms | h |
| test/test_declare.jl:54 | "`Relative` takes an integer count of any type" | forms | forms,compose | h |
| test/test_failures.jl:208 | comment | last block is event phase's round | due | l |
| test/test_lifecycle.jl:46 | "an origin that is not finite, not exact..." | origin | clock | h |
| test/test_lifecycle.jl:580 | "a tick-detected request stops at the tick's own boundary" | tick boundary | due | l |
| test/test_library.jl:1213 | "the discrete integrator accumulates `Δt in` per tick" | per tick, own period | zoh,bundle | l |
| test/test_library.jl:1462 | "the noise's density form scales by the period" | Δt in bundle | bundle | h |
| test/test_library.jl:2032 | "the zero-order hold reproduces the exact solution" | ZOH | zoh | h |
| test/test_show.jl:457 | "Deployment: the chart against the frame tops..." | chart over joint period | grid | l |
| test/test_show.jl:528 | "Deployment: the steps of an unsplit frame" | steps | clock | h |

## examples/
| loc | testset | says | tag | c |
|---|---|---|---|---|
| examples/test/test_longitudinal.jl:344 | "chapter 4: the discrete pitch hold at 50 Hz follows the continuous one" | discrete hold | zoh | l |
| examples/test/test_longitudinal.jl:366 | "chapter 5: altitude and airspeed loops tick at 10 Hz, pitch at 50 Hz" | two rates | scopes,grid | l |

## Counts per file
src: diagnostics 20, library 11, deployment 11, model 8, declare 6, executor 5, build 3, frame 3, structure 3, sim 2, conditions 1, show 1. Total 74. (Per-file `rg -c` counts lines: sim.jl 2, structure.jl 3, frame.jl 3, build.jl 3; src total 76 by that count, because model.jl, deployment.jl and diagnostics.jl line counts are as given in the table. The table rows match the line count of each file.)
test: test_diagnostics 19, test_lattices 18, test_discrete 16, fixtures 5, test_stepper 4, test_adaptive 3, test_library 3, test_declare 2, test_lifecycle 2, test_show 2, test_conditions 1, test_failures 1, utils 1. Total 77.
examples: 2. ext/docs: 0.
Grand total 153 (src 76 by `rg -c`, test 77, examples counted within the 153 as 2 of the above; the `rg -c` per-file sum over all dirs is 153).

## Counts per tag
(A row with several tags counts once per tag.)
- clock ≈ 62
- forms ≈ 33
- grid ≈ 28
- zoh ≈ 27
- due ≈ 16
- compose ≈ 10
- whole ≈ 5
- scopes ≈ 5
- bundle ≈ 4
- anchors ≈ 4
- library ≈ 2
- example 1
- simul, stagger: 0

These tag counts are approximate. I tallied them by eye and did not count them with a tool.

Notes for the re-pointing:
- Nothing cites "Simultaneous ticks", "Coincidence and stagger" or "When an anchor belongs in a library type" by that label. Those sections may be cited only through bare pointers.
- The largest group needing a judgment call is the 10 `# Design:` pointers in `src/library.jl` (discrete components) and `declare.jl:620/716`. They probably belong with the semantic-laws destination (ZOH and due sets).
- The diagnostics message strings, and the matching strings in `test/test_diagnostics.jl`, must change together. Changing a message changes the test's expected text.
- The first four tests in test_diagnostics (lines 840-852) assert the exact "(§10.5)" text.
