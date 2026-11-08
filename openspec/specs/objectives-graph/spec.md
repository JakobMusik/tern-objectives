# objectives-graph Specification

## Purpose
Shows objectives and tabs as a clickable two-column graph, with lines for links. The user manages objectives mostly by clicking, with a rename key and typed fields where text is needed, and sees at a glance which tabs serve which objective.

## Requirements

### Requirement: Opening the graph
"Objectives: Open graph" SHALL be a palette command bound to ⌃⌘O by default. It SHALL show the graph as a glimpse over the current tab, with keyboard focus in the graph. Run while the graph is shown as a glimpse over the current tab, it SHALL close it, so the same key opens and closes the graph. Run anywhere else, it SHALL show the graph over the current tab, replacing a graph left docked or in another tab: the window SHALL hold at most one graph at a time.

#### Scenario: Key toggles
- **WHEN** the user presses ⌃⌘O twice over the same tab
- **THEN** the first press shows the graph with focus in it, and the second closes it, leaving no graph pane in the window

#### Scenario: Toggle after clicking inside
- **WHEN** the user opens the graph, clicks an objective's title and presses ⌃⌘O
- **THEN** the graph closes

#### Scenario: Replacing a docked graph
- **WHEN** a graph was docked into a tab by a session switch and the user presses ⌃⌘O in that tab
- **THEN** a glimpse of the graph is shown over the tab and the window holds exactly one graph pane

### Requirement: Graph returns after its pickers
When a picker or field opened from the graph closes, answered or dismissed, the graph SHALL be shown over the current tab again if a click on the field, or on the graph while the field was open, had closed it.

#### Scenario: Clicking into a field
- **WHEN** the user clicks "＋ New objective", clicks into the title field, types "Write slides" and presses Enter
- **THEN** the graph is shown again with "Write slides" selected

#### Scenario: Dismissing by clicking the graph
- **WHEN** the user opens Side note from an objective's menu, clicks into the field and then clicks where the graph was
- **THEN** the field closes, the note is unchanged and the graph is shown again

### Requirement: Two-column layout
The graph SHALL show objectives in a left column, tabs in a right column, and link lines between them. A header SHALL sit above both columns.

#### Scenario: Columns shown
- **WHEN** the graph opens with two objectives and three tabs
- **THEN** a screenshot shows two objective nodes on the left, three tab nodes on the right, and the header above them

### Requirement: Empty state
With no objectives, the left column SHALL show a hint pointing at "＋ New objective". When objectives exist but the filters leave none to list, it SHALL show "No objectives match this filter." instead.

#### Scenario: First open
- **WHEN** the graph opens with an empty store
- **THEN** the left column shows the hint, and the right column still lists the window's tabs

#### Scenario: Nothing matches
- **WHEN** the store holds objectives, none of them linked to a tab in the current session, and the user clicks "This session"
- **THEN** the left column shows only "No objectives match this filter."

### Requirement: Objective ordering
Open objectives SHALL be ordered:
1. by priority, P0 first;
2. then by due date, earliest first, with no date last;
3. then by created time, oldest first.

The one exception is the left column while a priority change holds its order (Order held while changing priority).

#### Scenario: Mixed priorities and dates
- **WHEN** the store holds P2 due tomorrow, P2 with no due date, P0 with no due date, and P2 due today
- **THEN** the order is P0, P2 due today, P2 due tomorrow, P2 with no date

### Requirement: Objective node content
Each objective node SHALL show, on fixed single lines:
- a done box, a priority badge, the title and a ⋯ button, with a trash icon before the ⋯ on done objectives;
- below them, the side note (dimmed), a due chip on open objectives or a review chip on done ones, and tag chips.

Text that doesn't fit SHALL end in "…". Hovering the node SHALL show the full title, the full note and the created and done times, and for a done objective its review count and next review date.

