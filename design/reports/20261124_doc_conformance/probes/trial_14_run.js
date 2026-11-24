export const meta = {
  name: 'doc-conformance-trial-14',
  description: 'Docs conformance audit trial on spec §14: claim inventories and coverage, then blind verification',
  phases: [
    { title: 'Inventory', detail: 'mid-tier: spec, log, companion and coverage slices, with probes' },
    { title: 'Verify', detail: 'high-tier: blind re-judgment of flagged rows plus a sample of ok rows' },
  ],
}

const W = '/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance'
const R = '/Users/miguel/.julia/dev/Redstone.jl/design/reports/20261124_doc_conformance'
const LEADS = R + '/ledgers/stage_m/leads_14'

let active = 0
const waiting = []
async function slot(fn) {
  while (active >= 5) await new Promise(r => waiting.push(r))
  active++
  try { return await fn() } finally { active--; const n = waiting.shift(); if (n) n() }
}

const S = { type: 'string' }, I = { type: 'integer' }
const ROW = { type: 'object', properties: { id: S, file: S, line: I, kind: S, claim: S, evidence: S,
  verdict: { type: 'string', enum: ['finding', 'unverifiable'] }, class: S, fix: S, note: S },
  required: ['id', 'file', 'line', 'kind', 'claim', 'evidence', 'verdict'] }
const OK = { type: 'object', properties: { id: S, file: S, line: I, kind: S, claim: S, evidence: S },
  required: ['id', 'file', 'line', 'kind', 'claim', 'evidence'] }
const INV = { type: 'object', properties: {
  rows: { type: 'array', items: ROW }, ok: { type: 'array', items: OK },
  counts: { type: 'object', properties: { law: I, mech: I, decl: I, ptr: I, why: I, ex: I, surface: I, docstring: I, map: I, cite: I } },
  notes: S }, required: ['rows', 'ok', 'counts'] }
const JUDG = { type: 'object', properties: {
  judgments: { type: 'array', items: { type: 'object', properties: {
    id: S, conforms: { type: 'boolean' }, evidence: S, class: S, fix: S, clear: { type: 'boolean' }, backing_entry: S, note: S },
    required: ['id', 'conforms', 'evidence'] } },
  notes: S }, required: ['judgments'] }

const COMMON = `You are one agent of a docs conformance audit of Redstone.jl, a Julia framework for hierarchical hybrid simulation. The code is the source of truth, and the audit checks the docs against it. Your work is read-only: you edit no tracked file and you commit nothing.

Where to read. Read every file in the pinned worktree W = ${W}, detached at bd471af7. Every line number you report is a line of W. Never read the main checkout for content: other sessions commit there.

Running code. Put your probes in one script, P, that you create (path below), and run it a few times at most, never one Julia process per claim:
  cd ${W} && JULIA_LOAD_PATH="@" julia --startup-file=no --project=test P
Loading Redstone takes about 20 s. Never run the test suite. test/fixtures.jl and the test files show how to build models; reuse their fixtures where that is simplest. In the shell use /bin/ls or fd, never ls.`

const INV_METHOD = `Claim kinds:
- law: a rule the code must obey (a refusal and its diagnostic kind, an ordering, a shape, a default, a type).
- mech: how the code does it (which function does what, what is cached or allocated, what a call returns).
- decl: what a user writes (a signature, a keyword, a field, a declaration form).
- ptr: a pointer or roadmap sentence. why: rationale, prior art, a rejected alternative. ex: a worked example.
Check every law, mech and decl claim against the code. Check an ex claim only where it shows real API (names, signatures, printed output); a placeholder name in an illustration is fine. Count ptr and why claims, and list one only if it states something false about the code. One claim per checkable sentence or bullet: a paragraph with six rules gives six claims.

Verdicts:
- ok: the code does what the claim says. evidence is a src/ or test/ line of W ("src/trim.jl:212") or a probe line ("probe:40").
- finding: the code differs, or a name, keyword, field, diagnostic kind, reason or default is wrong.
- unverifiable: you could not settle it with reasonable effort. Say why in note.
For a finding, give class, your best guess (a verifier rules): drift (the doc is stale and something records the move: a later log entry, a rename, a commit), deviation (the code differs and nothing records it), defect (the doc states the intent and the code plainly misses it). Give fix: the replacement text, close to the doc's own wording, or for a defect the code change in one sentence.

Leads. Stage M scripts flagged names, keywords and citations; your slice's leads are in the file named below. Every lead ends in a row: ok when it is a placeholder, prior art or a local name, finding otherwise.

Output. Findings and unverifiable claims go in rows, in full. ok claims go in ok, with a claim summary under 100 characters. IDs run <slice>-001 upward in document order, shared by rows and ok. counts holds the number of claims per kind, listed or not.`

