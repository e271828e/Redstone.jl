C("A face name is an arbitrary string and may contain a dot (§8.6), so on `get_input` and `get_face` the head is matched rather than parsed: it is the longest declared face name that is a prefix of the address and is followed by the end, a `.` or a `[`, and a `Symbol` leaf names the face whole, with no steps.",
  new="A face name is an arbitrary string and may contain a dot (§8.6), so on `get_input` and `get_face` the head is matched rather than parsed. The head is the longest declared face name that is a prefix of the address and is followed by the end, a `.` or a `[`. A `Symbol` leaf names the face whole, with no steps.",
  note="mid-sentence colon goes; one sentence becomes three")
F(32)
C("Each step is checked at resolution against the type resolved so far.",
  new="Each step is checked at resolution against the type resolved so far (D-276).",
  tag="R", ruling="R19", newcites="D-276", note="bold headline of D-276 bullet 2, bold nowhere else in the frozen spec")
F(34); F(35); F(36)
C("A continuous state field is flat (§7.1), so `get_deriv`, and `get_state` on the continuous tier, take at most an index step.",
  new="`get_deriv`, and `get_state` on the continuous tier, take at most an index step, since a continuous state field is flat (§7.1, D-276).",
  tag="R", ruling="R19", newcites="§7.1 D-276", note="bold headline of D-276 bullet 4 and its 2026-09-30 annotation; rule first, reason after; bold nowhere else in the frozen spec")
F(38)
F(39, tag="R", ruling="R19", note="verify: the bold moves from 'checked once and baked' to 'the read runs ... unrolled at compile time'; bold headline of D-276 bullet 3, 'The baked read ... executes it as getfield and getindex calls unrolled at compile time', bold nowhere else; the binding read (bullet 5) stays plain with its pointers, and wiring (bullet 7) is not stated here")
C("The names carry a deliberate `get_` prefix.",
  new="The names carry a deliberate `get_` prefix (D-095).",
  tag="R", ruling="R7", newcites="D-095",
  note="verify: bold moved here, the headline of D-095's one ruling. D-095 Position: 'spelled with a get_ prefix ... a selector is a deferred read, so the prefix names the eventual action, keeps six short common nouns out of the namespace'; plain, the family's bold above carries D-095's one ruling")
F(41); F(42)
C("There is no selector for a value a component computes without declaring it, and there cannot be one, because only cells are addressable (§4.2, §8.3).",
  new="There is no selector for a value a component computes without declaring it, and there cannot be one, because only declared cells and stores are addressable (§4.2, §8.3).",
  tag="R", ruling="R9", note="F20: the store selectors address stores (src/readers.jl 48-49, 'Only cells and stores are addressable')")
F(44)
C("`get_face` addresses an output face of the mount level, the level its read set is mounted at (§14.9).",
  new="`get_face` addresses an output face of the mount level, the level its read set is mounted at (§14.9, D-277). Mounting relocates a whole problem or tap set (the three selector lists declaring what linearization seeds and reports) with `at(prefix, …)`.",
  tag="C", newcites="§14.9 D-277",
  note="D-277 bullet 3: 'get_face(name) names an output face of the mount level ... at the root it is the integration read it was'. Mounting linked at its first use (late link fixed); its gloss, moved from old 11675, stands as its own sentence, the #g-mounting definition; tap set linked there with the taps gloss moved from old 11668")
F(46); F(47)
C("Rule. A selector resolves against a source, before any client policy applies.",
  new="A selector resolves against a source (D-098).",
  tag="R", ruling="R31", newcites="D-098",
  note="R31: 'before any client policy applies' goes, since R5 leaves no client policy. Rule. label goes; bold headline of D-098's Position, 'a selector resolves against a source before any client policy'. R5 keeps the source rule as the one enforced rule")
F(50)
C("A table source is a boundary snapshot, or the scratch tables a service evaluation instantiates (§14.8).",
  new="A table source is a boundary snapshot, or the scratch tables a service evaluation instantiates (§14.8, D-124).",
  tag="C", newcites="§14.8 D-124",
  note="D-124 Rationale: 'table sources (a boundary snapshot, or the scratch tables a service evaluation instantiates, §14.8)'; Rationale-only")
C("The store selectors (`get_state`, `get_deriv`) resolve only against live stores.",
  new="The store selectors (`get_state`, `get_deriv`) resolve only against live stores (D-098).",
  tag="C", newcites="D-098",
  note="D-098 Position: 'store selectors (get_state/get_deriv) only against live stores'")
