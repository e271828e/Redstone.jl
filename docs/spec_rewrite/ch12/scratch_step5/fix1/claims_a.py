"""Update units/A/claims.md for the fixes; append its log part."""
import sys
sys.path.insert(0, 'scratch_step5/fix1')
from claimlib import rep, flush

U = 'A'
rep('P1-25', U,
    "its yields and the thread budget; §12.3",
    "its yields, the thread budget and the liveness heartbeat; §12.3")
rep('P1-25', U,
    'note: roadmap sentence; every word from the old opening or a section title (§12.2, §12.3, §12.5, §12.6, §12.7 titles).',
    'note: roadmap sentence; every word from the old opening or a section title (§12.2, §12.3, §12.5, §12.6, §12.7 titles); "the liveness heartbeat" is §12.2\'s fourth `####` label (chapter pass P1-25).')
rep('P1-15', U,
    'new: The control plane (the separate few-word atomic surface carrying pause, pace and stop) is not staging, structurally (D-022).',
    'new: It is not staging, structurally (D-022).')
rep('P1-15', U,
    "Gloss from the glossary's control-plane entry.\n\nadded: (the separate few-word atomic surface carrying pause, pace and stop)",
    'The plane is named by apposition in the sentence before, which now opens the section (chapter pass P1-15).\n\nadded: , the control plane.')
rep('P1-14', U,
    'new: Staged writes apply at drains (the points where the loop applies staged device writes),',
    'new: Staged writes apply at drains (the frame-top swaps that apply staged device writes),')
rep('P1-14', U,
    'added: (the points where the loop applies staged device writes)',
    'added: (the frame-top swaps that apply staged device writes)')
rep('P1-18', U,
    'new: Riding outside the drain/trace path is safe for determinism',
    'new: Riding outside the path through the drain and the trace, the primary record of a session, is safe for determinism')
rep('P1-18', U,
    'added: (the pacer\'s wall-clock waits)',
    'added: (the pacer\'s wall-clock waits)\n\nadded: , the primary record of a session,')
rep('P1-16', U,
    "added: This section covers, in order, when the loop reads the plane, the stop and its issuer, the pause, pace and `margin`, and the fields of `Control`, one of the periphery's own types (D-256), the one that holds the control plane.",
    "added: This section covers, in order, when the loop reads the plane, the stop and its issuer, the pause, pace and `margin`, and the fields of `Control`, the periphery's own type that holds the control plane (D-256).")
rep('P1-15', U,
    'new: Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields on that separate atomic surface.\ntag: F',
    'new: Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields on a separate atomic surface\ntag: F\nnote: opens the section (chapter pass P1-15); the control plane is named by apposition after it.')
rep('P1-15', U,
    'old: The loop consults them at frame top.\nnew: The loop consults them at frame top, the start of each frame.',
    'old: The loop consults them at frame top.\nnew: The loop consults the control plane at frame top, the start of each frame.\nnote: "them" becomes "the control plane", the fields now a paragraph back (chapter pass P1-15).')
rep('P1-27', U,
    'old: A change issued while a frame runs or waits is observed at the next frame top, at most one frame budget `h/p` later (D-269).\ntag: F',
    'old: A change issued while a frame runs or waits is observed at the next frame top, at most one frame budget `h/p` later (D-269).\nnew: A change issued while a frame runs or waits is observed at the next frame top, at most one frame budget (`h/p`, the step over the pace) later (D-269).\ntag: F\nnote: `p` is introduced 50 lines on, so `h/p` takes a gloss (chapter pass P1-27).\n\nadded: , the step over the pace')
rep('P1-17', U,
    "new: The stop word carries its issuer (D-203). The stop word is the control plane's stop command, one atomic word holding its issuer.",
    "new: The stop word carries its issuer (D-203). The stop word is the control plane's stop command, held in one atomic word.")
rep('P1-17', U,
    "the second sentence is R11's gloss as R15 words it.",
    "the second sentence is R11's gloss as R15 words it, less \"holding its issuer\", which the bold states (chapter pass P1-17).")
rep('P1-26', U,
    'new: `run!` and `replay!` take both as keywords and write them at entry. Both',
    'new: `run!` and `replay!` take both as keywords and write them when called. Both')
rep('P1-26', U,
    "note: split in three; D-269 bullet 2 sets `pace`'s default,",
    "note: split in three; bare \"entry\" becomes \"when called\" (chapter pass P1-26); D-269 bullet 2 sets `pace`'s default,")
