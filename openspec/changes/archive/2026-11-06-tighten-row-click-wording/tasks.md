# Tasks

Checks run in the headless harness at `/tmp/tobj`. Nothing here touches the live Tern: the plugin stays at 0.6.1, so there is no release.
- **Kv dump** reads `/tmp/tobj/config/plugin-data/objectives/kv.json`.
- **Layout** is the JSON that `ctl shot NAME` writes beside its PNG.

## 1. Wording

- [x] 1.1 `openspec/specs/tab-navigation/spec.md`, Purpose only: "Turns the graph into a switchboard: one click on a tab's header or on a pane row's jump button takes the user there, in whatever session it lives." The second sentence stays.

  Verify: `openspec show tab-navigation --type spec --json` prints the new Purpose, and `openspec validate --specs --strict` passes.

  Result: `openspec show` prints the new Purpose, and strict validation passes all 6 specs.
- [x] 1.2 `README.md`, four lines:
  - the intro: "Clicking a tab's header or a pane's → button jumps straight to it" replaces "Clicking a tab or a pane jumps straight to it";
  - the origin bullet: the tab you opened the graph from carries an accent ring, and its pane's row an accent bar at its left edge, instead of both being "outlined";
  - the rows bullet: "click anywhere on a row but its → button" replaces "click a row's name";
  - the unlinked bullet: "Tabs linked to no open objective" replaces "Tabs with no link".

  Verify: the README holds each new phrase, and none of "Clicking a tab or a pane jumps", "are outlined in the accent colour", "click a row's name" or "Tabs with no link" appears in it.

  Result: each new phrase appears once, and none of the four old ones remains.

## 2. Headless check

- [x] 2.1 The plugin, unchanged, behaves as the new scenario "Click beside the name" says.

  Verify: restart the harness, sync the repo into the fixtures, and open the graph from a live tab.
  - The layout gives a folded live row's `.ob-jump` rectangle.
  - `ctl click` 3 px left of that rectangle, at its vertical middle: the next shot shows the row's details, and the kv dump lists its pane as opened.
  - `ctl click` on the row's `.ob-rtype`: the details are gone, and the kv dump no longer lists the pane.
  - The shown session and tab, read before the first click and after the second, are the same.
  - Right-clicking a pane row opens the tab's "Link to" menu (README, right-click bullet).
  - Marking done the only objective linked to a tab draws that tab with the unlinked grey fill and dashed border, and reopening it brings the solid card back (README, unlinked bullet). Afterwards the kv dump holds the same objectives as before.

  Result (0.6.1 synced, the restarted harness came up with one session "Default"; pane 2 was split into tab 3 as panes 2 and 4, then the graph was opened from a new tab 8, so it showed as canvas pane 9 over tab 8):
  - Row 4 of tab 3: type 661.9–685.7, name 691.7–1155.6, jump 1161.5–1189.5 (x, px). The click at (1158.5, 325.7) lands in the 6 px gap between name and jump.
  - After it, tab 3 grows from 88 to 106 px with one `.ob-detail` line, and the kv dump's `expanded` gains `"4"`. After the click on the type at (673.8, 325.7), tab 3 is 88 px again with no detail line, and `"4"` is gone.
  - Before and after: session "Default", focus on canvas pane 9 over tab 8, tab 3's own focus on pane 2. Nothing jumped.
  - Right-click at (900, 325.7), on row 4's name, opens a menu headed "Link to" with the 7 open objectives (shot `t_menu`). Choosing "Read about rate limiting" (o6) links it to tab 3 (`tabs: [9, 3]`), and the node loses `ob-tab-unlinked`.
  - Marking o6 done gives tab 3 `ob-tab-unlinked` again, and the shot turns it from the white card with a solid border to the grey fill with a dashed border (`t_linked` against `t_done`). Reopening o6 from the Done group brings the card back.
  - After the Done group was folded and o6 unlinked through the same menu, the kv dump's objectives and the rest of its state equal the backup `/tmp/tobj/kv.pre-tighten.json`. This run logged nothing from `objectives`.

## 3. Publish

- [x] 3.1 Run the verify workflow, archive the change into `openspec/specs/`, run `openspec validate --specs --strict`, commit and push `main`, then stop the harness.

  Verify: `openspec show pane-details --type spec` holds the new wording and the scenario "Click beside the name", and `git status` is clean against `origin/main`.

  Result:
  - **Verify:** no warnings. The only open item was this task. Design adherence and code patterns were not verified: there is no `design.md`, and no plugin code changed since `cb42106`.
  - **Archive:** as `2026-11-06-tighten-row-click-wording`, with "Folded pane rows" modified in `pane-details`. Its Purpose and other scenarios are untouched, and no delta headers remain.
  - **Validation:** strict, 6 of 6 specs pass.
