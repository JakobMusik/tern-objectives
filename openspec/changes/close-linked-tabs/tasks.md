# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`; after each edit, `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again. Plugin timers fire only with window activity: use `/tmp/tobj/bin/pump`.
- **Helper ops** (`/tmp/tobj/bin/op`): `sessions`, `panes`, `new_tab`, `split`, `float`, `close`, `run`, `focus`, `agents`.
- **Objectives** are set up in `kv.json` with the plugin reloaded after (`ctl plugins fixtures`): links added to existing objectives, `done` set with a `done_at`.
- **Chats:** omp chats in folders under `/tmp/tobj/w/`, one short message each.
- **After the checks**, delete `~/.omp/agent/sessions/--private-tmp-tobj-*` and stop the harness service.

## 1. Spike

- [ ] 1.1 Check D5 and the tab-closing assumption with a helper op that closes every row pane of a tab, as D4 will.

  Verify, and record in design.md's source record:
  - closing every pane of a tab with a split and a float removes the tab (op `sessions`);
  - with the graph open over tab T, closing T's other panes: does T survive holding the glimpse? (op `sessions`, `ctl tree '.ob-root'`)

  If either differs from D4 and D5, stop and update the artifacts.

## 2. Close linked tabs

- [ ] 2.1 `Agents.save_now(cx, done)` (D4): run the capture at once and report when it has saved.

  Verify: a helper op calling it on a tab with a replied omp chat, whose saved entry was removed from `kv.json` first, sees `done(true, …)` called, and the kv dump holds the chat again afterwards.
- [ ] 2.2 The menu row and the confirmation (D1, D2, D3), the close (D4) and the graph's own tab (D5).

  Verify each scenario of "Objective menu" and "Closing a done objective's tabs":
  - X (done) linking tabs A, B, C with open Y linking C: X's ⋯ menu shows "Close linked tabs · 2 open tabs" (shot), and Y's has none;
  - a done objective whose only open tab Y also links shows no row;
  - Cancel leaves A, B, C open and `kv.json` unchanged;
  - confirming closes A and B and keeps C (op `sessions`), the kv dump still links X to A, B and C, and a shot shows the toast;
  - A held a replied omp chat: selecting X shows A under "Closed tabs" with "Resume", its row "omp";
  - with the graph opened over B, confirming leaves no tab holding only the graph, and the graph shows again.

## 3. Closed tabs and Prune

- [ ] 3.1 The view (D6): `closed` keeps only tabs an open objective, the selected objective or a listed review objective links; `Built.prunable` and the Prune button follow it.

  Verify each scenario of "Done objectives' closed tabs", "Prune button visibility" and review mode's "Closed tab in review", with `ctl tree` counts of `.ob-t-<tab>` and the header button, and a shot of review mode showing the dashed line and "Resume".
- [ ] 3.2 Prune (D7): open objectives' links only; snapshots and saved chats only when no done objective links the tab.

  Verify "Prune after closing a tab" and "Done objective's link kept" with kv dumps before and after confirming.

## 4. README

- [ ] 4.1 "Using the graph": the "Close linked tabs" row, what it closes and keeps, that omp chats come back with Resume, and where done objectives' closed tabs show; Prune keeps them. "Known limits": no undo, programs end, a chat in its first reply or on another machine can't come back.

  Verify by reading the sections against the delta specs.

## 5. Release 0.12.0

- [ ] 5.1 Version `0.12.0` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.12.0`. Tick this box, then commit, push `main` and tag `v0.12.0` (annotated, message "objectives 0.12.0").
- [ ] 5.2 **(live)** After the push has finished, `tern plugin install github.com/JakobMusik/tern-objectives --force`, from a shell with no harness variables. Verify `tern plugin list` shows `objectives 0.12.0 … ready`, with `tabnav 0.1.0` untouched.
- [ ] 5.3 **(live)** With the user: "Close linked tabs" on a done objective closes its tabs, keeps one an open objective links, and the closed ones show with Resume when the objective is selected; "Prune closed tabs" leaves them. Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive close-linked-tabs --yes`), run `openspec validate --specs --strict`, commit and push.
