# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`. After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells). Right after a reload, force a fresh render with a click on "All" before reading the graph. Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Reading:**
  - `ctl tree '.ob-obj'` for the left column's order, badges (`.ob-badge`, class `ob-p0`…`ob-p3`) and the selection (`ob-sel`);
  - `/tmp/tobj/bin/kv` for the store;
  - `ctl state` for picker and menu rows;
  - `ctl shot NAME` for a PNG and layout JSON.
- **Data:** demo names follow the specs: objectives "Fix login bug", "Review pull requests" and "Write slides"; sessions web, api and docs.
- **After the checks:** stop the harness service.

## 1. Priority clicks

- [ ] 1.1 Raise on click (D1) in `Store.cycle_priority`.

  Verify on the objectives-graph "Priority badge" scenarios, with a `ctl click` on the badge, then the kv dump and `ctl tree`:
  - "Raise one step": a P3 badge becomes P2, class `ob-p2`;
  - "Cycle wraps": a P0 badge becomes P3, class `ob-p3`;
  - a shot of both badges.
- [ ] 1.2 One default: P3 (D2), in `Store.create` and the loader.

  Verify:
  - objective-store "Creating an objective": "＋ New objective" with "  Fix login bug  " gives a kv record with priority 3, title trimmed, and no note, due date, tags, links or schedule.
  - objectives-graph "Create and select": the new node is selected, has a P3 badge, and every tab node shows "＋ Link".
  - tab-links "Create linked": "New objective for this tab…" in a tab gives a P3 record linked to that tab.
  - tab-links "Same title in the picker": two "Write slides" rows read `P3 · <time>`.
  - objective-store "Record without a priority": with the serve stopped, delete one record's `priority` from the harness `kv.json`, start it again and open the graph. The badge reads P3 and the node sorts among the P3s.
  - Existing priorities: the other records' priorities are the same in the kv dump before and after the update.
- [ ] 1.3 Held order (D3) in `lib/app.luau` and `View.build`.

  Verify, first the click-dispatch risk: after one badge click, no node has `ob-sel` and the left column's order is unchanged. If the click also selected the node, stop and update design D3 before going on.

  Then each scenario of objectives-graph "Order held while changing priority", reading the order with `ctl tree '.ob-obj'`, priorities from the kv dump, and picker rows from `ctl state`:
  - "Raising in place";
  - "A click elsewhere sorts again";
  - "Badges of several objectives";
  - "Fresh open sorts again", closing and opening with `plugins run plugin.objectives.open`;
  - "New objective during the hold";
  - "The picker stays sorted".

  Also:
  - a click on another control ("All") ends a hold;
  - during a hold, the tab menu (right-click a tab node) lists the raised objective first;
  - the Done group's order is unaffected;
  - render times from the log, and no errors.

## 2. Release 0.15.0

- [ ] 2.1 Version `0.15.0` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.15.0`. Tick this box, then commit, push `main` and tag `v0.15.0` (annotated, message "objectives 0.15.0").
- [ ] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.15.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.
- [ ] 2.3 **(live)** With the user:
  - a badge click raises the priority, and P0 wraps to P3;
  - the node stays in place across several badge clicks, and a click elsewhere sorts the column;
  - a new objective starts at P3.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive raise-priority-in-place --yes`), run `openspec validate --specs --strict`, commit and push.
