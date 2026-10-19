"""Apply one ruled edit to units/<U>/new.md, rewrap the paragraph, and log
the paragraph before and after to final_fixes_2.md.

    python3 apply.py ITEM UNIT OLD NEW [MARKER]

OLD matches with any run of whitespace standing for a space. MARKER (default
NEW, or OLD's first words when NEW is empty) finds the paragraph after the edit.
"""
import os, re, subprocess, sys

CH = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
LOG = os.path.join(CH, 'final_fixes_2.md')
WRAP = os.path.join(os.path.dirname(__file__), 'wrap.py')


def para_of(src, pos):
    a = src.rfind('\n\n', 0, pos)
    a = 0 if a < 0 else a + 2
    b = src.find('\n\n', pos)
    b = len(src) if b < 0 else b
    return src[a:b]


def main(item, unit, old, new, marker=None):
    path = os.path.join(CH, 'units', unit, 'new.md')
    src = open(path).read()
    pat = re.compile(r'\s+'.join(re.escape(w) for w in old.split()))
    ms = list(pat.finditer(src))
    if len(ms) != 1:
        sys.exit(f"{item}: old text found {len(ms)} times")
    before = para_of(src, ms[0].start())
    src = src[:ms[0].start()] + new + src[ms[0].end():]
    open(path, 'w').write(src)
    marker = marker or (new.split('\n')[0][:60] if new else None)
    subprocess.check_call([sys.executable, WRAP, path, marker])
    src = open(path).read()
    mp = re.compile(r'\s+'.join(re.escape(w) for w in marker.split()))
    after = para_of(src, mp.search(src).start())
    if not os.path.exists(LOG):
        open(LOG, 'w').write(
            "# Chapter 13: final fixes, units F and G (step 6b)\n\n"
            "Each entry gives the item, the unit, and the whole paragraph before and\n"
            "after the edit, verbatim from `units/<U>/new.md`, rewrap included.\n"
            "Replace each old paragraph with its new one, in order.\n")
    with open(LOG, 'a') as f:
        f.write(f"\n## Finding {item}, unit {unit}\n\nOld:\n\n````text\n{before}\n````\n\n"
                f"New:\n\n````text\n{after}\n````\n")
    print(after)


if __name__ == '__main__':
    main(*sys.argv[1:])
