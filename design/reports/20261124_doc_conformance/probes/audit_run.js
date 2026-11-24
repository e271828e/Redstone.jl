export const meta = {
  name: 'doc-conformance-group',
  description: 'Docs conformance audit, one chapter group: claim inventories and coverage, then blind verification',
  phases: [
    { title: 'Inventory', detail: 'spec, companion, log and coverage slices, with probes; a coarse inventory re-runs once' },
    { title: 'Verify', detail: 'high-tier: blind re-judgment of flagged rows plus a sample of ok rows' },
  ],
}

// args: { group, W, tip, R, slices: [{ key, kind: 'spec'|'companion'|'log'|'coverage',
//         agent: 'mid-tier'|'high-tier', lines, task }] }
// lines is the slice's doc lines, for the density check (spec and companion only).
// task is the slice's routing: its ranges, the code_map entries and the code to read.
// Leads are read from `${R}/ledgers/stage_m/leads_${group}/${key}.txt`.
// Returns compact measurements; merge_run.py builds the ledgers from the journal.
const { group, W, tip, R, slices } = args
for (const s of slices) if (!s.lines && s.range) s.lines = s.range[1] - s.range[0] + 1
const LEADS = `${R}/ledgers/stage_m/leads_${group}`

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

Where to read. Read every file in the pinned worktree W = ${W}, detached at ${tip}. Every line number you report is a line of W. Never read the main checkout for content: other sessions commit there.

Running code. Put your probes in one script, P, that you create (path below), and run it a few times at most, never one Julia process per claim:
  cd ${W} && JULIA_LOAD_PATH="@" julia --startup-file=no --project=test P
Loading Redstone takes about 20 s. Never run the test suite. test/fixtures.jl and the test files show how to build models; reuse their fixtures where that is simplest. In the shell use /bin/ls or fd, never ls.`

const INV_METHOD = `Claim kinds:
- law: a rule the code must obey (a refusal and its diagnostic kind, an ordering, a shape, a default, a type).
- mech: how the code does it (which function does what, what is cached or allocated, what a call returns).
- decl: what a user writes (a signature, a keyword, a field, a declaration form).
- ptr: a pointer or roadmap sentence. why: rationale, prior art, a rejected alternative. ex: a worked example.
Check every law, mech and decl claim against the code. Check an ex claim only where it shows real API (names, signatures, printed output); a placeholder name in an illustration is fine. Count ptr and why claims, and list one only if it states something false about the code.

Granularity. One claim is one checkable assertion, not one sentence or one paragraph. Split every sentence that asserts several things. For example, this passage of three sentences:
  "Composition checks three things, each by type or length alone, and none allocates. No \`set\` payload is \`nothing\`, each combinator operand is a node, and each \`at\` prefix is nonempty. A payload of \`nothing\` is \`ConditionNodeMisuse\` with reason \`:set_payload\`."
is six claims: (1) composition checks by type or length alone [mech]; (2) composition allocates nothing [law]; (3) a \`set\` payload of \`nothing\` is refused [law]; (4) each combinator operand must be a node [law]; (5) each \`at\` prefix must be nonempty [law]; (6) the refusal is \`ConditionNodeMisuse\` with reason \`:set_payload\` [law]. Normative spec prose yields about 0.4 to 0.8 claims per line, and a companion's narrative somewhat fewer. A coarse claim marked ok hides its false parts from every later check.

Verdicts:
- ok: the code does what the claim says. evidence is a src/ or test/ line of W ("src/trim.jl:212") or a probe line ("probe:40").
- finding: the code differs, or a name, keyword, field, diagnostic kind, reason or default is wrong.
- unverifiable: you could not settle it with reasonable effort. Say why in note.
For a finding, give class, your best guess (a verifier rules): drift (the doc is stale and something records the move: a later log entry, a rename, a commit), deviation (the code differs and nothing records it), defect (the doc states the intent and the code plainly misses it). Give fix: the replacement text, close to the doc's own wording, or for a defect the code change in one sentence.

Leads. Stage M scripts flagged names, keywords and citations; your slice's leads are in the file named below. Every lead ends in a row: ok when it is a placeholder, prior art or a local name, finding otherwise.

Output. Findings and unverifiable claims go in rows, in full. ok claims go in ok, with a claim summary under 100 characters. IDs run <slice>-001 upward in document order, shared by rows and ok. counts holds the number of claims per kind, listed or not.`