#### Scenario: Long note
- **WHEN** an objective has a 200-character side note
- **THEN** its node stays the same height, the note is cut with "…", and the node's tooltip holds the whole note

#### Scenario: Done node
- **WHEN** the user marks an objective with a due date done and opens the Done group
- **THEN** its node shows a trash icon, a "review in 1d" chip and no due chip, and its tooltip gives 0 reviews and tomorrow's date as the next review

### Requirement: Priority badge
Clicking the priority badge SHALL raise the priority one step, P3 → P2 → P1 → P0, and a click on a P0 badge SHALL wrap back to P3. Badge colours SHALL be: P0 red, P1 orange, P2 blue, P3 grey.

#### Scenario: Raise one step
- **WHEN** the user clicks the badge of a P3 objective
- **THEN** the objective becomes P2 and its badge turns blue

#### Scenario: Cycle wraps
- **WHEN** the user clicks the badge of a P0 objective
- **THEN** the objective becomes P3 and its badge turns grey

### Requirement: Objective menu
The ⋯ button SHALL open a picker with Rename, Side note, Due date, Tags and Delete. For a done objective with at least one linked tab open in this window that no open objective links, it SHALL also offer "Close linked tabs", with the number of those tabs.
- Rename and Side note SHALL open a one-line field pre-filled with the current value.
- Dismissing any picker or field SHALL change nothing.

#### Scenario: Rename
- **WHEN** the user picks Rename and enters "Fix login timeout"
- **THEN** the node shows "Fix login timeout"

#### Scenario: Dismissed field
- **WHEN** the user opens Side note and dismisses the field
- **THEN** the objective is unchanged

#### Scenario: Close row on a done objective
- **WHEN** done objective X links two open tabs that no open objective links
- **THEN** X's menu offers "Close linked tabs" with "2 open tabs", and an open objective's menu doesn't offer it

#### Scenario: Nothing to close
- **WHEN** done objective X's only open tab is also linked to an open objective
- **THEN** X's menu doesn't offer "Close linked tabs"

### Requirement: Due date picker and chip
The Due date picker SHALL offer:
- Today, Tomorrow, Friday (the next Friday after today), Next Monday and In 1 week;
- "Pick date…", which takes `YYYY-MM-DD`;
- Clear.

The due chip SHALL read "overdue Nd", "due today", "due tomorrow" or "due in Nd". It SHALL be amber when today or tomorrow, red when overdue, and muted otherwise.

#### Scenario: Overdue
- **WHEN** an open objective's due date is two days before today
- **THEN** its chip reads "overdue 2d" in red

#### Scenario: Due tomorrow
- **WHEN** the user picks "Tomorrow"
- **THEN** the chip reads "due tomorrow" in amber

### Requirement: Tag picker
The Tags picker SHALL list every existing tag, with a check on the objective's own, plus "New tag…". Choosing a tag SHALL add or remove it. "New tag…" SHALL ask for a name and add it. Tags SHALL show on the node as "#tag" chips.

#### Scenario: Add a new tag
- **WHEN** the user picks "New tag…" and enters "web"
- **THEN** the node shows a "#web" chip, and "web" is offered in the tag filter

### Requirement: Tab column
The right column SHALL group tabs under session headings, with the current session marked. The session holding the graph's origin pane SHALL come first, with the origin's tab first inside it; the other sessions SHALL follow in Tern's session order, and the other tabs in tab order. Without a live origin, sessions and tabs SHALL keep Tern's order. Shown closed tabs SHALL gather in a final "Closed tabs" group, and linked elsewhere tabs in an "Other windows" group.

#### Scenario: Three sessions
- **WHEN** the window holds sessions "web" (2 tabs), "api" (tabs "Server" and "Benchmarks") and "docs" (1 tab), and the user opens the graph from a pane in api's "Benchmarks"
- **THEN** the right column shows "api" first, marked current, with "Benchmarks" above "Server", then "web" and "docs" with their tabs in order

