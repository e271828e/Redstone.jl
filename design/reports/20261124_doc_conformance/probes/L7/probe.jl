# L7 probes: D-076, D-092, D-161 (log.md), run against the pinned worktree.
using Redstone
const R = Redstone
println("L1 family: ", R.DECLARATION_FAMILY)
for n in (:input_types, :output_types, :local_types, :init_x, :init_s, :init_m,
          :workspace, :init_workspace, :ws_init, :u_types, :y_types,
          :x_init, :s_init, :m_init)
    println("L2 isdefined ", n, " = ", isdefined(R, n))
end
# severity values over every concrete Diagnostic subtype
function leaves(T)
    out = Any[]
    for S in subtypes(T)
        isabstracttype(S) ? append!(out, leaves(S)) : push!(out, S)
    end
    out
end
using InteractiveUtils
sevs = Set{Symbol}()
for K in leaves(R.Diagnostic)
    ms = methods(R.severity, (K,))
    m = first(ms)
    # read the return of the most specific method without constructing an instance
    src = Base.uncompressed_ir(m)
    push!(sevs, Symbol(string(src.code[end])))
end
println("L3 severity method returns: ", sevs)
println("L4 severity method count: ", length(methods(R.severity)))
for n in (:loop, :run!, :trace, :latest, :binding, :phase_bodies, :interactive,
          :needs_calling_task, :get_state, :get_output, :get_input)
    println("L5 isdefined ", n, " = ", isdefined(R, n))
end
println("L6 init! kwargs: ", Base.kwarg_decl(first(methods(R.init!))))
println("L7 loop methods: ", methods(R.loop))
