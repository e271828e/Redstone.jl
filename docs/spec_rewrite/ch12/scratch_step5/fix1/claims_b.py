"""Update units/B/claims.md for the fixes; append its log part."""
import sys
sys.path.insert(0, 'scratch_step5/fix1')
from claimlib import rep, flush

U = 'B'
rep('P1-11', U,
    "which a stop at `t` (the localized event time) places inside a frame.\ntag: R\nruling: R10\nnote: F4; `t*` linked and glossed at its first use (verifier); frame linked, its gloss in the next sentence",
    "which a stop at `t` (the localized event time) places inside a frame, one iteration of the loop.\ntag: R\nruling: R10\nnote: F4; `t*` linked and glossed at its first use (verifier); frame linked at this first use, its gloss an appositive (chapter pass P1-11)")
rep('P1-11', U,
    'note: "It" spelled "The loop", since the frame\'s gloss sentence now sits before it',
    'note: "It" spelled "The loop", since the frame\'s gloss now ends the sentence before it')
rep('P1-11', U, 'added: A frame is one iteration of the loop.', 'added: , one iteration of the loop.')
rep('P1-14, P1-20, P1-13', U,
    "new: The diagnostic is written to the loop's own diagnostic cell (each writer's bounded ring of diagnostics and its heartbeat) (D-203). The run's-end sweep collects the diagnostic into",
    "new: The diagnostic is written to the loop's own diagnostic cell, a writer's own holding place for runtime diagnostics and liveness (D-203). The run's-end sweep, the loop's last pass over every diagnostic cell, collects the diagnostic into")
rep('P1-14, P1-20, P1-13', U,
    'split into three sentences, "it" spelled "the diagnostic" twice (verifier)',
    'split into three sentences, "it" spelled "the diagnostic" twice (verifier); the cell takes §12.2\'s gloss as an appositive, off the citation (chapter pass P1-14, P1-20); the run\'s-end sweep is glossed from D-201, "the loop sweeps every cell once more at the run\'s end" (chapter pass P1-13)')
rep('P1-14, P1-20, P1-13', U,
    "added: (each writer's bounded ring of diagnostics and its heartbeat)",
    "added: , a writer's own holding place for runtime diagnostics and liveness\n\nadded: , the loop's last pass over every diagnostic cell,")
rep('P1-19', U,
    'old: With `should_abort` set, the wrapper\'s exit path also requests a sim stop.\ntag: F',
    'old: With `should_abort` set, the wrapper\'s exit path also requests a sim stop.\nnew: With `should_abort` (the per-attachment failure policy, an `attach!` keyword) set, the wrapper\'s exit path also requests a sim stop.\ntag: F\nnote: `should_abort` linked and glossed at its first use in the section, the glossary\'s words (chapter pass P1-19)\n\nadded: (the per-attachment failure policy, an `attach!` keyword)')
rep('P1-24', U,
    'old: The run takes whole frames until the boundary time first covers the duration.\ntag: M\nnote: M7',
    'old: The run takes whole frames until the boundary time first covers the duration.\nnew: The run ends at the first grid boundary whose time reaches or exceeds `t_end` (D-133). The run takes whole frames only\nnewcites: D-133\ntag: M\nnote: M7; the sentence goes as a third statement of the landing, held by the bold and the whole-frames sentence, and verbatim §12.6\'s `t_plus` rule, which the pointer before it names (chapter pass P1-24)')
rep('P1-21', U,
    'new: The default of five seconds is generous for front-end window teardown and socket closes.',
    'new: The `join_timeout` default of five seconds is generous for front-end window teardown and socket closes.')
rep('P1-21', U,
    'the labelled lead-in folds into the topic sentence\n',
    'the labelled lead-in folds into the topic sentence; the default is named, its step (5) mention far back (chapter pass P1-21)\n')
rep('P1-23', U,
    'old: That is the disposition §10.4 gives its own two constants, extended here to an operational one (D-198).\ntag: F',
    'old: That is the disposition §10.4 gives its own two constants, extended here to an operational one (D-198).\nnew: That is the disposition §10.4 gives its own two constants, extended here to an operational one.\nnewcites: §10.4\ntag: F\nnote: D-198, cited at the bold the sentence before, is not repeated (chapter pass P1-23)')
rep('P1-22', U,
    'old: Deployment contexts legitimately differ in patience.\ntag: F',
    'old: Deployment contexts legitimately differ in patience.\nnew: Usage contexts legitimately differ in patience.\ntag: F\nnote: at a sentence\'s start "Deployment" read as the type, two sentences before `Deployment` (chapter pass P1-22)')
