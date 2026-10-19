#!/bin/zsh
S=/private/tmp/claude-501/-Users-miguel--julia-dev-Redstone-jl/4c32fc9c-3bf1-410f-8231-bf89ed29fb1e/scratchpad; R=/Users/miguel/.julia/dev/Redstone.jl; WT=/private/tmp/claude-501/-Users-miguel--julia-dev-Redstone-jl/4c32fc9c-3bf1-410f-8231-bf89ed29fb1e/scratchpad/wt
cd $WT
echo "==== COVERAGE EXPERIMENT"
echo "# touched for the coverage experiment" >> src/precompile.jl
JULIA_LOAD_PATH="@" julia -t auto --startup-file=no --check-bounds=yes --warn-overwrite=yes --depwarn=yes --code-coverage=@src --project=test $S/coverage_parent.jl 2>&1 | grep -E 'CHILD|PARENT|ERROR|Error'
rm -f src/*.cov test/*.cov
sed -i '' '/# touched for the coverage experiment/d' src/precompile.jl
echo "==== FINE PROBES"
for img in base workload; do
  if [ $img = base ]; then P=$R; else P=$WT; fi
  cd $P
  for i in 1 2; do echo -n "$img "; julia --startup-file=no --project=test $S/cold.jl 2>&1 | grep -E '^COLD|ERROR' | cut -c1-700; done
  for i in 1 2; do echo -n "$img "; julia --startup-file=no --project=examples $S/cold_examples.jl 2>&1 | grep -E '^EXAMPLES|ERROR' | cut -c1-400; done
done
cd $WT; for i in 1 2; do echo -n "workload "; julia --startup-file=no --project=test $S/cold_device.jl 2>&1 | grep -E '^DEVICE|ERROR'; done
echo "==== MATRIX"
for job in "base -O2" "workload -O2" "base -O0" "workload -O0"; do
  img=${job%% *}; opt=${job##* }
  if [ $img = base ]; then P=$R/test; else P=$WT/test; fi
  julia $opt --startup-file=no --project=$P -e 'using Redstone' > /dev/null 2>&1
  for scen in small repeated distinct; do for i in 1 2 3; do
    echo -n "$img $opt "; julia $opt --startup-file=no --project=$P $S/probes/cold_scenario.jl $scen 2>&1 | grep -E 'SCENARIO|ERROR' | cut -c1-300
  done; done
done
echo "==== DONE"
