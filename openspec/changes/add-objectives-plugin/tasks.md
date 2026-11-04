# Tasks

All checks run in the headless harness from design.md D14 (`/tmp/tobj`) unless a task is marked **(live)**. "kv dump" means reading `/tmp/tobj/config/plugin-data/objectives/kv.json`.

## 1. Scaffold and harness

- [x] 1.1 Create the package files:
  - `plugin.toml`: schema 1, id `objectives`, name "Objectives", version `0.1.0`, a description, `window = "window.luau"`, `styles = ["styles.css"]`;
  - a loading `window.luau` and `styles.css`;
  - `LICENSE`: MIT, © 2026 nyclanker.

  Verify: `tern plugin install <repo>` against an isolated `TERN_CONFIG_DIR=/tmp/tobj-install/config` prints `installed objectives 0.1.0`, and `tern plugin list` there shows it ready.
- [x] 1.2 Build the harness from D14 under `/tmp/tobj`: the fixtures copy, the `tern serve` service and a ctl helper.

  Verify: `ctl plugins fixtures` loads `objectives` with no plugin errors in `/tmp/tobj/logs`, and `ctl state` answers.
- [x] 1.3 Start `README.md` with:
  - the install command;
  - that the plugin is window-half only and needs nothing on `PATH`;
  - the data location `plugin-data/objectives/kv.json`;
  - removal with `tern plugin remove objectives`.

  Verify: the README's `tern plugin remove objectives`, and an install of the local repo folder, both succeed against the isolated config. The `github.com/…` form can only succeed once the repository exists, so it is checked in 9.4.

## 2. Risk checks before feature work

- [x] 2.1 Glimpse check (design R1/D2). A stub `open` command shows a canvas glimpse with one button that jumps to a pane in another session and one that opens `cx:pick`.

  Verify with `ctl click`, `shot` and `state`:
  - (a) after the jump, the target pane is focused and uncovered;
  - (b) a picker answer still reaches the handler;
  - (c) running `open` twice leaves exactly one canvas with owner `objectives` in `cx.canvas:list()` (kv dump of the list).

  If any of these fails, switch D2 to the side panel and update design.md before continuing.

  Result: (b) and (c) passed. (a) left the glimpse docked as a split in the old tab; closing the canvas before every jump fixed it with the glimpse kept, so the side panel was not needed (design D2, R1).
- [x] 2.2 Edge rendering check (design R2/D4). A stub graph with three fixed nodes per column, and masked edge layers coloured by `--bad`, `--warn`, `--accent` and `--t3`.

  Verify:
  - shots at 1400 px and 460 px wide, under both `ctl appearance light` and `ctl appearance dark`, show coloured lines;
  - `ctl dump` shows the line ends within 2 px of the node centres.

  If masks don't render, switch to the background-image palette fallback and update design.md D4/R2.

  Result: masks paint nothing (the SDK confirms `mask-image` takes gradients only), and `--accent` is teal in the harness theme. Switched to `background-image` edges in a fixed-width gap with one red/orange/blue/grey palette (design D4, R2). Measured with `/tmp/tobj/bin/edgecheck.py`, which samples the shot's pixels at both gap edges against the layout rects: every end within 0.6 px at 1400 and 460 px, light and dark, plus the selected layer.

## 3. Store and objective editing

- [x] 3.1 Implement the store (D6, D7) and wire a basic open-objective list into the graph:
  - schema v1 with a default state;
  - `mutate` with read-before-write, id allocation and time helpers;
  - the canvas shell with the header's "＋ New objective".

  Verify with `ctl click` on "＋ New objective", `ctl type` and `key Enter`, then a kv dump:
  - "  Fix login bug  " is stored trimmed, at P2, not done, with a created time;
  - a blank title stores nothing;
  - a 130-character title is cut to 120.
- [x] 3.2 Read-before-write.

  Verify: add an objective to `kv.json` from outside the graph, rename another objective in the graph, and confirm with a kv dump that both are present.
- [x] 3.3 Objective nodes:
  - fixed-height layout with the done box, priority badge, title, ⋯, dimmed note, due chip, tag chips and the hover tooltip;
  - ordering: priority, then due date, then created;
  - the priority cycle P0→P1→P2→P3→P0 with red, orange, blue and grey badges;
  - the done toggle and a collapsible "Done (n)" group, most recent first.

  Verify:
  - the four-objective ordering scenario, by shot;
  - a P3 click turns the objective P0 and red, by kv and shot;
  - done then reopen sets and then clears `done_at` and keeps the links (kv);
  - a 200-character note keeps the node height (`ctl dump`).
