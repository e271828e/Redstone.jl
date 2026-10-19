"""Track 2, agent 1: apply the edits of one phase, asserting each old text
occurs exactly once (in its entry, for log edits) before writing any file.

Usage: python3 -I apply.py <repo root> spec|log <out.md>
Writes the replay record (old and new text of every edit, in order) to out.md.
"""
import re
import sys
from pathlib import Path

root, phase, out = Path(sys.argv[1]), sys.argv[2], Path(sys.argv[3])
D = root / "docs/design"
SPEC, LOG = D / "spec.md", D / "decisions.md"
WALK = D / "companions/frame_walkthrough.md"

# --- phase 1: spec, glossary, companion -----------------------------------
SPEC_EDITS = [
    ("F54", SPEC,
     "[§12.6][s12-6], [§12.7][s12-7], [§14.7][s14-7]). Error · service, or build in a `sample_times`",
     "[§12.6][s12-6], [§12.7][s12-7], §13.5, [§14.7][s14-7]). Error · service, or build in a `sample_times`"),
    ("R12 glossary entry", SPEC,
     "[Appendix C][sC]). Severity is the kind's, not the payload's.\n\n<a id=\"g-species\">",
     "[Appendix C][sC]). Severity is the kind's, not the payload's.\n\n"
     "<a id=\"g-requester-roster\"></a>**requester roster** — the build's list of stop\n"
     "requests, one `Requester(path, port, reason)` per `StopFlag` output port, in\n"
     "build order (§13.5).\n\n<a id=\"g-species\">"),
    ("R12 first-use link in §13.5", SPEC,
     "This list is the requester roster (the build's",
     "This list is the [requester roster](#g-requester-roster) (the build's"),
    ("B85", WALK,
     "`init!` and `replay!` run boundary zero through `_host_boundary_zero!`, which",
     "`init!` runs boundary zero through the `Model`'s `init!`, which"),
]

# --- phase 2: the log ------------------------------------------------------
def ann(text):
    return f"Annotation (2026-10-19): {text}"

