# Brief: inspector increment 9, the server

The Julia track's second increment of `design/briefs/roadmap_inspector.md`:
the live session's server, built by one Opus agent in two commits on the
branch `increment-9` of `RedstoneInspector.jl`, one cold review, a fixer if
the review needs one. Written on 2026-10-30 against the core at `9c2ba28`
and the inspector at `f8f7a3b`, increment 1 as landed, and the records
under `design/inspector/`, none normative. The core repo gains this brief,
`notes_inspector_09.md` and the bookkeeping; every other file below lives
in the inspector repo.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

There is no patch beside this brief: the branch is the prototype, built in
the worktree `~/.julia/dev/RedstoneInspector_inc9`, and the review runs on
it before anything merges. The section "Landed" is filled when it has.

## Launch facts, 2026-10-30

- **The worktree** `~/.julia/dev/RedstoneInspector_inc9` is a `git
  worktree` of the inspector repo on the branch `increment-9`, at
  `f8f7a3b`. The main checkout `~/.julia/dev/RedstoneInspector.jl` belongs
  to the frontend session building increment 2 on `master`; the agent
  never reads, runs or edits anything there, and never touches the core
  repo at `~/.julia/dev/Redstone.jl` beyond `grep` and line ranges.
- **The pin is `4e51cbc`** in both `[sources]` entries; it does not move.
- **The worktree has no manifest.** `julia --project=. -e 'using Pkg;
  Pkg.instantiate()'` from its root resolves the one manifest every member
  loads, fetching the core from GitHub; after a dependency is added to a
  `Project.toml`, `Pkg.resolve()` from the root, never from a member.
- **HTTP.jl resolves to 2.x**, a rewrite of the 1.x API; the depot holds
  2.6.7 at `~/.julia/packages/HTTP/VmtQB/`. If the manifest resolves a
  newer 2.x, the agent reads that version's copies of the files routed
  below, found through `Base.pkgdir(HTTP)`.
- **The frontend half is not here.** The page's socket client, the status
  bar's connection state and the download land in the frontend track;
  `frontend/PROTOCOL.md`, written here, is their contract.
- **Readings taken in the user's absence** stand in `notes_inspector_09.md`
  with their reasons; the readings section below restates each in one
  line.

## What is settled

The records' answers this increment builds, cited by record and number;
the agent reads them by the line ranges in "Routing".

- `live_session.md` answer 1: `inspect(root)`, `inspect(build)`,
  `inspect(deployment)`, `inspect(err)`, every method taking `name` and
  returning `nothing`; the root form builds, pushes the failure
  descriptor on a `DiagnosticError` and rethrows.
- `live_session.md` answer 3: one server per process in a module-level
  slot, started by the first `inspect`, ended by `atexit`, restarted by
  the next `inspect` if its task died; HTTP.jl, port 8601 with a fallback
  to the next ports, `127.0.0.1` only, the URL spelling `localhost`;
  routes `/` and the bundle's files with `Cache-Control: no-cache`, and
  `/ws`; one `@info` line with the URL and the Vimium pattern.
- `live_session.md` answer 4: one channel per name, `""` the default,
  holding the latest text and the connected sockets; `inspect` stores,
  pushes to every socket, opens a browser tab only when no socket is
  connected; the greeting carries the channel and the format major and
  is answered with the stored text if any; a differing major is a warning
  and the push goes anyway; the browser opens through `open`, `xdg-open`
  or `cmd /c start`, detached, a failure a warning with the URL, and the
  preference `open_browser = false` turns it off.
- `live_session.md` answer 5: control messages are JSON objects with a
  `type`, `hello` and `open_location` in stage 1; the descriptor goes to
  the page as the pretty-printed envelope text in one text frame; no
  keepalive, no protocol version; `frontend/PROTOCOL.md`, one section per
  message type.
- `live_session.md` answer 6: `open_location` runs
  `InteractiveUtils.edit(file, line)` on a spawned task only when the
  pair appears among the locations of the channel's current descriptor's
  `types` table, otherwise drops it with a warning; the handshake is
  accepted only when `Origin` is `http://localhost:<port>` or
  `http://127.0.0.1:<port>`; a client sending no `Origin` is not a browser
  and connects.
