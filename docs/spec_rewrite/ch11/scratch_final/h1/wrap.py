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
