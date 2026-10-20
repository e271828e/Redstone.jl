import re,sys
def run(ver):
    txt="".join(open(f"{u}.{ver}.md").read() for u in "FGH")
    txt=re.sub(r"^```.*?^```","",txt,flags=re.S|re.M)
    secs=re.split(r"^(?=### 14\.)",txt,flags=re.M)
    res=set()
    for s in secs:
        name=s.split("\n",1)[0][:10]
        for m in re.finditer(r"\[([^\]]+)\]\((#g-[^)]+)\)",s):
            term=m.group(1).strip("`*").lower()
            stem=term[:-1] if term.endswith("s") else term
            before=s[:m.start()]
            plain=re.sub(r"\[([^\]]+)\]\([^)]+\)",r"\1",before)
            plain=re.sub(r"\[([^\]]+)\]\[[^\]]+\]",r"\1",plain).replace("`","").replace("*","").lower()
            plain=re.sub(r"\s+"," ",plain)
            hit=re.search(r"\b"+re.escape(stem)+r"s?\b",plain)
            if hit:
                res.add((name,m.group(2),term,plain[max(0,hit.start()-40):hit.end()+20]))
    return res
a=run("verified"); b=run("current")
for r in sorted(b-a): print("NEW", r)
print("--- still")
for r in sorted(b&a): print("OLD", r[:3])
