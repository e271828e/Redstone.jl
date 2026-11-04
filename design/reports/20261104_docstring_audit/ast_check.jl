# Compare each changed file with HEAD: docstrings stripped, ASTs equal.
strip_doc(x) = x
function strip_doc(e::Expr)
    if e.head == :macrocall && e.args[1] == GlobalRef(Core, Symbol("@doc")) && length(e.args) == 4
        return strip_doc(e.args[4])
    end
    Expr(e.head, map(strip_doc, filter(a -> !(a isa LineNumberNode), e.args))...)
end
bad = 0
for f in readlines(`git diff --name-only -- src`)
    new = strip_doc(Meta.parseall(read(f, String)))
    old = strip_doc(Meta.parseall(read(`git show HEAD:$f`, String)))
    ok = new == old
    println(rpad(f, 24), ok ? "code identical" : "CODE DIFFERS")
    ok || (global bad += 1)
end
println(bad == 0 ? "OK" : "$bad files differ")
