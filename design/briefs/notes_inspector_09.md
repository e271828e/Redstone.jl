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
- The bookkeeping edits to `design/pending.md` and
  `design/briefs/roadmap_inspector.md` are proposed at the end of this
  file once the increment lands, since the frontend session edits the same
  files in the shared tree.
