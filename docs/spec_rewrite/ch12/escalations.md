# Chapter 12: serious findings for the owner

Each finding shows a defect or inconsistency in the design itself, not in its
prose. The rewrite carries the text as written. Lines are `spec.md` lines at
`17ad42d`; `log` marks `decisions.md` lines.

## From the survey (checkpoint 1)

- **E1. "Resumable by the next `run!`"** (survey 1 F1, survey 2 F72; brief
  R7). §12.4 9054 and 9080 say a stopped simulation is "resumable by the
  next `run!` (§12.6)". D-132's Position says the same (log 4235–4236). Against
  it: §12.6 9300–9301 calls `stopped` terminal and 9403–9405 makes
  `stopped → init! → run!` the re-run; D-088's lifecycle (log 2777–2778)
  agrees; and `src/sim.jl`'s `_assert_advanceable` (400–411) admits only
  `initialized`. Both surveys ran it: `run!` on a stopped simulation raises
  `ServiceLifecycle: run! on a stopped simulation: re-running is the stopped
  → init! → run! cycle`. No entry annotates D-132. Recommendation: read
  "resumable" as re-runnable, since every other source and the code agree.
  §12.4 then says the simulation "can be re-run through `init!`, or
  restarted from a checkpoint (§12.6)", and track 2 annotates D-132's
  Position. If a stopped run was meant to continue under `run!`, that is a
  design change to D-088 and the code.
- **E2. The parked GUI's guarantees** (survey 1 F2; brief R2). D-310 parked
  the built-in GUI and spawns every device, a front end included (log
  13216–13231). §12.2 8711–8716 still argues that the scheduler stall cannot
  reproduce because "the GUI … waits on nothing, ever" and concludes "Under
  any starvation, then, the front end keeps rendering and the stop button
  keeps working". That rested on the GUI running on the calling task, a
  ground D-310 withdrew (D-027 Rejected, log 993–994, still says so). A
  front end is now a spawned task, so its stop reaches the loop only when the
  scheduler runs that task. §12.3 8823–8824 describes the parked GUI's read
  path ("The GUI does not use the wait. Being VSync-paced, it reads `latest`
  at each render"), from D-134's Rationale. Recommendation: §12.2 keeps the
  two grounds that stand (the loop yields every frame; nothing couples a
  stall to another task) and says a front end's stop reaches the loop
  through its handle's atomic stop word, under starvation as late as any
  input; "keeps working" goes. §12.3's GUI note goes, or becomes "A front
  end need not use the wait", if the owner wants that stated. Track 2
  annotates D-027's Rejected list and D-134's Rationale with D-310.
