# Chapter 12: items for the owner, besides escalations.md

Rulings the spec states with no entry behind them (lesson 17). Each stays
uncited until the owner rules whether to record it.

- B77 (half 1): the `systemsleep` variant admitted as a guarded addition;
  "tight" as fewer threads than the roster plus one; the wrapper treating an
  `unblock!`-provoked raise as shutdown, not a crash; each task reading
  `last_seen` at spawn; the pause block parking on a condition;
  `checkpoint`'s test that the latest snapshot is of the clock's boundary.
- B78 (half 2): see `rulings_batch.md` B78, the `restore = false` form and
  its refusals first among them.
- From track 2 agent 1: D-127's "`t₀` applied rather than compared", which
  the `restore = false` form contradicts; `restore!` missing from D-218's
  list of doors that reset the mode; `restore!(sim, cp)` taking the
  recording keywords, which D-261 bullet 7 does not name.