- [x] 3.4 The ⋯ menu, through `cx:pick` and `cx:prompt`:
  - **Rename**, pre-filled.
  - **Side note**: one line, cut to 200 characters, empty clears.
  - **Due date**: Today, Tomorrow, Friday, Next Monday, In 1 week, "Pick date…" with validation, Clear; plus the chip texts and colours.
  - **Tags**: normalised; toggle with a check; "New tag…"; unused tags disappear.
  - **Delete**, with confirm and cancel.

  Verify each spec scenario by click, type and kv dump: "2026-02-30" is rejected with a toast, "  Web Work " becomes `web-work`, a cancelled delete leaves `kv.json` unchanged, and a dismissed field changes nothing. Check the chip colours for overdue and tomorrow by shot.

  Result: all passed. Tern's one-line field drops a pasted line break before the plugin sees it, so the Multi-line paste scenario was reworded (approved) to "stored as one line", and the README notes it.
- [x] 3.5 Empty state hint.

  Verify: a shot with an empty store shows the hint, with tabs still listed on the right.

## 4. Tab column and links

- [ ] 4.1 Right column (D9):
  - sessions in Tern's order, with the current one marked;
  - tabs in order;
  - labels: the tab's name, else the first leaf pane's title;
  - the dimmed "<session> · tab <n>" line;
  - pane rows including floats, excluding parked panes and the graph's own pane.

  Verify by shot of a harness with three sessions, a split tab, one floating pane and one parked pane.
- [ ] 4.2 Selection with ＋/× link buttons, snapshot writing (D8), and faded dashed unlinked tabs.

  Verify:
  - click ＋ then × on one tab: the kv dump shows the link and then no link;
  - the snapshot holds label, session id and name, position, panes and window key;
  - a shot shows a faded tab turning solid when linked.
- [ ] 4.3 Link status:
  - derived live, closed and elsewhere states;
  - "Closed tabs" and "Other windows" groups;
  - the "Prune closed tabs" button, shown only when a closed tab exists, with a confirmation that names the count.

  Verify:
  - closing a linked tab gives a ghost and the button (shot);
  - setting a snapshot's window key to "9" in `kv.json` gives an elsewhere tab (shot);
  - a confirmed prune removes only the closed tab's links and snapshot (kv dump);
  - after a plugin reload (`ctl plugins fixtures`), live tabs are still live (shot).
- [ ] 4.4 Links follow tabs.

  Verify: move a pane from a linked tab to an unlinked one in the harness. The shot shows its row under the new tab, and the kv dump shows the links unchanged.
- [ ] 4.5 Palette commands:
  - "Objectives: Link this tab…": check marks for linked objectives, choosing toggles, an info toast when there are no objectives;
  - "Objectives: New objective for this tab…";
  - an error toast when the focused pane is parked.

  Then add the commands and ⌃⌘O to the README.

  Verify:
  - `ctl plugins run plugin.objectives.link_tab` and `new_for_tab` with `type` and `key Enter` give the expected kv dumps;
  - `ctl palette objectives` shows all three commands, with ⌃⌘O on "Open graph" (shot).
- [ ] 4.6 No automatic linking.

  Verify: diff the kv dump before and after opening a tab, closing a pane, and running a command. The links are unchanged.

## 5. Edges, selection emphasis and filters

- [ ] 5.1 Edge layers (D3, D4), built from the layout constants:
  - one line per link of an open objective, coloured by priority;
  - dashed for closed and elsewhere tabs;
  - none for done objectives.

  Verify: shots at 1400 px and 460 px, and `ctl dump`, show every line end within 2 px of its node's centre.
- [ ] 5.2 Selection emphasis: a thicker selected layer with the others at 0.25, and deselection by clicking empty graph space or the selected title again.

  Verify by shots after `ctl click` on a title and on empty space.
- [ ] 5.3 Filters:
  - the scope filter, All or This session, where This session keeps the selected objective;
  - the tag filter chips, one at a time;
  - the scope, tag, Done-group and expanded settings remembered in `view`.

  Verify:
  - the "This session" scenario (X shown, Y hidden, only the "web" tabs), by shot;
  - "#api" filtering, by shot;
  - after a plugin reload, the view settings are restored (kv dump and shot).
