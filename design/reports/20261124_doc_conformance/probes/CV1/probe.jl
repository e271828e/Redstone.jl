# CV1 probe: src/diagnostics.jl against Appendix C and §13.
using Redstone, InteractiveUtils
const R = Redstone
W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
tag(n, x) = println("probe:", n, " ", x)

# --- 1. kind set against Appendix C (names and severities)
spec = read(joinpath(W, "design/spec.md"), String)
i0 = first(findfirst("## Appendix C. The diagnostic kind set", spec))
i1 = first(findfirst("## Appendix D. Glossary", spec))
app = spec[i0:i1]
entries = Dict{String,String}()
for m in eachmatch(r"^- \*\*`(\w+)`\*\*(.*?)(?=^- \*\*`|^\*\*|^---|\z)"ms, app)
    entries[m[1]] = m[2]
end
sev(txt) = (m = match(r"\b(Error|Warning)\s*·", txt); m === nothing ? "?" : m[1])
code = Dict{String,Symbol}()
function walk(T)
    for S in subtypes(T)
        isabstracttype(S) ? walk(S) : (code[string(nameof(S))] = R.severity(
            S <: R.Diagnostic && isconcretetype(S) ? first(methods(S)).sig === nothing ? nothing : nothing : nothing))
    end
end
kinds_code = [string(nameof(S)) for S in subtypes(R.Diagnostic)]
tag("1a", "code kinds=$(length(kinds_code)) appendix entries=$(length(entries))")
tag("1b", "in code not in AppC: " * string(sort(setdiff(kinds_code, keys(entries)))))
tag("1c", "in AppC not code: " * string(sort(setdiff(collect(keys(entries)), kinds_code))))
# severity: build an instance is hard; read the method table instead
warnkinds = Set(string(nameof(first(m.sig.parameters[2:2]) isa Type ? m.sig.parameters[2] : Nothing))
                for m in methods(R.severity) if length(m.sig.parameters) == 2 && m.sig.parameters[2] !== R.Diagnostic)
tag("1d", "kinds with a severity method: " * string(sort(collect(warnkinds))))
appwarn = Set(k for (k, v) in entries if sev(v) == "Warning")
tag("1e", "AppC warnings: " * string(sort(collect(appwarn))))
tag("1f", "AppC warn not code warn: " * string(sort(setdiff(collect(appwarn), warnkinds))) *
          " ; code warn not AppC warn: " * string(sort(setdiff(collect(warnkinds), appwarn))))
tag("1g", "severity default: " * string(R.severity(R.DeadStage(path = "a", stage = "y_state"))))

# --- 2. BS3 ArgumentInvalid message
try
    R.BS3(-1.0, 1e-6)
catch e
    tag("2a", "BS3 refusal type=" * string(typeof(e)))
    d = R.diagnostic(R.DiagnosticError(R.diagnostics(e)[1])) 
    tag("2b", "BS3 message: " * R.message(d))
end

# --- 3. carrier mechanics
d1 = R.UnconnectedInput(path = "b", face = :u, declared = Float64)
d2 = R.DeadStage(path = "a", stage = "y_state")
d3 = R.UnconnectedInput(path = "a", face = :v, declared = Float64)
d4 = R.UnconnectedInput(path = "a", face = :u, declared = Float64)
err = R.DiagnosticError(R.Diagnostic[d1, d2, d3, d4])
tag("3a", "type=" * string(typeof(err)) * " kinds=" * string(R.kinds(err)))
tag("3b", sprint(showerror, err))
e1 = R.DiagnosticError(d2)
tag("3c", "fail-fast type=" * string(typeof(e1)) * " diagnostic=" * string(R.diagnostic(e1) === d2) * " structure=" * string(e1.structure) * " warnings=" * string(e1.warnings))
w = R.EmptyGreedyClaim(device = "Dev", binding = "B")
e2 = R.DiagnosticError(R.Diagnostic[d2, d1], R.Diagnostic[w])
tag("3d", sprint(showerror, e2))
tag("3e", sprint(showerror, R.DiagnosticError(d2, R.Diagnostic[w])))
tag("3f", "logline=" * R.logline(w))
tag("3g", "kinds excludes warnings: " * string(R.kinds(e2)))
tag("3h", "hasmethod diagnostics on fail-fast: " * string(hasmethod(R.diagnostics, Tuple{typeof(e1)})) *
          " ; kinds on fail-fast: " * string(hasmethod(R.kinds, Tuple{typeof(e1)})) *
          " ; diagnostic on collected: " * string(hasmethod(R.diagnostic, Tuple{typeof(err)})))

# --- 4. _warn!
try R._warn!(d2); catch e; tag("4a", "warn! error kind -> " * string(typeof(e)) * " : " * sprint(showerror, e)); end
lst = R.Diagnostic[]
Base.ScopedValues.with(R.BUILD_WARNINGS => lst) do
    R._warn!(w)
end
tag("4b", "bound append: " * string(length(lst)))
tag("4c", "unbound logs (see log line below)")
R._warn!(w)

