from coordlib import *
t=tip()
by=json.load(open(os.path.join(os.path.dirname(__file__),"logby.json")))
L=[d for ch in ('2','3','4','5','6','7') for d in by[ch]]; n=len(L); q=[L[i*n//5:(i+1)*n//5] for i in range(5)]
H=[1,hl('### 2.3'),hl('## 4.'),hl('### 5.3'),hl('### 6.2'),hl('## 7.'),hl('## 8.')]
desc=["title, Part I, §1 introduction, §2.1 to §2.2","§2.3 to §2.5, §3 component taxonomy","§4 ports and signals, §5.1 to §5.2","§5.3 to §5.5, §6.1 connections and hierarchy","§6.2 aggregation, §6.3 rates down the hierarchy","§7 state and data representation"]
maps=[cm("src/frame.jl","src/model.jl","src/stepper.jl","src/sim.jl"),cm("src/frame.jl","src/declare.jl","src/assembly.jl"),cm("src/store.jl","src/build.jl","src/leaves.jl","src/model.jl"),
      cm("src/build.jl","src/structure.jl","src/tracer.jl","src/assembly.jl"),cm("src/assembly.jl","src/structure.jl","src/library.jl"),cm("src/store.jl","src/leaves.jl","src/declare.jl","src/model.jl")]
spec=[dict(key=f"S6{'abcdef'[i]}",kind="spec",range=[H[i],H[i+1]-1],desc=desc[i],map=maps[i]) for i in range(6)]
ML=cm("src/library.jl","src/model.jl")
comps=[("K6a",["design/companions/event_visibility_walkthrough.md","design/companions/fused_evaluation_lineage.md"],297,cm("src/frame.jl","src/executor.jl","src/build.jl")),
       ("K6b",["design/companions/library_inventory.md"],505,ML),("K6c",["design/companions/linear_systems.md"],453,ML+", "+cm("src/linearize.jl")),
       ("K6d",["design/companions/lqr_tracker.md"],428,ML),("K6e",["design/companions/pid_anti_windup.md"],624,ML)]
comp=[dict(key=k,kind="companion",file=" and ".join(f)+(", both whole" if len(f)>1 else ", whole"),lines=ln,map=m) for k,f,ln,m in comps]
MA=cm("src/declare.jl","src/assembly.jl","src/build.jl","src/structure.jl","src/store.jl","src/leaves.jl","src/frame.jl","src/library.jl")
logs6=[dict(key=f"L6{'abcde'[i]}",kind="log",n=len(q[i]),map=MA) for i in range(5)]
D=f"design/spec.md §1 to §7 (lines 1-{H[6]-1})"
LL=sum(1 for _ in open(f"{W}/src/library.jl")); mid=LL//2
cov=[dict(key="CV6a",kind="coverage",files="src/store.jl, src/leaves.jl and src/bindings.jl whole",docs=D+" and §8.2 (rg -n '^### 8.2' design/spec.md)",map=cm("src/store.jl","src/leaves.jl","src/bindings.jl")),
     dict(key="CV6b",kind="coverage",files=f"src/library.jl lines 1-{mid}",docs=D+", §13.7 (the component library section) and the library companions in design/companions/",map=cm("src/library.jl")),
     dict(key="CV6c",kind="coverage",files=f"src/library.jl lines {mid+1}-{LL}",docs=D+", §13.7 (the component library section) and the library companions in design/companions/",map=cm("src/library.jl"))]
lead=lambda s: {"spec":[s["range"]]} if s["kind"]=="spec" else {}
cl={k:{"files":f} for k,f,_,_ in comps}
runs={"G6a":spec[:5],"G6b":[spec[5]]+comp[:4],"G6c":[comp[4]]+logs6[:4],"G6d":[logs6[4]]+cov}
for g,sl in runs.items():
    leads={}
    for s in sl:
        if s["kind"]=="spec": leads[s["key"]]={"spec":[s["range"]]}
        elif s["kind"]=="companion": leads[s["key"]]=cl[s["key"]]
        elif s["kind"]=="log": leads[s["key"]]={"log":q["abcde".index(s["key"][-1])]}
        else: leads[s["key"]]={"code":["src/store.jl","src/leaves.jl","src/bindings.jl"] if s["key"]=="CV6a" else ["src/library.jl"]}
    write(g,t,sl,leads)
