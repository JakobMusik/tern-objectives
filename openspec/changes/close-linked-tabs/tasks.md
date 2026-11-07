# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`; after each edit, `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again. Plugin timers fire only with window activity: use `/tmp/tobj/bin/pump`.
- **Helper ops** (`/tmp/tobj/bin/op`): `sessions`, `panes`, `new_tab`, `split`, `float`, `close`, `run`, `focus`, `agents`.
- **Objectives** are set up in `kv.json` with the plugin reloaded after (`ctl plugins fixtures`): links added to existing objectives, `done` set with a `done_at`.
- **Chats:** omp chats in folders under `/tmp/tobj/w/`, one short message each.
- **After the checks**, delete `~/.omp/agent/sessions/--private-tmp-tobj-*` and stop the harness service.

## 1. Spike

- [x] 1.1 Check D5 and the tab-closing assumption with a helper op that closes every row pane of a tab, as D4 will.

  Verify, and record in design.md's source record:
  - closing every pane of a tab with a split and a float removes the tab (op `sessions`);
  - with the graph open over tab T, closing T's other panes: does T survive holding the glimpse? (op `sessions`, `ctl tree '.ob-root'`)

  If either differs from D4 and D5, stop and update the artifacts.

  Result (harness, 2026-11-07, helper op `close_tab`):
  - tab 7, holding panes 6 and 10 side by side and pane 12 floating over them: closing all three in one call removed the tab; "Default" read `[3]` again;
  - tab 23, holding pane 22 with the graph's glimpse (pane 26, kind "plugin") over it: closing pane 22 alone left tab 23 alive, holding only the graph. So D5's step is required, not a guard: when the graph's tab is among those closed, the graph closes first, and `finish` reopens it over the tab Tern shows next.

## 2. Close linked tabs

- [x] 2.1 `Agents.save_now(cx, done)` (D4): run the capture at once and report when it has saved.

  Verify: a helper op calling it on a tab with a replied omp chat, whose saved entry was removed from `kv.json` first, sees `done(true, …)` called, and the kv dump holds the chat again afterwards.

  Result (harness): with omp chat "f1" in pane 37 (`/tmp/tobj/w/ompF`, replied), the helper's `save_now` op, running a copy of the plugin's modules against the helper's empty store, got `done(true, cx)` after 245 ms, and that store then held pane 37: agent "omp", folder `/tmp/tobj/w/ompF`, file `--private-tmp-tobj-w-ompF--/2026-11-07T06-02-45-696Z_….jsonl`. It is the same file the plugin itself saved at the turn's end, through the reworked `request()`.
- [x] 2.2 The menu row and the confirmation (D1, D2, D3), the close (D4) and the graph's own tab (D5).

  Verify each scenario of "Objective menu" and "Closing a done objective's tabs":
  - X (done) linking tabs A, B, C with open Y linking C: X's ⋯ menu shows "Close linked tabs · 2 open tabs" (shot), and Y's has none;
  - a done objective whose only open tab Y also links shows no row;
  - Cancel leaves A, B, C open and `kv.json` unchanged;
  - confirming closes A and B and keeps C (op `sessions`), the kv dump still links X to A, B and C, and a shot shows the toast;
  - A held a replied omp chat: selecting X shows A under "Closed tabs" with "Resume", its row "omp";
  - with the graph opened over B, confirming leaves no tab holding only the graph, and the graph shows again.

  Result (harness; X = "Write release notes" (o2, done) linking A = 38 (omp chat "f1", pane 37), B = 81 and C = 83; Y = "Fix login bug" (o1, open) linking C; Z = "Add caching layer" (o3, done) linking only C):
  - X's menu had 6 rows, the fifth "Close linked tabs · 2 open tabs" with the ⊗ icon, before Delete (shot `s22_menu`); Y's and Z's had the usual 5;
  - the confirmation read "Close 2 tabs · 1 tab linked to an open objective stays open; ends their programs; omp chats come back with Resume" (shot `s22_confirm`). Cancel left tabs `[3,38,81,83]` and the objectives' JSON unchanged;
  - confirming ran a capture (log: 199 ms, 1 saved), then left tabs `[3,83]`; X still linked `[38,81,83]`; 38's snapshot held pane 37 as an agent, and 37's chat file was saved. Shot `s22_closed` shows the toast "Closed 2 tabs of “Write release notes”", and the graph was shown again;
  - selecting X showed tab 38 in the `Linked to` section with one `.ob-resume`, its row "omp";
  - with tab D = 100 linked to X and the graph opened over it, confirming "Close 1 tab" left tabs `[3,83]`, no tab holding only the graph, and the graph shown again over tab 83.
- [x] 2.3 The done notice's button (D8): counted when marking done, "Close <n> tabs" after Undo, the same confirmation, the notice ended on confirm and kept on cancel; unselectable like the rest of the notice.

  Verify each scenario of "Closing tabs from the done notice": the header text after marking a linked objective done (`ctl tree '.ob-undo'`, shot) with its tabs still open; Cancel then Undo leaves the tabs open and the objective open; confirming closes the tabs, keeps the objective done and linked, and removes the notice; an objective with no open tabs gets no button.

  Result (harness; "Review pull requests" (o5, open) linking new tabs E = 113 and F = 116):
  - its done box gave the notice "Marked done “Review pull requests” · Undo · Close 2 tabs" (shot `s23_notice`), with tabs `[3,83,113,116]` still open;
  - "Close 2 tabs" opened the confirmation "Close 2 tabs"; Cancel brought the graph back with the notice and both buttons, and Undo then left the tabs open and o5 open (`done` false, no `done_at`);
  - marking it done again and confirming from the notice left tabs `[3,83]`, o5 done and still linking 113 and 116, and no notice;
  - "Ship the README" (o8), with no tabs, got "Marked done “Ship the README” · Undo" only;
  - with o8 linked to tab 129, a drag across the whole notice ("… · Undo · Close 1 tab") changed no pixel in any of its five parts between shots `s23_before` and `s23_drag` (`hl.py`: 0.00 each). Tab 129 stayed open.

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