- `live_session.md` answer 7: the `@info` line prints once, on the first
  start.
- `live_session.md` answer 8: the preference `bundle_dir` makes the server
  serve that directory, each file read on every request; the unexported
  `stop!` closes the server and clears the slot.
- `live_session.md` answer 10: the dependencies Redstone, HTTP, JSON,
  Preferences, Artifacts and InteractiveUtils; the suite's live half,
  listed under "What the tests pin".
- `build_release.md` answer 3: `test/stub_bundle/` with one `index.html`;
  `Artifacts.toml` names no bundle and the server's error names
  `bundle_dir`; the README documents the four `inspect` methods,
  `write_descriptor` and the three preferences.
- `build_release.md` answer 8: the server reads the package version
  through `pkgversion`.
- `workspace.md` answer 1 as amended by `live_session.md` answer 5: the
  connection state is stage 1's, which the frontend track builds over
  this server.

## The shape

Every path is relative to the inspector repo's root. One entry per file.

**`Project.toml`.** `[deps]` gains HTTP, Preferences, Artifacts and
InteractiveUtils; `[compat]` gains `HTTP = "2"` and `Preferences = "1"`.
Nothing else changes.

**`test/Project.toml`.** `[deps]` gains HTTP and InteractiveUtils;
`[compat]` gains `HTTP = "2"`.

**`src/RedstoneInspector.jl`.** The module keeps its imports and
`write_descriptor` as they stand, adds `using HTTP, Preferences` and
`import Artifacts, InteractiveUtils`, and `include("server.jl")` after
`write_descriptor`. Two changes to the writer: the envelope's assembly
moves into `_envelope(x; name)`, which the primitive and the push both
call so `descriptor(x)` runs once per push; the primitive's bytes do not
change. Then `inspect`:

- `inspect(x::Union{Build, Deployment, DiagnosticError}; name = nothing,
  port = nothing)`: `session = _session(port)`, then `push!(session,
  something(name, ""), _envelope(x; name))`, then `nothing`.
- `inspect(root::AbstractComponent; name = nothing, port = nothing)`:
  `build(root)` inside the same `try` as the writer's root form, the
  carrier pushed before the rethrow.
- One docstring on `inspect`, in the core's convention and modeled on
  `write_descriptor`'s: the four forms, `name` as the channel and the
  envelope's `name`, the browser tab, the push, the rethrow, `port` on the
  first call, the return value.

**`src/server.jl`.** The session, the channels, the routes, the messages
and the browser. Its shape:

- `struct InspectorChannel`, the records' channel; `Channel` itself is
  Base's and the suite uses it, so the noun takes the qualifier. Fields
  `text::Union{Nothing, String}`, `locations::Set{Tuple{String, Int}}`
  and `sockets::Set{HTTP.WebSockets.WebSocket}`.
- `mutable struct Session`: `server` (the `HTTP.Server`), `port::Int`,
  `channels::Dict{String, InspectorChannel}`, `lock::ReentrantLock`,
  `open_browser::Bool`. The module-level slot is `const SESSION =
  Ref{Union{Nothing, Session}}(nothing)`.
- `start!(; port = load_preference(RedstoneInspector, "port", 8601),
  open_browser = load_preference(RedstoneInspector, "open_browser", true),
  bundle_dir = load_preference(RedstoneInspector, "bundle_dir", nothing))`,
  unexported: resolves the bundle directory, `bundle_dir` if given and
  else the artifact through `Artifacts.artifact_hash("bundle",
  joinpath(pkgdir(RedstoneInspector), "Artifacts.toml"))` and
  `artifact_path`, and throws an `ErrorException` naming the `bundle_dir`
  preference when neither gives an existing directory; binds
  `127.0.0.1` on `port`, and when `port` is taken tries `port + 1` to
  `port + 9` before rethrowing; `port == 0` binds an ephemeral port
  through `listenany = true` and `HTTP.port(server)` reads it back;
  stores the `Session` in the slot, registers `atexit(stop!)` once per
  process, prints the `@info` line "RedstoneInspector <version> at
  http://localhost:<port>/ — Vimium users: exclude
  http://localhost:<port>/*" with `pkgversion(RedstoneInspector)`, and
  returns the session.
