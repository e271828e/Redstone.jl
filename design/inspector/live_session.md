# The live session: axis 6 of the inspector's stage 1

The record of one session, on 2026-10-28, that fixed the inspector's Julia
package and the server it runs in the REPL: the `inspect` and
`write_descriptor` entry points, the encoder, the server's life, the
channels a named `inspect` pushes to, the page protocol, the open-in-editor
request and the `Origin` check, the development loop, and what proves the
package works. It builds on `initial_design.md`'s answers 8, 10 and 13, on
`descriptor_design.md`'s answer 13 and on the hand-ons of
`visual_grammar.md` and `workspace.md`, and never restates them; where it
amends one, it says so. Like its parents it is not normative. Stage 2 gives
this same server a device side, and every answer below was taken with that
in view.

## Pending questions

Left open on purpose, each with its owner.

- **Vite's dev server proxying the socket.** The faster development loop of
  answer 8, which needs a preference listing extra allowed origins and a
  forwarding entry in the Vite configuration. Taken up by whoever develops
  the frontend, when the rebuild-and-reload loop chafes.
- **Zed in `edit`'s table.** Checked by increment 9: Zed is absent from
  Julia 1.13.3's editor table, and the fallback runs `zed path` without
  the line. The inspector's README gives the `InteractiveUtils.define_editor("zed")`
  entry for `startup.jl`; the package carries no editor code (answer 6).
  Proposing the entry upstream is open.
- **A token in the URL.** Stage 2's, if commanding a run over the socket
  earns more than the `Origin` check (answer 6).
- **A protocol version.** Stage 2's, needed only if a third client ever
  speaks the protocol (answer 5).
- **A raw user exception escaping a probe.** The failure bump's. Until it
  rules, `inspect(root)` lets it propagate and the tab keeps its previous
  descriptor (answer 7).

## Answered questions

1. **The `inspect` entry points: the root, the two artifacts, the carrier.**
   `inspect(root::AbstractComponent)` runs `Build(root)`, pushes the build
   descriptor on success and, on a `DiagnosticError`, pushes the failure
   descriptor and rethrows. `inspect(build::Build)` and
   `inspect(deployment::Deployment)` push the artifact's descriptor.
   `inspect(err::DiagnosticError)` pushes the failure descriptor of an
   error thrown elsewhere, which at the REPL is the `err` binding after a
   failed `Model(root)`; `err` holds an exception stack, so the package
   accepts a `Base.ExceptionStack` as a fifth form and takes the last
   `DiagnosticError` in it (increment 9). Stage 2 adds `inspect(sim)`. Every method takes
   `name` and returns `nothing`. The root form builds a `Build` only; a
   user who wants concrete `Δt` builds the `Deployment` and passes it.
   *Why:* the root form serves the edit loop with one call per iteration,
   the artifact forms serve a user with one in hand, and the `err` form
   costs one method. Rethrowing keeps the REPL's report beside the diagram
   and swallows nothing. Returning `nothing` keeps the REPL quiet, where a
   returned `Build` would print its whole `show` on every call.
   *Rejected:* artifacts only, which puts a `try` block or `err` between
   the user and every failure; the root only, as answer 8 literally reads,
   which makes a user holding a `Deployment` rebuild; deployment keywords
   on `inspect`, which duplicate `Deployment`'s signature.

2. **`write_descriptor` and the encoder: JSON.jl, two spaces, one code
   path.** `write_descriptor(path, x; name = nothing)`, destination first
   like `write(io, x)`, over the same argument set as `inspect`; the root
   form writes the failure descriptor and rethrows. Under it one primitive,
   `write_descriptor(io::IO, x; name)`, which the push into a channel also
   uses through an `IOBuffer`, so the file, the push and the live tab's
   download are one text. The encoder is JSON.jl version 1, at two spaces
   of indentation with a trailing newline, which settles the pending note
   of `descriptor_design.md` on pretty-printing. The package rebuilds the
   core's envelope with `name` right after `kind`, before the body, and
   `write_descriptor` writes no `name` unless given one. Nothing validates
   at runtime.
   *Why:* the core's round-trip test encodes `descriptor`'s value with
   JSON.jl and validates the parsed bytes; the same encoder at the same
   settings makes the bytes a client reads the bytes the suite validated.
   The push's bytes being the file's bytes means the page downloads the
   text it received, with no serializer of its own. `name` after `kind`
   makes a named and an unnamed descriptor of one model differ by one line.
   *Rejected:* JSON3, a second encoder whose rendering of a `Rational` or a
   `Float64` the core's test never sees; compact pushes, which cost the
   byte match for nothing on loopback.

