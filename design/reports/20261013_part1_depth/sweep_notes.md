# Orchestrator's sweep notes

Citations outside the rostered docs that the stages leave for the orchestrator.

## From stage 1

- `test/fixtures.jl:1271`: "§4.4's value-level constructor" → §8.2.
- `test/fixtures.jl:1258`: resource loading → §8.2, allocation-free rebuild → §9.7.
- `test/test_store.jl:187,219`: handle cell store and struct copy → §9.7.
- `src/diagnostics.jl:951`: `ProducedByTwoStages` "§4.3, §8.3" → §8.3.
- `src/diagnostics.jl:821`: `handle_at_root` cites "§4.3, §9.3, D-237" for no synthesis → §8.2. Its remedy should name the constant source (D-364).
- `test/test_build.jl:1376`: "no synthesis at a root (§4.3, D-243)" → §8.2.
- Loose but fine: `src/diagnostics.jl:797`, `test/test_build.jl:840`, `test/test_events.jl:116`.
- `tools/gloss_table.md` lines 62 and 263: value-level constructor recorded under §4.4 / §14.1.

## From stage 2

Done by the orchestrator: `implementation.md` and `pending.md`, §5.6 → §13.8
and §7.5 → §9.8, with `pending.md`'s quoted-diagnostics bullet → (§13.2, §13.8)
and its skip-or-summarize line → §11.2.

By rule, §5.6 → §13.8 and §7.5 → §9.8: `src/diagnostics.jl:890`,
`test/test_diagnostics.jl:945`, `test/test_build.jl:161,218`,
`test/test_blocks.jl:1741`, `test/fixtures.jl:892`.

Per line:
- `src/build.jl:856` marker scalar (§6.1, §9.1) → (§8.2, §9.1).
- `src/build.jl:1044` declaration by allocation (§7.3) → §8.2.
- `src/declare.jl:224` manifold projection (§5.2) → §8.2.
- `src/declare.jl:44` declaration is allocation (§7.3) → §8.2.
- `src/leaves.jl:348` abstract-entry lift (§6.1, D-236) → §8.2.
- `src/blocks.jl:15` the junction (§6.2, D-311) → §13.7.
- `src/diagnostics.jl:313` `UnknownPort` "§6.1, §8.4 w1" → Appendix C, §8.4 w1.
- `src/diagnostics.jl:920` the ladder's two exits (§5.4) → §13.8.
- `src/assembly.jl:959,979` obligation model (§6.1) → add §9.1.
- `test/test_leaves.jl:304,317` abstract arm (§6.1) → §8.2.
- `test/test_diagnostics.jl:923` walk clause hint (§6.1, §8.2) → §8.2.
- `test/test_build.jl:567` "§6.1's failure asymmetry" → §8.2.
- `test/test_build.jl:681` → (§8.2, D-236).
- `test/test_build.jl:1204` → §13.2.
- `test/test_build.jl:1228` bundle's own type (§5.2) → §13.2.
- `test/test_build.jl:1693` discrete allocator (§7.3) → §8.2.
- `test/test_blocks.jl:414,449` (§6.2, D-311) → §13.7.
- `test/test_blocks.jl:438` (§6.2, §6.1) → (§13.7, §6.1).
- `test/fixtures.jl:231` "§7.3's blessed idiom" → §8.2.
- `test/test_assembly.jl:751` obligation model → add §9.1.
- `tools/gloss_table.md` rows 259, 261, 297, 312 (§7.5 → §9.8), 279 (§5.6 → §13.8), and the blessed and workspace rows (§7.3 → §8.2).
- `pending.md:142` "§7.1's FlightCore-era names": the bullet now lives in `flight_case_studies.md` section 1; retarget or close.