rep('P1-30', U,
    "new: Julia's scheduler is cooperative, and the scheduler stall requires a thread monopolist,",
    "new: Julia's scheduler is cooperative, and a stall of that scheduler requires a thread monopolist,")
rep('P1-30', U,
    'note: F16, "freeze" in the scheduler sense becomes "the scheduler stall".',
    'note: F16, "freeze" in the scheduler sense becomes "the scheduler stall"; here "a stall of that scheduler", so the next section\'s "The scheduler stall" has its antecedent (chapter pass P1-30).')
rep('P1-20', U,
    'new: That is one check per run, against the frozen roster (the list of attached device entries) (§11.3).\ntag: F\n\nadded: (the list of attached device entries)',
    'new: That is one check per run, against the frozen roster, the list of attached device entries (§11.3).\ntag: F\nnote: the gloss is an appositive, so it and the citation are not two touching parentheses (chapter pass P1-20).\n\nadded: , the list of attached device entries')
rep('P1-20', U,
    "new: The mechanism is the per-writer diagnostic cell (a writer's own holding place for runtime diagnostics and liveness) (D-136), specified in full by §11.8,",
    "new: The mechanism is the per-writer diagnostic cell (D-136), specified in full by §11.8,")
rep('P1-20', U,
    "D-136's Position, placed at the cell; the handles are D-193's, cited next sentence.\n\nadded: (a writer's own holding place for runtime diagnostics and liveness)",
    "D-136's Position, placed at the cell; the handles are D-193's, cited next sentence. The gloss takes its own sentence after it, so gloss and citation are not two touching parentheses and D-136 does not move onto the handles (chapter pass P1-20).\n\nadded: A diagnostic cell is a writer's own holding place for runtime diagnostics and liveness.")
rep('P1-20', U,
    'old: The cell carries the single liveness timestamp.\nnew: The diagnostic cell carries the single liveness timestamp.',
    'old: The cell carries the single liveness timestamp.\nnew: It carries the single liveness timestamp.\nnote: "It" is the diagnostic cell of the gloss sentence before.')
rep('P1-20', U,
    'new: It counts published boundaries, that is grid, `t` and boundary zero (the initialization boundary at `t₀`) (§10.1, §10.4), not frames.',
    'new: It counts published boundaries, that is grid, `t` and boundary zero (the initialization boundary at `t₀`), not frames (§10.1, §10.4).\nnote: the citation moves to the clause\'s end, off the gloss (chapter pass P1-20).')
rep('P1-20', U,
    'new: The release-store of `latest` (the atomic reference readers acquire-load) (§11.2) happens before the counter increment under the lock.',
    'new: The release-store of `latest`, the atomic reference readers acquire-load (§11.2), happens before the counter increment under the lock.')
rep('P1-20', U,
    'note: M5; the bold on "before" goes.\n\nadded: (the atomic reference readers acquire-load)',
    'note: M5; the bold on "before" goes. The gloss is an appositive and §11.2 stays on `latest`, since §11.2 does not state the order (chapter pass P1-20).\n\nadded: , the atomic reference readers acquire-load')
rep('P1-28', U,
    "new: The device side's predicate, `counter > last_seen` (below), therefore implies",
    "new: The device side's test `counter > last_seen` (below) therefore implies")
rep('P1-28', U,
    "note: M5; the predicate now precedes the device side, so it points below.\n\nadded: The device side's predicate",
    "note: M5; the predicate now precedes the device side, so it points below. \"test\", since the full predicate adds `&& running` (chapter pass P1-28).\n\nadded: The device side's test")
rep('P1-29', U,
    'new: Inbound coalescing (the CAS merge that leaves one pending batch per device)',
    'new: Inbound coalescing (the compare-and-swap merge that leaves one pending batch per device)')
rep('P1-29', U,
    'added: (the CAS merge that leaves one pending batch per device)',
    'added: (the compare-and-swap merge that leaves one pending batch per device)')
rep('P1-19', U,
    'old: Any holder of a snapshot therefore indexes it without consulting the loop, whether the log or a post-run inspector.\ntag: F',
    'old: Any holder of a snapshot therefore indexes it without consulting the loop, whether the log or a post-run inspector.\nnew: Any holder of a snapshot therefore indexes it without consulting the loop, whether the log (the retained sequence of published snapshots) or a post-run inspector.\ntag: F\nnote: the log takes its §12.3 link and gloss (chapter pass P1-19).\n\nadded: (the retained sequence of published snapshots)')
flush()
