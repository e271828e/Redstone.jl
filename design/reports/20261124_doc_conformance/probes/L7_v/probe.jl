using Redstone, InteractiveUtils
const R = Redstone
for s in (:input_types, :output_types, :local_types, :u_types, :y_types,
          :init_x, :init_s, :init_m, :init_z, :x_init, :s_init, :m_init,
          :workspace, :init_workspace, :ws_init,
          :run!, :loop, :binding, :trace, :interactive, :needs_calling_task)
    println(rpad(s, 20), " defined=", isdefined(R, s))
end
function allsub(T)
    out = Any[]
    for S in subtypes(T)
        isabstracttype(S) ? append!(out, allsub(S)) : push!(out, S)
    end
    out
end
using InteractiveUtils
kinds = allsub(R.Diagnostic)
sev = Dict{Symbol,Int}()
# severity is a constant per kind method; read the returned literal through code_typed
for K in kinds
    st = code_lowered(R.severity, Tuple{K})[1].code[end]
    v = st isa Core.ReturnNode ? (st.val isa QuoteNode ? st.val.value : st.val) : st
    sev[v] = get(sev, v, 0) + 1
end
println("kinds: ", length(kinds), "  severity values: ", sev)
println("run! methods: ", length(methods(R.run!)), "  trace(sim) methods: ", methods(R.trace))
println("init! has trace kw: ", [(:trace in Base.kwarg_decl(m)) for m in methods(R.init!)])
println("binding methods: ", methods(R.binding))
