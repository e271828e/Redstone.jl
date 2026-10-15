# Unit B (§12.4): verification

Counts: 194 claims. MATCH 189, DRIFT 5, LOST 0. ADDED 25, all glosses, F15's `ArgumentInvalid` sentence or connectives, none meaning-changing. The three deletions in deleted.md are what R5, R8 and F3 order.

## DRIFT

1. C-134 (line 256): R15 not applied. Write "the control plane's stop command, one atomic word holding its issuer". This is the only site. Retag C-134 in claims.md as R15.
2. C-127 (lines 246–248): R8 not applied. "a terminal snapshot with the failure named in its diagnostic account" is false for every run, and R8 covers it, since the sentence rests on the publication R8 drops. In `src/sim.jl` the bracket runs before any publication (1183–1185), and `_advance!` returns at the frame-top stop read, before `frame!` (1420–1421). `_sweep_tail!` (1281) then folds the `DeviceCrash` into the residue. Fix: "…an ordinary stopped simulation. Its terminal snapshot is the one the run started from, and the `DeviceCrash` is in its termination record's tail residue."
3. C-037 (lines 59–62): antecedent. After the cell gloss, "collects it" and "presents it" can bind to the heartbeat, the cell or the record. Fix: "the diagnostic" in both places.
4. C-062: citation scope. Old "(§10.4; `tₖ = t₀ + k·h`, indexed …)" covered the index rule. Fix: append ([§10.4][s10-4]) to "Each grid time is indexed…".
5. C-183/C-184 (lines 350–353): antecedent. "`checkpoint` refuses such a run" now follows the boundary-zero sentence, which §13.4 returns to `built`. Fix: restore old's form, "…resets them, as after a throw inside boundary zero (gloss) ([§13.4][s13-4])."

## Citations

Every old citation survives except the drops F5, F10, F23 and R5 order. Each added entry carries its claim: D-030, D-316, D-310 b2, D-373 b2, D-203 b4, D-060 (standing clauses), D-368 b5, D-133, D-198, D-256 b3, D-093, D-106, D-138, D-189, D-132. The log's D-138 Rationale owes R8's correction.

## Bold

The new bolds pass the one-bold test. No ruling is bold twice in the frozen spec or in units A, F or G. The D-201/D-203 bold "**It is folded…**" (line 113) has a pronoun subject and follows a consequence. Fix: "**What the tail itself produces is folded into the termination record and presented through the logging backend, never published** (D-201, D-203). It comes later by construction."

## Moves

M7–M11 are done, and there are no others.

## Reader-cold names and links

- `t*` (line 31, its first use since F4) needs the link and gloss "[`t*`](#g-t) (the localized event time)".
- Move the control-plane link to its first use, line 22.
- Move the trace link to line 133, where replay's gloss uses it.
- Line 320 has a bare *entry* in a split sentence. Write "the abnormal shutdown entry".
- FlightCore's EOT, `SimulationTermination` and `network.jl` are class 3.

## Open question

F24's `stop!(entry.handle)` now sits beside the comment "no handle yet". The handle does exist before the spawn (src/devices.jl 466–468). Only a task to hold it is missing. F24 forbids other edits. Rule on "no task holds a handle yet", which is src's wording.

## Re-check

`build_inventory.py ch12 B` reports `checks failed: 0`, with 194 claims and 26 additions. Every fix and R15 are applied, and so are R8 over 9052–9053 and R19. I checked each changed sentence and the sentences beside it against old.md and the sources. All hold.

- The R8 sentence is true. `report!(entry, DeviceCrash)` writes to the handle's cell (src/devices.jl 225–226). `_reset_accounts!` leaves the cells alone (sim.jl 1315–1318). `_advance!` returns at the frame-top stop read, before `frame!`, whose `frame_top!` drain is the take (sim.jl 1420–1421, 1359). So no frame-top take happens and nothing is published. `_sweep_tail!` folds the cell into the residue (devices.jl 583). `_record` stores that residue with the source, `ControlRequestedStop(handle.who)` (sim.jl 376–378, devices.jl 118).
- The new glosses match the glossary: the control plane in step (1), the snapshot sentence, `t*` and "recorded batches" in replay's gloss. "The loop then publishes" keeps the antecedent. The bold, the repeated §10.4 citation, "as after" and "abnormal shutdown entry" are as the fixes asked.
- One minor finding remains. The frame link sits on the second use, "A [frame] is one iteration". Put it on the first use, "inside a frame."