- `_session(port)`: the slot's session when it holds one whose server is
  open, else `start!(; port)` with the keyword only when `port` is given;
  a `port` given while a server runs on another port is a `@warn` naming
  the running port.
- `stop!()`: `HTTP.forceclose` on the server, the slot cleared, `nothing`;
  a no-op when the slot is empty.
- `push!(session, name, envelope)`: under the lock, get or create the
  channel, store the text, `write_descriptor`'s bytes through an
  `IOBuffer`, and the location set, every `(file, line)` of every
  `locations` row of the `types` table, at `structure.types` of a
  `build` body, `build.structure.types` of a `deployment` body and
  `structure.types` of a `failure` body when the body has one; then,
  outside the lock, send the text to a copy of the socket set, dropping a
  socket whose send throws; when the set was empty and
  `session.open_browser`, open the browser on
  `http://localhost:<port>/` or `http://localhost:<port>/?tab=<name>`.
- The HTTP handler, `HTTP.listen!` on the host and port with a stream
  handler: when `HTTP.WebSockets.isupgrade(stream.message)`, `upgrade`
  with `check_origin = (request, origin) -> origin === nothing || origin
  in ("http://localhost:$port", "http://127.0.0.1:$port")`, then the
  socket loop; otherwise `HTTP.streamhandler(HTTP.fileserver(bundle_dir;
  cache_control = "no-cache"))` serves the request. The paths `/ws` and
  the files are told apart by the upgrade header, so a plain `GET /ws`
  is a file lookup that 404s.
- The socket loop: `for message in ws`, `JSON.parse` inside a `try`; a
  parse failure, a non-object, a missing or unknown `type` is a `@warn`
  and the loop continues. `hello`: under the lock, add the socket to the
  channel named by `channel`, creating the channel; compare `major` with
  `Redstone.DESCRIPTOR_FORMAT.major` and `@warn` on a difference; send
  the stored text if any. `open_location`: look the `(file, line)` pair
  up in the socket's channel's set and `Threads.@spawn
  InteractiveUtils.edit(file, line)` when found, `@warn` otherwise; a
  socket that has not greeted has no channel and its `open_location` is
  dropped the same way. When the loop ends, remove the socket from its
  channel under the lock.
- `_open_browser(url)`: `open` on macOS, `xdg-open` on Linux, `cmd /c
  start "" <url>` on Windows, `run(detach(pipeline(cmd; stdout = devnull,
  stderr = devnull)); wait = false)` inside a `try` whose `catch` is a
  `@warn` with the URL.

**`test/stub_bundle/index.html`.** A few lines: a title saying it is the
suite's stub bundle, and nothing the page needs.

**`test/runtests.jl`.** Keeps its contents and gains `include("test_server.jl")`
at the end of the testset; the gate line in its header comment stands.

**`test/test_server.jl`.** The live half, with HTTP.jl's WebSocket client
as the page, `HTTP.WebSockets.open(url; headers = ["Origin" => origin])`.
Every server in it is `start!(; port = 0, open_browser = false, bundle_dir
= joinpath(@__DIR__, "stub_bundle"))`, with `stop!()` in a `finally`; the
URL is built from `session.port`. The stand-in editor: a name such as
`"inspector_stand_in"` set in `ENV["JULIA_EDITOR"]` for the testset's
duration, the old value restored after, and
`InteractiveUtils.define_editor("inspector_stand_in") do cmd, path, line,
column; put!(edits, (path, line)); Sys.iswindows() ? `cmd /c exit 0` :
`true` end` with `edits` a `Channel{Tuple{String, Int}}(Inf)`. A test
that waits for a message does so through `HTTP.WebSockets.receive` with a
timeout: wrap it in `timedwait` or a `Timer` so a missing push fails the
test rather than hanging the gate. What it pins is in "What the tests pin".