3. **The server: one per process, HTTP.jl, spawned, a fixed port, loopback
   only.** A module-level slot holds one server per Julia process, started
   by the first `inspect` and never by `write_descriptor`. There is no
   public start or stop verb: the process's end is the server's end through
   `atexit`, and if the serving task dies the next `inspect` starts a fresh
   one. HTTP.jl serves the bundle and carries the WebSocket; its `serve!`
   runs the accept loop and each connection on spawned tasks, so in a
   multi-threaded session the page answers while the REPL thread is busy
   with a build, and in a single-threaded one it waits for the REPL to
   yield. The port is 8601 by default; when taken, the server tries the
   next few and prints the one it got; a keyword on the first `inspect`
   overrides it for the session and a package preference for the machine.
   It binds `127.0.0.1` only, and the opened URL spells `localhost`.
   Routes: `/` and the bundle's files from the bundle directory with
   `Cache-Control: no-cache`, and `/ws` for the socket. Remote use is SSH
   port forwarding, `ssh -L 8601:localhost:8601 host`, which delivers the
   connection to the server's own loopback and leaves its one assumption
   intact. The first `inspect` prints one `@info` line with the URL and
   the Vimium pattern of answer 7; later calls print nothing.
   *Why:* stage 2's "session-level server, per-simulation attach" is this
   object gaining a device side. A fixed port makes the Vimium exclusion
   a one-time edit, keeps a level's URL valid tomorrow and keeps the
   address retypable. Loopback decides who may connect, not which way
   messages flow: a server on `0.0.0.0` hands the descriptor, the source
   paths and, from stage 2, the staging of inputs to anyone on the
   network, and macOS prompts for it. *Rejected:* an ephemeral port, which
   breaks the three conveniences on an interface where they cost nothing;
   `@async`, which pins the server to the REPL thread; a framework over
   HTTP.jl, which adds nothing used.

4. **Channels: a name, its latest text, and the browser tabs listening.**
   The server keeps one channel per name: the name, `""` for the default,
   the latest pushed descriptor text, and the set of connected sockets.
   `inspect` stores the text first, pushes it to every socket of the
   channel, and opens a browser tab only when the set is empty. The name
   lives in the tab's URL, `/?tab=variant`, the default at `/` with no
   query, and the level stays in the hash, so a reload, a duplicated tab
   or a pasted URL announces the right channel with nothing kept in the
   browser; the page titles itself by the name. A channel is a channel and
   not a lock: every socket that greeted with the name receives every
   push. The text survives a close, so a tab closed by accident recovers
   on reopening its URL, and "closing a tab frees the name" means only
   that the next `inspect` of that name opens a browser tab again. The
   greeting is one message from the page naming its channel and the
   format major its bundle reads; the server answers with the stored text
   if any, and otherwise nothing, the landing panel staying up with the
   status bar reading "connected, waiting for `inspect`". The format check
   itself stays in the page's loader, which reads every descriptor's
   header, pushed or dropped; the two majors can differ only in answer 8's
   loop, where the server prints a warning from the greeting and pushes
   anyway. The browser opens through a dozen inline lines, `open` on
   macOS, `xdg-open` on Linux, `cmd /c start` on Windows, detached with
   output discarded; a failure to launch is a warning with the URL, never
   an error, and the preference `open_browser = false` turns it off for
   the remote case.
   *Why:* storing before opening makes the race harmless, since the
   greeting finds the text however long the browser takes. Several
   sockets per channel cost nothing and serve a second monitor. The
   sequence from the keystroke: build, store, ask the OS to open the URL,
   the browser fetches the page and its files, runs them, tries the
   handshake, greets, receives the text, draws. *Rejected:* refusing a
   second socket on a name, which needs an "already open" page and a rule
   for which tab is real; replacing the first with the second, which
   leaves a dead page; a browser choice, since the system default is the
   one with the user's Vimium exclusions.