rep('P1-22', U,
    'old: An unattended sweep wants to fail fast, a test battery exercising the abandonment path faster still, while a device with slow teardown may warrant more.\ntag: F',
    'old: An unattended sweep wants to fail fast, a test battery exercising the abandonment path faster still, while a device with slow teardown may warrant more.\nnew: A series of runs nobody watches wants to fail fast, a test battery exercising the abandonment path faster still, while a device with slow teardown may warrant more.\ntag: F\nnote: "sweep" names one pass through the execution order in this section; "nobody watches", not "unattended runs", since that term\'s link and gloss come later in the section (chapter pass P1-22)')
rep('P1-20', U,
    'Those values are well-defined by root-input totality (every root input must hold a value) (§14.6).',
    'Those values are well-defined by root-input totality, the rule that every root input must hold a value (§14.6).')
rep('P1-20', U,
    'the semicolon parenthetical splits into a gloss and the citation',
    'the semicolon parenthetical splits into an appositive gloss and the citation (chapter pass P1-20)')
rep('P1-20', U,
    'added: (every root input must hold a value)',
    'added: , the rule that every root input must hold a value')
rep('P1-31', U,
    'old: This protocol already has that path.\ntag: F',
    'old: This protocol already has that path.\nnew: This protocol already has that path,\ntag: F\nnote: moved after the mechanism and joined to its conclusion (chapter pass P1-31)')
rep('P1-31', U,
    'new: The loop reads that stop at the frame top, before any frame, so the run advances no frame.',
    'new: The loop reads it there, before any frame, so the run advances no frame.')
rep('P1-31', U,
    '§13.5 stays cited later in the paragraph',
    '§13.5 stays cited later in the paragraph; "that stop at the frame top" becomes "it there", the sentence now following the one that names both (chapter pass P1-31)')
rep('P1-31', U,
    'old: No new exit protocol is needed, therefore.\ntag: F',
    'old: No new exit protocol is needed, therefore.\nnew: so no new exit protocol is needed.\ntag: F')
rep('P1-13', U,
    "whose terminal snapshot is the one the run started from and whose termination record's tail residue holds the `DeviceCrash`.\ntag: R\nruling: R8\nnote: the run publishes nothing after the failure;",
    "whose terminal snapshot is the one the run started from and whose termination record's tail residue (the diagnostics the run's-end sweep folds in) holds the `DeviceCrash`.\ntag: R\nruling: R8\nnote: tail residue glossed from §13.5, \"the post-account diagnostics the run's-end sweep folds in\", with no citation so the sentence still ends on the `DeviceCrash` before the next \"It\" (chapter pass P1-13); the run publishes nothing after the failure;")
rep('P1-13', U,
    "added: (the primary record of a session)",
    "added: (the primary record of a session)\n\nadded: (the diagnostics the run's-end sweep folds in)")
rep('P1-12', U,
    'old: The stop already rides on the control plane, the separate atomic surface carrying pause, pace and stop (§12.1).\ntag: F',
    'old: The stop already rides on the control plane, the separate atomic surface carrying pause, pace and stop (§12.1).\nnew: The stop already rides on the control plane (§12.1).\ntag: F\nnote: the appositive repeated step (1)\'s gloss in the same section (chapter pass P1-12)')
rep('P1-20', U,
    "It would also leave half-written stores (the framework-owned homes of a component's state) (§13.6).",
    "It would also leave stores (the framework-owned homes of a component's state) half-written (§13.6).")
rep('P1-20', U,
    'note: split for the glosses of sweep and store\n',
    'note: split for the glosses of sweep and store; "half-written" moves after the gloss, so gloss and citation do not touch (chapter pass P1-20)\n')
rep('P1-33', U,
    'old: The published record is consistent, since the frame published nothing.\ntag: F',
    'old: The published record is consistent, since the frame published nothing.\nnew: What the run published is consistent, since the frame published nothing.\ntag: F\nnote: "the record" bare means the termination record in this section (chapter pass P1-33)')
rep('P1-20', U,
    'new: as after a throw inside boundary zero (the initialization boundary, the ordinary macro-sequence with an empty integrate) (§13.4).',
    'new: as after a throw inside boundary zero, the initialization boundary, which runs the ordinary macro-sequence with an empty integrate (§13.4).')
rep('P1-20', U,
    'one sentence, as in the old, so "such a run" keeps its antecedent (verifier)',
    'one sentence, as in the old, so "such a run" keeps its antecedent (verifier); the gloss is an appositive clause, off the citation (chapter pass P1-20)')
rep('P1-20', U,
    'added: (the initialization boundary, the ordinary macro-sequence with an empty integrate)',
    'added: , the initialization boundary, which runs the ordinary macro-sequence with an empty integrate')
flush()
