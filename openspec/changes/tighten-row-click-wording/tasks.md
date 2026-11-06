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

- [ ] 2.1 The plugin, unchanged, behaves as the new scenario "Click beside the name" says.

  Verify: restart the harness, sync the repo into the fixtures, and open the graph from a live tab.
  - The layout gives a folded live row's `.ob-jump` rectangle.
  - `ctl click` 3 px left of that rectangle, at its vertical middle: the next shot shows the row's details, and the kv dump lists its pane as opened.
  - `ctl click` on the row's `.ob-rtype`: the details are gone, and the kv dump no longer lists the pane.
  - The shown session and tab, read before the first click and after the second, are the same.
  - Right-clicking a pane row opens the tab's "Link to" menu (README, right-click bullet).
  - Marking done the only objective linked to a tab draws that tab with the unlinked grey fill and dashed border, and reopening it brings the solid card back (README, unlinked bullet). Afterwards the kv dump holds the same objectives as before.

## 3. Publish

- [ ] 3.1 Run the verify workflow, archive the change into `openspec/specs/`, run `openspec validate --specs --strict`, commit and push `main`, then stop the harness.

  Verify: `openspec show pane-details --type spec` holds the new wording and the scenario "Click beside the name", and `git status` is clean against `origin/main`.