5. **The protocol: typed text frames for control, the descriptor as its
   own bytes, live or hosted by one handshake.** A control message is a
   JSON object with a `type`; stage 1 has two, both from the page, `hello`
   with the channel and the format major, and answer 6's `open_location`.
   Stage 2 adds subscribe, stage, control and history as more types, and
   binary frames for values. The descriptor goes server to page as the
   pretty-printed envelope text in one text frame, unwrapped; the page
   tells it from a control message by one rule: an object with
   `format_version` at the top is a descriptor and one with `type` is a
   control message, and the schema's strictness guarantees an envelope
   never carries `type`. The page keeps the raw text for the download and
   feeds it to the loader a dropped file goes through. On load the page
   always tries a WebSocket to `/ws` at its own origin: the inspector's
   server accepts and the page is live; GitHub Pages fails the handshake
   at once and the page is the hosted copy, with no retry and no
   connection indicator. A connection lost after a successful one is the
   server going away, and the page retries with a backoff and greets again
   when a server answers. No keepalive: loopback is reliable, a closing tab
   sends a close frame, and a failed send drops the socket. No protocol
   version field: the bundle and the package ship under one tag (answer
   14), so the two ends are always one release. The document is
   `frontend/PROTOCOL.md` in the inspector repo, one section per message
   type, each stage appending. This brings the status bar's connection
   state forward from stage 2 to stage 1, an amendment to `workspace.md`'s
   answer 1, since the connection now exists in stage 1.
   *Why:* wrapping the envelope inside a control message either
   double-encodes it as a string or forces the page to re-serialize for
   the download, where JavaScript's number formatting breaks answer 2's
   byte match. One bundle serving both deployments has no way to know its
   server but to ask the question only the live server answers.
   *Rejected:* a control frame announcing the descriptor frame that
   follows, which couples two frames; a build flag or a URL marker for the
   hosted copy, a second bundle in all but name.

6. **Open-in-editor through `edit`, behind the descriptor's locations and
   an `Origin` check.** A click on a location in the detail pane sends
   `open_location` with the file and line. The server runs
   `InteractiveUtils.edit(file, line)` on a spawned task, so an editor that
   waits blocks no receive loop, and only when the pair appears among the
   locations of the channel's current descriptor's `types` table;
   otherwise it drops the request with a warning on the REPL. That set is
   exactly the set of rows the page can offer, since a wire or a face has
   no location of its own and the code behind a wire is reached through
   the enclosing assembly's method rows; the pending bump on further
   locations would grow both lists at once, being one list read twice. The
   line is the build's, so an edit since the last push may land a few
   lines off, as `@edit` does. The server accepts a WebSocket handshake
   only when its `Origin` header is the server's own address,
   `http://localhost:8601` or `http://127.0.0.1:8601`; a page from any
   other site is refused before it can greet. Nothing else is promised: no
   TLS, no login, and a local process that is not a browser connects
   regardless, as it could read the files anyway; the help page's about
   section and the protocol document say so.
   *Why:* `edit` is the function behind `@edit`, honors `JULIA_EDITOR`,
   `VISUAL` and `EDITOR`, and knows the common editors' line syntax, so
   the package carries no editor preference of its own. A browser lets any
   page open a WebSocket to loopback, and loopback does nothing against it
   because the browser is on the machine; `Origin` is the one header the
   page's code cannot alter. *Rejected:* an editor command in a
   preference, which duplicates Julia's convention; a secret token in the
   URL, as Jupyter and Pluto do, which costs every convenience the fixed
   port bought.

7. **The failure bump lands before the package's increment; the notice is
   `@info`, once.** `inspect(root)` on a carrier and `inspect(err)` both
   call `descriptor(err::DiagnosticError)`, which `descriptor_design.md`'s
   answer 13 left to the failure bump together with the carrier's
   `structure` field and the encoding of a diagnostic as data. The bump,
   a short session and a small core increment, lands at any point before
   the package is built, so the package's first increment ships all four
   `inspect` methods; the page side is already settled by `workspace.md`'s
   answer 10. The Vimium pattern prints once per process on the first
   `inspect`, in the same `@info` line as the URL, with the fuller
   explanation on the help page's keyboard section; nothing detects the
   extension.
   *Why:* a first package increment whose root form rethrows without
   pushing would split the edit loop's main value, a failure drawn, across
   two increments. `@info` respects the session's logger, so a user who
   finds the line noisy silences it with the standard tools.
   *Rejected:* a preference for the hint; `println`.

