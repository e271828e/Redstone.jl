<!-- For docs/design/companions/migration_outline.md: a paragraph below the table, after "The state-declaration conversion", expanding the row "Residual: the C172 AD audit for trim". Ruling R15 of chapter 14's rewrite moves it out of spec §14.8. -->

**The C172 AD audit for trim.** [§14.8][s14-8] keeps the audit's guidance on
Interpolations tables and in-model saturations. Its two other findings are
facts about Flight.jl's Cessna 172 model (`c172.jl`). The landing gear is
never evaluated off-zero airborne. The `norm`-at-zero guards are already in
place.