- [ ] 5.4 Light and dark appearances.

  Verify: shots under `ctl appearance light` and `ctl appearance dark` show every line, badge colour and the faded-tab style.

## 6. Navigation

- [ ] 6.1 Jumps (D10): a tab header jumps to the tab, a pane row label jumps to that exact pane, both across sessions.

  Verify:
  - after each `ctl click`, `ctl state` shows the expected session, tab and focused pane;
  - a shot shows the target pane uncovered.
- [ ] 6.2 Closed and elsewhere tabs don't jump; they show info toasts instead.

  Verify: `ctl state` is unchanged after clicking, and a shot shows the toast.

## 7. Pane details

- [ ] 7.1 The ▸/▾ expand toggle, which doesn't jump and is remembered, and terminal details:
  - ✓ or ✗, the status, the duration and the command;
  - ⟳ with elapsed time while a command runs, updated by a 1 s timer;
  - "no command yet".

  Verify: run `false` and `sleep 30` in harness panes with `ctl type` and `key Enter`. Shots show "✗ 1 · …  false", and an elapsed time that rises between two shots one second apart.
- [ ] 7.2 Details for other pane kinds: a file's path, a browser's URL, a plugin block's kind, otherwise the title.

  Verify by a shot of an expanded file-pane row showing its path.
- [ ] 7.3 Agent details (D11):
  - the state badge;
  - the "omp" reply line, cut to 160 characters plus "…";
  - the "you" line from `transcript`, with a placeholder until it loads;
  - a cache that reads at most one transcript per 250 ms tick.

  Verify: start `omp --no-session` with a cheap model in a harness pane and send one short prompt. Shots show "working", then idle with "you" and "omp" lines, and the log shows render times under 20 ms.

## 8. Live refresh and durability

- [ ] 8.1 Live refresh (D12):
  - event-driven renders, coalesced at 150 ms;
  - the 750 ms signature poll;
  - all timers stop once the canvas is gone.

  Verify: with the graph shown, open a tab, close a pane and rename a tab. After `ctl wait 1000`, shots show each change without reopening the graph, and once the canvas is closed the log shows no further renders.
- [ ] 8.2 Durability across reload.

  Verify: after a plugin reload, the objectives, links, view settings and edge sheet are all present (kv dump and shot), and the fixtures package folder still matches the repo's package files (`diff -r`).
- [ ] 8.3 Budget.

  Verify: with 30 objectives and 40 panes seeded in the harness, the logged render time stays under 20 ms and no `budget` pause appears in the log.

## 9. Package, publish and install

- [ ] 9.1 Finish the README: the install command, window-half only, the three commands with ⌃⌘O, the data location and removal, and one graph screenshot at `docs/graph.png` taken from the harness.

  Verify: the README contains each item named in the plugin-package README scenario.
- [ ] 9.2 Final local install check.

  Verify: a fresh isolated config gets `installed objectives 0.1.0` and shows the plugin ready in `tern plugin list`.
- [ ] 9.3 Publish: create the public repository `JakobMusik/tern-objectives` with `gh repo create --public`, set the topic `tern-plugin`, and push `main`.

  Verify: `gh repo view JakobMusik/tern-objectives --json visibility,repositoryTopics,licenseInfo` reports public, `tern-plugin` and MIT.
- [ ] 9.4 Install from GitHub.

  Verify: `tern plugin install github.com/JakobMusik/tern-objectives` against a fresh isolated config installs `objectives`, and it loads ready.
- [ ] 9.5 Tag `v0.1.0` and push the tag.

  Verify: `gh api repos/JakobMusik/tern-objectives/tags` lists `v0.1.0`.
- [ ] 9.6 **(live)** Install in the user's live Tern with `tern plugin install github.com/JakobMusik/tern-objectives`.

  Verify: `tern plugin list` shows `objectives 0.1.0` ready.
- [ ] 9.7 **(live)** Glimpse check in the user's window: open with ⌃⌘O, jump to a tab in another session, and reopen.

  Verify with the user: the glimpse behaves as checked in task 2.1, or the side-panel fallback recorded in design.md is used.

## Workflow follow-up

- Run the verify workflow against the specs before archiving.
- Archive the change so the six capability specs merge into `openspec/specs/`, then commit the archive.