#### Scenario: New order on a fresh open
- **WHEN** the user closes the graph, focuses a pane in web's second tab and opens the graph again
- **THEN** "web" comes first with its second tab at the top, then "api" and "docs"

#### Scenario: Origin pane closes
- **WHEN** the origin pane closes while the graph is shown
- **THEN** within a second the sessions and tabs are back in Tern's order

### Requirement: Tab node content
Each tab node SHALL show:
- its label: the tab's name if the user set one, else the title of its first pane;
- a dimmed line "<session> · tab <n>", which a closed tab starts with "closed · " and another window's tab with "other window · ";
- one row per pane in the tab, floating panes included.

Parked panes and the graph's own pane SHALL NOT be listed.

#### Scenario: Split tab with a float
- **WHEN** an unnamed tab holds two tiled panes and one floating pane
- **THEN** its label is the first tiled pane's title, and it lists three pane rows

#### Scenario: Closed tab's line
- **WHEN** a linked tab that was tab 2 of session "web" is closed
- **THEN** its node's dimmed line reads "closed · web · tab 2"

### Requirement: Unlinked tabs look different
A live tab with no link to an open objective SHALL be drawn with a light grey fill and a dashed border, and a linked live tab as a card with a solid border. Both SHALL draw their text at full strength.

#### Scenario: Linking removes the fade
- **WHEN** the user links an unlinked tab to an objective
- **THEN** the node changes from the grey fill with a dashed border to the card with a solid border, and its label's text colour is the same before and after

### Requirement: Link lines
For each link between a shown open objective and a tab shown in the right column, a line SHALL join the two nodes. A done objective's links SHALL get lines only while it is selected, in review mode too. Each line SHALL be:
- coloured by the objective's priority, or green (`#30a46c`) for a done objective;
- drawn dashed when the tab is closed or elsewhere;
- ending at the nodes' edges, at any graph width from 360 to 1600 pixels.

#### Scenario: Alignment at two widths
- **WHEN** the graph is captured at 1400 and 460 pixels wide
- **THEN** in both captures, each line's ends sit within 2 pixels of the vertical centres of its objective node and tab header

#### Scenario: Done objective selected
- **WHEN** the user opens the Done group and selects done objective X, linked to a live tab and a closed tab, while open objective Y links another tab
- **THEN** thick green lines join X to both tabs, the one to the closed tab dashed, and Y's line is faded

#### Scenario: Done objective not selected
- **WHEN** the user then clicks empty graph space
- **THEN** no green line shows, and Y's line is at full strength

#### Scenario: Lines in review mode
- **WHEN** review mode lists a done objective linked to a live tab
- **THEN** no line shows until the user selects that objective; then a green line joins its node to that tab's header, ending within 2 pixels of both vertical centres

#### Scenario: Filtered out
- **WHEN** open objective Y links a live tab and the tag filter hides Y
- **THEN** no line ends at that tab's header

### Requirement: Selection
Clicking an objective's title SHALL select it:
- its lines are drawn thicker;
- all other lines fade to about a quarter of their strength;
- when it is open, a link bar appears on every tab node.

Clicking the selected objective again, or empty graph space, SHALL clear the selection.

#### Scenario: Select and clear
- **WHEN** the user clicks an objective's title and then clicks empty graph space
- **THEN** the first screenshot shows its lines emphasised and a link bar on every tab node, and the second shows neither

#### Scenario: Selecting a done objective
- **WHEN** the user opens the Done group and clicks a done objective's title
- **THEN** it is drawn selected, its lines show, and no tab node has a link bar

### Requirement: Scope filter
The header SHALL offer [All | This session].
- **All:** every objective and every tab.
- **This session:** only objectives linked to at least one tab of the current session, plus the selected objective, and only the current session's tabs, including its closed linked tabs.

