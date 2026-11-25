from coordlib import *
t=tip()
by=json.load(open(os.path.join(os.path.dirname(__file__),"logby.json"))); L7=by["none"]
def endD():
    for i,l in enumerate(open(f"{W}/design/spec.md")):
        if l.startswith("<!--") and i>hl('## Appendix D'): return i
    return sum(1 for _ in open(f"{W}/design/spec.md"))
A,B,C,D=hl('## Appendix A'),hl('## Appendix B'),hl('## Appendix C'),hl('## Appendix D')
D4,D6,D8,E=hl('### D.4'),hl('### D.6'),hl('### D.8'),endD()
GL=" The glossary is generated into docs/src/glossary.md by docs/glossary.jl, so check each entry's definition against the code, not its rendering."
MA=cm("src/declare.jl","src/assembly.jl","src/build.jl","src/model.jl","src/sim.jl")
spec=[dict(key="SA",kind="spec",range=[A,B-1],desc="Appendix A, the taught contracts",map=cm("src/declare.jl","src/assembly.jl","src/library.jl"),extra="Check every contract, its default and its signature against the code."),
      dict(key="SB",kind="spec",range=[B,C-1],desc="Appendix B, the API synopsis",map=MA+", "+cm("src/trim.jl","src/linearize.jl","src/readers.jl"),extra="Check every entry point's signature, keywords, defaults and return against the code and Stage M's kwargs.tsv leads."),
      dict(key="SD1",kind="spec",range=[D,D4-1],desc="Appendix D preamble and D.1 to D.3",map=MA,extra=GL),
      dict(key="SD2",kind="spec",range=[D4,D6-1],desc="Appendix D, D.4 time and events and D.5 build pipeline",map=cm("src/frame.jl","src/stepper.jl","src/build.jl"),extra=GL),
      dict(key="SD3",kind="spec",range=[D6,D8-1],desc="Appendix D, D.6 runtime periphery and D.7 recording and replay",map=cm("src/dataplane.jl","src/devices.jl","src/roster.jl","src/trace.jl"),extra=GL),
      dict(key="SD4",kind="spec",range=[D8,E],desc="Appendix D, D.8 to D.10",map=cm("src/conditions.jl","src/trim.jl","src/diagnostics.jl"),extra=GL)]
comp=[dict(key="K7a",kind="companion",file="design/companions/longitudinal_aircraft.md, whole",lines=516,map=cm("src/library.jl","src/trim.jl","src/linearize.jl"),extra="It describes the examples package's aircraft (examples/ in W): check it against that code too."),
      dict(key="K7b",kind="companion",file="design/companions/store_at_rest_walkthrough.md, whole",lines=511,map=cm("src/store.jl","src/leaves.jl","src/model.jl","src/checkpoint.jl")),
      dict(key="T7",kind="companion",file="README.md, docs/src/index.md and the four pages in docs/src/tutorial/, all whole. These are user-facing docs, not companions: every code sample, name, keyword and printed result must match the code and the examples package (examples/ in W). Run each complete code sample in your probe script",lines=882,map=MA+", "+cm("src/trim.jl","src/linearize.jl"))]
lg=[dict(key="L7",kind="log",n=len(L7),map=MA)]
cov=[dict(key="CV7a",kind="coverage",files="src/show.jl and src/trace.jl whole",docs="design/spec.md §9.2 Rendering (rg -n '^#### Rendering' design/spec.md), §11.5 and §12.7",map=cm("src/show.jl","src/trace.jl")),
     dict(key="CV7b",kind="coverage",files="src/readers.jl whole; and the exported surface, every name in src/Redstone.jl's export lists, against docs/src/api.md (each exported name has an @docs entry or is deliberately absent)",docs="design/spec.md Appendix B and §14 (readers), docs/src/api.md",map=cm("src/readers.jl","src/Redstone.jl"))]
leads=lambda sl:{s["key"]:({"spec":[s["range"]]} if s["kind"]=="spec" else {"log":L7} if s["kind"]=="log" else
   {"files":{"K7a":["design/companions/longitudinal_aircraft.md"],"K7b":["design/companions/store_at_rest_walkthrough.md"],"T7":["README.md","docs/src/index.md"]+[f"docs/src/tutorial/{p}" for p in ("index.md","aircraft.md","trim.md","linearize.md")]}[s["key"]]} if s["kind"]=="companion" else
   {"code":{"CV7a":["src/show.jl","src/trace.jl"],"CV7b":["src/readers.jl","src/Redstone.jl"]}[s["key"]]}) for s in sl}
runs={"G7a":spec[:5],"G7b":[spec[5]]+comp+lg,"G7c":cov}
for g,sl in runs.items(): write(g,t,sl,leads(sl))