F(53)
C("Only stopped-sim service evaluations, `checkpoint`, and post-run inspection of the live stores (the replay-to-inspect, §11.2) ever hold live stores.",
  new="Only stopped-sim service evaluations, `checkpoint`, and post-run inspection of the live stores (the replay-to-inspect) ever hold live stores (§11.2).",
  note="the citation leaves the gloss's parentheses; checkpoint linked at its first use, no gloss")
F(55)
C("A reader resolving for a table source that names a store selector is therefore refused at resolution, as a `ReadResolution` (D-406).",
  new="A reader resolving for a table source that names a store selector is therefore refused at resolution, as a `ReadResolution` with reason `:store_selector` (D-406).",
  tag="R", ruling="R14", note="reason named, src/readers.jl 441-442; D-406 bullet 1 'refused as :store_selector'")
C("The resolver takes the source it resolves for, so the rule is the resolver's and not a client's.",
  new="The resolver takes the source it resolves for, so the rule is the resolver's and not a client's (D-406).",
  tag="R", ruling="R7", newcites="D-406",
  note="bold headline of D-406 bullet 1, 'The resolver takes the source it resolves for ... The source rule is the resolver's, not a client's', bold nowhere else; its citation repeated in the sentence")
F(58)
C("Client policy rides on top. It is D-083's service and inspection sides restated as a resolver property.",
  new="On top of the source rule sits one piece of authoring guidance (D-414).",
  tag="R", ruling="R5", newcites="D-414",
  note="R5: the two sentences are cut as false (D-414 Rejected, a resolver §14.4 keeps client-free; src/readers.jl 429-445) and replaced by the dictated guidance sentence. D-083 moves to the inspection sentence below")
A("An inspection read, a binding's or `series`', may name any cell the structure has, since it promises nothing beyond this build (D-083).")
A("Both reads resolve under the one service walk (§13.3).")
C("- Service reads speak the contract.",
  new="A service read, trim's `reads` or a tap, that should outlive the build reads a face with `get_face` (D-125).",
  tag="R", ruling="R5", newcites="D-125",
  note="R5: the bold lead-in goes plain and becomes the dictated guidance, since D-414 bullet 4 makes it authoring guidance. D-125 Position, 'get_face is admitted to the service set ... so an equilibrium equation crossing a generic seam binds the curated face contract', with D-414's annotation. The list becomes paragraphs")
C("Trim's `reads` and linearization's taps (the three selector lists declaring what linearization seeds and reports) name `get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`.",
  new="Trim's `reads` and linearization's taps name `get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`.",
  note="the taps link and gloss move to the first use, 'tap set' in the mounting sentence, the old gloss verbatim")
F(63)
C("`get_face` is the set's seam-crossing member. It resolves through export chains exactly as mounting (relocating a whole problem or tap set with `at(prefix, …)`) resolves root input faces (§14.9), so the read side mirrors the write side.",
  new="`get_face` resolves through export chains exactly as mounting resolves root input faces (§14.9, D-125), so the read side mirrors the write side.",
  tag="R", ruling="R5", newcites="§14.9 D-125",
  note="R5 cuts 'get_face is the set's seam-crossing member': since D-414 every path selector crosses a seam. The mounting gloss moved to the first use above. The sentence moves up into the guidance paragraph, beside the dictated get_face sentence (D-125 Position 'resolves through export chains exactly as §14.9's mounting resolves slot faces')")
C("An equilibrium equation meant to outlive the build it was posed against therefore binds the curated face behind a generically-held child rather than a path into it.",
  new="An equilibrium equation meant to outlive the build it was posed against therefore binds the curated face behind a generically held child (one held through a non-concrete field type) rather than a path into it.",
  tag="R", ruling="R5",
  note="verify: C-064, moved after the export-chain sentence its 'therefore' follows; kept as guidance (R5); 'generically held' linked at first use, gloss from #g-generic-holding")
C("A service evaluation needing an undeclared intermediate has one remedy, and it is the same for every client. The component exports it (§14.7).",
  new="A service evaluation needing an undeclared intermediate has that one remedy too, and it is the same for every client. The component exports it (§14.7).",
  tag="M", note="M5 and R6: merged into the undeclared-value paragraph, §14.4 its home; 'that ... too' ties it to the declare-an-output remedy")
