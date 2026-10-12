#### The bundle law: which names a component receives

**Rule.** Under the [bundle law](#g-bundle), a name appears in a component's bundle **iff the
corresponding store or fact exists for that component**.

| bundle field | present iff |
|---|---|
| `x` | the component declares `x_init` (continuous [tier](#g-tier)) |
| `s` | the component declares `s_init` (discrete tier) |
| `m` | the component declares `m_init` |
| `ws` | the component declares `ws_init` |
| `u` | the [function family](#g-function-family) (which bundle fields a given function may legally receive) may see inputs **and** the component declares `u_types` |
| `y` | the component produces any table [cell](#g-cell) at all (it declares `y_types`) |
| `y_x` / `y_s` | stage-1 [ports](#g-port) exist, under the tier's own spelling |
| `t` | always |
| `Δt` | the component is on the discrete tier |

**The stage-1 hand-down carries the stage-1 *return*.** `y_x`, or `y_s` on the
discrete tier, comes from the stage-1 [probe](#g-probe)'s return ([D-252][d-252]).
[§9.3][s9-3] already sources the rule. A component with no stage-1 [ports](#g-port)
has no `y_x`/`y_s` in its stage-2 bundle at all.

Undeclared stores are *absent*, never `nothing`-filled. Destructuring a field
that does not exist for the component fails at the probe, inside the [§13.2][s13-2]
framing diagnostic. The diagnostic carries [did-you-mean](#g-did-you-mean) (the offending name plus
the list-in-hand it should have matched) against the legal field set. An example
is "`x_deriv` of `Foo` destructures `m`, but `Foo` declares no
`m_init`". One law covers tier facts, stage legality and declarations alike.

The mechanism is structured, not textual. Destructuring an absent field throws a
`FieldError` carrying the type and the field name as data (Julia ≥ 1.12). The
probe catches it *matched against the bundle's own NamedTuple type* and
synthesizes the framing diagnostic from the legal set. It classifies the field
as an undeclared store, a wrong-tier fact, or a name illegal for this function
family. No message text is scraped, and the bundle stays a bare NamedTuple
([D-074][d-074]). A getproperty-wrapper spelling is the recorded fallback, should
type-matched interception prove insufficient.

The wrong-tier class covers the state letters too ([D-195][d-195]). `x` and `m` are
continuous-only, and `s` and `Δt` are discrete-only, so destructuring any of the
four on the wrong tier lands in that bucket.

The per-function name sets are **closed**, one set per function per [tier](#g-tier). The
update laws carry their tier in the name, so `x_deriv` and
`s_update` have one set each. The two output stages are shared machinery
over both tiers ([D-220][d-220]), so `y_state` and `y_direct` have one set per
tier. On the continuous tier the sets are `x, m, t [, ws]` and `x, m, u, y_x, t
[, ws]`. On the discrete tier they are `s, t, Δt [, ws]` and `s, u, y_s, t, Δt
[, ws]`. Adding a name to any of them is a decision-log entry, not a
convenience. The comments in the signature block above state each function's
maximal legal set at each tier. A given component's bundle narrows that set to
declared reality, and the destructuring narrows it further to actual reads. That
three-level funnel (stage name at its tier ⊇ bundle ⊇ reads) is worth teaching
once, because a stateless component legitimately writes `y_direct` while
owning neither `x` nor `m`.

#### The stage return law

**Rule.** An output stage returns its port NamedTuple, `y`, and nothing else.

`y` scatters into the component's declared cells as always, and every value a
later function needs is one of those cells ([§8.3][s8-3]). Stages are discovered by
method existence, and stage membership is a partition of the declared ports.

An empty `y = (;)` is a `DeadStage` build error at the probe ([§9.3][s9-3]). A stage
returning nothing at all computes nothing any consumer can read. That is the
inert-component check ([§8.1][s8-1]), applied to a single stage.

#### The handler return law

**Rule.** A handler returns a NamedTuple carrying the stores it writes. A key is
present **iff** the corresponding store exists on the component **and** the
handler updates it.

That is the bundle law's *iff* shape, now governing the return side. A pure FSM
(modes and events, no `x`) returns `(; m = (; phase = running))`. An `x`-only
reset map returns `(; x = (; x..., ω = 0.0))`. A handler touching both returns
both. Padding forms such as `((;), m⁺)` and `(x⁺, (;))` do not exist ([D-090][d-090], on
the argument-side ground of [D-074][d-074]).

The semantics per key are these. When `x` is present, the value is complete
against the state field set. When `m` is present, the names-subset predicate
applies. An unknown key gets did-you-mean against `{x, m}`. This is the same
`FieldError`-shaped machinery [§13.2][s13-2] builds for bundles, now running in both
directions ([§9.5][s9-5]).

