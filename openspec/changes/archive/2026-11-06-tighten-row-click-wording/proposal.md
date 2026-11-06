# Proposal

## Why

After `refine-graph-rows` was archived, two lines in the main specs say less than the plugin does:
- `pane-details` › "Folded pane rows" says a click on a row's **type or name** opens it. In 0.6.1 a click anywhere on a live row opens or folds it, except on its jump button: the left padding, the gaps, and the space after a short name count too. The README says "click a row's name" as well.
- `tab-navigation`'s Purpose still says "one click on a tab or pane node takes the user there". Since 0.6.0 a pane is reached through its row's jump button; a click on the rest of the row only opens its details.

## What Changes

- "Folded pane rows": a click anywhere on a live row except its jump button opens the row's details, and another such click folds them. A new scenario clicks the gap just left of the jump button.
- `tab-navigation` Purpose: one click on a tab's header or on a pane row's jump button takes the user there.
- README: "click anywhere on a row but its → button" replaces "click a row's name". At the user's request, the rest of the README was checked against the specs too, which turned up three more lines that don't match:
  - the intro says "Clicking a tab or a pane jumps straight to it", a line from the 0.1.0 scaffold; a pane is reached through its row's → button;
  - "The tab and pane you opened the graph from are outlined": the tab carries a ring, but the pane's row carries a bar at its left edge;
  - "Tabs with no link have a grey fill": the grey goes to tabs with no link to an *open* objective, so a tab linked only to done objectives is grey too.

  The right-click bullet ("its header or any pane row") was written before pane rows took clicks in 0.6.0, so the headless check confirms that a right-click on a row still opens the tab's menu.

The plugin's behaviour, code and version stay as they are; this change only brings the wording in line with 0.6.1.

Out of scope:
- any change to the plugin's code or styles, and so any release;
- other spec wording, and README lines that already match the plugin;
- the known limits: the origin is lost on reload, and the "Link to" menu overflows at about 30 objectives.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `pane-details`: "Folded pane rows" covers a click anywhere on the row but its jump button.

`tab-navigation`'s requirements don't change. Only its Purpose does, and that line is edited in the main spec directly, because a delta can't carry it.

## Impact

- **Specs:** `openspec/specs/pane-details/spec.md` through the delta; `openspec/specs/tab-navigation/spec.md`, Purpose line only.
- **Docs:** four sentences in `README.md`.
- **Code:** none. The headless check runs 0.6.1 as it is.