8. **The development loop: a `bundle_dir` preference, fixtures without
   Julia.** The production server reads the `bundle` artifact, the folder
   Pkg unpacks on install from the release asset `Artifacts.toml` names,
   through `artifact_hash` and `artifact_path` at runtime, since the
   `artifact"bundle"` macro refuses to load while the entry is absent
   (increment 9). The
   preference `bundle_dir` makes it serve that directory instead, each
   file read from disk on every request, so `vite build --watch` in
   `frontend/` and a browser reload show an edit against the real server,
   socket and descriptors. Most frontend work needs no Julia: the committed
   fixture descriptors open in Vite's dev server through the file loader
   with instant updates, and the Playwright checks run on them; the live
   session is needed only for the push, the greeting, open-in-editor and
   the real writer's output, where a reload is an adequate loop. Revise
   covers the request and message handlers, which the server calls by
   name; a change to the session or channel structs needs the unexported
   `stop!`, which closes the server and clears the slot, reached by
   qualified name. The greeting's version warning of answer 4 is this
   loop's only user.
   *Why:* serving a folder is what the production server already does, so
   the preference adds no code path. *Rejected:* Vite's dev server
   proxying `/ws`, which needs a second preference for the extra origin
   and a configuration entry, kept pending above; developing the live path
   only through the installed artifact.

9. **The standalone HTML export: deferred whole.** One `.html` holding the
   bundle and one descriptor, double-clicked and read offline. The
   mechanism is known: Vite's single-file plugin emits the bundle as one
   HTML file, `write_page(path, x)` inserts the descriptor text in a
   `<script type="application/json">` element before the closing tag, the
   loader gains a fourth source beside drop, pick and push, and the
   handshake already fails fast on a `file://` page. The costs are a second
   build target, about 1.5 MB per file since ELK alone is that size
   uncompressed, and a third exported function. Nothing in stage 1
   anticipates it, and nothing designed here stands in its way.
   *Why:* sharing already works in two steps, `write_descriptor` and a
   drop on the hosted copy, offline once cached and uploading nothing; the
   export collapses them into one at the price above, and a request for a
   file to email is what user feedback answers better than we can.
   *Rejected:* building it now; building the single-file bundle in CI for a
   function that comes later, the spike's lesson on a dependency held for
   a later need.

10. **The package, its tests, the fixture script, the hand-on; the schema
    moves beside its writer.** The package is `RedstoneInspector`, the repo
    `RedstoneInspector.jl` with the Julia package at its root and
    `frontend/` beside it (answer 14); its dependencies are Redstone, HTTP,
    JSON, Preferences and the standard library's Artifacts and
    InteractiveUtils. Its test suite runs with no browser and no bundle:
    a server on port 0 with `open_browser = false` and a stub `bundle_dir`,
    and HTTP.jl's WebSocket client playing the page: a greeting receives
    bytes equal to `write_descriptor`'s on the same artifact, a second
    `inspect` arrives as a push, a greeting on an empty channel receives
    nothing, a foreign `Origin` is refused, an `open_location` outside the
    descriptor's locations is dropped and one inside reaches a stand-in
    editor set through `JULIA_EDITOR`, and `write_descriptor`'s root form
    on a failing model writes a failure descriptor and rethrows; the
    browser itself is checked by looking, under answer 11's review model.
    `scripts/fixtures.jl` in the inspector repo, run against the pinned
    Redstone, builds the examples package's models and the repo's own
    synthetic model, writes each with `write_descriptor` into
    `frontend/fixtures/`, and copies the schema of record into
    `frontend/schema/`; both copies are committed, so the frontend builds
    and tests without Julia, and the pipeline fails when regeneration
    differs (answer 16). In the core, the schema of record moves from a
    root `schema/` directory to `src/descriptor.json`, beside
    `src/descriptor.jl`; the inspector reads it from `pkgdir(Redstone)` as
    before.
    *Why:* the bundle build is a Node job on machines that may have no
    Julia, so the schema copy is a pinned snapshot with a drift check, the
    rule the fixtures already follow, and a pin bump shows the format's
    change as a reviewed diff. A root directory for one file was out of
    proportion beside `src`, `test`, `examples` and `docs`, and the schema
    is the writer's contract, changed in the writer's commit.
    *Rejected:* running Julia inside the bundle build to resolve
    `pkgdir`; fetching the schema from the core repo at the pinned tag at
    build time, which fails offline and states the pin twice;
    `src/schema/descriptor.json`, the same one-file directory one level
    down.

