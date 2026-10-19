import re
exec(open('replay.py').read().split("print(len(E1)")[0])
def render(s):
    s = re.sub(r'\[([^\]]*)\]\([^)]*\)', r'\1', s)
    s = re.sub(r'\[([^\]]*)\]\[[^\]]*\]', r'\1', s)
    return s.replace('`','').replace('*','')
def W(s): return len(render(s))
def firsttok(l):
    # first token of a line, keeping backtick spans and link markup together
    l=l.strip(); toks=l.split(' '); buf=[]; t=0
    for w in toks:
        buf.append(w); t+=w.count('`')
        if t%2==0: break
    return ' '.join(buf)
for tag,E in (('FIX',E1),('RULED',E2)):
    for h,U,old,new in E:
        lines=new.split('\n')
        for i,l in enumerate(lines):
            if l.startswith('|') or l.startswith('    '): continue
            if W(l)>80: print(tag,h[:30],'OVER',W(l),repr(render(l)))
            if i+1<len(lines) and lines[i+1].strip() and not lines[i+1].startswith('|'):
                nt=firsttok(lines[i+1])
                if W(l)+1+W(nt)<=80: print(tag,h[:30],'LOOSE',W(l),'+',W(nt),repr(render(l)[-30:]),'|',render(nt))