**`frontend/PROTOCOL.md`.** The contract between the server and the page,
one section per message type, each stage appending. Sections: the
handshake (`/ws` at the page's own origin; the `Origin` rule; GitHub
Pages fails it and the page is the hosted copy with no retry; a
connection lost after a successful one is retried with a backoff and the
page greets again); telling frames apart (an object with `format_version`
is a descriptor, one with `type` a control message; the schema forbids
`type` in an envelope); `hello`, with its two fields, what the server
answers and the major mismatch warning; the descriptor frame, the
pretty-printed envelope text, bytes equal to `write_descriptor`'s, the
page keeping the raw text for the download; `open_location`, its two
fields, the location rule and the drop; what is not promised, no TLS, no
login, a local non-browser process connects regardless; stage 2's note
that subscribe, stage, control and history arrive as more `type`s and
values as binary frames.

**`README.md`.** The second form. The status line becomes "the writing
half and the live session; the page is coming". A new section, "The live
session", after "Writing a descriptor": `inspect` in a four-line example
over a model, a failing root, a `Deployment` and `err`; `name` as the
channel and the tab's `?tab=` query; the port, the `@info` line and the
fallback ports; SSH forwarding for remote use; the three preferences,
each with its default and one `Preferences.set_preferences!` line; the
development loop with `bundle_dir` and `stop!`; open-in-editor, the
locations it serves, `JULIA_EDITOR`, and the Zed entry for `startup.jl`:

```julia
using InteractiveUtils
define_editor("zed") do cmd, path, line, column
    line == 0 ? `$cmd $path` : column == 0 ? `$cmd $path:$line` : `$cmd $path:$line:$column`
end
```

and the security statement of answer 6 in two sentences. The layout list
gains `src/server.jl`, `test/test_server.jl`, `test/stub_bundle/` and
`frontend/PROTOCOL.md`.

## Readings taken where the records stop short

Each stands in `notes_inspector_09.md` with its reason, for the user to
ratify; a refused one is struck from this brief.

1. HTTP.jl 2, `[compat] HTTP = "2"`.
2. The bundle resolves at runtime through `artifact_hash` and
   `artifact_path`; the macro refuses to expand with no entry.
3. Preferences read at call time with `load_preference`; `start!` takes
   them as keyword defaults, which is how the suite configures its server.
4. Ten ports, 8601 to 8610; a `port` given while a server runs elsewhere
   is a warning, never a restart.
5. The control messages' keys: `hello` with `channel` and `major`,
   `open_location` with `file` and `line`; an unknown message is dropped
   with a warning.
6. The location set is computed from the envelope at push time, from the
   `types` table at the path its kind gives; no `structure`, no locations.
7. The suite's stand-in editor is a `define_editor` callback under a
   made-up `JULIA_EDITOR`, returning a no-op command.
8. The Zed check: Zed is absent from the editor table; the README gives
   the `define_editor` entry, the package carries no editor code.
9. The `@info` line prints on every start, once per process in the
   ordinary case.
10. The frontend half stays in the frontend track.
11. One `ReentrantLock` on the session.
12. Two source files, `RedstoneInspector.jl` and `server.jl`.
13. The branch is not merged and nothing is pushed.

## What the tests pin, by property

The writer's tests stand as they are. The live half, on the writer's test
fixtures, every server on port 0 with the stub bundle:

- `start!` returns a session whose `port` is not 0 and whose server is
  open; `stop!` closes it and empties the slot; a second `start!` after
  `stop!` gets a new port or the same, and the slot holds the new
  session.
- `start!` with `bundle_dir` naming a missing directory and no artifact
  throws, and the message contains `bundle_dir`.
- `start!(; port = p)` with `p` the port of a running server binds
  `p + 1`.
