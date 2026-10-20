# Unit B1, cold verification

Phase 1 split 198 items into 137 sub-assertions, appended to `verify_phase1.md`.
`check_unit.py appB check B1` gives `checks failed: 0`.

## Counts

- Inventory claims: 208. MATCH 208 (M 82, F 71, R 43, C 10, X 2). DRIFT 0. LOST 0.
- ADDED: 8 declared additions plus the R-ruled new glosses. Over-claiming: 0.
- Signature findings: 1, plus 1 reader-cold type.
- Citation findings: 3, all weak carriers. No citation was lost.
- Bold: 0 spans. Labels: four `####` labels, as R4 asks.
- Inbound findings: 0 for B1. Frozen 14108 is still unmet, as ruled (carried to Appendix C).

## M claims, three notes (all still MATCH)

- C-141. The kept clock and priors are stated for `overlay!(sim)`. The model form inherits them through "is the model's form" (homes 9634).
- C-147. The cited span covers `trim!` only. Appendix C's `ArgumentInvalid` entry (homes 13755) holds `trim!` and `linearize` together.
- C-177. "Normalization shim" is missing from the cited span. §11.4 holds it at homes 7577 ("attach-compiled shim", D-104).

## ADDED

Each addition checked against its source: §8.5/D-039 (`AbstractComponent`), §10.5/D-185 (sample-time entries), `src/model.jl:8–32` (composed `Model` forms), `src/sim.jl:2358–2360` and `src/dataplane.jl:469` (`Simulation` and snapshot reads), `src/devices.jl:105–114` with §11.6 ("request shutdown") for `stop!(handle)`, §10.2 frozen 5613 (`RK4`, `Heun`), and §11.6 frozen 7882 for `attach!`'s return. None claims more than its source.

## Signatures

All match `<S>/frozen_tree/src/` or a recorded ruling (`world`, `device`, `h`/`N_base`). Findings:

1. `Relative(K, φ = 0)` follows `src/declare.jl:166`. §10.5 and D-185 spell `Φ`, and the coordinator ruled "the spec's spellings stay" for positional names. B1 also writes `(D, Φ, Δt)` two entries later. Fix: `Relative(K, Φ = 0)`, or rule φ an exception.
2. Positional names where B keeps the spec's spelling over `src`'s: `input_faces(c)` (src `comp`, §13.3 `c`) and `linearize(model, taps; …)` (src `tap_set`, §14 `taps`). Both are consistent with the ruling. Recorded, no fix.

## Citations

1. C-132, "At a status other than `:consistent` it is `ServiceLifecycle` (§14)". §14 (frozen 11393) gives the legal status but not the kind. D-319's Position names `ServiceLifecycle`. Fix: cite "(§14, D-319)".
2. C-117, D-317 on "entry point into `:consistent`". D-317 carries this only by implication ("written only by the model's own doors"). `src/model.jl` states it outright. Acceptable. Optional fix: add §12.6.
3. C-160, D-317 on the convenience forms' keywords. D-317 carries this only through "compose through a `Float64` model". `src/sim.jl:145–150` lists the keywords. Acceptable.

Every replaced or added citation listed in `rulings.md` was read in the frozen log. Each field carries its claim. D-319 and D-268 are Rationale-only, as the rulings say.

## Inbound (R2, B1's share)

5626 (`algorithm` row, "bound against the state buffer"), 6043 (the Deployment table), 7810 (the `Deployment` entry), 8969 (`join_timeout` 5.0), 9369 (four recording keywords, with `overlay!`) and 14870 (the `Model` block, under "`Model`'s own entry points") all still find their content in B1. 14108 is carried to Appendix C's pass.

## Reader-cold names

- `DeviceHandle` appears only in `attach!`'s return. The frozen spec never names it. Fix: "The device handle, `DeviceHandle`. One type, …".

## Proposals awaiting the owner (rulings.md, "Still proposed")

Each one checked against the frozen spec. All five hold:

- Stages vs update laws: §5.2 frozen 1040 gives each leaf exactly two output stages.
- `running(handle)`: the obligation is at §11.6 frozen 8024.
- `pending(handle, slot)`: it belongs to the panel kit, §11.7 frozen 8393–8398.
- Assembly parenthetical: §8.5 frozen 3204–3206 gives the default `nothing` to `transparent_container` alone. Moving "mandatory" to M makes the ambiguity worse.
- `stop_reason`: it is owned at §8.2 frozen 2913 (D-316). §13.5 frozen 10677 cites back to §8.2.
