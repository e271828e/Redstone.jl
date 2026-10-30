# Notes: inspector increment 2, rulings taken in the user's absence

The user left on 2026-10-30 after increment 1 landed, asking for autonomous
work with findings and decisions recorded. Every ruling below is the
coordinating session's, each with its reason, for the user to ratify or
strike; a struck one is reverted by a finding. Nothing is pushed from this
session. The brief is `brief_inspector_02_foundation_pure.md`.

## Findings

1. **Both generator checks fail on the schema as pinned.**
   `json-schema-to-typescript` 16.0.0 turns the node branches' `"path":
   true` placeholders into `path: unknown`, and the intersection with
   `NodeIdentity`'s optional `path?: string` gives `string | undefined`;
   the envelope's `"build": true` likewise leaves `d.build` as `BuildBody
   | undefined` inside `if (d.kind === "build")`. Probed with `tsc` 6.0.3
   under `--strict` in the scratchpad (`scratchpad/gen/probe.ts`).
2. **ajv strict mode still refuses the schema** after the fix, now on
   `strictRequired` for the `not` clauses. Default strictness compiles it
   and every fixture validates. The pipeline runs ajv at default
   strictness, the spike's practice, now stated in the brief.
3. **The oracle.** `scratchpad/oracle/resolve.py` implements the parent
   rule, the memberships, the level graphs, the resolution to terminals,
   the routes and the feedthrough edges in Python over the committed
   fixtures. Its feedthrough counts (16, 5, 0, 0 on `closed_loop`,
   `containers`, `rates`, `large`) and its root-face route totals (11, 2,
   3, 20) equal the core's `_feedthrough` and `face_routes` run on the
   same models (`scratchpad/oracle/crosscheck.jl`, through the inspector's
   `scripts` project). The brief's pins are its numbers.

## Rulings

1. **The schema commit in the core, `778d6ee`.** `build_release.md`'s
   pending list pre-ruled the fix as schema-side and additive, "spelling
   the shared fields in the branch"; the commit does exactly that for the
   seven shared fields in both node branches and adds the same spelling
   for the three bodies in the envelope's branches, by `$ref`. Validation
   of every instance is unchanged, the core's `descriptor` file is green
   (530 assertions). The pending entry in `build_release.md` is closed
   with the outcome. *Why a core commit while away:* the record had
   already decided the fix's side, and a types layer written by hand
   around the generated file is what answer 4 rejected.
2. **The schema copy lands in increment 2 ahead of the pin bump**, as its
   first commit on `increment-2`. The pin can only name a pushed core
   commit, and nothing is pushed, so the bump waits for the user: push
   the core, bump both revisions to that hash by the README's procedure,
   which rewrites the copy to the same bytes, then push the inspector.
   Until then the `fixtures` job would redden on the copy; it never runs.
3. **`--additionalProperties false` on the generator.** `NodeIdentity`
   has no `additionalProperties` keyword because the node branches build
   on it with `allOf`, so the generator gives it an index signature. The
   option sets the generator's default for that one object and changes no
   validation.
4. **A failure body's `structure` is optional in the header check.**
   `workspace.md` answer 10 refuses "a body without `structure.nodes`";
   `failure_structure.json` has no structure by design, so the rule reads
   on the build and deployment bodies.
5. **The label's last fallback is the kind word.** A structureless failure
   with no `name` and no file name has no root node to take a display
   name from.
6. **`App.svelte` is a text shell.** The roadmap's "no drawing" is kept;
   the shell prints the loader's outcome so `npm run dev` shows the loader
   on a real file, and increment 3 replaces its body.
7. **The `frontend` CI job lands now** with `npm run check` and `npm
   test`; the roadmap gave the job to increment 3 with the browser
   checks, which extend it. Without it, "visible: `npm test` and `npm run
   check` green" is only visible on one machine.
8. **`elkGraph` joins without sizing.** `build_release.md` answer 5 lists
   the ELK graph function among the pure modules; the spike's version
   measured text with a canvas context, which is DOM work, so the
   function takes sizes and the canvas supplies them in increment 3.
9. **A primitive root's level is one block, no pins, no wires.** Its
   faces are the root faces; drawing them as pins would need wires the
   descriptor does not carry. Increment 3 decides the drawing.
10. **Vitest 5.0.5 and `json-schema-to-typescript` 16.0.0** are fixed
    today from npm, the two versions the spike did not pin. Vitest 5
    needs Node 26 and Vite 8, both in place.

## Coordination

- Increment 9's session works in `~/.julia/dev/RedstoneInspector_inc9` on
  `increment-9`; this one in `~/.julia/dev/RedstoneInspector.jl-inc2` on
  `increment-2`; the main checkout is idle. Overlap: `README.md` (this
  increment inserts a "Frontend" section after "Fixtures"; increment 9
  edits the status line, adds a live-session section and the layout list)
  and nothing else; increment 9 does not touch `CI.yml`.
- Neither session commits `design/pending.md` or
  `roadmap_inspector.md`; the bookkeeping those files owe is listed here
  for the user: the stage-1 bullet and the roadmap's increment 2 entry
  gain a "built on `increment-2`, awaiting merge" line once the review
  closes.

## For the user, in order

1. Read the rulings; strike any, and the fixer reverts it.
2. Push the core (`778d6ee` and the bookkeeping commits).
3. Merge `increment-2` onto `master` (rebase, fast-forward), bump the pin
   to the pushed core hash, regenerate, push; the first CI run exercises
   the `frontend` job.
4. The look-and-adjust pass has nothing to look at in this increment;
   the first look is increment 3's.

## Outcome, 2026-10-30

Built, reviewed and fixed, on `increment-2` at `7120790` in
`~/.julia/dev/RedstoneInspector.jl-inc2`, not pushed. The brief's "Built"
section carries the record: five commits, `npm run check` 0 errors,
`npm test` 161 assertions, every pin equal between the oracle, the
reviewer's scratch file and the modules, every brief mutant red, the shell
driven in a real browser. Three findings landed by the fixer and verified
by the reviewer: `LAST_SEPARATE` pinned on `containers`' root (the brief's
bullet had named `descent`, which has no output pin, and is corrected),
the resolution's side key pinned on an inline synthetic structure, and a
`null` body or a failure `structure` without `nodes` refused in words
instead of throwing. One acceptable survivor: the label falling back to
the root's type instead of its alias, no fixture having an aliased root.
Cosmetic: one line of `MAP.md`'s resolve.test clause runs long.

The core's bookkeeping left for the user, since this session does not
commit `pending.md` or the roadmap while increment 9's session may: the
stage-1 bullet and the roadmap's increment 2 entry gain "built on
`increment-2` at `7120790`, awaiting merge and push". The merge and the
pin bump are the steps under "For the user" above; the pin bump's hash is
the core's tip after the push, `778d6ee` or later.

The user returned the same day and asked for the steps above to be run:
the core pushed at `abf1d81`, `increment-2` fast-forwarded onto master,
the pin bumped to `abf1d81` as `ccbedf8` (102 depot slugs in eight
fixtures, nothing else), pushed, CI green on all four jobs, the worktree
and branch removed, and the pending bullet and roadmap entry written.
