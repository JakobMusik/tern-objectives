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

- [x] 1.1 Raise on click (D1) in `Store.cycle_priority`.

  Verify on the objectives-graph "Priority badge" scenarios, with a `ctl click` on the badge, then the kv dump and `ctl tree`:
  - "Raise one step": a P3 badge becomes P2, class `ob-p2`;
  - "Cycle wraps": a P0 badge becomes P3, class `ob-p3`;
  - a shot of both badges.

  Result (harness; o1 "Fix login bug", o2 "Review pull requests", o3 "Write slides", all P3, created a minute apart; o4 "Set up CI" done):
  - **Raise one step:** one click on o3's badge gave `P2`, class `ob-p2`, kv priority 2. Two more gave P1 (`ob-p1`) and P0 (`ob-p0`, kv 0).
  - **Cycle wraps:** a click on o3's P0 badge gave `P3`, class `ob-p3`, kv 3.
  - **Shots:** `rp_held_p0` (red P0 badge, third in the column) and `rp_wrap_p3`.
- [x] 1.2 One default: P3 (D2), in `Store.create` and the loader.

  Verify:
  - objective-store "Creating an objective": "＋ New objective" with "  Fix login bug  " gives a kv record with priority 3, title trimmed, and no note, due date, tags, links or schedule.
  - objectives-graph "Create and select": the new node is selected, has a P3 badge, and every tab node shows "＋ Link".
  - tab-links "Create linked": "New objective for this tab…" in a tab gives a P3 record linked to that tab.
  - tab-links "Same title in the picker": two "Write slides" rows read `P3 · <time>`.
  - objective-store "Record without a priority": with the serve stopped, delete one record's `priority` from the harness `kv.json`, start it again and open the graph. The badge reads P3 and the node sorts among the P3s.
  - Existing priorities: the other records' priorities are the same in the kv dump before and after the update.

  Result (harness):
  - **Creating an objective:** "＋ New objective" with `  Fix login bug  ` stored `{id o22, title "Fix login bug", done false, priority 3, created, tags [], tabs []}`, with no note, due or review field.
  - **Create and select:** o22's node had a `P3` badge and `ob-sel`. The window's one tab node (tab 3) showed `＋ Link` (shot `rp_new_p3`).
  - **Create linked:** "New objective for this tab…" with "Update docs", run in tab 3 (the window's only tab), stored o21 at priority 3 with tabs `[3]`.
  - **Same title in the picker:** with o3 wrapped back to P3 and a second "Write slides" (o23) made, "Link this tab…" rows read `Write slides` + `P3 · 11-08 17:59` and `Write slides` + `P3 · 11-13 00:15`.
  - **Record without a priority:** the serve was stopped, and the 0.14.1-era store went back in with the `priority` field deleted from o1 "Write release notes". All its other records are P2. After a restart and open, o1's badge read `P3` (`ob-p3`) and the open order was o2, o20 (both P2), then o1. The old default would have put o1, the oldest, first. The render's store write saved the default, so o1 now stores priority 3.
  - **Existing priorities:** o2, o4, o20, o5 and o6 still hold priority 2 after that open, as they did before.
- [x] 1.3 Held order (D3) in `lib/app.luau` and `View.build`.

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

  Result (harness, same data as 1.1):
  - **Click dispatch:** after one click on o3's badge, no node had `ob-sel`, and the column still read o1, o2, o3, with o3 at P2 below two P3s. So the badge click sends only `prio=`, and D3 stands.
  - **Raising in place:** after each of three clicks on o3's badge, the column read o1, o2, o3. After the third the badge read P0 and the kv dump held priority 0.
  - **A click elsewhere sorts again:** a click on empty space between the columns gave o3, o1, o2. A first try below the column landed outside the graph, which is only as tall as its content, and changed nothing.
  - **Badges of several objectives:** from o1, o2, o3 (all P3), clicks on o3's badge, then o2's, left o1, o2, o3 after each, with kv priorities o2 2 and o3 2.
  - **Fresh open sorts again:** with o3 raised to P0 under a hold (column o1, o2, o3), `plugins run plugin.objectives.open` closed the graph (no `.ob-root`) and opened it again with o3, o2, o1.
  - **New objective during the hold:** with the column held at o3 (P0), o1 (P2), o2 (P1), the palette command made "Update docs" (o21, P3). The graph stayed shown and read o3, o1, o2, o21.
  - **The picker stays sorted:** after "Raising in place" again (column o1, o2, o3 with o3 at P0), "Link this tab…" rows read Write slides `P0`, Fix login bug `P3`, Review pull requests `P3`. The column still listed o3 third.
  - **"All" ends a hold:** held o3, o2, o1 (o1 just raised to P2) became o3, o1, o2 after a click on "All".
  - **Tab menu during a hold:** right-clicking tab 3 gave rows "Write slides · 11-13 00:15", "Fix login bug · …", "Review pull requests · …", "Copy". The column read o1, o2, o3 with the menu open and after Escape.
  - **A verb that draws later ends a hold:** a click on ⋯ of o21 during a hold redrew the column sorted at once, while the menu was still open (D3, `later`).
  - **Done group:** marking o2 done ended a hold and re-sorted the column. Badge clicks on o4, then o2, left the Done group as o2, o4 (most recently done first).
  - **Log:** 31 renders, the longest 2.7 ms; no errors or warnings.

## 2. Release 0.15.0

- [x] 2.1 Version `0.15.0` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.15.0`. Tick this box, then commit, push `main` and tag `v0.15.0` (annotated, message "objectives 0.15.0").

  Result: the install into `/tmp/tobj-inst150/config` printed `installed objectives 0.15.0 → /tmp/tobj-inst150/config/plugins/objectives`.
- [x] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.15.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.

  Result: `installed objectives 0.15.0 → ~/Library/Application Support/Tern/plugins/objectives`; `tern plugin list` shows `objectives 0.15.0 … ready`, `omp-narration 0.1.0 … ready` and `tabnav 0.1.0 … ready`. The tag is `v0.15.0` (`fdb1a45`), signed.
- [ ] 2.3 **(live)** With the user:
  - a badge click raises the priority, and P0 wraps to P3;
  - the node stays in place across several badge clicks, and a click elsewhere sorts the column;
  - a new objective starts at P3.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive raise-priority-in-place --yes`), run `openspec validate --specs --strict`, commit and push.
