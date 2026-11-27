#!/bin/zsh
# p14: per-testset wall times of the longitudinal file, V1 (the worktree's) and A (probe copy),
# each in a fresh process, on the cached code and right after a forced recompile (`touch`).
cd /Users/miguel/.julia/dev/Redstone.jl-worktrees/tutorial_1b
P=../tutorial_1b_probes
one() { JULIA_TEST_VERBOSE=true julia --startup-file=no --project=examples/test $P/run_file.jl $1 > $P/p14_$2.raw 2>&1; }
touch examples/src/longitudinal.jl; one examples/test/test_longitudinal.jl V1_recompiled
one examples/test/test_longitudinal.jl V1_cached
one $P/test_longitudinal_A.jl A_cached
touch examples/src/longitudinal.jl; one $P/test_longitudinal_A.jl A_recompiled