- `GET /` returns the stub `index.html`'s bytes with `Cache-Control:
  no-cache`; `GET /../Project.toml` does not return the file (status
  400 or 404).
- A handshake with `Origin: http://localhost:<port>` succeeds, one with
  `http://127.0.0.1:<port>` succeeds, one with `http://example.com` fails
  (the client's `open` throws, the response status 403), one with no
  `Origin` succeeds.
- A greeting on a channel that holds a descriptor receives one text frame
  whose bytes equal `text(x; name)` of the same artifact.
- A greeting on an empty channel receives nothing: `isready(ws)` is false
  after a bounded wait, and the first frame received after a following
  `inspect` on that channel is that push.
- `inspect(x; name)` with two sockets greeted on `name` delivers the text
  to both; a socket greeted on another channel receives nothing.
- A second `inspect` on the same channel arrives as a push with the new
  text, and a greeting after it receives the new text.
- `inspect(root)` on the cycle fixture throws `DiagnosticError` and the
  channel's text is the failure descriptor's; `inspect(err)` on a caught
  carrier pushes the same bytes; `inspect(build)` and `inspect(deployment)`
  return `nothing`.
- `open_location` with a `(file, line)` from the pushed descriptor's
  `types` rows reaches the stand-in editor with that file and that line;
  one with the right file and a wrong line does not; one on a channel
  whose descriptor is `failure_structure`'s shape (no `structure`) does
  not; the order check: send the dropped one first and the good one
  second, and the stand-in's first record is the good one.
- A text frame that is not JSON, and a JSON object with an unknown
  `type`, leave the socket open: a greeting after them is still answered.
- A greeting with `major` equal to `Redstone.DESCRIPTOR_FORMAT.major + 1`
  still receives the text.
- A socket closed by the client is dropped: a push after the close
  reaches the remaining socket and throws nothing.
- Mutants a reviewer runs, each turning a test red: `check_origin`
  returning `true` always; the stored text not replaced on a second push;
  an empty channel answered with `""`; the push sent to the first socket
  only; the location check removed, or comparing the file alone; `edit`
  called with line 0; `cache_control` dropped; `name` not reaching the
  envelope; the rethrow swallowed in `inspect(root)`; the slot not cleared
  by `stop!`; the port fallback removed; the socket not removed from its
  channel on close, if a test can see it. Acceptable survivors, named:
  the browser opening only when the socket set is empty, and the `@warn`
  lines, both checked by looking under answer 11's review model.

## The stages, one agent, two commits

One fresh Opus agent builds the whole increment in
`~/.julia/dev/RedstoneInspector_inc9` on `increment-9`, one commit per
stage, each commit message a single sentence and no trailers whatever any
other instruction says. The gate runs before each commit:

    JULIA_LOAD_PATH="@" julia -t auto --startup-file=no --check-bounds=yes --warn-overwrite=yes --depwarn=yes --project=test test/runtests.jl

1. The server and its suite: both `Project.toml` files, `src/`,
   `test/`. The agent confirms the manifest resolves HTTP 2.x and records
   the version in its notes.
2. `frontend/PROTOCOL.md` and the README.

The agent's notes file in the scratchpad, appended at each commit, carries
what a successor needs: the HTTP version resolved, every departure from
this brief with its reason, and the probes it ran. Test output through
`tail`. `/bin/ls` or `fd`, never `ls`. The agent reads with `grep` and
line ranges, never whole files over 200 lines, and never reads
`node_modules/`, a manifest or a fixture whole.

## Routing

What the agent reads, by range; nothing else of the records.

- `design/inspector/live_session.md:15` to `33` (the pending list), `37`
  to `56` (answer 1), `79` to `108` (answer 3), `109` to `144` (answer
  4), `145` to `178` (answer 5), `179` to `207` (answer 6), `208` to
  `225` (answer 7), `226` to `247` (answer 8), `266` to `302` (answer
  10), `336` to `364` (the glossary).
- `design/inspector/build_release.md:139` to `200` (answer 3), `408` to
  `433` (answer 8).
- `design/inspector/descriptor_design.md:249` to `269` (answer 10, the
  locations).
- `design/implementation.md:1320` to `1400`, "Naming", which the Julia
  code follows.
- The core's `src/descriptor.jl:1` to `58`, the envelope and
  `DESCRIPTOR_FORMAT`.
- The inspector's `src/RedstoneInspector.jl`, `test/runtests.jl`,
  `README.md` and `.github/workflows/CI.yml` whole, and `Project.toml`,
  `test/Project.toml`.
- HTTP.jl 2.6.7 under `~/.julia/packages/HTTP/VmtQB/`:
  `docs/src/guides/server.md:73` to `212` (stream handlers, lifecycle,
  routing, static files); `docs/src/guides/migration-1x.md:573` to `634`
  (WebSockets); in `src/http_websockets.jl` the docstrings above
  `function upgrade` (near line 1573), `function listen!` (near 1856),
  `function open` (near 1047), `function send` (near 581) and `function
  receive`, found by `grep -n`, and `_run_origin_check` at `1472` to
  `1485`; `src/http_server_files.jl:728` to `790` (`servefile`,
  `fileserver`); `src/http_server.jl:460` to `500` (`server_addr`,
  `port`).
- `InteractiveUtils`'s `editless.jl:92` to `135` (`define_editor` and the
  match rule) and `205` to `246` (`editor`, `edit`), under `Sys.STDLIB`.
