# Chapter 11, half 1 fixes: units A to D

The editorial fixer's log for `chapter_pass_1.md` and the RP rulings in
`chapter_rulings.md` that touch units A to D. Each entry gives the item, the
unit, and the old and new text of `units/<U>/new.md`, verbatim. Entries apply
in order, each to the file as the earlier entries left it. Entries 1 to 50
were applied before the rewrap, entry 51. Inventory-only entries change
`inventory.json` alone.

## 1. P1-1, unit A

Old:

````text
[§11.8][s11-8] the third
cross-task channel, runtime diagnostics and liveness.
````

New:

````text
[§11.8][s11-8] runtime diagnostics and liveness, a third channel between tasks beside the two data channels.
````

Inventory: C-008's `new` follows.

## 2. P1-1, unit A

Old:

````text
its per-device staging and drain,
````

New:

````text
its per-device staging, staged representation and drain,
````

The pass's optional wording, sourced from §11.4's title. Inventory: C-005 follows.

## 3. P1-2, unit A

Old:

````text
That lock does
enforce the [boundary](#g-boundary)-visibility rule ([§10.3][s10-3]), a boundary being a published
consistency point, because the lock is only ever free between steps.
Transplanting it here was nevertheless rejected,
````

New:

````text
That lock does
enforce the [boundary](#g-boundary)-visibility rule ([§10.3][s10-3]), because the lock is only ever free between steps.
A boundary is a published consistency point.
Transplanting the lock here was nevertheless rejected,
````

Replaying the pass's fix verbatim leaves "Transplanting it" binding to *boundary*, so the next sentence names the lock. Inventory: C-014 and C-015 follow; added "a boundary being a published consistency point," becomes "A boundary is a published consistency point."

## 4. P1-3, unit A

Old:

````text
The replacement has five planes. Its unit of account is the [frame](#g-frame)
````

New:

````text
The replacement's unit of account is the [frame](#g-frame)
````

Inventory: C-019's `new` becomes "The replacement's unit of account is the frame (one grid step, §10.1)."

## 5. P1-3, unit A

Old:

````text
for Earth-centered, Earth-fixed.

1. Staging
````

New:

````text
for Earth-centered, Earth-fixed.

The replacement has five planes.

1. Staging
````

"The replacement has five planes." becomes its own paragraph before the list. C-018 unchanged.

## 6. P1-4, unit A

Old:

````text
**The loop runs on the calling task** ([D-310][d-310]). The calling task runs the loop
itself, and every rostered device runs on a spawned task. This is what the
````

New:

````text
**The loop runs on the calling task** ([D-310][d-310]). This is what the
````

Inventory: C-038 (tag M) now maps to plane 5's span, "Task topology places one loop on the calling task (the task that invoked `run!`) and one spawned task per rostered device". The claim survives there.

## 7. P1-5, unit A

Old:

````text
(hazard pointers, epochs, RCU grace periods)
  which makes these patterns hard in non-GC languages.
````

New:

````text
(hazard pointers, epochs, read-copy-update grace periods)
  which makes lock-free handoffs hard in non-GC languages.
````

Inventory: C-053 follows.

## 8. P1-6, unit A

Old:

````text
([§11.5][s11-5], [§12.7][s12-7]).


````

New:

````text
([§11.5][s11-5], [§12.7][s12-7]).

````

A's file ended in a blank line, and the assembler adds one. No span changes.

## 9. P1-1, unit A

Inventory only.

Old: 

New: added: "staged representation", "beside the two data channels"

Inventory only, for entries 1 and 2.

## 10. P1-9, unit B

Old:

````text
[ports](#g-port) (each one declared name with its cell)
````

New:

````text
[ports](#g-port) (the addressable unit, one declared name with one cell)
````

Inventory: the added gloss follows (entry 19).

## 11. P1-9, unit B

Old:

````text
[cells](#g-cell) (the typed entries of the
signal table, [§8.3][s8-3])
````

New:

````text
[cells](#g-cell) (the signal table's typed value holders, one per output port,
[§8.3][s8-3])
````

Both §8.3 citations stay: each sits with its own claim. Inventory: the added gloss follows (entry 19).

## 12. P1-10, unit B

Old:

````text
Root inputs are the root component's own input faces.
````

New:

````text
Root inputs are the root component's own input [faces](#g-face) (the names
ports wear on their component's boundary).
````

Inventory: the added sentence follows.

## 13. P1-10, unit B

Old:

````text
An exported output [face](#g-face) (the name a port wears on its
component's boundary), spelled `get_face(name)`
````

New:

````text
An exported output face, spelled `get_face(name)`
````

Inventory: the added gloss "(the name a port wears on its component's boundary)," is dropped.

## 14. RP-3, unit B

Old:

````text
**The snapshot deliberately does *not* carry the state stores (`x`, `s`,
`m`)** ([D-038][d-038]).
````

New:

````text
**The snapshot deliberately does *not* carry the state stores** `x`, `s` and
`m` ([D-038][d-038]).
````

RP-3. Inventory: C-048 follows, tag R, ruling RP-3.

## 15. RP-4, unit B

Old:

````text
Coverage is global at the effective stride. The
endpoints below are kept.

**The endpoints are retained unconditionally** ([D-137][d-137]). The run's
first snapshot
````

New:

````text
Coverage is global at the effective stride. And
**the endpoints are retained unconditionally** ([D-137][d-137]).

The run's
first snapshot
````

RP-4. Inventory: C-118 becomes "And the endpoints are retained unconditionally" and C-130 "the endpoints are retained unconditionally (D-137).", both tag R, ruling RP-4.

## 16. P1-13, unit B

Old:

````text
and the snapshot the door publishes
under `restore!` and `replay!` ([§12.6][s12-6])
````

New:

````text
and the snapshot `restore!` or
`replay!` publishes as it builds the run ([§12.6][s12-6])
````

Inventory: C-132 follows; "as it builds the run" added (entry 19).

## 17. P1-14, unit B

Old:

````text
The `totals` monotonicity across
logged snapshots ([§11.8][s11-8]) is untouched.
````

New:

````text
The monotonicity of `totals`, the
status's cumulative per-writer counters, across logged snapshots
([§11.8][s11-8]) is untouched.
````

Inventory: C-140 follows (entry 19); the gloss is added.

## 18. P1-15, unit B

Old:

````text
public throughout ([§8.3][s8-3]). An intermediate a device wants to stream
is one promoted to a declared output.
````

New:

````text
public throughout ([§8.3][s8-3]).
````

The pass offered a cut or a reduction; this is the cut. The claim's home is the same section's "The inspection path for one is promotion to a declared output ([D-194][d-194])". Inventory: C-161 now maps there.

## 19. P1-9, P1-13, P1-14, unit B

Inventory only.

Old: added "(each one declared name with its cell),", "(the typed entries of the signal table, §8.3)."; C-140 new as auto-mapped minus the gloss

New: added "(the addressable unit, one declared name with one cell),", "(the signal table's typed value holders, one per output port, §8.3).", "as it builds the run"; C-140 new = the whole new sentence, gloss included

## 20. P1-16, unit C

Old:

````text
writes into a running model through its root inputs alone.
````

New:

````text
writes into a running model through its [root inputs](#g-root-input)
(the root component's own input faces) alone.
````

Inventory: the added periphery sentence follows; the gloss is added.

## 21. P1-16, unit C

Old:

````text
Its members are [root inputs](#g-root-input) (the inputs
no component produces).
````

New:

````text
Its members are root inputs.
````

Inventory: added "(the inputs no component produces)." is dropped. C-002 is unchanged.

## 22. P1-16, unit C

Old:

````text
is the name a port wears on its component's boundary. It is routed inward to
consumers
````

New:

````text
is the name a port wears on its component's boundary. A root input is routed inward to
consumers
````

Inventory: C-004 follows.

## 23. P1-17, unit C

Old:

````text
#### The write surface

````

New:

````text
#### Root inputs

````

Inventory: the added heading follows.

## 24. P1-17, unit C

Old:

````text
in order, cover the
write surface, exclusivity and claims,
````

New:

````text
in order, cover
root inputs, exclusivity and claims,
````

Inventory: the added parts sentence follows.

## 25. P1-18, unit C

Old:

````text
through the
resolution ([§11.7][s11-7])
````

New:

````text
through port
resolution ([§11.7][s11-7])
````

Inventory: C-010 follows.

## 26. P1-19, unit C

Old:

````text
Devices, mappings, the [trace](#g-trace) and the GUI write path address root
inputs by face name ([§8.6][s8-6]). The
trace is the primary record of a session.
````

New:

````text
Devices, mappings, the [trace](#g-trace) (the primary record of a session) and the GUI write path address root
inputs by face name ([§8.6][s8-6]).
````

Inventory: added "The trace is the primary record of a session." is dropped and the gloss added; C-011 follows (entry 31).

## 27. P1-20, unit C

Old:

````text
the CAS merge and
the atomicswap drain all stay. They serve atomicity and
[coalescing](#g-coalescing) (the CAS merge keeping one pending batch per
device), not arbitration.
````

New:

````text
the compare-and-swap (CAS) merge and
the atomicswap drain all stay. They serve atomicity and
[coalescing](#g-coalescing) (keeping one pending batch per
device), not arbitration.
````

Inventory: C-019 follows; added "(the CAS merge keeping one pending batch per device)" is replaced by "(keeping one pending batch per device)"; "compare-and-swap (CAS)" is added.

## 28. P1-22, unit C

Old:

````text
[harness writer](#g-harness-writer) (the one writer whose surface is derived,
not claimed). It is a task-free entry point, the
````

New:

````text
[harness writer](#g-harness-writer) (the framework-owned writer beside the
roster). It is an entry point with no task of its own, the
````

Applied as written. The gloss now repeats its own sentence's "One framework-owned remainder sits beside the roster", so the orchestrator may prefer §11.8's gloss (RP-9's wording). Inventory: C-061 follows; the added gloss is replaced.

## 29. P1-23, unit C

Old:

````text
The roster (entries, claims, attachment order)
````

New:

````text
The roster (roster entries, claims, attachment order)
````

Inventory: C-084 follows.

## 30. P1-24, unit C

Old:

````text
with a stable device id,
never a roster index,
````

New:

````text
with a stable device id
(described below), never a roster index,
````

Inventory: C-090 follows; "(described below)" added.

## 31. P1-19, unit C

Inventory only.

Old: C-011 new "Devices, mappings, the trace and the GUI write path ..."

New: C-011 new "Devices, mappings, the trace (the primary record of a session) and the GUI write path ..."

## 32. P1-25, unit A

Old:

````text
takes the staged batches and applies them
````

New:

````text
takes the staged [batches](#g-batch) (each device's set of pending writes) and applies them
````

Inventory: C-025 follows; the gloss is added. §11.1's first use of *batch*.

## 33. P1-25, unit B

Old:

````text
plus the batches ([§11.5][s11-5])
````

New:

````text
plus the [batches](#g-batch) of staged device writes ([§11.5][s11-5])
````

The sentence already carries the trace-header gloss, so *batch* takes a gloss without parentheses (one parenthetical per sentence). Inventory: C-051 follows; "of staged device writes" added.

## 34. P1-25, unit C

Old:

````text
is the set of faces a writer's batch
entries may reach.
````

New:

````text
is the set of faces the entries of a writer's [batch](#g-batch)
(its staged set of writes, applied whole at the next drain) may reach.
````

Inventory: C-002 follows; the gloss is added.

## 35. P1-25, unit C

Old:

````text
Attaching the greedy claimant last is the idiom
````

New:

````text
Attaching the [greedy claimant](#g-greedy-claim) (the device holding the computed claim) last is the idiom
````

§11.3's first use of the term. Inventory: C-054 follows; the gloss is added.

## 36. P1-25, unit C

Old:

````text
**The periphery resolves root faces against the activation's cell layout
alone** ([D-261][d-261]).
````

New:

````text
**The periphery resolves root faces against the [activation](#g-activation)'s cell layout
alone** ([D-261][d-261]). An activation is the build's typed products at a
scalar type.
````

The link sits inside the bold; the bold's words are unchanged. A gloss inside the bold would change it, so the gloss is its own sentence after the citation, in the glossary's words. Inventory: C-048 follows; the sentence is added.

## 37. P1-25, unit C

Old:

````text
with their probe values, beside
````

New:

````text
with their [probe](#g-probe) values (the real values the build evaluates each user function with), beside
````

The gloss is §11.4's probe gloss. Inventory: C-049 follows; the gloss is added.

## 38. P1-25, unit C

Old:

````text
which continues from the interrupted boundary ([§12.7][s12-7]).
````

New:

````text
which continues from the interrupted [boundary](#g-boundary), a published
consistency point ([§12.7][s12-7]).
````

The sentence already holds "(fresh trajectory)", and a gloss in parentheses would sit against the citation, so the gloss is an appositive. Inventory: C-114 follows; the appositive is added.

## 39. P1-26, unit D

Old:

````text
(the
CAS merge, CAS being compare-and-swap, that keeps one pending set of writes
per device)
````

New:

````text
(the
compare-and-swap, or CAS, merge that keeps one pending set of writes
per device)
````

Inventory: C-007 and the added clause follow.

## 40. P1-27, unit D

Old:

````text
newest wins per [face](#g-face)** (the name a port wears on its component's
boundary) ([D-104][d-104]).
````

New:

````text
newest wins per face** ([D-104][d-104]).
````

The link leaves the bold; the bold's words are unchanged. Inventory: C-010 follows; the added gloss is dropped.

## 41. P1-27, unit D

Old:

````text
Untouched faces survive,
````

New:

````text
Untouched [faces](#g-face)
(the names ports wear on their component's boundary) survive,
````

Inventory: C-013 follows; the gloss is added.

## 42. P1-28, unit D

Old:

````text
That is the per-face ZOH.
````

New:

````text
That is the per-face zero-order hold (ZOH).
````

Inventory: C-013 follows; "zero-order hold" added.

## 43. P1-29, unit D

Old:

````text
is the exception, since several tasks
````

New:

````text
is the exception to the single writer, since several tasks
````

The pass's second option. Moving the sentence after "so the retry is bounded" would leave "The failure case" binding to the harness cell's failed CAS. Inventory: the added R4 sentence follows; "to the single writer" added.

## 44. RP-6, unit D

Old:

````text
The worked example at the end of this section
works that hazard through. A pending `flaps` edit is clobbered by an
unrelated `gear` message, undrained and undiagnosable.
````

New:

````text
Under overwrite, a pending `flaps` edit is clobbered by an
unrelated `gear` message, undrained and undiagnosable. The worked example at the end of this section
works that hazard through.
````

RP-6. Inventory: C-020 follows, tag R, ruling RP-6; "Under overwrite," added.

## 45. P1-31, unit D

Old:

````text
on the device task, as
the shared pure helper with an owner ([§11.6][s11-6]).
````

New:

````text
on the device task.
`TableBinding` is the shared pure helper, with an owner ([§11.6][s11-6]).
````

Inventory: C-097 follows.

## 46. P1-32, unit D

Old:

````text
are both known at attach. Both are
known because `claims(binding)`
````

New:

````text
are both known at attach, because `claims(binding)`
````

Inventory: C-023 follows; added "Both are known because" is dropped.

## 47. P1-33, unit D

Old:

````text
The face-name → position schema lives in the
[roster](#g-roster) entry (the writer's record in the list of attached
devices) ([D-104][d-104]).
````

New:

````text
The writer's [roster](#g-roster) entry, its record in the list of attached
devices, holds the face-name → position schema ([D-104][d-104]).
````

Inventory: C-031 follows; the added gloss is replaced by "its record in the list of attached devices,".

## 48. P1-34, unit D

Old:

````text
applied through its compiled scatter, in attachment order ([D-024][d-024]).
````

New:

````text
applied through its compiled scatter, in attachment order ([D-024][d-024]),
the harness cell last ([§11.3][s11-3]).
````

The pass wrote "in attachment order, the harness cell last ([§11.3][s11-3], [D-024][d-024])". That would put the harness-last clause under D-024, which does not rule it (D-174 does, cited in §11.3). So D-024 keeps its old scope and the pointer takes §11.3 alone. Inventory: C-081 follows; "the harness cell last (§11.3)" added.

## 49. P1-35, unit D

Old:

````text
answer to panel reuse (a port being the addressable unit of the model).
````

New:

````text
answer to panel reuse. A port is the addressable unit of the model.
````

Inventory: C-112 follows; the added gloss is replaced by the new sentence.

## 50. P1-25, unit D

Old:

````text
(published consistency points, where snapshots
go out)
````

New:

````text
(published consistency points, where [snapshots](#g-snapshot)
go out)
````

§11.4's first use of *snapshot* sits inside the boundary gloss, so a gloss of its own would nest. The link sits there without a gloss. No span changes.

## 51. P1-37 and the rewrap, units A, B, C and D

Every prose paragraph and list item of the four `new.md` files was reflowed
greedily to 80 rendered columns. Link markup is collapsed and asterisks are
counted. Links and code spans are never broken. Fenced blocks, headings and
the blockquoted generation chain are untouched. No line now runs over 80
rendered columns, which covers every over-80 and ragged line P1-37 names.
The rewrap changes line breaks only: for each unit, `norm` and `units` of
`checks/norm.py` return the same text before and after, so no inventory span
changes. To replay it, run the script below as `python3 wrap.py apply
units/<U>/new.md all` for U in A, B, C and D.

````python
"""Reflow prose paragraphs to 80 rendered columns (links collapsed, asterisks counted).
Links and code spans are never broken. Fenced blocks, headings, blockquotes untouched.
Usage: wrap.py report <file>          list over-80 lines and ragged paragraphs
       wrap.py apply <file> all       reflow every paragraph and list item"""
import re, sys
W = 80
LINK = re.compile(r'\[([^\]]+)\]\((#[^)]*)\)|\[([^\]]+)\]\[([^\]]*)\]')


def rw(s):  # rendered width
    return len(LINK.sub(lambda m: m.group(1) or m.group(3), s))


def tokens(s):
    out, i, cur = [], 0, ""
    while i < len(s):
        ch = s[i]
        if ch == " ":
            if cur: out.append(cur); cur = ""
            i += 1; continue
        if ch == "`":
            j = s.index("`", i + 1); cur += s[i:j + 1]; i = j + 1; continue
        if ch == "[":
            m = LINK.match(s, i)
            if m: cur += m.group(); i = m.end(); continue
        cur += ch; i += 1
    if cur: out.append(cur)
    return out


def blocks(lines):
    """(start, end) index ranges of reflowable paragraphs / list items"""
    i, n, res = 0, len(lines), []
    while i < n:
        l = lines[i]
        if l.startswith("```"):
            j = i + 1
            while not lines[j].startswith("```"): j += 1
            i = j + 1; continue
        if not l.strip() or l.startswith("#") or l.startswith(">") or l.startswith("|"):
            i += 1; continue
        j = i + 1
        while j < n and lines[j].strip() and not lines[j].startswith("```") \
                and not re.match(r'(- |\d+\. )', lines[j]) and not lines[j].startswith("#"):
            j += 1
        res.append((i, j)); i = j
    return res


def reflow(par):
    m = re.match(r'(- |\d+\. )', par[0]); lead = m.group() if m else ""
    ind = " " * len(lead)
    text = " ".join(x.strip() for x in par)[len(lead):]
    out, cur, empty = [], lead, True
    for t in tokens(text):
        if empty: cur += t; empty = False
        elif rw(cur + " " + t) <= W: cur += " " + t
        else: out.append(cur); cur = ind + t
    out.append(cur)
    for l in out[1:]:
        assert not re.match(r'\s*([-+*>]|#+|\d+[.)])( |$)', l), l
    return out


def ragged(par):
    """a non-final line that could take the next line's first token"""
    for a, b in zip(par, par[1:]):
        nt = tokens(b.strip())[0]
        if rw(a) + 1 + rw(nt) <= W - 8: return True
    return False


if __name__ == "__main__":
    cmd, f = sys.argv[1], sys.argv[2]
    lines = open(f).read().split("\n")
    if cmd == "report":
        fence = False
        for k, l in enumerate(lines, 1):
            if l.startswith("```"): fence = not fence; continue
            if not fence and rw(l) > W: print(f"over {k} ({rw(l)}): {l[:50]}")
        for s, e in blocks(lines):
            if ragged(lines[s:e]): print(f"ragged {s+1}-{e}: {lines[s][:50]}")
    else:
        new = []; prev = 0
        for s, e in blocks(lines):
            new += lines[prev:s] + reflow(lines[s:e]); prev = e
        new += lines[prev:]
        open(f, "w").write("\n".join(new))
````

## Not applied

No EDITORIAL item was declined. Each RULING item went as `chapter_rulings.md`
rules it:

- P1-7: held by RP-1. Previews keep no bold. No text change.
- P1-8: held by RP-2. "The binding rule" stays. No text change.
- P1-11: applied as RP-3 (entry 14).
- P1-12: applied as RP-4 (entry 15).
- P1-21: held by RP-5. §11.3 and §11.4 both keep `OutOfClaimEntry` and
  `ClaimedFaceEntry`. No text change.
- P1-30: applied as RP-6 (entry 44).
- P1-36: held by RP-7. No text change.

These items were applied with a change to the pass's wording. The reasons
are in the entries:

- P1-2 (entry 3): the next sentence names the lock, to fix the antecedent.
- P1-25: *batch* in §11.2 (entry 33) and *boundary* in §11.3 (entry 38) take
  glosses without parentheses. *activation* in §11.3 (entry 36) takes its gloss
  as a sentence outside the bold. *snapshot* in §11.4 (entry 50) is linked
  inside the boundary gloss, with no gloss of its own.
- P1-29 (entry 43): the pass's second option.
- P1-34 (entry 48): D-024 keeps its scope, and the pointer cites §11.3 alone.
- P1-9 (entries 10 and 11): both §8.3 citations stay.

Flagged: P1-22's gloss (entry 28) repeats its own sentence. RP-9's §11.8
gloss, "(the framework-owned write path `stage!(sim, …)`)", would avoid that.
