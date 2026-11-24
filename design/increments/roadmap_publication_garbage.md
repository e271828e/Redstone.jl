# Roadmap: publication's garbage

The analysis `pending.md`'s bullet calls for (§9.8, §10.7, §11.2, D-269).

A new snapshot and table copy per boundary are by design: §11.2 leaves
published snapshots to the GC, so a run never avoids it. The requirement
that sets the target is a hardware-in-the-loop run: a paced run in which no
collection pause may break a frame deadline, at the expense of logging.
Publication cannot be switched off for it, since a device reads the model
through the snapshot.

On a small model `publish!` allocates about 784 B per boundary, plus 8 B per
`Float64` cell and about 272 B per rostered device, and the status vector is
two thirds of it (`../reports/20261002_tuple_walks/report.md`, section 7). A
proper analysis on a model of real size comes first, with the pause length
measured against the frame deadline, then a ruling beside D-269, then the
build. The analysis should assess:

- **Sharing status records.** `_status` builds a fresh vector of writer
  records at every publication. An unchanged record could be shared with
  the previous snapshot. A device's heartbeat changes every frame, which
  makes this a design question.
- **A scheduled young collection.** §9.8 names `GC.gc(false)` at frame
  boundaries, and nothing in `src/` builds it. The candidate: the pacer's
  wait collects when enough garbage has built up and the time to the next
  deadline exceeds the recent p99 pause with a margin. Unpaced runs and
  `step!` skip it, and `PacerStatus` reports the pauses.
- **What limits a scheduled collection.** The trigger is process-wide, so
  a device that allocates can still start a collection mid-frame. The GUI
  will be the main such device, so the analysis runs with it attached.
  With the log on, thinned snapshots die in the old generation, where only
  a full collection reclaims them. The fixed cost grows with tasks, live
  heap and GC threads.
- **Device-side garbage.** A device's own task allocates too. Staging
  rebuilds every batch dynamically (`_normalize`), at any width. The
  collection trigger is process-wide, so the analysis counts this beside
  publication's garbage.