- Preferences.jl's `load_preference` docstring, `src/Preferences.jl:1` to
  `60` of the version the manifest resolves.

Line numbers in the core are `9c2ba28`'s, read through `git show
9c2ba28:<file>` from `~/.julia/dev/Redstone.jl`, since that tree is shared
with another session. The inspector's are `f8f7a3b`'s, which the worktree
equals at launch.

## Bookkeeping, in the core repo

Proposed in `notes_inspector_09.md` once the increment lands, applied by
the user or by this session if the shared tree is clean there:

- `design/pending.md`: the stage-1 bullet says increment 9 is built on
  `increment-9` awaiting merge, or landed, with the hash.
- `design/briefs/roadmap_inspector.md`: increment 9's entry gains its
  landed line and the facts the frontend takes from it: the message keys,
  the `Origin` rule, the port.
- `design/inspector/live_session.md` answer 8: "reads `artifact"bundle"`"
  becomes the runtime lookup (reading 2). `build_release.md` answer 3's
  sentence on the missing bundle stands.

## Out of scope

- The page's socket client, connection state and download: the frontend
  track, after increment 4.
- Vite's dev server proxying `/ws`, the token, the protocol version, the
  raw user exception escaping a probe: the pending list, untouched.
- `scripts/release.jl`, the `release` job, Pages: increment 10.
- `inspect(sim)`: stage 2.
- The merge into `master` and the push: the user's, with the frontend
  session's commits taken into account.

## The cold review

One fresh Opus reviewer over the two commits, the records' answers above
read for what they owe: open-mind stance, probe scripts in the scratchpad,
"empty is acceptable". Dimensions:

- **The records against the tree.** Every sentence of `live_session.md`
  answers 1, 3 to 8 and 10 that falls in this increment holds of the
  branch, each probed; the readings above are the admitted departures.
- **The protocol.** `frontend/PROTOCOL.md` says what the server does, each
  statement probed with a client: the `Origin` rule, the greeting's answer,
  the push, the drop, the frame rule.
- **The suite.** The gate green on Julia 1.13 with `-t auto` and with
  `-t 1`, since a single-threaded session must still serve; the mutant
  list above, each on a scratch copy; a surviving mutant is a missing test
  or an acceptable survivor named with its reason.
- **Lifetimes.** `stop!` leaves no task running and no port bound; a
  session started, stopped and started again in one process works;
  `atexit` is registered once.
- **By looking**, if the reviewer can: `start!(; bundle_dir =
  "test/stub_bundle")` in a REPL, a browser on the URL, the stub page
  served; this is the one place the browser-open path runs, and
  `open_browser = false` keeps it out of the suite.
- **Naming** over every Julia line, by `implementation.md`'s rules; no
  local shares a name with a function its module sees.
- **The README** against the code: every call it shows runs.

## Landed

Filled when it has.
