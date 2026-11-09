# tab-links Specification

## Purpose
Connects objectives to the Tern tabs where their work happens. The links are many-to-many and are made only by the user. Each tab keeps its own meaning, rather than links pointing at individual panes.

## Requirements

### Requirement: Many-to-many tab links
An objective SHALL be linkable to any number of tabs, and a tab to any number of objectives. A link SHALL name a tab, never an individual pane.

#### Scenario: One tab, two objectives
- **WHEN** the user links tab "API Learning" to objectives "API notes" and "Review pull requests"
- **THEN** both objectives list that tab, and the graph draws two lines into its node

### Requirement: Linking from the graph
While an objective is selected, open or done, every tab node SHALL show a full-width link bar at its foot: "＋ Link" when the tab is not linked to the selected objective, "× Unlink" when it is. Clicking the bar SHALL add or remove that one link, SHALL keep the selection, and SHALL NOT jump to the tab. The bar's text SHALL NOT be selectable, so a press that drifts a little before release still counts as a click.

#### Scenario: Add then remove a link
- **WHEN** the user selects an objective, clicks "＋ Link" on a tab node, then clicks "× Unlink" on the same node
- **THEN** `kv.json` shows the link after the first click and not after the second, and the graph stays shown with the objective still selected

#### Scenario: Press that drifts across the bar
- **WHEN** the user presses on "＋ Link", moves the pointer 40 px along the bar and releases
- **THEN** no text is selected and `kv.json` shows the link

### Requirement: Link this tab command
"Objectives: Link this tab…" SHALL open a picker of open objectives in graph order, with a check on those already linked to the focused pane's tab. Choosing an objective SHALL toggle its link to that tab. With no open objectives it SHALL show an info toast and change nothing.

#### Scenario: Toggle from the palette
- **WHEN** the focused pane is in tab "App status check" and the user picks an unchecked objective in "Objectives: Link this tab…"
- **THEN** that objective is linked to the tab

#### Scenario: No objectives
- **WHEN** there are no open objectives and the user runs "Objectives: Link this tab…"
- **THEN** a toast says there are no objectives yet and nothing changes

### Requirement: New objective for this tab command
"Objectives: New objective for this tab…" SHALL ask for a title, then create an objective already linked to the focused pane's tab, at the starting priority and place set in Configure (P3 and the top by default).

#### Scenario: Create linked
- **WHEN** the user runs the command in tab "API Learning" and enters "Add caching layer"
- **THEN** a new P3 objective "Add caching layer" exists, linked to that tab, first among the open objectives

### Requirement: Focused pane without a tab
When the focused pane belongs to no tab, both tab commands SHALL show an error toast and change nothing.

#### Scenario: Parked focus
- **WHEN** a tab command runs in a session whose only pane is parked, so no pane in a tab has focus
- **THEN** an error toast explains that the focused pane is not in a tab, and `kv.json` is unchanged

### Requirement: No automatic linking
The plugin SHALL NOT create or remove links on its own. Opening, closing or moving tabs and panes, and running commands or agents, SHALL leave links unchanged.

#### Scenario: New tab stays unlinked
- **WHEN** the user opens a new tab and runs an omp agent in it
- **THEN** no objective links the new tab

### Requirement: Link status
Each linked tab the graph shows SHALL be shown in one of three states, worked out from the current window every time the graph draws and never stored:
- **live:** the window holds the tab;
- **closed:** the window does not hold it, and its snapshot came from this window;
- **elsewhere:** its snapshot came from another window.

#### Scenario: Reload is not a close
- **WHEN** the plugin is reloaded, as happens on every Tern restart, and the graph is reopened
- **THEN** every linked tab the window still holds is shown live, with its links intact

#### Scenario: Closing a tab
- **WHEN** the user closes a tab linked to an open objective
- **THEN** it is shown as closed, and its links are kept

#### Scenario: Tab from another window
- **WHEN** a linked tab's snapshot names a window key other than this window's
- **THEN** it is shown as elsewhere

