#!/bin/sh
# Stage M of the docs conformance audit. Run from the repository root of the
# pinned worktree: sh design/reports/20261124_doc_conformance/probes/stage_m/run.sh
# Each output lands in ledgers/stage_m/ beside this folder's parent.
here=$(dirname "$0")
out="$here/../../ledgers/stage_m"
mkdir -p "$out"
export JULIA_LOAD_PATH="@"
J="julia --startup-file=no --project=test"
for s in names kwargs kinds descriptor citations; do
    $J "$here/$s.jl" > "$out/$s.tsv" 2> "$out/$s.err" || echo "$s failed: see $out/$s.err"
done
$J design/tools/docstring_signatures.jl > "$out/signatures.txt" 2>&1 || echo "signatures failed"
$J design/tools/docstring_roster.jl "$out/roster.tsv" > "$out/roster.txt" 2>&1 || echo "roster failed"
julia --startup-file=no --project=docs docs/make.jl > "$out/docs_build.txt" 2>&1 || echo "docs build failed"
