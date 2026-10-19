import re
L=open('spec.md').read().split('\n')
secs=[(11267,11319,'head'),(11320,11375,'14.1'),(11376,11487,'14.2'),(11488,11558,'14.3'),(11559,11717,'14.4'),(11718,11820,'14.5'),(11821,11873,'14.6')]
terms={'activation':'g-activation','boundary zero|boundary-zero':'g-boundary-zero','checkpoint':'g-checkpoint','stores?':'g-store','drains?':'g-drain','roster':'g-roster',
'trace':'g-trace','snapshots?':'g-snapshot','frame':'g-frame','deployment':'g-deployment','executor':'g-executor','control-plane|control plane':'g-control-plane',
'sweeps?':'g-sweep','tiers?':'g-tier','faces?':'g-face','root inputs?':'g-root-input','workspace':'g-workspace','seams?':'g-seam','fragments?':'g-fragment',
'assembly|assemblies':'g-assembly','components?':'g-component','contract':'g-contract','local wires?|local_wires':'g-local-wire','combine':'g-combine','override':'g-override',
'kinds?':'g-kind','did-you-mean':'g-did-you-mean','lens(es)?':'g-lens','cells?':'g-cell','views?':'g-view','nominal':'g-nominal','probes?':'g-probe','probe.value|probe_value':'g-probe-value',
'selectors?':'g-selector','leaf address':'g-leaf-address','buffers?':'g-buffer','ports?':'g-port','taps':'g-taps','mounting|mounted':'g-mounting','devices?':'g-device',
'guards?':'g-guard','due':'g-due','trace header':'g-trace-header','projection':'g-projection','ticks?':'g-tick','predicate':'g-predicate','priors?':'g-prior','replay':'g-replay',
'stop request':'g-stop-request','harmonic grid':'g-harmonic-grid','baselines?':'g-baseline','requester roster':'g-requester-roster','scratch':'g-scratch','signal tables?':'g-signal-table',
'generic(ally)?.held|generic holding':'g-generic-holding','schema':'g-schema-vs-layout','layout':'g-schema-vs-layout','value-level constructor':'g-value-level-constructor',
'conditions?':'g-condition','root-input totality':'g-root-input-totality','service lifecycle|lifecycle':'g-service-lifecycle','Model':'g-model','Build':'g-build','run':'g-run','batch(es)?':'g-batch',
'entry|entries':'g-entry','continuous component':'g-continuous-component','fragment tree|tree':'g-fragment-tree','execution order':'g-execution-order','probe chain':'g-probe','event':'g-state-event',
'recorders':'g-recorders','log':'g-log','phase':'g-phase'}
for a,b,n in secs:
    print('==',n)
    for t,g in terms.items():
        for i in range(a,b+1):
            line=L[i-1]
            # strip link targets to avoid matching inside (#g-...)
            txt=re.sub(r'\]\([^)]*\)',']',line); txt=re.sub(r'\]\[[^\]]*\]',']',txt)
            flags = 0 if t in ('Model','Build') else re.I
            m=re.search(r'(?<![\w-])('+t+r')(?![\w-])',txt,flags)
            if m:
                linked = ('(#'+g+')') in line
                print(f'  {t:28s} first {i} linked_on_line={linked}: …{txt[max(0,m.start()-30):m.end()+20]}…')
                break
