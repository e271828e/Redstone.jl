# What sets the phugoid's frequency on the longitudinal aircraft. A standalone probe: the
# page's equations of motion, a central-difference Jacobian at the page's rounded trim, and
# the slow and fast pairs with the pitch damping removed and with drag frozen in speed.
# Run with `julia --startup-file=no probe_phugoid.jl`; it needs no project.
using LinearAlgebra
const g = 9.81
p0 = (m = 1000.0, S = 16.0, c̄ = 1.5, Iyy = 1800.0, T_max = 2500.0, ρ = 1.225,
      CL0 = 0.3, CLα = 5.0, CD0 = 0.03, k = 0.05, Cm0 = 0.05, Cmα = -1.0, Cmq = -12.0, Cmδe = -1.2)
function f(p, x, u; dragV = true)
    V, γ, θ, q = x
    α = θ - γ
    q̄ = 0.5 * p.ρ * V^2
    q̄D = dragV ? q̄ : 0.5 * p.ρ * 50.0^2      # drag frozen at the trim speed when dragV = false
    CL = p.CL0 + p.CLα * α
    Cm = p.Cm0 + p.Cmα * α + p.Cmq * q * p.c̄ / (2V) + p.Cmδe * u[1]
    T = u[2] * p.T_max
    [(T * cos(α) - q̄D * p.S * (p.CD0 + p.k * CL^2)) / p.m - g * sin(γ),
     (q̄ * p.S * CL + T * sin(α)) / (p.m * V) - g * cos(γ) / V,
     q,
     q̄ * p.S * p.c̄ * Cm / p.Iyy]
end
function modes(p; kw...)
    x0 = [50.0, 0.0, 0.019930, 0.0]; u0 = [0.025058, 0.37234]
    A = zeros(4, 4)
    for j in 1:4
        h = 1e-6; e = zeros(4); e[j] = h
        A[:, j] = (f(p, x0 + e, u0; kw...) - f(p, x0 - e, u0; kw...)) / 2h
    end
    λ = filter(z -> imag(z) > 0, eigvals(A))
    slow = λ[argmin(abs.(λ))]; fast = λ[argmax(abs.(λ))]
    (ω_ph = round(abs(slow), digits = 4), T_ph = round(2π / imag(slow), digits = 2), ζ_ph = round(-real(slow) / abs(slow), digits = 4),
     ω_sp = round(abs(fast), digits = 3))
end
println("Lanchester      ", (ω = round(sqrt(2) * g / 50, digits = 4), T = round(2π / (sqrt(2) * g / 50), digits = 2)))
println("full model      ", modes(p0))
println("Cmq = 0         ", modes(merge(p0, (Cmq = 0.0,))))
println("drag frozen in V", modes(p0; dragV = false))
println("Cmq = 0 & frozen", modes(merge(p0, (Cmq = 0.0,)); dragV = false))
Mα = 0.5 * 1.225 * 2500 * 16 * 1.5 * -1.0 / 1800
println("factor sqrt(-Mα)/ω_sp = ", round(sqrt(-Mα) / modes(p0).ω_sp, digits = 4), ", times Lanchester ω = ", round(sqrt(-Mα) / modes(p0).ω_sp * sqrt(2) * g / 50, digits = 4))
