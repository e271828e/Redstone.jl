"""Rendered width of markdown lines: width.py <file> <from> <to> [limit]; lists lines past limit."""
import re, sys
def rendered(line):
    s = re.sub(r'\[([^\]]*)\]\[[^\]]*\]', r'\1', line)
    s = re.sub(r'\[([^\]]*)\]\([^)]*\)', r'\1', s)
    return s.replace('**', '').replace('`', '')
if __name__ == '__main__':
    f, a, b = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    lim = int(sys.argv[4]) if len(sys.argv) > 4 else 80
    lines = open(f).read().split('\n')
    incode = False
    for i in range(a, b + 1):
        l = lines[i - 1]
        if l.startswith('```'): incode = not incode; continue
        if not incode and len(rendered(l)) > lim:
            print(i, len(rendered(l)), rendered(l))
