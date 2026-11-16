# Where does the StepFloor at tight tolerance on M1 come from?
include(joinpath(@__DIR__, "kepler.jl"))
for lab in ("A", "B_mid"), tol in (1e-6, 1e-7)
    r = kepler_run(candidate(lab, tol))
    for s in logged(r.sim)
        st = writer_status(s, "loop")
        isempty(st.recent) || println(lab, " ", tol, " snapshot t=", s.t, " ", st.recent)
    end
end