const SPEC_TASK = (range, extra, map) => `Your slice: design/spec.md lines ${range}.${extra} For context, take the heading outline with rg -n '^#' design/spec.md and read another section only when a claim depends on it. The glossary entries a claim links to (#g-...) sit in Appendix D. Read these code_map.md entries for the files involved: ${map}. Then read the code each claim names.`

const SLICES = [
  { key: 'S14a', kind: 'spec', file: 'design/spec.md',
    task: SPEC_TASK('12835-13480 (§14.1 to §14.5: conditions, fragments, resolution, application, boundary zero)', '',
      'code_map.md lines 224-250 (src/conditions.jl), 885-1003 (src/model.jl), 1183-1302 (src/sim.jl)') },
  { key: 'S14b', kind: 'spec', file: 'design/spec.md',
    task: SPEC_TASK('13481-14128 (§14.6 to §14.8: root-input totality and override, the trim problem, the trim service)', '',
      'code_map.md lines 1474-1496 (src/trim.jl), 224-250 (src/conditions.jl), 885-1003 (src/model.jl), 1183-1302 (src/sim.jl), 516-612 (src/diagnostics.jl)') },
  { key: 'S14c', kind: 'spec', file: 'design/spec.md',
    task: SPEC_TASK('14129-14580 (§14.9 mounting and §14.10 linearization)',
      ' Also Appendix B lines 15201-15291 (Condition algebra, Stopped-sim services), and the Appendix C entries that start at lines 15749, 15765, 15769, 15801, 15804, 15817, 15825, 15829, 15833, 15837 and 15920, each running to the next bullet: check each kind entry\'s severity, stage, policy and every payload field against the struct and its raise sites.',
      'code_map.md lines 828-884 (src/linearize.jl), 1015-1072 (src/readers.jl), 1474-1496 (src/trim.jl), 516-612 (src/diagnostics.jl)') },
  { key: 'K14a', kind: 'companion', file: 'design/companions/trim_environment_walkthrough.md',
    task: `Your slice: design/companions/trim_environment_walkthrough.md, whole. It is a companion: the spec outranks it. When a companion claim disagrees with the code but agrees with the spec, report it as a finding on the companion and name the agreeing spec line in note. Read code_map.md lines 1474-1496 (src/trim.jl), 224-250 (src/conditions.jl) and 885-1003 (src/model.jl), then the code each claim names. The companion's own section numbers are "section N"; a § is a spec citation.` },
  { key: 'K14b', kind: 'companion', file: 'design/companions/linearization_walkthrough.md',
    task: `Your slice: design/companions/linearization_walkthrough.md, whole. It is a companion: the spec outranks it. When a companion claim disagrees with the code but agrees with the spec, report it as a finding on the companion and name the agreeing spec line in note. Read code_map.md lines 828-884 (src/linearize.jl) and 1015-1072 (src/readers.jl), then the code each claim names. Numerical claims (a derivative, a gain, a sign) are probed.` },
  { key: 'L14', kind: 'log', file: 'design/log.md',
    task: `Your slice: the 37 ratified design/log.md entries listed at the top of your leads file, each with its line range. For each entry read the Status line and the Position section only (from **Position.** to **Rationale.**). Each Position bullet or sentence that settles a rule is a claim. The log is never rewritten (design/rules/log_rules.md rule 1), so old vocabulary or notation is not a finding; a wrong code identifier, keyword, kind or default is, and so is a rule the code contradicts. A contradicted rule is class deviation, unless a later entry already moved it: then drift, naming that entry in note (find it with rg on the topic's names in design/log.md). Flag a rejected alternative only if the code visibly does the rejected thing. The code_map.md entries for src/conditions.jl (lines 224-250), src/trim.jl (1474-1496), src/linearize.jl (828-884) and src/readers.jl (1015-1072) route you to the code.` },
  { key: 'C14', kind: 'coverage', file: 'src',
    task: `Your slice is the code-to-docs direction, for src/conditions.jl, src/trim.jl, src/linearize.jl and src/readers.jl whole, and in src/sim.jl and src/model.jl the functions whose comments cite §14 (rg -n '§14' src/sim.jl src/model.jl). The docs to search: design/spec.md §14 (lines 12835-14580), Appendix B (14909-15379), Appendix C (15380-16001), the docstrings, docs/src/api.md and design/code_map.md. Answer four questions, and use kind for the question:
- surface: every author-facing name (named in Appendix B or in docs/src/api.md), keyword argument, public field, diagnostic raise site (its kind and reason) and user-visible behaviour in these files. Is it covered by the spec, an appendix or a docstring? Internal helpers owe only code_map.md. Not covered is a finding, usually class deviation.
- docstring: does each docstring in these files match its code: signature, keywords, defaults, return, raised kinds? design/rules/docstring_rules.md says what a docstring must state; do not audit style.
- map: do the code_map.md entries for these files (lines 224-250, 828-884, 885-1003, 1015-1072, 1183-1302, 1474-1496) match the code?
- cite: does every § and D-nnn comment in these files point at a section or entry that treats its topic? Use the heading outline (rg -n '^#' design/spec.md) and the entry titles (rg -n '^### D-' design/log.md).
For every row, file and line are the code site; claim states what the doc says or omits; evidence names where you looked. In the leads, "names" rows are names a docstring mentions that no Julia file defines.` },
]

