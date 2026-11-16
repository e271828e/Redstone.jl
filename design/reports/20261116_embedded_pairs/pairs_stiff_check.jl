# Direct check of the step-control stability figures: the scalar test equation
# y′ = λy under each pair's R and E, with the real accept/reject rule.
# Elementary: factor = 0.9·err^(-1/p). PI: 0.9·err^(-0.7/p)·mem^(0.4/p).
using Printf
pairs = (
    ("BS3",         z -> 1 + z + z^2/2 + z^3/6,          z -> -z^3/48 - z^4/48, 3),
    ("three-stage", z -> 1 + z + z^2/2 + z^3/6,          z -> 3z^3/4,           3),
    ("three, s=1/26", z -> 1 + z + z^2/2 + z^3/6,        z -> 3z^3/4/26,        3),
    ("Zonneveld",   z -> 1 + z + z^2/2 + z^3/6 + z^4/24, z -> -z^4/24 - z^5/24, 4),
)
function run(R, E, p; pi, λ = -1000.0, tol = 1e-6, n = 4000)
    y, h, mem = 1.0, 1e-4, 0.0
    zs = Float64[]; rejected = 0; accepted = 0
    while accepted < n
        z = h * λ
        err = abs(E(z) * y) / tol
        if err > 1
            rejected += 1
            h *= max(0.2, 0.9 * err^(-1 / p))
            continue
        end
        f = (pi && mem != 0.0) ? 0.9 * err^(-0.7 / p) * mem^(0.4 / p) : 0.9 * err^(-1 / p)
        y *= R(z); accepted += 1
        accepted > n - 1000 && push!(zs, -z)
        mem = max(err, 1e-4)
        h *= clamp(f, 0.2, 10.0)
    end
    (extrema(zs)..., rejected)
end
for (name, R, E, p) in pairs, pi in (false, true)
    lo, hi, rej = run(R, E, p; pi)
    @printf("%-14s %-10s  -hλ over the last 1000 steps in [%.3f, %.3f], rejected %d of 4000\n",
        name, pi ? "PI" : "elementary", lo, hi, rej)
end
