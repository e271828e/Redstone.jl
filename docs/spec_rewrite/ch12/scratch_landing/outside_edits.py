import sys
D = "/Users/miguel/.julia/dev/Redstone.jl/docs/design/"
S, L, I, W = "spec.md", "decisions.md", "implementation.md", "companions/inbound_periphery_walkthrough.md"
E = [
# B22
(S, "name, and the device is dead from boundary zero ([§12.4][s12-4]).",
    "name, and the device is dead from the run's first frame top ([§12.4][s12-4])."),
# B23
(S, "first snapshot is published ([§12.6][s12-6], [D-274][d-274]).",
    "first snapshot is published ([D-274][d-274])."),
# B24 11949
(S, """The
[recorders](#g-recorders) are cleared exactly as [§12.6][s12-6] states for
`init!`. Those are the [trace](#g-trace), the log, and any
[batches](#g-batch) still in [staging cells](#g-staging-cell) (where a
device's pending write batch waits between drains).""",
"""The
[recorders](#g-recorders) restart exactly as [§12.6][s12-6] states for
`init!`. The [trace](#g-trace) and the log are new objects, and any
[batches](#g-batch) still in [staging cells](#g-staging-cell) (where a
device's pending write batch waits between drains) are cleared."""),
# B24 12913
(S, "anchored at `t0` and recordings cleared ([§12.6][s12-6]).",
    "anchored at `t0` and the recorders built anew ([§12.6][s12-6])."),
# B24 14370
(S, """the trace and the log jointly. They are cleared together at
`init!`, at `restore!` and at a trim commit, so they restart with the run
they record ([§12.6][s12-6], [§14.8][s14-8]).""",
"""the trace and the log jointly. `init!`, `restore!` and a trim commit
build them anew together, so they restart with the run they record
([§12.6][s12-6], [§14.8][s14-8])."""),
# B25
(S, """Checks the state's
    fingerprint (`CheckpointMismatch`) and its `t` against its grid
    (`CheckpointMidFrame`) before any write. Copies the state back, settles
    through the hooks and writes `:consistent` last. It takes no status
    gate ([§12.6][s12-6]). A writing door.""",
"""Checks the state's
    fingerprint and deployment (`CheckpointMismatch`) and its `t` against
    its grid (`CheckpointMidFrame`) before any write ([§12.6][s12-6]).
    Copies the state back, settles through the hooks and writes
    `:consistent` last. It takes no status gate ([D-319][d-319]). A writing
    door."""),
# B26 12998
(S, """and surface-checked exactly as the GUI's writes (the harness cell,
  [§12.6][s12-6]). It is legal under `run!` and `step!` alike.""",
"""and surface-checked exactly as any device's (the harness cell,
  [§11.3][s11-3]). It is legal under `run!` and `step!` alike
  ([§12.6][s12-6])."""),
# B26 14220
(S, "convention ([§12.6][s12-6], [§11.3][s11-3]).",
    "convention ([§11.3][s11-3], [§12.6][s12-6])."),
# B26 14226
(S, "`ClaimedFaceEntry` ([§11.3][s11-3], [§12.6][s12-6]).",
    "`ClaimedFaceEntry` ([§11.3][s11-3])."),
# B26 walkthrough 5
(W, """`spec.md` [§11.3][s11-3] (root inputs, claims, the roster freeze), [§11.4][s11-4] (staging and the drain), [§11.7][s11-7] (GUI write path),
[§12.6][s12-6] (harness cell) and decision""",
"""`spec.md` [§11.3][s11-3] (root inputs, claims, the roster freeze, the harness cell), [§11.4][s11-4] (staging and the drain),
[§11.7][s11-7] (GUI write path) and decision"""),
# B26 walkthrough 197
(W, "([§12.6][s12-6]). This is the design's one **derived** surface",
    "([§11.3][s11-3]). This is the design's one **derived** surface"),
# B27 11018
(S, "a checkpoint whose fingerprint matches the simulation's",
    "a checkpoint whose fingerprint and deployment match the simulation's"),
# B27 12928 + B39 12930
(S, """  `t` and `t₀`, and the fingerprint. Legal in `initialized` and `stopped`,
  refused after a `t*` stop and after an abandoned frame
  (`CheckpointMidFrame`). A checkpoint is not a condition and has no algebra
  ([§12.6][s12-6], [§14.1][s14-1], [D-274][d-274], [D-319][d-319]).""",
"""  `t` and `t₀`, the fingerprint and the deployment. Legal in `initialized`
  and `stopped`, refused after a `t*` stop and after an abandoned frame
  (`CheckpointMidFrame`). A checkpoint is not a condition and has no algebra
  ([§14.1][s14-1], [D-274][d-274], [D-319][d-319])."""),
# B27 12933
(S, "It checks the checkpoint's fingerprint (`CheckpointMismatch`) and its",
    "It checks the checkpoint's fingerprint and deployment\n  (`CheckpointMismatch`) and its"),
# B27 12942
(S, "with the same keywords and the same fingerprint check.",
    "with the same keywords and the same fingerprint and deployment check."),
# B27 13394
(S, """raised when a checkpoint's fingerprint disagrees with the
  target simulation or model.""",
"""raised when a checkpoint's fingerprint or deployment disagrees
  with the target simulation or model."""),
# B28
(S, """trace by frame ordinal, after the trace's checkpoint is restored. It
re-records, ends `initialized`, and validates the checkpoint's fingerprint
(stores, root-input faces and the `Deployment`) up front, restoring the
clock with the rest of the state ([§12.7][s12-7]).""",
"""trace by frame ordinal, after the trace's checkpoint is restored under
the default form. It re-records, ends `initialized`, and validates the
checkpoint's fingerprint (the structural layout) and its `Deployment` up
front. The default form restores the clock with the rest of the state
([§12.7][s12-7])."""),
# B29 14073
(S, "[D-318][d-318]). Its doors are listed\nin the `Model` block",
    "[D-318][d-318]). Its entry points are listed\nin the `Model` block"),
# B29 4336
(S, "A simulation never shares its model, and its doors are the only\nway in:",
    "A simulation never shares its model, and its entry points are the\nonly way in:"),
# B30
(S, "A halt names a frame at or after the one the feed starts from. It ends",
    "A halt names a frame from the one the feed starts from through the\n  recording's last. It ends"),
# B31 13301
(S, """- **`MissingInit`** ([§12.6][s12-6]). Error · service · fail-fast. The
  simulation's status, the entry point called (`run!`/`step!`).""",
"""- **`MissingInit`** ([§12.6][s12-6], [§12.7][s12-7]). Error · service ·
  fail-fast. The simulation's status, the entry point called
  (`run!`/`step!`/`replay!`/`live!`)."""),
# B31 13303
(S, """- **`ServiceLifecycle`** ([§11.3][s11-3], [§14][s14]). Error · service ·
  fail-fast. The operation
  (`attach!`/`detach!`/`init!`/`restore!`/`trim!`/`checkpoint`/`linearize`),""",
"""- **`ServiceLifecycle`** ([§11.3][s11-3], [§12.7][s12-7], [§14][s14]). Error ·
  service · fail-fast. The operation
  (`attach!`/`detach!`/`init!`/`restore!`/`trim!`/`checkpoint`/`linearize`/`live!`),"""),
# B31 13428
(S, """  [§12.6][s12-6], [§14.7][s14-7]). Error · service, or build in a `sample_times`""",
"""  [§12.6][s12-6], [§12.7][s12-7], [§14.7][s14-7]). Error · service, or build in a `sample_times`"""),
(S, "  `step!`, `replay!`, `pace!`, `margin!`, `trim!`, `linearize`, `TableBinding`,",
    "  `step!`, `replay!`, `live!`, `pace!`, `margin!`, `trim!`, `linearize`, `TableBinding`,"),
# B32
(S, "same loop with staging fed from a recording",
    "same loop with its drain fed from a recording"),
# B34
(S, "un-pause, pace, `margin`, the stop word, the running flag, the wait and\n`join_timeout`, consulted",
    "un-pause, pace, `margin`, the stop word, the sticky stopped status, the\nrunning flag, the wait and `join_timeout`, consulted"),
# B35
(S, "raised at a frame-top or wait\nunmask point, so the run",
    "raised at a frame-top, wait or\npause-block unmask point, so the run"),
# B39 11002
(S, "algebra, and `restore!` puts it back ([§12.6][s12-6], [D-273][d-273]).",
    "algebra, and `restore!` puts it back ([D-273][d-273])."),
# B39 11061
(S, "state at a frame top as one value), not a condition, and it has no algebra\n([§12.6][s12-6], [D-274][d-274]).",
    "state at a frame top as one value), not a condition, and it has no algebra\n([D-274][d-274])."),
# B39 7087
(S, "([§11.5][s11-5], [§12.7][s12-7]). Sizing follows.",
    "([§11.5][s11-5], [§12.4][s12-4], [§12.7][s12-7]). Sizing follows."),
# B33
(I, "its model a `Model{Float64}` by type (§12.1, D-256, D-317).",
    "its model a `Model{Float64}` by type (§12.6, D-256, D-317)."),
(I, "- §12.6's input mode: `mode(sim)`, `to_time` and `live!` (D-260).",
    "- §12.6 and §12.7's input mode: `mode(sim)`, `to_time` and `live!` (D-260)."),
(I, """A deviceless loop
never yields (§12.2), so a test that spawns""",
"""§12.2 guarantees
a per-frame yield only with devices attached, and an unpaced deviceless loop
never yields, so a test that spawns"""),
# B36
(L, "Finally `t_end`'s landing rule, stated once in [§12.4][s12-4](1):",
    "Finally `t_end`'s landing rule, stated once in [§12.4][s12-4]:"),
(L, "[§12.4][s12-4], [§12.4][s12-4](1), [§12.4][s12-4](5), [§12.6][s12-6],\n[§12.7][s12-7], [§9.2][s9-2]",
    "[§12.4][s12-4], [§12.4][s12-4](5), [§12.6][s12-6],\n[§12.7][s12-7], [§9.2][s9-2]"),
(L, "([D-093][d-093], [§12.6][s12-6]) stands as shorthand for it.",
    "([D-093][d-093]) stands as shorthand for it."),
# B37
(L, """because [§12.6][s12-6] defines the unattended run as
the deviceless one and [§13.4][s13-4]'s rethrow presupposes it.""",
"""because [§11.1][s11-1] defines the unattended run,
[§12.6][s12-6] states that a deviceless `run!` is fully synchronous, and
[§13.4][s13-4]'s rethrow presupposes it."""),
]
texts = {f: open(D + f, encoding="utf-8").read() for f in {e[0] for e in E}}
bad = 0
for f, old, new in E:
    n = texts[f].count(old)
    if n != 1:
        print(f"MATCH {n}: {f}: {old[:80]!r}"); bad += 1
if bad: sys.exit(1)
for f, old, new in E:
    texts[f] = texts[f].replace(old, new)
for f, t in texts.items():
    open(D + f, "w", encoding="utf-8").write(t)
print("applied", len(E))