#### Scenario: This session
- **WHEN** objective X is linked only to a tab of session "web", objective Y is linked only to a tab of "misc", and the current session is "web" with scope "This session"
- **THEN** the graph shows X and not Y, and only the tabs of "web"

### Requirement: Tag filter
The header SHALL show a chip for each existing tag. Clicking a chip SHALL show only objectives holding that tag; clicking it again SHALL clear the filter. At most one tag filter SHALL be active at a time. When no objective holds the filtered tag any more, the filter SHALL be dropped and every objective shown again.

#### Scenario: Filter by tag
- **WHEN** the user clicks the "#api" chip
- **THEN** only objectives tagged "api" are listed, and the chip is drawn active

#### Scenario: Filtered tag removed
- **WHEN** the "#api" filter is active and the user removes the tag "api" from the last objective holding it
- **THEN** the "#api" chip is gone, every objective is listed again, and the kv dump's view settings hold no tag filter

### Requirement: New objective button
"＋ New objective" in the header SHALL ask for a title, create the objective at P3 with no links, and select it.

#### Scenario: Create and select
- **WHEN** the user clicks "＋ New objective" and enters "Write slides"
- **THEN** "Write slides" appears selected with a P3 badge, and every tab node shows a "＋ Link" bar

### Requirement: Prune button visibility
The header SHALL show "Prune closed tabs" only while at least one closed tab it shows is linked to an open objective.

#### Scenario: Button appears
- **WHEN** a tab linked to an open objective is closed while the graph is shown
- **THEN** "Prune closed tabs" appears in the header

#### Scenario: Only done objectives' tabs
- **WHEN** the only closed tabs are linked to done objectives alone, and the user selects one of those objectives
- **THEN** its closed tabs show, and the header shows no "Prune closed tabs"

### Requirement: Live refresh
While the graph is shown, it SHALL redraw by itself within one second of any of these:
- a tab or pane opening, closing or moving;
- a title change;
- the current session changing;
- an agent's state changing;
- a command finishing.

#### Scenario: New tab appears
- **WHEN** a new tab is opened while the graph is shown
- **THEN** the tab appears in the right column without the graph being reopened

### Requirement: Light and dark themes
Lines, badges, chips and the unlinked-tab fill SHALL stay distinguishable in both Tern's light and dark appearances.

#### Scenario: Both appearances
- **WHEN** the graph is captured in the light appearance and in the dark appearance
- **THEN** both captures show every line, every badge colour, and unlinked tabs filled differently from linked ones

### Requirement: Origin highlight
The pane that has focus when the graph opens SHALL be the graph's origin. While the graph is shown, the tab node holding the origin pane SHALL carry an accent ring, and the origin's pane row an accent bar. The highlight SHALL follow the pane into another tab and SHALL disappear if the pane closes. Each fresh open SHALL take a new origin; showing the graph again after one of its pickers SHALL keep it.

#### Scenario: Opened from a split pane
- **WHEN** focus is in the right-hand pane of a split tab and the user opens the graph
- **THEN** a screenshot shows that tab node ringed and the right-hand pane's row marked, and no other node or row marked

#### Scenario: Origin pane moves
- **WHEN** the origin pane is moved into another tab while the graph is shown
- **THEN** the ring and the row mark move to that tab's node and the pane's new row

#### Scenario: Kept after a picker
- **WHEN** the user opens the graph, clicks "＋ New objective", clicks into the field, types a title and presses Enter
- **THEN** the graph shown again marks the same tab and pane

#### Scenario: New origin on a fresh open
- **WHEN** the user closes the graph, focuses a pane in another tab and opens the graph again
- **THEN** only the new pane's tab node and row are marked

### Requirement: Larger hit areas
The done box, the ⋯ button and the trash icon SHALL each take clicks over at least 22 px of width and the full 18 px height of their line in objective nodes. A pane row's jump button SHALL take clicks over at least 28 px of width and the row's full 22 px height. The Hard, Good and Easy buttons SHALL each be at least 22 px tall. Objective nodes SHALL stay 48 px tall outside review mode, and pane rows 22 px.

