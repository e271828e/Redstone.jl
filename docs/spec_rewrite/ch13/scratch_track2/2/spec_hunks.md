### S1. D-408, §13.6, the abnormal-path bold

Old:

```
to final, and rejoins the ordinary tail** ([D-030][d-030]). The protocol becomes one tail
with two entry points. Graceful entry follows a *completed* final boundary, and
abnormal entry follows a *discarded* one. Everything downstream of "final
```

New:

```
to final, and rejoins the ordinary tail** ([D-030][d-030], [D-408][d-408]). The protocol becomes one
tail with two entry points. Graceful entry follows a *completed* final boundary,
and abnormal entry follows a *discarded* one. Everything downstream of "final
```

### S2. D-409, §13.5, the inspection doctrine

Old:

```
a line [D-316][d-316] narrows. Inspection is human-facing, has no effect on run
```

New:

```
a line [D-316][d-316] narrows ([D-409][d-409]). Inspection is human-facing, has no effect on run
```

### S3. D-413, §13.5, ignored requests

Old:

```
validity broke even on a run that continued ([D-316][d-316]). Two uses share
```

New:

```
validity broke even on a run that continued ([D-316][d-316], [D-413][d-413]). Two uses share
```

### S4. D-410, §13.5, post-terminal dynamics

Old:

```
have well-defined terminal states, which is better modeling ([D-060][d-060]).
```

New:

```
have well-defined terminal states, which is better modeling ([D-060][d-060], [D-410][d-410]).
```

### S5. D-414, §13.5, the `t_end` range

Old:

```
`ArgumentInvalid`, refused before the ignore list is read.
```

New:

```
`ArgumentInvalid`, refused before the ignore list is read ([D-414][d-414]).
```

### S6. D-414, §13.5, the entry check

Old:

```
first frame. After `init!` that snapshot is boundary zero's, so an authored
[condition](#g-condition) (the path-addressed sparse overlay that sets a build's state) already
terminal ends the run at `t₀` with that snapshot final, integrating nothing. A
run that starts later ends where it started, advancing no frame.
```

New:

```
first frame ([D-414][d-414]). After `init!` that snapshot is boundary zero's, so an
authored [condition](#g-condition) (the path-addressed sparse overlay that sets a build's state)
already terminal ends the run at `t₀` with that snapshot final, integrating
nothing. A run that starts later ends where it started, advancing no frame.
```

### S7. D-108 (B51, lesson 42), §13.6, the refusal of an errored simulation

Old:

```
errored simulation outright (`ServiceLifecycle`, [§14][s14]). Operations on the [roster](#g-roster)
(the list of attached device entries) refuse it with them ([§11.3][s11-3], [D-232][d-232]).
```

New:

```
errored simulation outright (`ServiceLifecycle`, [§14][s14], [D-108][d-108]). Operations on the
[roster](#g-roster) (the list of attached device entries) refuse it with them ([§11.3][s11-3], [D-232][d-232]).
```

### S8. D-369 (B56, lesson 42), §13.2, the stream surfacing through the status

Old:

```
each snapshot carries beside the signal table) ([§11.2][s11-2]). The liveness heartbeat
([§12.2][s12-2]) rides in the same diagnostic cells, and the pacer's record ([§10.7][s10-7]) sits
beside the writers' records in the status. The stream is never collected, since
there is no collection to join. Nothing in the argument of [D-084][d-084] applies to it.
That decision is about what the *build* warns on.
```

New:

```
each snapshot carries beside the signal table) ([§11.2][s11-2], [D-369][d-369]). The liveness
heartbeat ([§12.2][s12-2]) rides in the same diagnostic cells, and the pacer's record
([§10.7][s10-7]) sits beside the writers' records in the status. The stream is never
collected, since there is no collection to join. Nothing in the argument of
[D-084][d-084] applies to it. That decision is about what the *build* warns on.
```

### S9. D-412, §13.7, the pin generalization

Old:

```
each declares its `out` pinned ([D-312][d-312]).
```

New:

```
each declares its `out` pinned ([D-312][d-312], [D-412][d-412]).
```

### S10. D-411, §13.7, the two uses of `Constant`

Old:

```
Two uses need `Constant` ([D-143][d-143]), though a listed block needs none to be built
([D-313][d-313]). The zero-contributor configurations ([§6.2][s6-2]) are one. There, a required
aggregate input has no physical contributor, and the zero total must be spelled
as a wire. The rig stub below is the other. The block's value is instance data,
like junction arity, not an overridable default ([D-143][d-143]). A configuration wanting
an externally settable source uses a root input ([§11.3][s11-3]), which keeps the block
from drifting into a back-door input default. A handle that references bulk data
never surfaces as a root input ([D-237][d-237]); a rig holds such a handle through a
[constant source](#g-constant-source) (a `Constant`, publishing the value its instance holds) instead
([§14.9][s14-9], [D-364][d-364]).
```

New:

```
Two uses need `Constant` ([D-143][d-143], [D-411][d-411]), though a listed block needs none to be
built ([D-313][d-313]). The zero-contributor configurations ([§6.2][s6-2]) are one. There, a
required aggregate input has no physical contributor, and the zero total must be
spelled as a wire. The rig stub below is the other. The block's value is
instance data, like junction arity, not an overridable default ([D-143][d-143]). A
configuration wanting an externally settable source uses a root input ([§11.3][s11-3]),
which keeps the block from drifting into a back-door input default. A handle
that references bulk data never surfaces as a root input ([D-237][d-237]); a rig holds
such a handle through a [constant source](#g-constant-source) (a `Constant`, publishing the value its
instance holds) instead ([§14.9][s14-9], [D-364][d-364]).
```

### S11. D-411, §13.7, the first shipped instance

Old:

```
makes it the source block's first shipped instance ([D-143][d-143]). Bespoke
```

New:

```
makes it the source block's first shipped instance ([D-143][d-143], [D-411][d-411]). Bespoke
```
