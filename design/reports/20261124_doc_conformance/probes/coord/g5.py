from coordlib import *
t=tip(); L11=logs('11'); L12=logs('12'); k=len(L11)//3
H=[hl(x) for x in ('## 11.','### 11.3','### 11.5','### 11.7','## 12.','### 12.4','### 12.6','### 12.7','## 13.')]
S=lambda i:[H[i],H[i+1]-1]
MD=cm("src/dataplane.jl","src/devices.jl","src/roster.jl")
MS=cm("src/sim.jl","src/control.jl","src/checkpoint.jl")
ga=[dict(key="S11a",kind="spec",range=S(0),desc="§11 preamble, §11.1 staged writes and snapshot reads, §11.2 snapshot publication",map=MD+", "+cm("src/sim.jl")),
    dict(key="S11b",kind="spec",range=S(1),desc="§11.3 root inputs, claims and the frozen roster, §11.4 per-device staging and the drain",map=MD+", "+cm("src/bindings.jl")),
    dict(key="S11c",kind="spec",range=S(2),desc="§11.5 the input trace, §11.6 devices",map=MD+", "+cm("src/trace.jl")),
    dict(key="S11d",kind="spec",range=[H[3],H[4]-1],desc="§11.7 the GUI write path, §11.8 the per-writer diagnostic cell",map=MD+", "+cm("src/diagnostics.jl")),
    dict(key="K11b",kind="companion",file="design/companions/inbound_periphery_walkthrough.md, whole",lines=296,map=MD)]
gb=[dict(key="S12a",kind="spec",range=[H[4],hl('### 12.4')-1],desc="§12 preamble, §12.1 control plane, §12.2 loop scheduling, §12.3 the next-snapshot wait",map=MS),
    dict(key="S12b",kind="spec",range=[hl('### 12.4'),hl('### 12.6')-1],desc="§12.4 shutdown protocol, §12.5 scripts and mid-run mutation",map=MS+", "+cm("src/devices.jl","src/roster.jl")),
    dict(key="S12c",kind="spec",range=[hl('### 12.6'),hl('### 12.7')-1],desc="§12.6 run lifecycle and partial advance",map=MS+", "+cm("src/model.jl")),
    dict(key="S12d",kind="spec",range=[hl('### 12.7'),H[8]-1],desc="§12.7 replay",map=MS+", "+cm("src/trace.jl")),
    dict(key="K11",kind="companion",file="design/companions/flight_case_studies.md, whole",lines=503,map=MD+", "+MS)]
gc=[dict(key="L11a",kind="log",n=k,map=MD),dict(key="L11b",kind="log",n=k,map=MD),dict(key="L11c",kind="log",n=len(L11)-2*k,map=MD+", "+cm("src/trace.jl")),
    dict(key="L12",kind="log",n=len(L12),map=MS)]
D11=f"design/spec.md §11 and §12 (lines {H[0]}-{H[8]-1})"
gd=[dict(key="CV11a",kind="coverage",files="src/dataplane.jl and src/devices.jl whole",docs=D11,map=cm("src/dataplane.jl","src/devices.jl")),
    dict(key="CV11b",kind="coverage",files="src/roster.jl, src/control.jl and src/checkpoint.jl whole",docs=D11,map=cm("src/roster.jl","src/control.jl","src/checkpoint.jl")),
    dict(key="CV12",kind="coverage",files="src/sim.jl whole, except the functions whose comments cite §13 or §14 (audited earlier)",docs=D11,map=cm("src/sim.jl"))]
write("G5a",t,ga,{s["key"]:({"spec":[s["range"]]} if s["kind"]=="spec" else {"files":["design/companions/inbound_periphery_walkthrough.md"]}) for s in ga})
write("G5b",t,gb,{s["key"]:({"spec":[s["range"]]} if s["kind"]=="spec" else {"files":["design/companions/flight_case_studies.md"]}) for s in gb})
write("G5c",t,gc,{"L11a":{"log":L11[:k]},"L11b":{"log":L11[k:2*k]},"L11c":{"log":L11[2*k:]},"L12":{"log":L12}})
write("G5d",t,gd,{"CV11a":{"code":["src/dataplane.jl","src/devices.jl"]},"CV11b":{"code":["src/roster.jl","src/control.jl","src/checkpoint.jl"]},"CV12":{"code":["src/sim.jl"]}})
