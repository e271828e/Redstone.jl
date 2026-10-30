# Notes: inspector increment 9, the server

Rulings taken while the user was away, 2026-10-30, each with its reason,
for the user to ratify or strike. The brief is
`brief_inspector_09_server.md`; a struck reading is removed there too.
Nothing was pushed: the inspector's work sits on the branch `increment-9`
in the worktree `~/.julia/dev/RedstoneInspector_inc9`, and the core's
commits are local.

## Facts found by probing

1. **HTTP.jl resolves to 2.x.** The depot holds 1.10.17, 1.11.0 and 2.6.7,
   and the default environment's manifest has 2.6.7. Version 2 is a
   rewrite: `HTTP.listen!(f, host, port)` runs a stream handler,
   `HTTP.WebSockets.upgrade(f, stream; check_origin)` turns a stream into
   a socket with the `Origin` policy as a callback `(request, origin) ->
   Bool`, `HTTP.fileserver(dir; cache_control)` serves a directory,
   `HTTP.port(server)` returns the bound port, and `listenany = true`
   binds an ephemeral port. Server tasks run on the `:interactive` thread
   pool. Everything `live_session.md` answers 3 to 6 ask for exists in it.
2. **`artifact"bundle"` refuses to expand with no entry.** With an
   `Artifacts.toml` holding only the comment, a file containing
   `artifact"bundle"` fails at load with "Cannot locate artifact
   'bundle'", before any code runs. `Artifacts.artifact_hash("bundle",
   toml)` returns `nothing` at runtime instead, and `artifact_path(hash)`
   gives the directory.
3. **Zed is not in Julia 1.13.3's editor table.** `InteractiveUtils`'s
   `define_default_editors` knows vim, gvim, nano, gedit, micro, kak,
   helix, textmate, kate, subl, atom, pycharm, bbedit, code, notepad++
   and `open`; an unknown editor hits the fallback `cmd path`, which
   drops the line. Zed's CLI takes `zed path:line[:column]`. The user's
   environment has `EDITOR=nvim`, no `JULIA_EDITOR`, and `startup.jl`
   defines no editor.
4. **The format major lives at `Redstone.DESCRIPTOR_FORMAT.major`**
   (`src/descriptor.jl:10`), unexported.
5. **The `types` table's path by kind**, from the committed fixtures:
   `build.structure.types`, `deployment.build.structure.types`,
   `failure.structure.types`; `failure_structure.json` has no `structure`
   and so no locations.

## Readings

1. **HTTP.jl 2, `[compat] HTTP = "2"`.** It is what a fresh add resolves,
   and its stream handler plus `upgrade` cover the three routes in one
   server. Pinning 1.x would start the package on a version the registry
   is leaving.
2. **The bundle resolves at runtime** through `artifact_hash` and
   `artifact_path`, never the macro (fact 2). `build_release.md` answer 3's
   expectation, "the server finds no bundle and its error names
   `bundle_dir`", holds through this route; `live_session.md` answer 8's
   phrase "reads `artifact"bundle"`" is amended in the bookkeeping to name
   the runtime lookup.
3. **Preferences are read at call time** with `load_preference`, not the
   `@load_preference` macro, so an edit takes effect at the next start
   without recompiling. The unexported `start!(; port, open_browser,
   bundle_dir)` takes the three as keywords defaulting to the preferences,
   which is how the suite runs a server on port 0 with `open_browser =
   false` and the stub bundle without writing a `LocalPreferences.toml`
   into the workspace. Answer 3 says "no public start or stop verb";
   `stop!` is already unexported, and `start!` is its twin.
4. **Ten ports, 8601 to 8610.** Answer 3's "the next few" needs a number.
   A `port` keyword given to `inspect` while a server already runs on
   another port is a warning naming the running port, never a restart,
   since a restart would drop every connected tab.
5. **The control messages' spelling.** `{"type": "hello", "channel":
   "<name>", "major": 1}` and `{"type": "open_location", "file":
   "<path>", "line": <n>}`. The record names the fields' content, not
   their keys; `frontend/PROTOCOL.md` fixes them for the frontend session.
   A message that is not a JSON object with a known `type` is dropped
   with a warning on the REPL and the socket stays open.
6. **The location set is computed from the envelope at push time**, every
   `locations` row of the `types` table (fact 5), and stored beside the
   channel's text; a failure descriptor with no `structure` has an empty
   set, so every `open_location` on that channel is dropped. The envelope
   is built once per push and both the text and the set come from it.
7. **The suite's stand-in editor** is a `define_editor` callback for a
   made-up editor name, set as `JULIA_EDITOR` for the test's duration,
   which records the file and line on a `Channel` and returns a no-op
   command. The fallback for an unknown editor passes no line (fact 3), so
   a script could not pin it, and a script named `vim` runs differently
   on Windows, where the `julia` job also runs.
8. **The Zed check's outcome** (fact 3): the package carries no editor
   code, keeping answer 6's principle; the README's open-in-editor section
   gives the `define_editor("zed")` entry for `startup.jl`, and the user's
   `startup.jl` is left alone. Proposing the entry upstream to Julia is a
   note for the user.
9. **The server task's death and the `@info` line.** The line prints on
   every start, which is once per process in the ordinary case; a restart
   after the serving task died prints it again, since the port may differ.
10. **The frontend half stays out.** The page's socket client, the status
    bar's connection state and the download land in the frontend track
    once increment 4 has the status bar, as agreed before the split;
    `frontend/PROTOCOL.md` is the contract between the two sessions.
11. **One lock.** A `ReentrantLock` on the session guards the channel table
    and each channel's socket set; a push iterates a copy of the set and a
    failed send drops the socket. Answer 4 says nothing about threads, and
    HTTP 2 runs the handlers on the interactive pool while `inspect` runs
    on the caller's.
12. **Two source files.** `src/RedstoneInspector.jl` keeps the module, the
    imports, `write_descriptor` and `inspect`; `src/server.jl` holds the
    session, the channels, the routes, the messages and the browser.
    `build_release.md` answer 3's layout says "RedstoneInspector.jl and its
    files".
13. **No merge into `master` and no push.** The branch waits for the user,
    since the frontend session commits to `master` in the main checkout in
    parallel, and the overnight rule pushes nothing.

## Open for the user

- Whether to add the Zed `define_editor` to `~/.julia/config/startup.jl`
  (reading 8), and whether to propose it upstream.
- The bookkeeping edits, proposed at the end of this file.

## Facts from the increment 2 session, for the merge

Received while the builder ran. Increment 2 is on the branch `increment-2`
in `~/.julia/dev/RedstoneInspector.jl-inc2`, also off `f8f7a3b`; the main
checkout is untouched by both sessions. Outside `frontend/` it edits only
`README.md`, a "Frontend" section inserted after "Fixtures" with the
layout list left to increment 9, and `.github/workflows/CI.yml`, a
`frontend` job appended after `fixtures`. Under `frontend/` it replaces
`schema/descriptor.json` with the core's edited schema and adds the Vite
project. The core gained `778d6ee`, a change to `src/descriptor.json`
alone, because both generator checks of `build_release.md`'s pending list
failed on the schema as pinned; the next pin bump moves to `778d6ee` or
later and the `fixtures` job's schema-copy check goes green only after
that bump. Increment 9 needs nothing from it and keeps the pin at
`4e51cbc`. The two branches touch no common file but `README.md`: the
"Frontend" section is increment 2's alone, and the layout list is a
two-sided hunk, increment 2 adding a `frontend/` line and renaming the
`CI.yml` line for its job, increment 9 adding its four lines; whichever
branch merges second rebases and keeps both sides.

## The builder's departures, for adjudication

The builder landed `1eb1414` (the server and its suite) and `390e85e`
(the protocol document and the README) on `increment-9`, 733 insertions
over nine files, 96 assertions, the gate green at `-t auto` and `-t 1` in
about 17 s, every mutant of the brief red but the named survivor. HTTP.jl
resolved to **2.14.0**, not the 2.6.7 the brief routed; the builder read
the routed files in that version. Nine departures, each with the
builder's reason; my view in brackets, the cold review pending.

1. `import HTTP`, not `using HTTP`: HTTP 2 exports `port`, `request`,
   `open`, `get`, and the brief's locals `port` and `request` would share
   a name with a function the module sees. [Right under the naming rule.]
2. `Session`'s fields reordered with an inner constructor leaving
   `server` unset until the bind, since the handler closes over the
   session. [Fine.]
3. `_write_envelope(io, envelope)` as the one JSON encoding, shared by
   `write_descriptor` and the push through `sprint`; the writer's bytes
   unchanged. [Fine; the brief's `_envelope` plus this is the split it
   asked for.]
4. The browser launch is `pipeline(detach(cmd); stdout = devnull, stderr
   = devnull)`; the brief's spelling was a `MethodError`. [The brief's
   error.]
5. `Base.invokelatest` on `edit` and on the two handler entries: an
   editor defined after the server started was invisible from a socket
   task ("method too new"), and the handlers' latest methods are what
   Revise's loop needs. [Right; answer 8's Revise claim depends on it.]
6. The stream handler catches `WebSocketError` only, so a refused
   handshake or a dropped page logs no handler error. [Fine.]
7. A second `hello` moves the socket to the new channel. [A reading the
   brief should have taken; one socket, one channel.]
8. The spawned `edit` is wrapped in try/catch with a `@warn`. [Fine.]
9. `open_location` requires `file isa String && line isa Integer`, since
   a JSON `2.0` would otherwise match line 2 through `isequal`. [Fine.]

Two things the builder raised for the user: `inspect` is unexported like
`write_descriptor`, while `live_session.md` answer 9 speaks of "a third
exported function", so the records assumed exports and D-226's rule says
otherwise; and `stop!` ends the server-side socket loops within about
0.25 s while the client sees no close frame at once.

## The cold review and its adjudication

The reviewer (one Opus agent, scratch copies only) ran the gate at both
thread counts (96 of 96, about 14 s of tests), 29 mutants, 13 of them its
own, and probes over every routed answer; no sentence of the records was
found broken but the two below, and no departure of the builder was judged
wrong. Twelve findings, all landed by a fixer as one commit; my rulings:

1. **F1, defect.** A dead serving task is not followed by a restart:
   `isopen(server)` stays true, `_session` reuses the dead session, and
   `stop!` throws from `forceclose` before clearing the slot. Fix: alive
   means `isopen` and the serve task not done; `stop!` clears the slot
   first and turns a `forceclose` error into a warning; a test kills the
   task and checks the restart and the quiet `stop!`.
2. **F2, docs.** `define_editor` is neither exported nor public from
   `InteractiveUtils` on 1.13.3; the README's and the brief's Zed snippet
   must qualify it.
3. **F3, record and docs.** At the REPL `err` is a `Base.ExceptionStack`,
   not the `DiagnosticError`, so `inspect(err)` as the record spells it is
   a `MethodError`. *Reading 14:* a fifth method,
   `inspect(stack::Base.ExceptionStack; name, port)`, takes the last
   `DiagnosticError` in the stack and errors plainly when there is none,
   so the record's gesture works as written; `live_session.md` answer 1's
   sentence is amended in the bookkeeping to say the stack is accepted.
4. **F4, F5, F6, missing tests**: the deployment and failure location
   paths; a second `hello` moving the socket; `atexit` registered once
   across restarts; `_session` honoring `port` on a first call. M22, a
   socket kept after a failed send, is accepted as defensive code.
5. **F7, F8**: `HTTP.escapeuri` for the deprecated `escape`; a binary
   frame is dropped with a warning, since stage 1's frames are text.
6. **F9, F10, naming.** `push!(session, name, envelope)` gave Base's
   generic a second meaning and a misleading error on a `Symbol` name:
   renamed `push_descriptor!`, and `inspect` takes `String(something(name,
   ""))`. `listening` becomes `listening_sockets`.
7. **F11, F12, nits**: the traversal test compares against the file the
   path resolves to; the README says `force = true` re-sets a preference.

## Outcome and the proposed bookkeeping

The branch `increment-9` stands rebased on the inspector's `master`
(`ccbedf8`), four commits, `a2d14eb`, `ebcb652`, `e423b9c` and `38b8c8e`,
128 assertions green at both thread counts; the brief's "Landed" section
has the arc. The worktree `~/.julia/dev/RedstoneInspector_inc9` can be
removed after the merge (`git worktree remove`). To land: from the main
checkout, `git merge --ff-only increment-9`, push, and watch the CI run,
the first check of the suite on Ubuntu and Windows.

*Reading 14*, taken at the review: `inspect(stack::Base.ExceptionStack;
name, port)` pushes the last `DiagnosticError` in the stack, because the
REPL's `err` is the stack and not the exception, so the record's gesture
`inspect(err)` works as written.

Proposed edits once merged, each a sentence:

- `design/pending.md`, the stage-1 bullet: increment 9 landed at `<merge
  hash>` with its brief; next is increment 3, the canvas, with the page's
  socket client due after increment 4 by `frontend/PROTOCOL.md`.
- `design/briefs/roadmap_inspector.md`, increment 9's entry: a landed
  line with the hash, and the facts the frontend takes: the message keys
  of reading 5, the `Origin` rule, the ten ports, the moving `hello`, the
  binary frames dropped, and that the frontend half waits for increment
  4.
- `design/inspector/live_session.md`: answer 1's "the `err` binding after
  a failed `Model(root)`" gains "which holds an exception stack, accepted
  as a fifth form" (reading 14); answer 8's "reads `artifact"bundle"`"
  becomes the runtime lookup through `artifact_hash` and `artifact_path`
  (reading 2); the pending list's Zed entry closes with reading 8's
  outcome. `build_release.md` answer 3 stands.