#### Scenario: Measured hit areas
- **WHEN** a screenshot's layout data is read outside review mode
- **THEN** every done box, trash icon and ⋯ button is at least 22 × 18 px, every jump button at least 28 × 22 px, objective nodes are 48 px tall, and pane rows are 22 px tall

#### Scenario: Review nodes
- **WHEN** a screenshot's layout data is read in review mode
- **THEN** every Hard, Good and Easy button is at least 22 px tall, and every listed node has the same height

### Requirement: Graph in any session
"Objectives: Open graph" SHALL show the graph as a canvas, Tern's built-in block filled from window Lua, in every session the window shows, on this machine or another. Nothing SHALL need installing on another machine, and the plugin SHALL define no block of its own. If a session's machine can't show a canvas, an error toast SHALL say so and nothing SHALL open.

#### Scenario: Canvas over the tab
- **WHEN** the user presses ⌃⌘O
- **THEN** the current tab shows a canvas owned by `objectives` with keyboard focus, and the plugin's data folder holds only `kv.json`

#### Scenario: Clicks in the canvas
- **WHEN** the graph is shown and the user selects an objective and clicks "＋ Link" on a tab node
- **THEN** the objective is selected and `kv.json` shows the new link

#### Scenario: Graph left by 0.3.0
- **WHEN** a 0.3.0 graph block is open while the plugin reloads as this version, and the user then presses ⌃⌘O
- **THEN** the block is gone and the canvas is shown

### Requirement: Controls don't select text
Dragging across a tag chip, a due chip, a P0–P3 badge, the header's "All" and "This session" buttons, "Prune closed tabs", "＋ New objective", or a pane row's type, name or jump button SHALL NOT select its text. Neither dragging across nor double-clicking a group or session heading SHALL select its text: "Done (n)", "Closed tabs", "Other windows", a session heading, the `Linked to` heading or the `Other tabs` divider.

#### Scenario: Drag across the header
- **WHEN** the user presses in the header's empty space, drags across "＋ New objective", the tag filter chips and "All" / "This session", and releases in empty space
- **THEN** the screenshot shows no text highlight on any of them

#### Scenario: Drag across a node's badge and chips
- **WHEN** the user drags from an objective's side note across its due chip and tag chip, and from its title across its P0–P3 badge
- **THEN** the screenshot shows no text highlight on the badge or the chips, and the objective's priority is unchanged

#### Scenario: Drag along a pane row
- **WHEN** the user drags from a tab's header across a pane row's type and name
- **THEN** the screenshot shows no text highlight on the row

#### Scenario: Double-click on the Done header
- **WHEN** the left column holds done objectives, and the user double-clicks the word "Done" in the "Done (n)" header
- **THEN** the screenshot shows no text highlight on the header

#### Scenario: Double-click on a session heading
- **WHEN** the user double-clicks a session's name in the right column
- **THEN** the screenshot shows no text highlight on the heading

#### Scenario: Titles stay selectable
- **WHEN** the user double-clicks a word in an objective's title
- **THEN** the word is highlighted, as before

### Requirement: Rename key
"Objectives: Rename selected objective", default key ⌥R, SHALL open the one-line Rename field for the selected objective, filled with its title, while the graph is shown over the current tab. The field SHALL behave as from ⋯ › Rename, and the selection SHALL stay. With no objective selected, or no graph shown over the tab, it SHALL show an info toast saying to select an objective in the graph, and change nothing.

#### Scenario: Rename by key
- **WHEN** the user selects "Fix login bug" in the graph, presses ⌥R and enters "Fix login timeout"
- **THEN** the node shows "Fix login timeout", the kv dump holds that title, and the objective is still selected

#### Scenario: Nothing selected
- **WHEN** no objective is selected and the user presses ⌥R in the graph
- **THEN** an info toast says to select an objective, and no field opens

