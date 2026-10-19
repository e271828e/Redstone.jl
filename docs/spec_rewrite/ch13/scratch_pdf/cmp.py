import re,sys
src=open('chapter_new.md').read()
pdf=open('scratch_pdf/chapter.txt').read()
pdf=pdf[pdf.index('13. Error discipline',pdf.index('=====PAGE 20')):]
# strip code fences
src=re.sub(r'```.*?```','',src,flags=re.S)
src=re.sub(r'<a id[^>]*></a>','',src)
src=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',src)
src=re.sub(r'\[([^\]]*)\]\(#[^)]*\)',r'\1',src)
src=re.sub(r'^\[[^\]]+\]:.*$','',src,flags=re.M)
src=re.sub(r'[`*#|>_\\-]',' ',src)
pdf=re.sub(r'[`*#|>_\\-]',' ',pdf)
pdf=re.sub(r'=====PAGE \d+=====','',pdf)
w=lambda s:re.findall(r"[A-Za-z0-9§.'’]+",s)
sw,pw=w(src),w(pdf)
print(len(sw),len(pw))
import difflib
sm=difflib.SequenceMatcher(None,sw,pw,autojunk=False)
for t,a,b,c,d in sm.get_opcodes():
    if t!='equal': print(t,' '.join(sw[a:b])[:150],'||',' '.join(pw[c:d])[:150])