REJ = "\n\n**Rejected.**"
LOG_EDITS = [  # (item, entry, old, new); old must occur once inside the entry
    ("B42", "012",
     "**Rationale.** Recorded only through the rejections below." + REJ,
     "**Rationale.** Recorded only through the rejections below.\n\n" + ann(
         "D-259 retired the strata, so the Stratum-B topological\n"
         "stall is the topological-sort stall in the nominal evaluation (§13.8).") + REJ),
    ("B44", "057",
     "**Rationale.** Recorded only through the rejections below." + REJ,
     "**Rationale.** Recorded only through the rejections below.\n\n" + ann(
         "§13.1 no longer says the two errors of a typo'd\n"
         "wire render adjacently by path. The did-you-mean names the input the other\n"
         "error says is unfed, so the pairing explains itself.") + REJ),
    ("B45 Spec", "058", "**Spec.** [Appendix C][sC]", "**Spec.** §13.2, [Appendix C][sC]"),
    ("B45, R11", "058",
     "**Rationale.** Recorded only through the rejections below." + REJ,
     "**Rationale.** Recorded only through the rejections below.\n\n" + ann(
         "amended by D-222 and D-250. The one carrier is\n"
         "`DiagnosticError{P}`, which replaces `BuildError` (D-222). Warnings ride no\n"
         "shared stream: a warning raised while producing an artifact lives on that\n"
         "artifact, and one raised while mutating state lives in that state's status\n"
         "(D-250). The fourth rejection counts blocking a warnings-as-errors switch\n"
         "against a separate channel; D-250 rejects that switch, and §13.2 states the\n"
         "rejection.") + REJ),
    ("B46", "059",
     "[§13.4][s13-4], [§14][s14]", "[§13.4][s13-4], §13.6, [§14][s14]"),
    ("B47", "060",
     "state, never an exception, stands." + REJ,
     "state, never an exception, stands.\n\n" + ann(
         "the Tier-2 event of the detection clause is a\n"
         "localized event, which a stop that must be localized declares as a\n"
         "sign-form event (§13.5). The `stop_on` root faces are stop requests since\n"
         "D-316, and the policy binds per advance, not at `Simulation` construction\n"
         "(D-255).") + REJ),
    ("B48 (D-061)", "061",
     "face lists and the terminal split stand." + REJ,
     "face lists and the terminal split stand.\n\n" + ann(
         "the public `resolve` resolves one level, an\n"
         "immediate child, and the declared-type walk is the service walk (§13.3).\n"
         "Since D-406 and D-407, device read bindings and log extraction by series\n"
         "resolve on the service side; GUI panels are parked (D-310). The inspection\n"
         "case is snapshot and log inspection (§13.3).") + REJ),
    ("B49", "062",
     "parameter and tier transparency stand ([§13.7][s13-7])." + REJ,
     "parameter and tier transparency stand ([§13.7][s13-7]).\n\n" + ann(
         "predicate selection is `select`, a selector of\n"
         "`input_passthrough` and `output_passthrough` (D-251), not a `faces` method.\n"
         "The face-route printer is `show(::Structure)` (D-257), not the `Build`\n"
         "printer (§13.7).") + REJ),
    ("B50 Spec", "071",
     "**Spec.** [§13.7][s13-7]", "**Spec.** §14.9"),
    ("B50", "071",
     "**Rationale.** Recorded only through the rejections below." + REJ,
     "**Rationale.** Recorded only through the rejections below.\n\n" + ann(
         "the helper is recorded in §14.9. §13.7's library\n"
         "holds components only.") + REJ),
    ("B52", "114",
     "predicate tests no longer mirrors the snapshot's index." + REJ,
     "predicate tests no longer mirrors the snapshot's index.\n\n" + ann(
         "§13.4 indexes a failure by the frame-entry\n"
         "boundary index (D-128, D-230). The counter-plus-recorded-`t` indexing this\n"
         "entry presupposes is historical, and §13.4 no longer rests on it.") + REJ),
    ("B53", "120",
     "producer; in a rig, a stub child)." + REJ,
     "producer; in a rig, a stub child).\n\n" + ann(
         "the remainder is exported via\n"
         "`input_passthrough(rig, child; except)` (§13.7). The slot of the second\n"
         "rejection's slot-typing rule is a root input since D-206.") + REJ),
    ("B48 (D-130)", "130",
     "stays enforcing where promises depend on\nit." + REJ,
     "stays enforcing where promises depend on\nit.\n\n" + ann(
         "since D-406 and D-407, device read bindings and log\n"
         "extraction by series resolve on the service side, and\n"
         "`ReadBindingUnresolved` retires (D-406); GUI panels are parked (D-310). The\n"
         "inspection case is snapshot and log inspection (§13.3).") + REJ),
    ("B54", "131",
     "advisory." + REJ,
     "advisory.\n\n" + ann(
         "§13.4 names only the terminal statuses and the\n"
         "return to `built`; the five-state count is §12.6's.") + REJ),
    ("B57", "141",
     "here and in the Rejected list are [§7.1][s7-1]'s." + REJ,
     "here and in the Rejected list are [§7.1][s7-1]'s.\n\n" + ann(
         "the grow-by-migration-demand rule the Rationale\n"
         "cites is retired: a listed block is built whenever wanted, with no\n"
         "demonstrating model required (D-313). The Bool gates the third rejection\n"
         "cites admit no `Not`; the negation is one character at the consumer\n"
         "(D-311).") + REJ),
    ("B58", "142",
     "scope stays unnarrowed by this\nfinding." + REJ,
     "scope stays unnarrowed by this\nfinding.\n\n" + ann(
         "under D-316 a plausibility check meaning \"stop\n"
         "the run\" publishes a `StopFlag` port, which `StopRequest` spells, and no\n"
         "keyword names it.") + REJ),
    ("B59", "143",
     "tier stand." + REJ,
     "tier stand.\n\n" + ann(
         "the root slot of the second clarification is a\n"
         "root input since D-206 (§11.3). The demonstrated-need charter the Rationale\n"
         "cites is retired: a block joins the library by judgement against three\n"
         "guidelines (D-313, §13.7).") + REJ),
    ("B60", "159",
     "five-value count to six." + REJ,
     "five-value count to six.\n\n" + ann(
         "superseded in part by D-250. §13.2's two-stream\n"
         "partition is gone; a service warning lives on the artifact the call returns.") + REJ),
    ("B40", "184",
     "[D-314][d-314]." + REJ,
     "[D-314][d-314].\n\n" + ann(
         "§13.7's starting inventory does not list `Group`.\n"
         "`Group` belongs to §13.7's library as its one member admitted by persona.") + REJ),
    ("B62 Spec", "203",
     "[§12.6][s12-6], [§13.5][s13-5], [§13.6][s13-6], [Appendix C][sC]",
     "[§12.6][s12-6], §13.2, [§13.5][s13-5], [§13.6][s13-6], [Appendix C][sC]"),
    ("B62", "203",
     "home for the fact, stands." + REJ,
     "home for the fact, stands.\n\n" + ann(
         "amended by D-233. The final boundary time is always\n"
         "present, a value of the deployment's scalar and never `nothing`, so the\n"
         "record has no absent-time arm.") + REJ),
    ("B48 (D-242)", "242",
     "what is at stake." + REJ,
     "what is at stake.\n\n" + ann(
         "since D-406 and D-407, device read bindings and log\n"
         "extraction by series resolve on the service side; GUI panels are parked\n"
         "(D-310). The inspection case is snapshot and log inspection (§13.3).") + REJ),
    ("B68", "255",
     "[§12.7][s12-7], [§13.5][s13-5], [Appendix C][sC]",
     "[§12.7][s12-7], §13.2, [§13.5][s13-5], [Appendix C][sC]"),
]