#### Scenario: Letters still reach the panes
- **WHEN** focus is in a shell prompt and the user types "r" and "R"
- **THEN** the prompt shows "rR", and no field or toast appears

### Requirement: Done objectives group
Clicking an open objective's done box SHALL mark it done. Done objectives SHALL leave the open list and gather in a "Done (n)" group at the bottom of the left column:
- the group is collapsed by default and opens or closes on click;
- inside it, the most recently done objective comes first;
- a done objective draws lines only while it is selected.

A done objective's box SHALL do nothing.

#### Scenario: Marking done
- **WHEN** the user clicks the done box of a linked open objective that is not selected
- **THEN** it moves into the Done group, the count goes up by one, and its lines are gone

#### Scenario: Box of a done objective
- **WHEN** the user opens the Done group and clicks a done objective's box
- **THEN** it stays in the Done group, the count is unchanged, and the kv dump shows it still done

### Requirement: Closing a done objective's tabs
Choosing "Close linked tabs" SHALL ask for confirmation, naming how many tabs it will close and how many linked tabs stay open because an open objective links them. On confirmation it SHALL save the omp chats in those tabs as it does at a turn, then close every pane of each of them, and change no links. A graph sitting in one of them SHALL close first and show again after. If the chats can't be saved, it SHALL close nothing and say so. Cancelling SHALL change nothing.

#### Scenario: Close two, keep one
- **WHEN** done objective X links open tabs A, B and C, open objective Y also links C, and the user picks "Close linked tabs" in X's menu
- **THEN** the confirmation names 2 tabs to close and 1 that stays open; after confirming, the window holds C but not A or B, and the kv dump shows X still linked to A, B and C

#### Scenario: Chat ready to resume
- **WHEN** tab A held an omp chat that had replied, A was closed this way, and the user selects X
- **THEN** A shows under "Closed tabs" with "Resume", and its row starts with "omp"

#### Scenario: Cancelled
- **WHEN** the user picks "Close linked tabs" and cancels the confirmation
- **THEN** A, B and C are all still open, and `kv.json` is unchanged

#### Scenario: The graph's own tab
- **WHEN** done objective X links only tab D, the graph was opened over D, and the user confirms "Close linked tabs"
- **THEN** D is gone, no tab is left holding only the graph, and the graph is shown again

### Requirement: Closing tabs from the done notice
When an objective is marked done in the graph and has tabs "Close linked tabs" would close, its "Marked done" notice SHALL also offer "Close <n> tabs" after Undo. Clicking it SHALL ask the same confirmation as the menu row. Confirming SHALL close the tabs and end the notice; cancelling SHALL leave the notice and its Undo as they were. Marking done SHALL NOT close any tab by itself.

#### Scenario: Offered after marking done
- **WHEN** open objective X links two open tabs that no other open objective links, and the user clicks X's done box
- **THEN** the header reads "Marked done “X” · Undo · Close 2 tabs", and both tabs are still open

#### Scenario: Cancel keeps Undo
- **WHEN** the user clicks "Close 2 tabs" and cancels the confirmation, then clicks Undo within 10 seconds of marking done
- **THEN** both tabs are still open, and X is open again

#### Scenario: Confirmed from the notice
- **WHEN** the user clicks "Close 2 tabs" and confirms
- **THEN** both tabs are closed, X stays done and still links them, and the header shows no notice

#### Scenario: Nothing to close
- **WHEN** an objective with no open linked tabs is marked done
- **THEN** the header reads "Marked done “<title>” · Undo", with no close button

### Requirement: Done objectives' closed tabs
A closed tab that only done objectives link SHALL NOT show in the right column, except while one of those objectives is selected or is listed in review mode.

#### Scenario: Out of the way
- **WHEN** done objective X's tab A is closed, no other objective links A, and nothing is selected
- **THEN** the right column has no node for A

