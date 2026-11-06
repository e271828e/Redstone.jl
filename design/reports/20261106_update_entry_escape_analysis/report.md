# The update entry's gather and the compiler's escape analysis, 2026-11-06

`20261106_wide_store_compile/report.md` recorded that a wide discrete store
whose value reaches a port from stage 1 compiles about as the cube of its
width, placed the time in the compiler's escape analysis, and left the
statement that hands the analysis the wide object unpinned. This report pins
it, corrects the earlier report's attribution, records the fix, and holds the
reproducer the earlier report lacked. The bullet "Wide discrete stores
compile superlinearly" retires with the fix.

Every figure is a fresh process on Julia 1.13.3 with `--startup-file=no`,
`JULIA_LOAD_PATH="@"` and `--project=test`. The scripts are
`repro_escape_analysis.jl` beside this file, which needs no Redstone, and
the session's scratchpad probes `probe_pieces.jl`, `probe_patch.jl` and
`probe_handler.jl`, whose models are the earlier report's.

## 1. The statement

Julia's compiler runs its escape analysis on a function in
`ipo_dataflow_analysis!` (`Compiler/src/optimize.jl`) only when the
function is not yet known effect-free and every statement is effect-free
except field stores, `:new` and calls that write argument memory alone;
`scan_non_dataflow_flags!` limits the analysis to those three by a comment
it calls a performance hack. An array store, `memoryrefset!`, is none of
them and switches the analysis off for the whole function. The analysis
tracks each value's possible aliases and replays every change to a value
over its whole alias set (`propagate_escape_change!`,
`ssair/EscapeAnalysis.jl`), which is what makes an `N`-leaf value built in
the body from `N` buffer loads cost about `N³`.

The executor has one body of that shape: the **update entry**. Its bundle
gathers `u` and `y` inline, each an `SVector` built from as many loads of
the cell store, and its only write is `sstore[] = s⁺`, a field store on the
store's `Ref`. The stage and RHS entries write the cell store and the flat
`ẋ` buffer, so the analysis never runs on them. A `@code_typed` of
`run_entry!` for a 4-wide `UnitDelay` shows the body the analysis sees: two
cursor stores, the loads, the `Core.tuple` and `%new` of the `SVector`, the
`setfield!` on the `Ref`, and nothing else.

The compile time of each piece, `run_entry!` first and then the chunk's
barrier call that inlines it again, so the analysis runs twice:

| model | stage-1 entry | update entry | update chunk | `init!` |
|---|---|---|---|---|
| `UnitDelay`, 100 wide | 0.02 s | 1.6 s | 5.3 s | 7.1 s |
| `Delay(K = 200, taps = true)` | 0.07 s | 9.2 s | 31.8 s | 39.9 s |
| `Delay(K = 200)` | 0.00 s | 0.00 s | 0.01 s | 0.3 s |

The earlier report attributed the cost to stage-1 publication. The stage-1
entry is cheap in every row. The taps form is slow because the update
bundle carries every own port (`s_update` reads the complete fresh table,
§5.3), so it gathers the 200-wide `taps` cell though `s_update` never
reads it; the plain form gathers a scalar `y` and is cheap, as the earlier
report's control found, for a reason it could not name. The ring's own
`:new` in `s_update`, 200 wide, costs nothing: the analysis is cheap on a
wide value built from field reads and expensive on one built from buffer
loads.

A second body has the shape: an **event handler** whose return has no `x`
writes the mode store by field store and nothing else. A component with a
100-wide input and a mode-only handler took 1.56 s at `init!` against the
0.4 s baseline. The guard walk writes the `now` vector, so guards are
safe.

## 2. The reproducer

`repro_escape_analysis.jl` builds the update entry's shape with none of the
framework: an entry struct holding a `Ref`, two cell addresses and a
cursor; a store bundle; an unrolled gather; the successor stored into the
`Ref` through a chunk-like `@noinline` call. Variant `a` is that shape;
`b` puts the two gathers behind a `@noinline` call; `c` puts the store
behind one instead; `d` adds a `Base.donotdelete`; `e` replaces the `Ref`
by a one-element `Vector`. Compile time of the chunk call:

| `N` | `a` inline gathers | `b` gather barrier | `c` store barrier | `d` `donotdelete` | `e` `Vector` store |
|---|---|---|---|---|---|
| 50 | 0.51 s | 0.01 s | 0.53 s | 0.01 s | 0.02 s |
| 100 | 4.57 s | 0.03 s | 3.97 s | 0.03 s | 0.03 s |
| 200 | 29.5 s | 0.05 s | 29.5 s | 0.06 s | 0.07 s |
| 400 | 229 s | 0.14 s | 233 s | 0.18 s | 0.16 s |

`c` confirms the mechanism: the analysis runs in the caller, and a barrier
on the store leaves the gathered `:new` in the analyzed body. `d` and `e`
work by tripping the analysis's gate, `donotdelete` and `memoryrefset!`
being neither field store nor `:new`; both rest on the hack's roster and
`e` would change §9.7's store representation. `b` is the fix. Removing the
dead `y` gather, the cursor stores or the `s` load from `a` changes
nothing; reaching the buffer as a plain argument instead of through the
bundle makes `a` about twice as slow.

## 3. The fix

`gather_input_barrier` (store.jl) is `gather_input` behind a `@noinline`
call. `_bundle_expr` takes the gather's name; the update entry's
`make_bundle` and the handler's `make_handler_bundle` pass the barrier,
the stage, RHS and guard bundles keep the inline gather. The call returns
the value on the stack and allocates nothing; `_fire_entry!` and
`_event_bodies`' handler closure take the handler bundle. The pin is
`test_executor.jl`'s testset "the update and handler bundles gather behind
a barrier".

`init!` before and after, with the ticks body's cost per call:

| model | `init!` before | after | ticks body before | after |
|---|---|---|---|---|
| `UnitDelay(0.0)` | 0.29 s | 0.29 s | 2.4 ns | 5.2 ns |
| `UnitDelay`, 100 wide | 7.1 s | 0.37 s | 11 ns | 31 ns |
| `UnitDelay`, 400 wide | 341 s | 1.0 s | | 149 ns |
| `Delay(K = 200, taps = true)` | 39.9 s | 0.45 s | 98 ns | 95 ns |
| the 100-wide mode-only handler | 1.56 s | 0.35 s | | |

Every body stays at 0 B. The 3 ns a scalar discrete block pays per tick is
the two calls, one per gathered side.

## 4. Upstream

The cost is the compiler's, and the reproducer is the material for an
issue on JuliaLang/julia. No open issue names it: searches for
`ipo_dataflow_analysis`, "escape analysis compile time", "escape analysis
latency" and "EscapeAnalysis quadratic" on 2026-11-06 found none, and
53688, the one hit under the first, is a runtime regression.
