"""Apply half 1's EDITORIAL fixes to units A and B, paragraph by paragraph.
Run from docs/spec_rewrite/ch12 on the files as at 69a3191. Writes
scratch_step5/fix1/log_new.md (the new.md part of chapter_fixes_1.md)."""
import re, sys
sys.path.insert(0, 'scratch_step5/fix1')
LINK = re.compile(r'\[[^\]]+\](?:\([^)]*\)|\[[^\]]*\])')


def rendered(s):
    s = re.sub(r'\[([^\]]+)\]\(#[^)]*\)', r'\1', s)
    s = re.sub(r'\[([^\]]+)\]\[[^\]]*\]', r'\1', s)
    return len(s)


def wrap(text, first, rest, width=80):
    text = re.sub(r'\s+', ' ', text).strip()
    text = re.sub(r'`[^`]+`|' + LINK.pattern, lambda m: m.group().replace(' ', '\x00'), text)
    lines, cur = [], first
    for w in text.split(' '):
        cand = (cur + ' ' + w) if cur.strip() else cur + w
        if rendered(cand.replace('\x00', ' ')) <= width or not cur.strip():
            cur = cand
        else:
            lines.append(cur); cur = rest + w
    lines.append(cur)
    out = [l.replace('\x00', ' ') for l in lines]
    for l in out[1:]:
        assert not re.match(r'\s*(\d+\.|[-*+>#]|\|)\s', l), l
    return '\n'.join(out)


def block_of(text, i):
    """The paragraph, or the numbered-list item, holding offset i."""
    a = text.rfind('\n\n', 0, i); a = 0 if a < 0 else a + 2
    b = text.find('\n\n', i); b = len(text) if b < 0 else b
    blk = text[a:b]
    if re.match(r'\d+\. ', blk):                       # a list: narrow to the item
        starts = [m.start() for m in re.finditer(r'^\d+\. ', blk, re.M)]
        rel = i - a
        s = max(x for x in starts if x <= rel)
        e = min([x for x in starts if x > rel] + [len(blk)])
        blk = blk[s:e].rstrip('\n'); a = a + s; b = a + len(blk)
    return a, b, blk


LOG = []


def flex(old):
    return r'\s+'.join(map(re.escape, old.split()))


def edit(fid, unit, old, new, wrapit=True):
    path = f'units/{unit}/new.md'
    t = open(path).read()
    ms = list(re.finditer(flex(old), t))
    assert len(ms) == 1, (fid, len(ms), old[:60])
    i = ms[0].start()
    a, b, blk = block_of(t, i)
    m = re.search(flex(old), blk)
    nb = blk[:m.start()] + new + blk[m.end():]
    if wrapit:
        if re.match(r'\d+\. ', nb):
            nb = wrap(nb, '', '   ')
        else:
            nb = wrap(nb, '', '')
    t = t[:a] + nb + t[b:]
    open(path, 'w').write(t)
    LOG.append((fid, unit, blk, nb))


def join(fid, unit, tail_of_first):
    """Join the paragraph ending in tail_of_first to the next one."""
    path = f'units/{unit}/new.md'
    t = open(path).read()
    ms = list(re.finditer(flex(tail_of_first) + r'\n\n', t))
    assert len(ms) == 1, (fid, tail_of_first)
    i = ms[0].start()
    a, _, _ = block_of(t, i)
    e = t.find('\n\n', ms[0].end()); e = len(t) if e < 0 else e
    blk = t[a:e]
    nb = wrap(blk, '', '')
    t = t[:a] + nb + t[e:]
    open(path, 'w').write(t)
    LOG.append((fid, unit, blk, nb))


# ---------------------------------------------------------------- unit A
edit('P1-25', 'A', "its yields and the\nthread budget;",
     "its yields, the\nthread budget and the liveness heartbeat;")

edit('P1-15', 'A',
     "The [control plane](#g-control-plane) (the separate few-word atomic surface\ncarrying pause, pace and stop) is not staging, structurally ([D-022][d-022]).",
     "Pause, un-pause, pace changes, `margin` changes and stop are a few scalar\nfields on a separate atomic surface, the [control plane](#g-control-plane).\nIt is not staging, structurally ([D-022][d-022]).")
