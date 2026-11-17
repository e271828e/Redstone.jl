# Notes: the tutorial's design discussion, 2026-11-17

The record of the probes run during the discussion that settled the
tutorial's arc, and of what the discussion found beside the arc. The aim,
the arc, the rulings and the plan are `../roadmap_tutorial.md`. The probes
ran read-only against the tree at `bc77937`.

## 1. The probes

The scripts sit beside this file. All ran with `--startup-file=no`, the
first two under `--project=examples` and the third under the root project.

| Probe | Script | Result |
|---|---|---|
| `closed_loop` with each tracking input wired from the selected command, bypassing the `UnitDelay`s | `probe_loop.jl` | `AlgebraicCycle` among seven members, classified real, the two PIDs and the tracker traced structurally |
| `closed_loop` linearized from `h_ref` to the altitude | `probe_loop.jl` | `TapResolution`: the root input is unseedable by tier, since a discrete consumer reads it |
| pitch hold with the continuous `PID(Kp = -2.0, Ki = -1.0)`, linearized from `θ_ref` to `θ` | `probe_continuous.jl` | linearizes; eigenvalues `-2.047 ± 8.064im`, `-1.392`, `-0.642`, `-0.052`; DC gain 1 |
| the same loop with `DiscretePID` at 50 Hz, both flown through a 0.05 rad step at 1 s | `probe_continuous.jl` | largest gap between the tiers 0.0021 rad over 10 s; peaks 0.0799 and 0.0820 rad |
| an enum-valued root input staged between steps, read by a `Select`, a junction and a `DiscretePID`'s `engaged` | `probe_enum.jl` | stages and logs as the enum; the standby PID tracks the pilot's command to 1e-11 |

A run's time history comes from `series(sim, reads(…))`, which returns
`t` and one column per entry over the logged snapshots, one per frame by
default.

## 2. What the discussion found beside the arc

- **Two sentences of the pending bullet were wrong.** "One chapter per
  layer of the example model" no longer described the arc, and the
  tutorial cannot linearize from `h_ref` to the altitude while a discrete
  controller reads the reference. The bullet was rewritten.
- **The loop of chapter 6 is settled design.** The PID's code never reads
  `v` in `y_direct`, yet the wire closes a cycle by stage-2 conservatism
  (§5.4). A continuous member is classified artificial with the dead hop
  named, and a discrete one real, traced structurally (§13.8).
  `pid_anti_windup.md` sections 3 and 9 and `lqr_tracker.md` section 7
  record it. The chapter needs one paragraph on the rule: an input to a
  component with a stage-2 output is a feedthrough edge, whether the
  output reads it or not.
- **A signal for the audit.** The examples' test helpers wrap the one-port
  history as `logged_port(sim, path, name)`, which suggests a shortcut the
  audit may want to weigh.

## 3. Not yet probed

The hold chain and the standby tracking across two rates, and the approach
under the autopilot down to the touchdown. Both need gains retuned, and
both are increment 1's prototype to run.
