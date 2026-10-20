import re,sys
f=sys.argv[1]
secs=[(726,939),(940,1309),(1310,1450),(1451,1733)]
lines=open(f,encoding='utf-8').read().split('\n')
terms={'g-boundary-zero':r'boundary zero','g-scratch':r'\bscratch\b','g-component':r'\bcomponents?\b','g-root-input':r'\broot inputs?\b','g-checkpoint':r'\bcheckpoints?\b','g-selector':r'\bselectors?\b','g-cell':r'\bcells?\b','g-guard':r'\bguards?\b','g-tier':r'\btiers?\b','g-port':r'\bports?\b','g-probe':r'\bprobe','g-condition':r'\bconditions?\b','g-sweep':r'\bsweeps?\b','g-activation':r'\bactivations?\b','g-seam':r'\bseams?\b','g-baseline':r'\bbaseline\b','g-face':r'\bfaces?\b','g-override':r'\boverride\b','g-model':r'`Model`','g-trimproblem':r'TrimProblem','g-recorded-not-built':r'recorded, not built','g-contract':r'\bcontracts?\b','g-at':r'`at`','g-store':r'\bstores?\b','g-root-input-totality':r'totality','g-trace':r'\btrace\b','g-batch':r'\bbatch','g-walked':r'\b(walked|pinned)\b','g-due':r'\bdue\b','g-tick':r'\bticks?\b','g-mounting':r'\bmount','g-design_world':'design_world','g-taps':r'\btap set','g-nominal':r'\bnominal\b','g-projection':r'\bprojection\b','g-leaf-address':r'leaf address','g-fragment':r'\bfragment','g-signal-table':r'signal table','g-buffer':r'\bbuffers?\b','g-workspace':r'\bworkspace','g-feedthrough':r'feedthrough','g-continuous-component':r'continuous component','g-field-handle':r'\bhandles?\b'}
for a,b in secs:
    infence=False
    first={}
    for i in range(a-1,b):
        l=lines[i]
        if l.startswith('```'): infence=not infence; continue
        if infence: continue
        plain=re.sub(r'\[([^\]]*)\]\((#g-[^)]+)\)',lambda m:'\x00'+m.group(2)+'\x00',l)
        for g,pat in terms.items():
            if g in first: continue
            # link?
            for tok in re.split(r'(\x00#g-[^\x00]+\x00)',plain):
                if tok.startswith('\x00'):
                    if tok.strip('\x00')[1:]==g: first[g]=('link',i+1); break
                elif re.search(pat,tok):
                    first[g]=('bare',i+1); break
    linked=set()
    for i in range(a-1,b):
        for m in re.finditer(r'\(#(g-[^)]+)\)',lines[i]): linked.add(m.group(1))
    print('==',a,b)
    for g in sorted(linked):
        if g in first and first[g][0]=='bare': print('  bare before link:',g,first[g][1])
