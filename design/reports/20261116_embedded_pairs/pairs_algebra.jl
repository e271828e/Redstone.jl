# Exact algebra of three embedded Runge–Kutta pairs: order conditions, the
# estimate's error terms and the stability polynomials. Rational arithmetic
# throughout; floats only for the printed norms and the stability limits.
using LinearAlgebra, Printf

# ── Rooted trees ────────────────────────────────────────────────────────────
struct Tree
    ch::Vector{Tree}
end
order(t::Tree) = 1 + sum(order, t.ch; init = 0)
key(t::Tree) = "[" * join(sort!(key.(t.ch))) * "]"

# Multisets of trees from L[1:maxi] with total order m.
function forests(m, L, maxi)
    m == 0 && return [Tree[]]
    out = Vector{Vector{Tree}}()
    for i in 1:maxi
        o = order(L[i])
        o > m && continue
        for f in forests(m - o, L, i)
            push!(out, [L[i]; f])
        end
    end
    out
end
function trees_through(n)
    T = [[Tree(Tree[])]]
    for q in 2:n
        L = reduce(vcat, T)
        push!(T, [Tree(f) for f in forests(q - 1, L, length(L))])
    end
    T
end

γ(t::Tree) = order(t) * prod(γ, t.ch; init = 1)
function σ(t::Tree)
    groups = Dict{String,Tuple{Tree,Int}}()
    for c in t.ch
        k = key(c)
        groups[k] = (c, get(groups, k, (c, 0))[2] + 1)
    end
    prod(factorial(m) * σ(c)^m for (c, m) in values(groups); init = 1)
end
# The vector of stage weights Φᵢ(t).
Φ(t::Tree, A) = isempty(t.ch) ? ones(Rational{BigInt}, size(A, 1)) :
                reduce((u, v) -> u .* v, [A * Φ(c, A) for c in t.ch])

# ── The pairs ───────────────────────────────────────────────────────────────
R(x) = Rational{BigInt}(x)
struct Pair
    name::String
    A::Matrix{Rational{BigInt}}
    b::Vector{Rational{BigInt}}     # the advancing solution
    e::Vector{Rational{BigInt}}     # the estimate, h·Σ eᵢkᵢ
    p::Int                          # claimed order of b
end