#### Scenario: Shown with its objective
- **WHEN** the user selects X
- **THEN** A shows under "Closed tabs" in the `Linked to “X”` section

#### Scenario: Also linked to an open objective
- **WHEN** a closed tab is linked to done objective X and to open objective Y, and nothing is selected
- **THEN** it shows under "Closed tabs"

### Requirement: Linked tabs section
While an objective is selected, the right column SHALL start with a section headed `Linked to “<title>”`: the shown tabs linked to it. When other tabs are shown, the "Other tabs" divider and those tabs SHALL follow, each part ordered as "Tab column" says. Linking or unlinking a tab SHALL move it across the divider at once. Deselecting SHALL restore the normal order. With no linked tab shown, neither heading nor divider SHALL show.

#### Scenario: Linked tabs on top
- **WHEN** the window holds sessions "web" (tabs "App build" and "Components") and "api" (tabs "Server" and "Benchmarks"), objective X is linked to "Components" and "Benchmarks", the graph was opened from "Server", and the user selects X
- **THEN** the column reads: `Linked to “X”`, "api" with "Benchmarks", "web" with "Components", the "Other tabs" divider, "api" with "Server", then "web" with "App build"

#### Scenario: Linked closed tab
- **WHEN** X is also linked to a closed tab and the user selects X
- **THEN** that tab shows under a "Closed tabs" heading inside the top section, after the live tabs, and not again below the divider

#### Scenario: Linking moves a tab up
- **WHEN** X is selected and the user clicks "＋ Link" on "App build", below the divider
- **THEN** "App build" shows at once in the top section, under "web" before "Components", its bar reading "× Unlink", and the kv dump holds the link

#### Scenario: Unlinking moves a tab down
- **WHEN** the user then clicks "× Unlink" on "Benchmarks"
- **THEN** "Benchmarks" shows at once below the divider, under "api" with the "Server" tab, its bar reading "＋ Link", and the kv dump no longer holds that link

#### Scenario: Last link removed
- **WHEN** X is selected, linked to one shown tab, and the user clicks that tab's "× Unlink"
- **THEN** the heading and the divider are gone, the column is in its normal order, and every bar reads "＋ Link"

#### Scenario: Deselect and select again
- **WHEN** the user clicks X to deselect it, and clicks it again
- **THEN** after the first click there is no heading or divider and the column is in its normal order; after the second, the top section holds the same tabs as before

#### Scenario: Nothing linked
- **WHEN** the user creates "Write slides" with "＋ New objective", which selects it
- **THEN** the column shows no `Linked to` heading and no divider

#### Scenario: First link
- **WHEN** "Write slides" is selected with nothing linked and the user clicks "＋ Link" on a tab
- **THEN** the column starts with `Linked to “Write slides”` and that tab, followed by the divider and every other tab

#### Scenario: This session
- **WHEN** the scope is "This session", X is linked to tabs in the current session and in another, and the user selects X
- **THEN** the top section holds only the current session's linked tabs

#### Scenario: Every shown tab linked
- **WHEN** the scope is "This session", every tab of the current session is linked to X, and the user selects X
- **THEN** the column shows the `Linked to` heading and those tabs, and no divider

### Requirement: Other tabs divider
The divider between the `Linked to` section and the other tabs SHALL be a 3 px accent-coloured bar across the right column, with "Other tabs" on an accent-outlined pill in its middle. Its row SHALL be 32 px tall, and the lines SHALL stay on their nodes.

#### Scenario: Divider look
- **WHEN** X is selected and linked to one of three shown tabs
- **THEN** a screenshot shows the accent bar across the right column between the two sections, with "Other tabs" on a pill in its middle, and each line's ends sit within 2 pixels of the vertical centres of its objective node and tab header