edit('P1-15', 'A',
     "Pause, un-pause, pace changes, `margin` changes and stop are a few scalar\nfields on that separate atomic surface. The loop consults them at frame top,",
     "The loop consults the control plane at frame top,")

edit('P1-16', 'A',
     "and the fields of\n`Control`, one of the periphery's own types ([D-256][d-256]), the one that\nholds the control plane.",
     "and the fields of\n`Control`, the periphery's own type that holds the control plane\n([D-256][d-256]).")

edit('P1-18', 'A',
     "Riding outside the drain/[trace](#g-trace)\npath is safe",
     "Riding outside the path through the drain and the\n[trace](#g-trace), the primary record of a session, is safe")

edit('P1-14', 'A',
     "(the points where the loop applies\nstaged device writes)",
     "(the frame-top swaps that apply staged\ndevice writes)")

edit('P1-27', 'A', "at most one frame budget `h/p` later",
     "at most one frame budget (`h/p`, the step over the pace) later")

edit('P1-17', 'A',
     "The stop word is the\ncontrol plane's stop command, one atomic word holding its issuer.",
     "The stop word is the\ncontrol plane's stop command, held in one atomic word.")

edit('P1-26', 'A', "and write them at entry.", "and write them when called.")

edit('P1-30', 'A', "and the scheduler stall requires a thread monopolist",
     "and a stall of that scheduler requires a thread monopolist")

edit('P1-20', 'A',
     "[roster](#g-roster) (the list of attached device entries) ([§11.3][s11-3]).",
     "[roster](#g-roster), the list of attached device entries ([§11.3][s11-3]).")

edit('P1-20', 'A',
     "[diagnostic cell](#g-diagnostic-cell) (a writer's own holding place for\nruntime diagnostics and liveness) ([D-136][d-136]), specified in full by [§11.8][s11-8],\nplus the device `Task` handles the loop already owns, and nothing besides.\nThe diagnostic cell carries the single liveness timestamp.",
     "[diagnostic cell](#g-diagnostic-cell) ([D-136][d-136]), specified in full by [§11.8][s11-8],\nplus the device `Task` handles the loop already owns, and nothing besides.\nA diagnostic cell is a writer's own holding place for runtime diagnostics\nand liveness. It carries the single liveness timestamp.")

edit('P1-20', 'A',
     "(the\ninitialization boundary at `t₀`) ([§10.1][s10-1], [§10.4][s10-4]), not\nframes.",
     "(the\ninitialization boundary at `t₀`), not frames ([§10.1][s10-1], [§10.4][s10-4]).")

edit('P1-20', 'A',
     "[`latest`](#g-latest) (the atomic reference readers\nacquire-load) ([§11.2][s11-2]) happens",
     "[`latest`](#g-latest), the atomic reference readers\nacquire-load ([§11.2][s11-2]), happens")

edit('P1-28', 'A', "The device side's predicate, `counter > last_seen` (below), therefore implies",
     "The device side's test `counter > last_seen` (below) therefore implies")

edit('P1-29', 'A', "(the CAS merge that\nleaves one pending batch per device)",
     "(the compare-and-swap merge\nthat leaves one pending batch per device)")

edit('P1-19', 'A', "whether the log or a post-run inspector.",
     "whether the [log](#g-log) (the retained sequence of published snapshots) or a\npost-run inspector.")

# ---------------------------------------------------------------- unit B
edit('P1-11', 'B',
     "places inside a frame. A [frame](#g-frame) is one\n   iteration of the loop. The loop",
     "places inside a [frame](#g-frame), one iteration of the\n   loop. The loop")

edit('P1-14, P1-20', 'B',
     "cell](#g-diagnostic-cell)** (each writer's bounded ring of diagnostics and its heartbeat) ([D-203][d-203]).",
     "cell](#g-diagnostic-cell)**, a writer's own holding place for runtime diagnostics and liveness ([D-203][d-203]).")

edit('P1-13', 'B', "The\n   run's-end sweep collects the diagnostic",
     "The\n   run's-end sweep, the loop's last pass over every diagnostic cell, collects\n   the diagnostic")

