# Chapter 11, step 5: the chapter pass, half 2

Scope: `chapter_new.md` lines 941–1928 (§11.5 to the end of §11.8, units F
to J), read whole against `chapter_old.md` 803–1612, `brief.md` R1–R32 and
`docs/design/tools/spec_style.md`. Cross-split claims were checked by grep
against `chapter_new.md` 1–940. Bolds were checked against half 1 and the
frozen spec's other chapters. No ruling is bold twice.

Counts: 29 findings, 6 RULING and 23 EDITORIAL.

## RULING

**P2-2.** L1053, unit F. Bit-identity points at the wrong section. "A
header without them could therefore not back the bit-identity claim
([§12.7][s12-7])". The same section cites the law at §2.4 at L949 and
L1099, and survey 2's M53 points the law at §2.4. §12.7 holds the
mechanism. Fix: "…the bit-identity claim ([§2.4][s2-4])". If the replay
mechanism is meant, cite both: "([§2.4][s2-4], [§12.7][s12-7])".

**P2-3.** L1085, unit F. The harness writer's gloss disagrees with D-200.
"(the framework-owned write path of the calling task)" copies the glossary,
but D-200 and R4 say a harness `stage!` runs on any task. §11.3 (L516,
"the one writer whose surface is derived, not claimed") and §11.8 (L1731,
"the framework-owned write path `stage!(sim, …)`") use two other glosses.
That makes three glosses for one term, and one of them is wrong. Fix: use
§11.8's gloss here, and correct the glossary entry (spec L14023) at
landing.

**P2-4.** L1405, unit G2. R10's F51 text uses a reserved word and a
possessive citation. "It is the same kind of reflection check as §8.1's
shadowing check, an `isdefined`/`!==` pair ([§8.1][s8-1])". Bare *kind* is
reserved for the diagnostic kind, which §11.8 links at L1779, and "§8.1's"
is an unlinked possessive citation. Fix: "It is a reflection check like the
shadowing check of [§8.1][s8-1], an `isdefined`/`!==` pair."

**P2-5.** L1146 and L1169, unit G1. The section says "mandatory" twice
with two meanings. "That is one mandatory word" means the `AbstractDevice`
subtype. Twenty lines later the bold says "**Only `loop` is mandatory**"
([D-366][d-366]). Read together, the two seem to contradict each other.
Fix, changing the bold: "**Of the four functions, only `loop` is
mandatory**". Editorial fallback, leaving the bold as it is: L1146 becomes
"That subtype is one required word, and it costs nothing".

**P2-25.** L1185, unit G1. R21's code comment is 108 columns wide. The
block's other comments are 83–90 columns wide, inherited from the old text.
Fix: split the comment over two lines, as L1177–1178 do:
`# no dead-marking: task_state shows the end,` and then
`# claims stay, §11.3`, both aligned at column 46.

**P2-29.** L1526–1527, unit H. The bold includes a connective. In
"**Widgets, however, name the component's own ports, never root inputs**",
"however" adds weight and states no ruling. Fix: "Widgets, however,
**name the component's own ports, never root inputs**" ([D-026][d-026]),
or move "however" before the bold.

## EDITORIAL

**P2-1.** L1283–1286, unit G1. An antecedent is broken. "This is
[§12.4][s12-4](6)'s case" now follows "Claims and the roster entry persist
to run end", so "This" reads as the persistence. In the old text it meant
the loop body returning. The claim gloss inserted at L1283 also splits the
paragraph. Fix: move the clause after L1280, "A window ✕ or peer EOT is the
loop body returning, which is [§12.4][s12-4](6)'s case." Then put the claim
gloss after the `task_state` sentence.

**P2-6.** L1515 and L1532, unit H. §11.7's glosses disagree with the rest
of the half. *claim* is glossed "(the set of root inputs a device *may*
write)". The glossary, §11.2 (L178), §11.5 (L969) and §11.6 (L1283) say "the
set of faces". *root input* is glossed "(the only thing the periphery may
write)". The glossary and §11.5 say "the root component's own input faces".
Fix: use the glossary glosses.

