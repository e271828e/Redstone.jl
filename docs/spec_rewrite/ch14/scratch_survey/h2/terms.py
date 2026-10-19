import re,sys
L=open(sys.argv[1]).read().split('\n')
secs=[('14.7',11874,12054),('14.8',12055,12371),('14.9',12372,12483),('14.10',12484,12730)]
terms={
'condition':(r'\bconditions?\b','g-condition'),
'baseline':(r'`?baseline`?','g-baseline'),
'TrimProblem':(r'TrimProblem\b','g-trimproblem'),
'taps':(r'\btaps?\b','g-taps'),
'mounting':(r'\bmount(ing|ed|s)?\b','g-mounting'),
'at':(r'`at`|at\(','g-at'),
'override':(r'override','g-override'),
'combine':(r'\bcombine','g-combine'),
'fragment':(r'\bfragment','g-fragment'),
'design_world':(r'design_world','g-design_world'),
'boundary zero':(r'boundary[- ]zero','g-boundary-zero'),
'checkpoint':(r'\bcheckpoint','g-checkpoint'),
'activation':(r'\bactivation','g-activation'),
'tier':(r'\btiers?\b','g-tier'),
'nominal':(r'\bnominal\b','g-nominal'),
'scratch':(r'\bscratch\b','g-scratch'),
'seam':(r'\bseams?\b','g-seam'),
'sweep':(r'\bsweeps?\b','g-sweep'),
'selector':(r'\bselectors?\b','g-selector'),
'leaf address':(r'leaf address','g-leaf-address'),
'root input':(r'root[- ]inputs?','g-root-input'),
'face':(r'\bfaces?\b','g-face'),
'port':(r'\bports?\b','g-port'),
'component':(r'\bcomponents?\b','g-component'),
'contract':(r'\bcontracts?\b','g-contract'),
'cell':(r'\bcells?\b','g-cell'),
'store':(r'\bstores?\b','g-store'),
'buffer':(r'\bbuffers?\b','g-buffer'),
'probe':(r'\bprobe\b','g-probe'),
'guard':(r'\bguards?\b','g-guard'),
'projection':(r'\bprojection\b','g-projection'),
'walked/pinned':(r'\b(walked|pinned|Walked)\b','g-walked'),
'recorded, not built':(r'recorded, not built','g-recorded-not-built'),
'worked':(r'\bWorked\b|\bworked\b','g-worked'),
'Model':(r'`Model`','g-model'),
'workspace':(r'workspace','g-workspace'),
'signal table':(r'signal table','g-signal-table'),
'trace':(r'\btrace\b','g-trace'),
'trace header':(r'trace header','g-trace-header'),
'boundary':(r'\bboundary\b','g-boundary'),
'tick':(r'\bticks?\b','g-tick'),
'due':(r'\bdue\b','g-due'),
'feedthrough':(r'feedthrough','g-feedthrough'),
'continuous component':(r'continuous component','g-continuous-component'),
'constant source':(r'constant source','g-constant-source'),
'scenario component':(r'scenario component','g-scenario-component'),
'did-you-mean':(r'did-you-mean','g-did-you-mean'),
'root-input totality':(r'totality','g-root-input-totality'),
'batch':(r'\bbatch(es)?\b','g-batch'),
'staging cell':(r'staging cells?','g-staging-cell'),
'recorders':(r'recorders','g-recorders'),
'value-level constructor':(r'value-level constructor','g-value-level-constructor'),
'executor':(r'\bexecutor','g-executor'),
'build':(r'`Build`','g-build'),
'stage':(r'stage function|output stage','g-stage-function'),
'predicate':(r'predicate','g-predicate'),
'kind':(r'\bkinds?\b','g-kind'),
'entry':(r'\bentry\b|\bentries\b','g-entry'),
'frame':(r'\bframes?\b','g-frame'),
'field handle':(r'handle','g-field-handle'),
'execution order':(r'execution order','g-execution-order'),
'run':(r'\bruns?\b','g-run'),
'deployment':(r'deployment','g-deployment'),
'chunking':(r'chunk','g-chunking'),
'probe value':(r'probe value|probe_value|synthesi','g-probe-value'),
'snapshot':(r'snapshot','g-snapshot'),
'replay':(r'replay','g-replay'),
'harmonic grid':(r'grid','g-harmonic-grid'),
}
strip=lambda s: re.sub(r'\[([^\]]*)\]\((#g-[^)]*)\)',r'\1',re.sub(r'\[§[^\]]*\]\[[^\]]*\]|\[D-\d+\]\[[^\]]*\]|\[Appendix [A-Z]\]\[[^\]]*\]','',s))
for name,a,b in secs:
  print('==',name)
  for t,(rx,anc) in terms.items():
    first=None;link=[]
    for i in range(a,b+1):
      l=L[i-1]
      if '#'+anc+')' in l: link.append(i)
      if first is None and re.search(rx,strip(l)): first=i
    if first or link:
      print(f'  {t}: first {first}; links {link}')
