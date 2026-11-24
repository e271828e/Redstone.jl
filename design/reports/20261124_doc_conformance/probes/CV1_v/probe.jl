# CV1_v probes: verifier for slice CV1 (src/diagnostics.jl coverage). Run from W with --project=test.
include(joinpath(pwd(), "test", "RedstoneTests.jl"))

@eval RedstoneTests begin
const R = Redstone
p(label, x) = println(rpad(label, 28), " => ", x)
function tryshow(f)
    try
        f(); "no throw"
    catch e
        e
    end
end

# CV1-003: every Diagnostic subtype is a concrete immutable struct
allk = filter(n -> (v = getfield(R, n); v isa Type && v <: R.Diagnostic && v !== R.Diagnostic),
              names(R; all = true))
p("003 n kinds", length(allk))
p("003 abstract/mutable", [n for n in allk if isabstracttype(getfield(R, n)) || ismutabletype(getfield(R, n))])

# CV1-018: grouping
ds = R.Diagnostic[R.StoreWithoutUpdate(path = "z", store = :x_init),
                  R.ClassMixed(path = "b", declarations = [:x_init]),
                  R.StoreWithoutUpdate(path = "a", store = :s_init),
                  R.StoreWithoutUpdate(path = "a", store = :x_init),
                  R.ClassMixed(path = "a", declarations = [:m_init])]
println(sprint(showerror, R.DiagnosticError(ds)))
p("018 kinds", R.kinds(R.DiagnosticError(ds)))

# CV1-026/027: _seconds on nested Dual
using ForwardDiff
d1 = ForwardDiff.Dual{:a}(1.5, 1.0)
d2 = ForwardDiff.Dual{:b}(d1, 2.0)
p("027 _seconds nested", (R._seconds(d2), typeof(R._seconds(d2))))
for K in (:ChatteringBudget, :FiringBudget, :StepFloor, :DebtReanchor, :DeviceJoinTimeout,
          :NonfiniteState, :StepError, :CheckpointMidFrame)
    T = getfield(R, K)
    p("026 $K.t", fieldtype(T, :t))
end

# CV1-034/057: StepError rendering by host and interrupt
cf = R.CursorFrame("plant", :x_deriv, :integrate, 2)
p("057 four-field attempt", cf.attempt)
p("057 phase attempt 1", R._phase_text(R.CursorFrame("plant", :x_deriv, :integrate, 2, 1)))
p("057 phase attempt 3", R._phase_text(R.CursorFrame("plant", :x_deriv, :integrate, 2, 3)))
p("057 phase round attempt 3", R._phase_text(R.CursorFrame("plant", :x_deriv, :round, 2, 3)))
for host in (:boundary_zero, :overlay, :restore, :loop), cause in (ErrorException("boom"), InterruptException())
    println("--- 034 host=$host cause=$(typeof(cause))")
    println(sprint(showerror, R.StepError(cf, 0.25, 3, host, cause)))
end

# CV1-047: PathResolution
model = feedback_model()
e = tryshow(() -> resolve(model, "sum/a"))
d = R.diagnostic(e); p("047 resolve sum/a", (d.reason, d.level, d.segment, d.tail, d.owner))
e = tryshow(() -> resolve_terminal(model, "sum/a/b"))
d = e isa R.DiagnosticError ? R.diagnostic(e) : e; p("047 terminal sum/a/b", d isa R.Diagnostic ? (d.reason, d.level, d.tail) : d)
e = tryshow(() -> resolve(model, ""))
p("047 empty", R.diagnostic(e).reason)
p("047 fields", fieldnames(R.PathResolution))

# CV1-060/085/088/107/114/117/129/150 payload fields
for K in (:ClassMixed, :GuardForm, :UserCodeFraming, :EntryTypeMismatch, :DeviceJoinTimeout,
          :BindingContractMismatch, :UninitializedInputs, :NotAttached, :MalformedDatum, :ArgumentInvalid)
    T = getfield(R, K)
    p("fields $K", collect(zip(fieldnames(T), fieldtypes(T))))
end
p("060 msg", R.message(R.ClassMixed(path = "a", declarations = [:x_init])))
p("085 msg", R.message(R.GuardForm(path = "a", event = :e, observed = Int)))
p("107 msg", R.message(R.EntryTypeMismatch(:u, "x", Float64)))

# CV1-070: EmptyFaceSelection through _warn!, bound and unbound
ws = R.Diagnostic[]
R.with(R.BUILD_WARNINGS => ws) do
    R._passthrough_faces("output_passthrough", "kid", ["a", "b"], (), (), n -> false)
    R._passthrough_faces("output_passthrough", "kid", ["a", "b"], (:a, :b), (), nothing)
end
p("070 warnings", [(typeof(w), w.selector, w.names, w.candidates) for w in ws])
p("070 severity", R.severity(ws[1]))
p("070 only reachable?", tryshow(() -> R._passthrough_faces("x", "kid", ["a"], (), (:a,), nothing)))

# CV1-102/104/105
p("102 MalformedDatum(\"s\")", R.MalformedDatum("s"))
p("102 methods", methods(R.MalformedDatum))
p("105 KINDS", R.KINDS)

# CV1-139/140/147
e = tryshow(() -> R.TableBinding(a = 1, b = (deadzone = 0.1,), c = (face = 3,), d = (face = "x", deadzone = 1.5, expo = 2.0)))
p("139 table reasons", [(x.reason, x.entry) for x in R.diagnostics(e)])
for x in R.diagnostics(e); println("   ", R.message(x)); end
println("   ", R.message(R.ArgumentInvalid(call = :step!, reason = :both_given)))
println("   ", R.message(R.ArgumentInvalid(call = :live!, reason = :not_replaying)))
e = tryshow(() -> R.BS3(-1.0, Inf))
p("147 BS3", [(x.call, x.reason, x.argument, x.value) for x in R.diagnostics(e)])
println(sprint(showerror, e))

# CV1-124: CHECKPOINT_ORIGIN
p("124", R.CHECKPOINT_ORIGIN)
end