# B78: (entry, sections to add), from spec_fields.py's run, filtered by hand.
B78 = [
    ("005", ["§13.8"]), ("019", ["§13.5"]), ("022", ["§13.4"]),
    ("084", ["§13.5"]), ("147", ["§13.5"]), ("218", ["§13.5"]),
    ("231", ["§13.7"]), ("235", ["§13.4"]), ("237", ["§13.7"]),
    ("251", ["§13.2", "§13.7"]), ("254", ["§13.2"]), ("261", ["§13.4"]),
    ("274", ["§13.4"]), ("294", ["§13.4"]), ("322", ["§13.7"]),
    ("364", ["§13.7"]), ("387", ["§13.6"]), ("389", ["§13.4"]),
    ("398", ["§13.4"]), ("401", ["§13.2"]), ("406", ["§13.3", "§13.5"]),
    ("407", ["§13.3"]),
]


def key(sec):
    m = re.match(r"§(\d+)(?:\.(\d+))?$", sec)
    return (0, int(m.group(1)), int(m.group(2) or 0)) if m else (1, sec)


def entry_span(text, n):
    m = re.search(rf"^### D-{n} — .*?(?=^### D-|^<!-- citation link)", text, re.M | re.S)
    assert m, f"D-{n} not found"
    return m.start(), m.end()


def spec_field_edit(text, n, adds):
    s, e = entry_span(text, n)
    body = text[s:e]
    m = re.search(r"^\*\*Spec\.\*\* (.*?)(?=\n\n)", body, re.M | re.S)
    old = m.group(0)
    items = re.split(r",\s+", m.group(1))
    for a in adds:
        names = [i[1:i.index("]")] if i.startswith("[") else i for i in items]
        assert a not in names, f"D-{n} already lists {a}"
        pos = next((j for j, x in enumerate(names) if key(x) > key(a)), len(items))
        items.insert(pos, a)
    new = "**Spec.** " + ", ".join(items)
    return old, new


records = []
if phase == "spec":
    texts = {p: p.read_text() for _, p, _, _ in SPEC_EDITS}
    for item, p, old, new in SPEC_EDITS:
        c = texts[p].count(old)
        assert c == 1, f"{item}: old text occurs {c} times in {p.name}"
        texts[p] = texts[p].replace(old, new)
        records.append((item, p.relative_to(root), old, new))
    for p, t in texts.items():
        p.write_text(t)
elif phase == "log":
    text = LOG.read_text()
    for item, n, old, new in LOG_EDITS:
        s, e = entry_span(text, n)
        c = text[s:e].count(old)
        assert c == 1, f"{item}: old text occurs {c} times in D-{n}"
        text = text[:s] + text[s:e].replace(old, new) + text[e:]
        records.append((f"{item}, D-{n}", LOG.relative_to(root), old, new))
    for n, adds in B78:
        old, new = spec_field_edit(text, n, adds)
        s, e = entry_span(text, n)
        assert text[s:e].count(old) == 1
        text = text[:s] + text[s:e].replace(old, new) + text[e:]
        records.append((f"B78, D-{n}", LOG.relative_to(root), old, new))
    LOG.write_text(text)

with out.open("w") as f:
    for i, (item, p, old, new) in enumerate(records, 1):
        f.write(f"### {i}. {item} — `{p}`\n\nOld:\n\n```\n{old}\n```\n\nNew:\n\n```\n{new}\n```\n\n")
print(f"{len(records)} edits applied")
