import re,sys
def rlen(w):
    w=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',w); w=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',w)
    return len(w.replace('**',''))
def wrap(text,first='',rest='',width=80):
    # tokens: keep link markup atomic even with spaces inside [..]
    toks=re.findall(r'(?:\[[^\]]*\]\([^)]*\)|\[[^\]]*\]\[[^\]]*\]|[^\s\[]+|\[)+[^\s]*',text)
    toks=text.split()
    # re-join tokens that split inside [...]
    out=[];buf=''
    for t in toks:
        if buf: buf+=' '+t
        else: buf=t
        if buf.count('[')>buf.count(']') or buf.count('`')%2==1: continue
        out.append(buf); buf=''
    if buf: out.append(buf)
    lines=[];cur=first;curlen=rlen(first);pre=first
    for t in out:
        add=(1 if cur.strip() else 0)+rlen(t)
        if cur.strip() and curlen+add>width:
            lines.append(cur); cur=rest+t; curlen=rlen(rest)+rlen(t)
        else:
            cur=cur+(' ' if cur.strip() else '')+t; curlen+=add
    lines.append(cur)
    return '\n'.join(lines)
src=sys.stdin.read()
first=sys.argv[1] if len(sys.argv)>1 else ''
rest=sys.argv[2] if len(sys.argv)>2 else ''
print(wrap(' '.join(src.split()),first,rest))