// A slice may give task in full, or the template fields below, from which task is built:
// spec {range: [a, b], desc, map, extra}; companion {file, map, extra}; log {n, map}; coverage {files, docs, map}.
function taskOf(s) {
  if (s.task) return s.task
  const x = s.extra ? ' ' + s.extra : ''
  if (s.kind === 'spec') return `Your slice: design/spec.md lines ${s.range[0]}-${s.range[1]} (${s.desc}).${x} For context, take the heading outline with rg -n '^#' design/spec.md and read another section only when a claim depends on it. The glossary entries a claim links to (#g-...) sit in Appendix D. Read these code_map.md entries for the files involved: ${s.map}. Then read the code each claim names. A complete Julia code block in your range is run in your probe script, adapted only as far as it needs fixtures.`
  if (s.kind === 'companion') return `Your slice: ${s.file}. It is a companion: the spec outranks it. When a companion claim disagrees with the code but agrees with the spec, report it as a finding on the companion and name the agreeing spec line in note. Read these code_map.md entries: ${s.map}, then the code each claim names. The companion's own section numbers are "section N"; a § is a spec citation. Numerical claims (a derivative, a gain, a sign) are probed.${x}`
  if (s.kind === 'log') return `Your slice: the ${s.n} ratified design/log.md entries listed at the top of your leads file, each with its line range. For each entry read the Status line and the Position section only (from **Position.** to **Rationale.**). Each Position bullet or sentence that settles a rule is a claim; split as the granularity rule says. The log is never rewritten (design/rules/log_rules.md rule 1), so old vocabulary or notation is not a finding; a wrong code identifier, keyword, kind or default is, and so is a rule the code contradicts. A contradicted rule is class deviation, unless a later entry already moved it: then drift, naming that entry in note (find it with rg on the topic's names in design/log.md). Check every superseded → chain an entry carries ends at a ratified entry, and every D-nnn and § citation in the Position resolves. Flag a rejected alternative only if the code visibly does the rejected thing. These code_map.md entries route you to the code: ${s.map}.${x}`
  if (s.kind === 'coverage') return `Your slice is the code-to-docs direction, for ${s.files}. The docs to search: ${s.docs}, Appendix B and Appendix C (rg -n '^## Appendix' design/spec.md for their ranges), the docstrings, docs/src/api.md and design/code_map.md. Answer four questions, and use kind for the question:
- surface: every author-facing name (named in Appendix B or in docs/src/api.md), keyword argument, public field, diagnostic raise site (its kind and reason) and user-visible behaviour in these files. Is it covered by the spec, an appendix or a docstring? Internal helpers owe only code_map.md. Not covered is a finding, usually class deviation.
- docstring: does each docstring in these files match its code: signature, keywords, defaults, return, raised kinds? design/rules/docstring_rules.md says what a docstring must state; do not audit style.
- map: do the code_map.md entries for these files (${s.map}) match the code?
- cite: does every § and D-nnn comment in these files point at a section or entry that treats its topic? Use the heading outline (rg -n '^#' design/spec.md) and the entry titles (rg -n '^### D-' design/log.md).
For every row, file and line are the code site; claim states what the doc says or omits; evidence names where you looked. In the leads, "names" rows are names a docstring mentions that no Julia file defines.${x}`
  throw new Error(`slice ${s.key}: no task and unknown kind ${s.kind}`)
}

function invPrompt(s, nudge) {
  return `${COMMON}\n\n${INV_METHOD}\n\n${taskOf(s)}\n\nYour leads file: ${LEADS}/${s.key}.txt\nYour probe script P: ${R}/probes/${s.key}/probe.jl (create the folder).\nYour slice id: ${s.key}.${nudge || ''}`
}

const FLOOR = { spec: 0.3, companion: 0.2 }
function counted(inv) { return Object.values(inv.counts).reduce((a, b) => a + (b || 0), 0) }

async function inventory(s) {
  const opts = (label) => ({ label, phase: 'Inventory', schema: INV, agentType: s.agent || (s.kind === 'log' ? 'high-tier' : 'mid-tier') })
  const inv = await slot(() => agent(invPrompt(s), opts(`inv:${s.key}`)))
  if (!inv || !FLOOR[s.kind] || !s.lines) return inv
  const density = counted(inv) / s.lines
  if (density >= FLOOR[s.kind]) return inv
  log(`${s.key}: ${counted(inv)} claims over ${s.lines} lines (${density.toFixed(2)} per line), below ${FLOOR[s.kind]}: re-running`)
  const nudge = `\n\nA first inventory of this slice counted ${counted(inv)} claims over ${s.lines} lines, ${density.toFixed(2)} per line, which is too coarse. Split as the granularity rule says, and return the whole inventory.`
  const inv2 = await slot(() => agent(invPrompt(s, nudge), opts(`inv2:${s.key}`)))
  return inv2 && counted(inv2) > counted(inv) ? inv2 : inv
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

const results = await pipeline(slices,
  s => inventory(s),
  async (inv, s) => {
    if (!inv) return { slice: s.key, failed: 'inventory' }
    const sampled = sample(inv.ok)
    const items = [...inv.rows, ...sampled].sort((a, b) => a.file === b.file ? a.line - b.line : (a.file < b.file ? -1 : 1))
    log(`${s.key}: ${counted(inv)} claims, ${inv.rows.length} flagged, ${inv.ok.length} ok, ${sampled.length} sampled`)
    const v = items.length ? await slot(() => agent(verPrompt(s, items),
      { label: `ver:${s.key}`, phase: 'Verify', schema: JUDG, agentType: 'high-tier' })) : null
    const j = new Map((v ? v.judgments : []).map(x => [x.id, x]))
    const flaggedIds = new Set(inv.rows.map(r => r.id))
    let confirmed = 0, overturned = 0, missed = 0
    for (const [id, x] of j) {
      if (flaggedIds.has(id)) { if (x.conforms) overturned++; else confirmed++ }
      else if (!x.conforms) missed++
    }
    return { slice: s.key, counted: counted(inv), flagged: inv.rows.length, ok: inv.ok.length,
      sampled: sampled.length, confirmed, overturned, missed, verified: !!v }
  })

return results.filter(Boolean)
