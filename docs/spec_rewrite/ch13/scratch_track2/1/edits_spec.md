### 1. F54 — `docs/design/spec.md`

Old:

```
[§12.6][s12-6], [§12.7][s12-7], [§14.7][s14-7]). Error · service, or build in a `sample_times`
```

New:

```
[§12.6][s12-6], [§12.7][s12-7], §13.5, [§14.7][s14-7]). Error · service, or build in a `sample_times`
```

### 2. R12 glossary entry — `docs/design/spec.md`

Old:

```
[Appendix C][sC]). Severity is the kind's, not the payload's.

<a id="g-species">
```

New:

```
[Appendix C][sC]). Severity is the kind's, not the payload's.

<a id="g-requester-roster"></a>**requester roster** — the build's list of stop
requests, one `Requester(path, port, reason)` per `StopFlag` output port, in
build order (§13.5).

<a id="g-species">
```

### 3. R12 first-use link in §13.5 — `docs/design/spec.md`

Old:

```
This list is the requester roster (the build's
```

New:

```
This list is the [requester roster](#g-requester-roster) (the build's
```

### 4. B85 — `docs/design/companions/frame_walkthrough.md`

Old:

```
`init!` and `replay!` run boundary zero through `_host_boundary_zero!`, which
```

New:

```
`init!` runs boundary zero through the `Model`'s `init!`, which
```