### Requirement: Creation time after the title
Each objective node SHALL show its creation time after the title, dimmed, as `MM-DD HH:MM` in local time, so objectives with the same title can be told apart. A title too long for the line SHALL be cut with "…" before the time is. The time SHALL come from when the objective was created and SHALL NOT be part of its title: renaming SHALL NOT change it, and objectives created before this version SHALL show it too.

#### Scenario: Two with one title
- **WHEN** the user creates "Write slides" with "＋ New objective", and again a minute or more later
- **THEN** both nodes read "Write slides", each followed by its own creation time from the kv dump's `created`, as `MM-DD HH:MM`, and both kv titles are exactly "Write slides"

#### Scenario: Long title
- **WHEN** an objective's title is 120 characters long and the graph is 1400 pixels wide
- **THEN** its node's title ends in "…" and the creation time after it is shown whole

#### Scenario: Rename keeps the time
- **WHEN** the user renames "Write slides" to "Write talk slides"
- **THEN** the rename field held "Write slides" without the time, and the node reads "Write talk slides" followed by the same creation time as before

#### Scenario: Done and review nodes
- **WHEN** the user opens the Done group, and later lists a due objective in review mode
- **THEN** each done node and each review node shows its creation time after the title

### Requirement: Order of closed and other-window tabs
Inside the "Closed tabs" and "Other windows" groups, tabs SHALL be ordered by the session name stored with them, then by the position they had in it. Tabs with no stored snapshot SHALL come first, in the order they were created.

#### Scenario: Two sessions' closed tabs
- **WHEN** objective X links closed tabs "web · tab 2", "api · tab 3" and "api · tab 1", and the user selects X
- **THEN** under "Closed tabs" they read in the order "api · tab 1", "api · tab 3", "web · tab 2"

### Requirement: Ghost tabs look different
A closed or other-window tab SHALL be drawn with a faint dashed border and no fill, with everything but its "Resume" button at half strength, so it reads as gone; a closed tab's label SHALL be struck through. Linking it to an open objective SHALL NOT change that.

#### Scenario: Closed tab linked to an open objective
- **WHEN** a tab linked to open objective Y is closed
- **THEN** a screenshot shows its node with a faint dashed border, no fill, half-strength text and a struck-through label, unlike Y's live tabs

### Requirement: Order held while changing priority
After a click on a priority badge, the left column SHALL keep the order it had before that click, through any further badge clicks on any objective, so a clicked node stays where it was. The next click in the graph on anything else, or a fresh open of the graph, SHALL end the hold and sort the column again. An open objective that appears during the hold SHALL follow the held ones. The "Link this tab" picker and the tab menu SHALL stay sorted.

#### Scenario: Raising in place
- **WHEN** the graph lists the P3 objectives "Fix login bug", "Review pull requests" and "Write slides" in that order, and the user clicks the badge of "Write slides" three times
- **THEN** after each click "Write slides" is still third, and after the third its badge reads P0 and the kv dump holds priority 0 for it

#### Scenario: A click elsewhere sorts again
- **WHEN** the order is held after "Raising in place" and the user clicks empty space in the graph
- **THEN** "Write slides" moves to the top of the left column

#### Scenario: Badges of several objectives
- **WHEN** the user clicks the badge of "Write slides" and then the badge of "Review pull requests"
- **THEN** the left column's order is the same after both clicks as before the first

#### Scenario: Fresh open sorts again
- **WHEN** the order is held after "Raising in place", and the user closes the graph with ⌃⌘O and opens it again
- **THEN** "Write slides" is at the top of the left column

#### Scenario: New objective during the hold
- **WHEN** the order is held and the user runs "Objectives: New objective for this tab…" and enters "Update docs"
- **THEN** "Update docs" is listed after the held objectives, whose order is unchanged

#### Scenario: The picker stays sorted
- **WHEN** the order is held after "Raising in place" and the user runs "Objectives: Link this tab…"
- **THEN** "Write slides" is the picker's first row, while the left column still lists it third