C("- Inspection readers admit the whole family, within the source rule.",
  new="Inspection reads admit the whole family, within the source rule.",
  tag="R", ruling="R5",
  note="bold lead-in goes plain (D-095 Rationale only); 'readers' becomes 'reads', the dictated text's word for a binding's or series' read")
C("Output-device bindings, log extraction by `series` and snapshot inspection take deep paths, `get_face` names and leaf addresses alike (D-406, D-407, D-414).",
  new="Output-device bindings and log extraction by `series` take deep paths, `get_face` names and leaf addresses alike (D-406, D-407, D-414). Snapshot inspection reads a cell by path and port name instead (§11.2).",
  tag="R", ruling="R5", newcites="D-406 D-407 D-414 §11.2",
  note="F21: snapshot inspection leaves the selector clients, R5's dictated sentence (src/dataplane.jl 480-481)")
C("The store selectors reach only the inspection clients that actually hold stores (`checkpoint`, post-run inspection). A snapshot-bound reader is barred from them by source, not by client.",
  new="A store selector resolves only for a reader that runs over live stores, which today are the services' (§14.7, §14.10). A snapshot-bound reader is barred from it by source, not by client.",
  tag="R", ruling="R5", newcites="§14.7 §14.10",
  note="F22's sentence, R5's dictated wording (src/readers.jl 36-42; src/bindings.jl 147, src/sim.jl 2252 resolve for :table)")
C("- `ignore_stop_requests` is not a family client.",
  new="`ignore_stop_requests` is not a family client.",
  note="bold lead-in goes plain (D-095 Rationale and Rejected only)")
C("It names requesters from the `Build`'s requester roster, period (§13.5, D-060, D-316).",
  new="It names requesters from the `Build`'s requester roster (the build's list of stop requests, one per `StopFlag` output port), period (§13.5, D-316).",
  tag="C", newcites="§13.5 D-316",
  note="D-060's policy clause is superseded by D-316 (annotation 2026-10-08); D-316 bullet 6 carries the fact. D-060 moves to the next sentence. requester roster linked and glossed (carried item), gloss from #g-requester-roster")
C("Termination is run policy over the requests the model declares, and no path selector reaches `ignore_stop_requests`.",
  new="Termination is run policy over the requests the model declares, and no path selector reaches `ignore_stop_requests` (D-060, D-316).",
  tag="C", newcites="D-060 D-316",
  note="verify: D-316 added for the second clause (the ignore list addresses the roster, reads no cell). D-060 Rejected, 'Root-type-declared policy: stopping is run policy', a clause D-316's annotation leaves standing; Rationale-only")
C("The five selectors, their sources, and their clients:",
  new="The five selectors and their sources:", tag="R", ruling="R5")
C("| selector | resolves against | service reads | inspection readers | |---|---|---|---| | `get_state(path, leaf)` | live stores | named in the contract | only clients that hold stores | | `get_deriv(path, leaf)` | live stores | named in the contract | only clients that hold stores | | `get_output(path, leaf)` | a table source | named in the contract | admitted | | `get_input(leaf)` | a table source | named in the contract | admitted | | `get_face(leaf)` | a table source | named in the contract | admitted |",
  new="| selector | resolves against | |---|---| | `get_state(path, leaf)` | live stores | | `get_deriv(path, leaf)` | live stores | | `get_output(path, leaf)` | a table source | | `get_input(leaf)` | a table source | | `get_face(leaf)` | a table source |",
  tag="R", ruling="R5", note="R5: the table keeps its selector and source columns and drops the two client columns")
C("Compiled readers are the gather twin over this family and the layout tables.",
  new="Compiled readers are the gather twin (D-066) over this family and the layout tables (where each value physically lives).",
  tag="R", ruling="R7", newcites="D-066",
  note="bold lead-in becomes the bold headline of D-066's third semicolon ruling, 'compiled readers as the gather twin'; §14.4 its home (R6). layout linked at first use, gloss from #g-schema-vs-layout")
C("Trim's cost read (`ẋ` and output fields) and linearization's Jacobian gather are one primitive run in reverse.",
  new="Trim's residual reads (`ẋ` and output fields) and linearization's Jacobian gather are one primitive run in reverse.",
  tag="R", ruling="R9", note="F23: trim reads a residual system, not a cost (§14.7)")
F(79)