# --- 5. runtime carrier
cf = R.CursorFrame("a/b", :x_deriv, :integrate, 2)
tag("5a", "attempt default=" * string(cf.attempt) * " eq=" * string(cf == R.CursorFrame("a/b", :x_deriv, :integrate, 2, 0)))
nf = R.NonfiniteState(path = "a", leaf = "q", value = NaN, t = 0.5, boundary = 3)
tag("5b", R.message(nf) * " sev=" * string(R.severity(nf)))
se = R.StepError{typeof(nf)}(cf, 0.5, 3, :loop, nf)
tag("5c", sprint(showerror, se))
for host in (:boundary_zero, :overlay, :restore)
    tag("5d-$host", sprint(showerror, R.StepError{typeof(nf)}(R.CursorFrame(nothing, :none, :drain, 0), 0.0, 0, host, nf)))
end
tag("5e", sprint(showerror, R.StepError{InterruptException}(cf, 0.5, 3, :loop, InterruptException())))
tag("5f", "phase texts: " * join((R._phase_text(R.CursorFrame("", :f, p, 2, a)) for (p, a) in
        ((:integrate, 2), (:arrival, 0), (:validation, 0), (:trial, 1), (:project, 0), (:round, 1), (:ticks, 0), (:drain, 0), (:zzz, 0))), " | "))
tag("5g", "_seconds Dual: " * string(R._seconds(R.ForwardDiff.Dual(1.5, 1.0))) * " nested " * string(R._seconds(R.ForwardDiff.Dual(R.ForwardDiff.Dual(2.5, 1.0), 1.0))))
tag("5h", "IllegalInvariant: " * sprint(showerror, R.InternalInvariant("x")))
tag("5i", "StepError{Int} bound: " * (try R.StepError{Int}; "no error" catch e; string(typeof(e)) end))

# --- 6. messages that Appendix C / docstrings promise
ai = R.ArgumentInvalid(call = :BS3, reason = :range, argument = :reltol, value = -1.0)
tag("6a", R.message(ai))
tag("6b", R.message(R.ArgumentInvalid(call = :TableBinding, reason = :deadzone, entry = :ch, value = 2.0)))
tag("6c", R.message(R.ArgumentInvalid(call = :Model, reason = :scalar, argument = :T, value = Int)))
tag("6d", R.message(R.ArgumentInvalid(call = :frame!, reason = :range, argument = :k, value = 10, related = 5)))
tag("6e", R.message(R.ConditionResolution(path = "p", store = :x, field = :q, reason = :unconvertible, declared = Float64, value = "a", observed = String, origin = "o")))
tag("6f", R.message(R.EmptyFaceSelection(who = "input_passthrough", path = "c", selector = :only, names = String[], candidates = String["a"])))
tag("6g", "grid cap sq: " * string(R.PRIME_DIVISOR_CAP^2 == 2^40))
tag("6i", "msg ClassMixed has local_wires: " * R.message(R.ClassMixed(path = "a", declarations = [:x_init])))
tag("6j", "GuardForm fields: " * string(fieldnames(R.GuardForm)) * " ; ClassMixed fields: " * string(fieldnames(R.ClassMixed)) * " ; BindingContractMismatch: " * string(fieldnames(R.BindingContractMismatch)) * " ; EntryTypeMismatch: " * string(fieldnames(R.EntryTypeMismatch)))
tag("6k", "MalformedDatum cause any: " * string(R.MalformedDatum(42).cause))

# --- 7. method coverage over the kind set
Ks = subtypes(R.Diagnostic)
tag("7a", "kinds without a message method: " * string([nameof(T) for T in Ks if !hasmethod(R.message, Tuple{T})]))
pathless = [nameof(T) for T in Ks if :path in fieldnames(T) && !any(m -> m.sig.parameters[2] === T, methods(R.path))]
tag("7b", "kinds with a `path` field and no path method: " * string(pathless))
withpath = [nameof(T) for T in Ks if !(:path in fieldnames(T)) && any(m -> m.sig.parameters[2] === T, methods(R.path))]
tag("7c", "kinds with a path method and no path field: " * string(withpath))
tag("7d", "hasdoc: " * string([(n, Base.Docs.hasdoc(R, n)) for n in (:diagnostic, :diagnostics, :kinds, :logline, :path, :severity, :message, :Diagnostic, :DiagnosticError, :MalformedDatum, :StepError, :CursorFrame, :InternalInvariant, :GridEntry, :GridReport, :BUILD_WARNINGS, :CHECKPOINT_ORIGIN)]))
tag("7e", "isexported: " * string([(n, Base.isexported(R, n)) for n in (:Diagnostic, :DiagnosticError, :StepError, :MalformedDatum, :kinds, :diagnostics, :diagnostic, :severity, :path, :message, :warnings)]))
tag("7f", "ispublic: " * string([(n, Base.ispublic(R, n)) for n in (:Diagnostic, :DiagnosticError, :StepError, :MalformedDatum, :kinds, :diagnostics, :diagnostic, :severity, :path, :message, :warnings, :logline)]))
tag("7g", "payload fields of every kind: " * join(["$(nameof(T))($(join(fieldnames(T), ",")))" for T in Ks], "; "))
