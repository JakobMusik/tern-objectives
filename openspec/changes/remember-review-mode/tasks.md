# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`. After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells). Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Reading:**
  - `ctl tree '.ob-obj'` for the left column, and `ctl tree '.ob-revbtn'` for the Review button and its `ob-on` class;
  - `/tmp/tobj/bin/kv` for the store;
  - `ctl shot NAME` for a PNG and layout JSON.
- **Data:** a store with three open objectives ("Fix login bug", "Review pull requests", "Write slides") and done objectives, two of them due today. Restore it from a copy under `/tmp/tobj` before each scenario that rates or removes.
- **After the checks:** stop the harness service.

## 1. Remember review mode

- [ ] 1.1 Keep the window's flag across opens (design D1, D2): `M.open` no longer clears `reviewing`. Update the comments on `reviewing` in `lib/app.luau`.

  Verify each objective-review "Leaving review mode" scenario, toggling the graph with `plugins run plugin.objectives.open` and reading `ctl tree`:
  - "Reopened in review mode": "Review (2)" has `ob-on` and only the two due objectives are listed;
  - "Left before closing";
  - "Nothing due at the next open": remove the due record from the harness `kv.json` by hand, then put it back;
  - "Forgotten on reload", with `ctl plugins fixtures`;
  - "Last one rated", "Button clicked again" and "Picker from review mode", unchanged.

  Also check that a fresh open in review mode still clears the Undo notice, and that the settings page's "Next open shows the graph" still holds: ⌃⌘O twice from the settings page shows the columns.
- [ ] 1.2 ⌥N ends review mode (design D3) in `M.new_key`.

  Verify each objectives-graph "New objective key" scenario, using `ctl key Alt+n`, typing the title, and reading `ctl tree` and the kv dump:
  - "From review mode";
  - "From a shell after review mode", with focus in a shell pane;
  - "In the graph" and "From a shell", unchanged.

  Also check that a dismissed title field (Esc) leaves review mode ended.
- [ ] 1.3 README: in "Reviewing done objectives", one sentence saying review mode stays on when you close the graph and comes back at the next open in that window, until it ends or Tern restarts. Verify by reading the section.

  Also check the render times in `/tmp/tobj/logs/tern-serve.log`, with no errors.

## 2. Release 0.18.0

- [ ] 2.1 Version `0.18.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.18.0`. Tick this box, then commit, push `main` and tag `v0.18.0` (annotated, message "objectives 0.18.0").
- [ ] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.18.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.
- [ ] 2.3 **(live)** With the user:
  - close the graph in review mode and open it again: it shows review mode;
  - ⌥N from review mode shows the new objective in the list;
  - with review mode remembered in one window, the graph in a second window that hasn't been in review mode opens without it.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive remember-review-mode --yes`), run `openspec validate --specs --strict`, commit and push.
