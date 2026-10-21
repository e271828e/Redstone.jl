# Brief: the Part I depth pass

The owner ruled on 2026-10-13 to apply the depth rule to Part I of
`design/spec.md`, read strictly. This brief turns the audits in this
directory into edits. Read `README.md` here first: it states the rule, the
size estimates, the owner's decisions and the law list. The audits
`depth_ch01-04.md` (P entries), `depth_ch05-07.md` (M entries),
`laws_ch08-10.md` and `laws_ch11-14.md` give each item's location, its
destination and its unique facts.

## The owner's rulings

1. Part I gets shorter. Every move the README and the audits list happens.
2. Chapter 2 becomes the formalism of a run. Its new layout: a short chapter
   intro stating the system class, then §2.1 Time and boundaries, §2.2
   Integration and inputs (or a better title), §2.3 Events, §2.4 Runs, §2.5
   Exclusions. Old §2.1 becomes §2.3 and old §2.2 becomes §2.5. The stage
   may merge §2.1 and §2.2 into one section if the result reads better, and
   then the numbers shift by one; report the final map.
3. Trim and linearization get one sentence each in §7.2 (law D4).
4. §7.3's idioms (M42) go to §8.2 as authoring guidance. §7.4's lineage
   narrative (M43) goes to a new companion,
   `design/companions/fused_evaluation_lineage.md`. §7.4 keeps its last
   paragraph, the computer/integrator split, and is retitled for it.
5. and 6. Handled by the orchestrator, not by a stage: the new entry D-364
   on bulk-data rig environments, its annotations on D-139 and D-237, and the
   §14.9 wording.

## The orchestrator's rulings on the audits' open points

Placement, so that citations map one to one:

- **§5.6 moves whole to a new §13.8**, "Cycle diagnosis: feedthrough
  tracing", after §13.7. Part I keeps two things, placed in §5.4 or §5.5:
  tracing is diagnostic only and ordering correctness comes from the
  two-stage split alone (D-012), and the verdict defining a real and an
  artificial loop (M18 item 2). §5.6 then no longer exists.
- **§7.5 moves whole to a new §9.8**, "Allocation policy: a scoped
  invariant", after §9.7. "Event firings are not recorded" (D-309) goes to
  §11.2 instead. §7.5 then no longer exists, and §1's design criterion
  cites §9.8.
- **§4.4's value-level constructor (P23)** goes to §8.2, citing §14.1 for its
  purpose.
- **§3.4's integrate-and-dump facts (P9)** land in §8.6's worked IMU. Facts
  §8.6 cannot hold without losing its thread go to
  `companions/flight_case_studies.md`.
- **The unbundling-component candidate (P19)** goes to
  `companions/library_inventory.md`.

Borderline items:

- Keep in Part I: M1's de-spelled sentence, M7's "modes are state for the
  feedthrough split", M18's verdict, M20's "a container's elements count as
  immediate children", M23(b), M31, M33's "the flat vector still exists",
  P3, P7's laws, P11, P14's ruling sentence restated as "the port is the unit
  of every external read and write" with its D-363 citation, the bullet list
  going (the glossary holds it).
- Move: M10, M11, M13, M21, M26, M27, M34, P5, P12, P19, P20.
- Trim: P7's "nothing is lost" clause, P8 to its law, its verdict and its
  sampling-interface sentence, P17's middle sentence.
- Add: PG1 to §3.2. PG2 to the boundary sequence (B4). PG3 to §4.4, as the
  reason a bulk-data handle enters only through a component. PG4 as a
  rewording of §2.1's "Detection resolution is an execution-policy detail" so
  it agrees with §10.7.

## How every stage works

- **The tip.** Start from `git rev-parse HEAD` and the working tree as you
  find it. Earlier stages leave uncommitted edits. Never revert, stash or
  commit anything. Never touch `src/`, `test/`, `implementation.md`,
  `pending.md`, `extensions.md` or `docs/spec_rewrite/`; the orchestrator
  sweeps those.
- **Read first.** `design/tools/spec_style.md` and
  `design/tools/decisions_style.md`, in full. They bind every edit.
  Chapters 1 to 10 have had their readability rewrite: no **Rule.**,
  **Why.** or **Example.** labels there, and bold marks a ruling once, with
  its D-citation in the same sentence. Each ruling is bold in one place only,
  so a moved ruling keeps its bold at its new home and loses it at the old
  one. Text moved into chapters 11 to 14 keeps the register it arrives in.
- **No loss.** A cut sentence's facts must exist at their destination before
  the cut. Where the destination already states them, cut. Where it states
  them partly, add the missing facts there in the destination's register.
  Never resolve doubt by deleting: report it.
- **No new norms.** A law added to Part I restates what Parts II to IV
  already decide, at Part I's level, citing the D-entry that rules it. If
  the source is ambiguous or two sources disagree, write nothing and report
  it.
- **Citations.** Section citations are linkified, `[§9.8][s9-8]`. Write new
  ones bare (`§9.8`) and run `julia design/tools/linkify.jl`, which
  converts them. A scripted edit matches the linkified spelling. Glossary
  links are inline, `[drain](#g-drain)`, one per term per section, with a
  5 to 10 word gloss at first use in a section.
- **Back-pointers.** Every citation, in the spec, the log, the companions
  and the glossary, that pointed at moved content is repointed, including
  D-entries' **Spec.** fields. `depth_ch05-07.md` and `depth_ch01-04.md` list
  the known ones; grep for the rest.
- **The battery** runs from the repository root after your edits and must be
  green: `linkify.jl`, then `check_refs.jl`, `check_rows.jl`,
  `check_glossary.jl --strict`, `check_bold.jl`, and `linkify.jl` again as a
  no-op. All live in `design/tools/`.
- **Shell.** `ls` is aliased to `eza` and can hang; use `/bin/ls` or `fd`.
- **Report.** Hand back, as text, the files you edited with a line each,
  every placement or wording judgment you made with its reason, anything you
  left undone and why, and the battery output's last lines.
