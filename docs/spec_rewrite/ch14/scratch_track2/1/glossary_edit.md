## 1. B74c glossary `#g-design_world` (`docs/design/spec.md`, commit 1)

Old:

```markdown
<a id="g-design_world"></a>**`design_world`** — the shipped thin world (aircraft +
`SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`) that mounts an
aircraft for trim and linearization. "Aircraft as root" is the shallowest
world, not a special case ([§14.9][s14-9]).
```

New:

```markdown
<a id="g-design_world"></a>**`design_world`** — the rig this design records for design-time
work, aircraft + `SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`,
which mounts an aircraft for trim and linearization. `SimpleAtmosphere` and
`NoWind` are FlightPhysics' atmosphere types. "Aircraft as root" is the
shallowest world, not a special case ([§14.9][s14-9]).
```

