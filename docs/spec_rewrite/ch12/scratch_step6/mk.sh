mk () {
	printf '%s\n=====\n%s\n' "$1" "$2" > scratch_step6/spec.txt
	python3 scratch_step6/pe.py edit units/$3/new.md ruled_edits.md "$4" $3 scratch_step6/spec.txt
}
rw(){ printf '%s\n=====\n%s\n' "$1" "$2" > scratch_step6/spec.txt; python3 scratch_step6/raw.py units/$3/claims.md ruled_edits.md "$4" $3 scratch_step6/spec.txt; }