## Design axes

This session closed axis 6. What it hands on, in working order:

1. **The schema's move**, `schema/descriptor.json` to `src/descriptor.json`,
   with the sweep of every citation (answer 10). Its own small commit.
2. **The failure bump**, before the package's increment (answer 7): the
   carrier's `structure` field built, `descriptor(::DiagnosticError)`, the
   encoding of a diagnostic as data, and its ruling on a raw user
   exception. Its body and the deployment overlay's bump stay as
   `visual_grammar.md` hands them on.
3. **Axis 7**, build, release and verification, with what this session
   adds: `scripts/fixtures.jl` wired into CI; the TypeScript types
   generated from the committed schema copy at bundle build time, and the
   generator's choice; the CI that builds the bundle, attaches it to the
   release and updates `Artifacts.toml`; the hosted copy's address, which
   fixes the schema's `$id` and the help page's second Vimium pattern; the
   Documenter `@ref` links of the detail pane; and the release checklist
   that keeps one tag for the package and the bundle. Ran on 2026-10-29
   and 30; its record is `build_release.md`.
4. **The package's increment**, after the frontend of axes 3 to 5 and the
   failure bump: the four `inspect` methods and `write_descriptor` with its
   `IO` primitive, the server with its channels, the protocol's stage 1
   half and `frontend/PROTOCOL.md`, open-in-editor and the `Origin` check,
   the three preferences `port`, `open_browser` and `bundle_dir`, the
   unexported `stop!`, and the test suite of answer 10. The Zed check of
   the pending list runs in it.
5. **Stage 2's device side**, over this server as built: the channel's
   sockets are the subscribers, control messages are more `type`s, values
   are binary frames, the `Origin` check already guards the socket that
   will stage inputs, `inspect(sim)` is the fifth method, and the token
   and the protocol version wait on the pending list above.

## Glossary

- **Bundle directory.** The folder the server serves the page from: the
  artifact Pkg unpacked on install, or the `bundle_dir` preference's
  folder in the development loop.
- **Channel.** The server's record for one name: the name, the latest
  descriptor text pushed to it, and the sockets of the browser tabs that
  greeted with it. The default channel's name is `""`.
- **Control message.** A text frame carrying a JSON object with a `type`
  field: `hello` and `open_location` in stage 1, stage 2's verbs later.
- **Descriptor frame.** A text frame carrying the pretty-printed envelope
  as its own bytes, told from a control message by its `format_version`
  key.
- **Greeting.** The page's first message after the handshake, `hello` with
  its channel name and the format major its bundle reads; the server
  answers with the channel's stored text if any.
- **Handshake.** The HTTP request that asks a server to open a WebSocket at
  `/ws`. Accepted by the inspector's server when the `Origin` is its own,
  refused by GitHub Pages, which is how the page learns whether it is live.
- **Hosted page, live page.** The same bundle loaded from GitHub Pages,
  with no socket, or from the inspector's server, with one.
- **Loopback.** The interface `127.0.0.1`, reachable only from the machine
  itself. The server binds it and nothing else.
- **Origin.** The scheme, host and port a page was loaded from, which the
  browser puts in every handshake and the page's code cannot alter.
- **Preference.** A per-machine setting read through Preferences.jl: `port`,
  `open_browser` and `bundle_dir` in stage 1.
- **Spawned task.** A task created with `Threads.@spawn`, free to run on any
  thread, against an `@async` task pinned to the thread that made it.
