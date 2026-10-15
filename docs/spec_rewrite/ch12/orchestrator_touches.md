# Orchestrator touches, chapter 12

## O-1 (unit B, step (5)), from final_verify_1.md's one finding

B15 dropped "the tail's own owner". Restored, with D-256 beside §12.1.

Old:

```
5. Join under the `join_timeout` cap. It is a keyword of the `Simulation`
   constructor, held on `Control` ([§12.1][s12-1]), a positive real in seconds of wall
   clock, defaulting to 5 ([Appendix B][sB]). The constructor refuses any other value
   as `ArgumentInvalid`. A device task exceeding the cap is reported *by name*
   in a `DeviceJoinTimeout` diagnostic ([Appendix C][sC]). It is then abandoned rather
   than left to hang `run!`.
```

New:

```
5. Join under the `join_timeout` cap. It is a keyword of the `Simulation`
   constructor, held on `Control`, the tail's own owner ([§12.1][s12-1],
   [D-256][d-256]), a positive real in seconds of wall clock, defaulting to 5
   ([Appendix B][sB]). The constructor refuses any other value as
   `ArgumentInvalid`. A device task exceeding the cap is reported *by name* in
   a `DeviceJoinTimeout` diagnostic ([Appendix C][sC]). It is then abandoned
   rather than left to hang `run!`.
```

`claims.md`: the two B15 claims' `new` spans take the clause, and the second's
`newcites` adds D-256. All four checkers pass.

O-1, second part: the item (step (5), unit B lines 49–60) rewrapped at 80
rendered columns, link markup collapsed, as `final_verify_1.md`'s Re-check
section gives it. Text unchanged, whitespace only; checked by script.