### Requirement: Links follow tabs, not panes
When a pane moves to another tab, its row SHALL move to that tab's node, and every link SHALL stay with the tab it names.

#### Scenario: Pane moved between tabs
- **WHEN** the user moves a pane from linked tab A to unlinked tab B
- **THEN** the pane's row is shown under B, A keeps its links, and B stays unlinked

### Requirement: Link menu on tab nodes
Right-clicking a tab node SHALL open a menu headed "Link to", with one row per open objective, in graph order, checked when that objective is linked to the tab. Choosing a row SHALL add or remove that one link, whether or not an objective is selected. With no open objectives, the menu's only row of its own SHALL be a disabled one saying so; Tern's own Copy row, which every menu gets, may follow it.

#### Scenario: Link without selecting
- **WHEN** no objective is selected and the user right-clicks a tab node and chooses an unchecked objective
- **THEN** `kv.json` shows that objective linked to the tab, and a line joins the two nodes

#### Scenario: Unlink from the menu
- **WHEN** the user right-clicks a tab node linked to an objective and chooses that objective's checked row
- **THEN** `kv.json` no longer shows that link

#### Scenario: No objectives yet
- **WHEN** the store holds no open objectives and the user right-clicks a tab node
- **THEN** the menu's only row of its own is a disabled one saying there are no objectives yet, choosing it does nothing, and `kv.json` is unchanged

#### Scenario: Menu heading
- **WHEN** the store holds two open objectives and the user right-clicks a tab node
- **THEN** the menu starts with the heading "Link to", followed by the two objectives' rows

### Requirement: Creation time in link choices
Where the user picks an objective to link, each objective SHALL show its creation time as `MM-DD HH:MM` in local time: a tab menu row SHALL read `<title> · <time>`, and a "Link this tab" picker row SHALL show `P<priority> · <time>` as dim text after the title. Headings, toasts and confirmations SHALL keep the plain title.

#### Scenario: Same title in the tab menu
- **WHEN** two open objectives are both titled "Write slides", created at different minutes, and the user right-clicks a tab node
- **THEN** the menu has two rows, each "Write slides · " followed by that objective's creation time, and choosing one links only that objective in the kv dump

#### Scenario: Same title in the picker
- **WHEN** the user runs "Objectives: Link this tab…" with the same two objectives open, both still at the P3 they were made with
- **THEN** both rows read "Write slides", each with dim text `P3 · ` followed by its own creation time

#### Scenario: Plain title in a toast
- **WHEN** the user picks one of them in "Objectives: Link this tab…"
- **THEN** the toast reads "Linked to Write slides", without the time

### Requirement: Links of done objectives
A done objective's links SHALL change the same way as an open objective's: through the link bars while it is selected, in the Done group or in review mode. Nothing else SHALL change them: marking done, Undo, rating, reopening and closing its tabs SHALL leave them as they are, and the only exception SHALL be Resume, which hands a closed tab's links to the tab it opens ("Resuming a closed tab").

#### Scenario: Unlink from a done objective
- **WHEN** done objective X links tabs A and B, and the user opens the Done group, selects X and clicks "× Unlink" on A
- **THEN** the kv dump shows X linked to B only, X is still done and selected, and A shows below the "Other tabs" divider with "＋ Link"

#### Scenario: Link a done objective
- **WHEN** the user then clicks "＋ Link" on tab C
- **THEN** the kv dump shows X linked to B and C, and a green line joins X to C

#### Scenario: Resume moves a done objective's link
- **WHEN** done objective X is linked to closed tab A, which held an omp chat that had replied, and the user selects X and clicks A's "Resume"
- **THEN** the kv dump shows X linked to the new tab instead of A, and X is still done

#### Scenario: Reopening keeps the links
- **WHEN** done objective X links live tab A and tab B, closed with "Close n tabs", and the user reopens X with "Reset review"
- **THEN** the kv dump shows X open and linked to A and B, and B shows under "Closed tabs" with a dashed line to X