edit('P1-19', 'B', "With `should_abort` set, the wrapper's exit path",
     "With [`should_abort`](#g-should_abort) (the per-attachment failure policy,\n   an `attach!` keyword) set, the wrapper's exit path")

edit('P1-24', 'B', "the run's own clock. The run takes whole frames until the boundary time first covers the duration.", "the run's own clock.")

edit('P1-21', 'B', "The default of five seconds is generous",
     "The `join_timeout` default of five seconds is generous")

edit('P1-23', 'B',
     "extended here to an operational one ([D-198][d-198]).",
     "extended here to an operational one.")

edit('P1-22', 'B', "Deployment\ncontexts legitimately differ in patience. An unattended sweep wants to fail\nfast,",
     "Usage contexts\nlegitimately differ in patience. A series of runs nobody watches wants to\nfail fast,")

join('P1-32', 'B', "addressed by the roster entry rather than by a handle\n([D-189][d-189]).")
join('P1-32', 'B', "so it is dead from the run's first\nframe top ([D-138][d-138]).")
join('P1-32', 'B', "The claims of a failed device persist to run end ([D-138][d-138]).")

edit('P1-20', 'B',
     "[root-input totality](#g-root-input-totality) (every root\ninput must hold a value) ([§14.6][s14-6]).",
     "[root-input totality](#g-root-input-totality), the rule that every root\ninput must hold a value ([§14.6][s14-6]).")

edit('P1-31', 'B',
     "*already pending* at the run's first frame top. This protocol already\nhas that path. The loop reads that stop at the frame top, before any frame, so\nthe run advances no frame. No new exit protocol is needed, therefore.",
     "*already pending* at the run's first frame top. The loop reads it there,\nbefore any frame, so the run advances no frame. This protocol already has\nthat path, so no new exit protocol is needed.")

edit('P1-13', 'B',
     "whose terminal snapshot is the one the run started from and whose\ntermination record's tail residue holds the `DeviceCrash`.",
     "whose terminal snapshot is the one the run started from and whose\ntermination record's tail residue (the diagnostics the run's-end sweep folds\nin) holds the `DeviceCrash`.")

join('P1-32', 'B', "**An `InterruptException` inside a device's `init!` is the operator's stop,\nnot that device's crash** ([D-268][d-268]).")

edit('P1-12', 'B',
     "The stop already rides on\nthe control plane, the separate atomic surface carrying\npause, pace and stop ([§12.1][s12-1]).",
     "The stop already rides on\nthe control plane ([§12.1][s12-1]).")

join('P1-32', 'B', "**Masking across the boundary is normative, not an implementation hint**\n([D-132][d-132]).")

edit('P1-20', 'B',
     "half-written [stores](#g-store) (the\nframework-owned homes of a component's state) ([§13.6][s13-6]).",
     "[stores](#g-store) (the\nframework-owned homes of a component's state) half-written ([§13.6][s13-6]).")

join('P1-32', 'B', "**The tail's bookkeeping is masked too** ([D-268][d-268]).")

edit('P1-33', 'B', "The\npublished record is consistent, since the frame published nothing.",
     "What\nthe run published is consistent, since the frame published nothing.")

edit('P1-20', 'B',
     "[boundary zero](#g-boundary-zero) (the initialization boundary, the ordinary\nmacro-sequence with an empty integrate) ([§13.4][s13-4]).",
     "[boundary zero](#g-boundary-zero), the initialization boundary, which runs\nthe ordinary macro-sequence with an empty integrate ([§13.4][s13-4]).")

# P1-35: one blank line before §12.5's heading, so B ends on one newline.
p = 'units/B/new.md'; t = open(p).read()
assert t.endswith('\n\n') and not t.endswith('\n\n\n')
open(p, 'w').write(t[:-1])
LOG.append(('P1-35', 'B', '(the file ends "the run.\\n\\n")', '(the file ends "the run.\\n")'))

with open('scratch_step5/fix1/log_new.md', 'w') as f:
    for fid, u, o, n in LOG:
        f.write(f"### {fid}, unit {u}, `units/{u}/new.md`\n\nOld:\n\n````markdown\n{o}\n````\n\nNew:\n\n````markdown\n{n}\n````\n\n")
print(len(LOG), 'edits')
