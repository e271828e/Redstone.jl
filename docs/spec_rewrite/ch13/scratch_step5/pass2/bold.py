import re,sys
def sents(text):
    # crude: split paragraphs, then sentences
    out=[]
    for para in re.split(r'\n\s*\n',text):
        p=' '.join(para.split())
        for s in re.split(r'(?<=[.!?])\s+(?=[A-Z*`\[])',p):
            out.append(s)
    return out
def bolds(text):
    res=[]
    for s in sents(text):
        if '**' in s:
            ds=sorted(set(re.findall(r'\[D-(\d+)\]',s)))
            for b in re.findall(r'\*\*(.+?)\*\*',s):
                res.append((ds,b[:90]))
    return res
new=open('chapter_new.md').read().split('\n')
spec=open('scratch_survey/h1/spec.md').read().split('\n')
mine=bolds('\n'.join(new[612:1392]))
h1=bolds('\n'.join(new[:612]))
other=bolds('\n'.join(spec[:9908]+['']+spec[11141:13674]))
mine_ds=set(d for ds,_ in mine for d in ds)
print('MINE')
for ds,b in mine: print(ds,b)
print('\nOTHER HITS')
for name,coll in (('half1',h1),('spec',other)):
    for ds,b in coll:
        if set(ds)&mine_ds: print(name,ds,b)