function invPrompt(s) {
  return `${COMMON}\n\n${INV_METHOD}\n\n${s.task}\n\nYour leads file: ${LEADS}/${s.key}.txt\nYour probe script P: ${R}/probes/${s.key}/probe.jl (create the folder).\nYour slice id: ${s.key}.`
}

function sample(okRows) {
  const pool = okRows.filter(r => ['law', 'mech', 'decl', 'surface', 'docstring', 'map'].includes(r.kind))
  const step = Math.max(1, Math.floor(pool.length / Math.max(3, Math.ceil(pool.length / 10))))
  return pool.filter((_, i) => i % step === 0)
}

function verPrompt(s, items) {
  const list = items.map(r => `- ${r.id} | ${r.file}:${r.line} | ${r.kind} | ${r.claim}`).join('\n')
  return `${COMMON}

You are the independent verifier for slice ${s.key}. Below are claims taken from the docs (or, for coverage rows, statements about what the docs say or omit about a code site). For each one, decide from scratch whether the docs and the code at W agree. You are not told why anyone listed a claim: some agree and some do not. Read the doc text at the given line yourself, since the one-line summary may be lossy, and read the code. Probe behavioural claims. Your probe script P: ${R}/probes/${s.key}_v/probe.jl (create the folder).

For each id return conforms (true when the doc matches the code) and evidence (a src/ or test/ line of W, or a probe line). When conforms is false, also return:
- class: drift (the doc is stale and something records the move: a later log entry, a rename sweep, or a commit; try git -C ${W} log --oneline -S'<name>'), deviation (the code differs and nothing records it), defect (the doc states the intent and the code plainly misses it), or gap (design/pending.md records the work as still owed; list its bullets with rg -n '^- \\*\\*' design/pending.md and read the relevant one).
- fix: the replacement doc text, close to the doc's wording, or for a defect the code change in one sentence.
- clear: true when the code fixes the new text in only one way and the fix touches no rule beyond the claim.
- backing_entry: for a deviation, the ratified log entry that backs the doc's text, if one does.
Return one judgment per id, every id.

The claims:
${list}`
}

function merge(s, inv, flagged, sampled, v) {
  const j = new Map((v ? v.judgments : []).map(x => [x.id, x]))
  const byId = new Map([...inv.rows, ...inv.ok].map(r => [r.id, r]))
  const out = { slice: s.key, counts: inv.counts, n_ok: inv.ok.length, n_rows: inv.rows.length, n_sampled: sampled.length,
    confirmed: [], overturned: [], missed: [], unjudged: [], inv_notes: inv.notes || '', ver_notes: v ? (v.notes || '') : 'no verifier' }
  for (const r of flagged) {
    const x = j.get(r.id)
    if (!x) { out.unjudged.push(r.id); continue }
    if (x.conforms) out.overturned.push({ id: r.id, at: `${r.file}:${r.line}`, claim: r.claim, inv_verdict: r.verdict, why: x.evidence + (x.note ? ' | ' + x.note : '') })
    else out.confirmed.push({ ...r, ver: x })
  }
  for (const r of sampled) {
    const x = j.get(r.id)
    if (!x) { out.unjudged.push(r.id); continue }
    if (!x.conforms) out.missed.push({ ...byId.get(r.id), ver: x })
  }
  return out
}

const results = await pipeline(SLICES,
  s => slot(() => agent(invPrompt(s), { label: `inv:${s.key}`, phase: 'Inventory', schema: INV, agentType: 'mid-tier' })),
  async (inv, s) => {
    if (!inv) return { slice: s.key, failed: 'inventory' }
    const flagged = inv.rows
    const sampled = sample(inv.ok)
    const items = [...flagged, ...sampled].sort((a, b) => a.file === b.file ? a.line - b.line : (a.file < b.file ? -1 : 1))
    log(`${s.key}: ${inv.rows.length} flagged, ${inv.ok.length} ok, ${sampled.length} sampled for verification`)
    const v = items.length ? await slot(() => agent(verPrompt(s, items), { label: `ver:${s.key}`, phase: 'Verify', schema: JUDG, agentType: 'high-tier' })) : null
    return merge(s, inv, flagged, sampled, v)
  })

return results.filter(Boolean)