# BS3 as shipped: four stages, the fourth at the step's end.
bs3 = Pair("BS3 3(2), four stages",
    R.([0 0 0 0; 1//2 0 0 0; 0 3//4 0 0; 2//9 1//3 4//9 0]),
    R.([2 // 9, 1 // 3, 4 // 9, 0]),
    R.([-5 // 72, 1 // 12, 1 // 9, -1 // 8]), 3)

# The three-stage pair on BS3's first three stages; scale s = 1.
three = Pair("Three-stage 3(2)",
    R.([0 0 0; 1//2 0 0; 0 3//4 0]),
    R.([2 // 9, 1 // 3, 4 // 9]),
    R.([1, -3, 2]), 3)

# Zonneveld 4(3), tableau recalled from memory: RK4 plus a stage at 3/4.
zb = R.([1 // 6, 1 // 3, 1 // 3, 1 // 6, 0])
zb̂ = R.([-1 // 2, 7 // 3, 7 // 3, 13 // 6, -16 // 3])
zonn = Pair("Zonneveld 4(3)",
    R.([0 0 0 0 0; 1//2 0 0 0 0; 0 1//2 0 0 0; 0 0 1 0 0; 5//32 7//32 13//32 -1//32 0]),
    zb, zb .- zb̂, 4)

# ── The analysis ────────────────────────────────────────────────────────────
const T = trees_through(6)
@assert length.(T) == [1, 1, 2, 4, 9, 20]

# Error coefficient of the solution and coefficient of the estimate, per tree.
τ(b, A, t) = (dot(b, Φ(t, A)) - 1 // γ(t)) / σ(t)
ε(e, A, t) = dot(e, Φ(t, A)) / σ(t)
nrm(v) = sqrt(Float64(sum(abs2, v)))

# Stability polynomial coefficients: Σ zᵏ wᵀAᵏ⁻¹1, k = 1…s (constant term apart).
function polycoeffs(w, A)
    s = size(A, 1)
    v = ones(Rational{BigInt}, s)
    out = Rational{BigInt}[]
    for _ in 1:s
        push!(out, dot(w, v))
        v = A * v
    end
    out
end
evalpoly1(c0, cs, z) = c0 + sum(Float64(cs[k]) * z^k for k in eachindex(cs))
devalz(cs, z) = sum(k * Float64(cs[k]) * z^k for k in eachindex(cs))      # z·P′(z)

# The largest x with |R(-x′)| ≤ 1 on all of [0, x], and the same on the imaginary axis.
function limit(f)
    x = 0.0
    step = 1e-4
    while x < 50 && f(x + step) <= 1 + 1e-12
        x += step
    end
    x
end

function analyse(pr::Pair)
    (; name, A, b, e, p) = pr
    println("\n══ ", name, " ══")
    c = A * ones(Rational{BigInt}, size(A, 1))
    println("c = ", c, "   Σe = ", sum(e), "   Σ|e| = ", Float64(sum(abs, e)))

    # 1. The solution's order: every τ through p vanishes, some τ at p+1 does not.
    for q in 1:p
        @assert all(iszero(τ(b, A, t)) for t in T[q]) "solution fails order $q"
    end
    τnext = [τ(b, A, t) for t in T[p+1]]
    @assert any(!iszero, τnext)
    println("solution: order ", p, " exactly;  A(", p + 1, ") = ‖τ‖₂ = ", @sprintf("%.4e", nrm(τnext)))

    # 2. The estimate cancels every term below order p …
    for q in 1:p-1
        @assert all(iszero(ε(e, A, t)) for t in T[q]) "estimate has a term of order $q"
    end
    # 3. … and sees every term of order p.
    lead = [ε(e, A, t) for t in T[p]]
    println("estimate, order-", p, " terms per tree (", length(lead), "): ", lead)
    println("  blind to ", count(iszero, lead), " of ", length(lead), " trees;  ‖lead‖₂ = ",
        @sprintf("%.4e", nrm(lead)))
    nxt = [ε(e, A, t) for t in T[p+1]]
    nxt2 = [ε(e, A, t) for t in T[p+2]]
    println("  next terms: ‖order ", p + 1, "‖/‖lead‖ = ", @sprintf("%.3f", nrm(nxt) / nrm(lead)),
        ";  ‖order ", p + 2, "‖/‖lead‖ = ", @sprintf("%.3f", nrm(nxt2) / nrm(lead)))
    # The step at which the estimate's leading term equals the solution's true
    # leading local error, in units where the elementary differentials are 1.
    println("  ‖lead‖/A(", p + 1, ") = ", @sprintf("%.3f", nrm(lead) / nrm(τnext)),
        "  (scale-dependent: the estimate's margin over the true error, times h)")

    # 4. Stability.
    rc = polycoeffs(b, A)
    ec = polycoeffs(e, A)
    println("R(z) = 1 + ", join(["($(rc[k]))z^$k" for k in eachindex(rc) if !iszero(rc[k])], " + "))
    println("E(z) = ", join(["($(ec[k]))z^$k" for k in eachindex(ec) if !iszero(ec[k])], " + "))
    xr = limit(x -> abs(evalpoly1(1.0, rc, complex(-x))))
    xi = limit(y -> abs(evalpoly1(1.0, rc, complex(0.0, y))))
    @printf("stability limits: real axis %.3f, imaginary axis %.3f\n", xr, xi)

    # Step-size control on a stiff mode (Hall's analysis): at the real-axis
    # limit z, u = Re(zR′/R), v = Re(zE′/E), exponent 1/p.
    z = complex(-xr)
    u = real(devalz(rc, z) / evalpoly1(1.0, rc, z))
    v = real(devalz(ec, z) / evalpoly1(0.0, ec, z))
    C = [1 u; -1/p 1-v/p]
    β1, β2 = 0.7 / p, 0.4 / p
    M = [1 u 0; -β1 1-β1*v β2; 1 v 0]
    @printf("  at z = %.3f: |E(z)| = %.4f, u = %.3f, v = %.3f\n", -xr, abs(evalpoly1(0.0, ec, z)), u, v)
    @printf("  spectral radius, elementary controller %.3f, PI controller %.3f (< 1 is stable)\n",
        maximum(abs, eigvals(C)), maximum(abs, eigvals(M)))
end

# Sanity: classical RK4's A(5) is the textbook 1.45e-2.
rk4τ = [τ(zonn.b, zonn.A, t) for t in T[5]]
@printf("check: RK4 A(5) = %.4e (textbook 1.45e-2)\n", nrm(rk4τ))

foreach(analyse, (bs3, three, zonn))

# Zonneveld's embedded solution on its own: order 3 exactly?
let (; A) = zonn
    for q in 1:3
        @assert all(iszero(τ(zb̂, A, t)) for t in T[q])
    end
    println("\nZonneveld's embedded b̂: order 3 conditions hold; order-4 τ̂ = ", [τ(zb̂, A, t) for t in T[4]])
end
