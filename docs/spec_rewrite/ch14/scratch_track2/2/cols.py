"""Rendered width of lines: links show their label, code and emphasis lose their markers.
usage: cols.py FILE START END [LIMIT]  -> lines over LIMIT (default 80)"""
import re, sys, unicodedata
def rendered(l):
    l = re.sub(r"\[([^\]]+)\]\[[^\]]+\]", r"\1", l)
    l = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", l)
    l = l.replace("**", "").replace("`", "")
    return l
def width(s):
    return sum(0 if unicodedata.combining(c) else 1 for c in s)
if __name__ == "__main__":
    f, a, b = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    lim = int(sys.argv[4]) if len(sys.argv) > 4 else 80
    for i, l in enumerate(open(f).read().split("\n")[a-1:b], a):
        w = width(rendered(l))
        if w > lim: print(i, w, l)