**P2-7.** L966–973, unit F. The argument reads worse than the old text.
"The rule is uniform because…" is broken by two gloss sentences, a claim
and then a greedy claim. The contract's gloss now carries the §11.3
pointer, "(the root's declared interface, [§11.3][s11-3])", which aims it
at the wrong home, since §11.3 holds the greedy claim and not the contract.
Fix: "…as wide as the root [contract](#g-contract) (the root's declared
interface)", with "[§11.3][s11-3]" moved after "computes at attach". Fold
"A claim is the set of faces a device *may* write" into the claim link's
gloss at L966.

**P2-8.** L994–999, unit F. The glosses pile up. "Per boundary (a
published consistency point) it is smaller than the log's snapshot, the
immutable per-boundary publication. The log is… The snapshot is the
carve-out's standing occupant…" says "per boundary" twice. Fix: "Per
[boundary](#g-boundary) (a published consistency point) it is smaller than
the [log](#g-log)'s [snapshot](#g-snapshot). The log is the retained
sequence of published snapshots. A snapshot, the immutable per-boundary
publication, is the carve-out's standing occupant and…"

**P2-9.** L1016, L1031 and L1034, unit F. "fingerprint" is used at L1016
and glossed only at L1031. The two compared parts are stated three times:
in the contents list, in R17's sentence, and in "The header carries the
run's `Deployment` and the structural layout", which was the old bullet's
label. The paragraph then says "the layout", a third name. Fix: gloss at
L1016, "the fingerprint (the structural layout)". At L1034 drop the first
sentence and start "The deployment comes from [§9.2][s9-2]…". At L1038
write "The fingerprint is the store layout…".

**P2-10.** L1057–1058, unit F. The section quotes a claim before it states
it. "…what 'given the initial state and the trace, the log is recomputable'
requires" comes forty lines before L1097–1098 states it. Fix: add
"(below)" after the quote.

**P2-11.** L1065, unit F. "door" is a reader-cold name. "by the door that
builds the run" has no glossary entry and no introduction in the half.
Fix: "by the door that builds the run (`init!`, `restore!` or `replay!`,
[§12.6][s12-6])". §12.6 uses "the door that builds the run".

**P2-12.** L943–995, unit F. Three terms are used before §11.5 defines
them. "drained" is used at L943 and L955, and the drain's link and gloss
come at L956. "component" is used at L962 and linked at L988. "boundary" is
used at L962 in its structural sense, in the face gloss, and then linked at
L995 in its consistency-point sense. Fix: link and gloss the drain at L943.
Move the component link and its gloss to L962.

**P2-13.** L1134–1139, unit G1. The rewrite reads worse than the old text.
One old sentence is now four, split by glosses. *batch* and *staging cell*
are used here for the first time in §11.6 and are not linked. The frame
link glosses "frame top", not frame. Fix: "A [batch](#g-batch) staged
there would land in a [staging cell](#g-staging-cell) that no
[drain](#g-drain) reads. A report would land in a [diagnostic
cell](#g-diagnostic-cell) that no [frame](#g-frame) top folds." Then give
each gloss in one short following sentence, or as a single parenthetical.

**P2-14.** L1111 and L1145, unit G1. *device* is defined twice in §11.6.
L1111 says "A device is an attached participant…", and L1145 says "A
device is a user type subtyping the framework's neutral root". Fix for
L1145: "A device's type subtypes the framework's neutral root, `MyDevice <:
AbstractDevice` ([D-177][d-177])."

**P2-15.** L1345–1431, unit G2. *greedy claim* comes late in §11.6. It is
used in prose from L1345 ("silence is not greediness") and in the bullets
at L1393, but linked and glossed only at L1430. "The computed claim source"
(L1346) and "a returned one" (L1431) are never glossed in §11.6. Fix: move
the greedy-claim link and gloss to L1345 or L1393. At L1346 write "The
computed claim source (the greedy one, [§11.3][s11-3])".

**P2-16.** L1288, unit G1. The `should_abort` paragraph sits under the
label "The author-owned loop body". It is an `attach!` keyword, which makes
it an entry point. Fix: add a label "The failure policy" before L1288.

**P2-17.** L1260, unit G1. `Telemetry` in the loop sketch is never
introduced. FlightCore has no such type: `Flight.jl_clean/lib` holds no
`struct Telemetry`. L1234–1236 introduce only `T16000M` and `UDPInput`. Fix:
"…and `UDPInput` is FlightCore's UDP input device type. `Telemetry` is an
illustrative output device type."

**P2-18.** L1582–1586, unit H. The glosses split a pair of sentences.
"At build time it follows…" and "At run start the switch follows…" are now
separated by the long `World` gloss and by "A scenario component is the
home of a sim-time script." Fix: end the build-time sentence at "exports to
root", then add "A scenario component is the home of a sim-time script."
Give the `World` gloss a sentence of its own before it.

**P2-19.** L1631, unit H. The `T16000M` introduction is wedged into the
label's quoted parenthetical. Fix: "…renders the fact in its source label,
such as "claimed by `T16000M` — task dead". `T16000M` is FlightCore's type
for the Thrustmaster T16000M joystick. The heartbeat is surfaced in place
([§12.2][s12-2])."

**P2-20.** L1705–1708, unit H. The new `pending.md` gloss leaves the
following "which" without a clear antecedent: it can attach to `pending.md`
or to the half. "the bridge" and "the browser client" are reader-cold. The
label is also echoed by the first words. Fix: "The GUI package's half
stays deferred, and `pending.md` (the record of what the implementation
still owes) tracks it. The built-in GUI's parking ([D-310][d-310]) assigns
it to the browser client over the bridge, the link to the simulation whose
design D-310 leaves open."

**P2-21.** L1917–1925, unit J. Two problems at the end of §11.8.
"…retains snapshot references ([§11.2][s11-2]), so `totals` is monotone…
So `log_every` decimation…" chains two "so"s, and the lines are underfilled
(L1919, L1921). "[D-136][d-136] lists the rejected alternatives" sits under
"Composition with the log", but its alternatives are a shared queue, a live
status, double-buffering and unbounded accumulation. Fix: "Because the log
retains…, `totals` is monotone across logged snapshots. `log_every`
decimation (…) therefore loses…" Move the D-136 sentence to the end of "One
diagnostic cell per writer", after L1771, as "The rejected alternatives are
in [D-136][d-136]."

**P2-22.** L1729–1731, L1743 and L1757–1758, unit J. *diagnostic cell* is
used at L1743 and linked at L1757. Two places stack parentheses:
"(the framework-owned write path `stage!(sim, …)`) ([D-200][d-200])" and
"(its own holding place for runtime diagnostics) ([D-136][d-136],
[D-200][d-200])". Fix: link and gloss the term at L1743. Put each citation
inside the gloss's parentheses, after a comma.

**P2-23.** L1738, unit J. The roster's gloss "(the list of attached device
entries, …)" uses *entry* loosely. The half has four roster glosses: L1068,
L1128, L1571 and L1738. Fix: "(the list of attached devices, [§11.3][s11-3])".

**P2-24.** L1095–1097 and L1813–1816, units F and J. Two facts are stated
twice, each site pointing at the other, with the pointers inherited from
the old text. First, "the state trajectory is derived from header plus
batches" is in §11.2 (L183–187, pointing at §11.5) and in §11.5 (pointing at
§11.2). Second, "heartbeat stored inside the handle primitives, so the
framework observes activity without owning the loop" is in §11.6 (L1275–1277)
and §11.8. Both sites state the claim, so nothing is lost. Optional fix: cut
§11.5's "the state trajectory included", and cut §11.8's "That way the
framework observes… ([§11.6][s11-6])" to the pointer.

**P2-26.** Several lines, all units. These lines run over 80 rendered
columns: L1031 (81), L1324 (139, never wrapped), L1534, L1539, L1554, L1559,
L1574, L1586, L1631, L1705 and L1865. These are badly underfilled: L1132,
L1372, L1489, L1633, L1749, L1872, L1882, L1919 and L1921. Fix: rewrap each
paragraph.

**P2-27.** L1020, unit F. The run's gloss is circular. "the [run](#g-run)
(the state one run owns)" links lowercase text to the glossary's `Run`
type. This is inherited. Fix: "the [`Run`](#g-run) (the state one run owns,
a `Simulation` field)".

**P2-28.** L1861, unit J. `maxlog` is reader-cold. Fix: "Presentation is
where `maxlog`, the cap Julia's logging macros put on repeats, lives." D-136
calls the threshold "the `maxlog` successor".
