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
- **WHEN** the user clicks Note in an objective's action bar, clicks into the field and then clicks where the graph was
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

### Requirement: Objective node content
Each objective node SHALL show:
- a grip (open objectives, outside review mode), a done box, a priority badge and the title, plus a trash icon on done objectives;
- below them, the side note (dimmed), a due chip on open objectives or a review chip on done ones, and tag chips.

Text other than the title that doesn't fit SHALL end in "…". Hovering the node SHALL show the full title, the full note and the created and done times, and for a done objective its review count and next review date.

#### Scenario: Long note
- **WHEN** an objective with a one-line title has a 200-character side note
- **THEN** its node stays 48 px tall, the note is cut with "…", and the node's tooltip holds the whole note

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
Clicking an objective node anywhere but its title, grip, done box, badge, trash icon or action bar SHALL select it:
- its action bar shows under it;
- its lines are drawn thicker;
- all other lines fade to about a quarter of their strength;
- a link bar appears on every tab node, for an open or a done objective.

Clicking the selected objective there again, or empty graph space, SHALL clear the selection.

#### Scenario: Select and clear
- **WHEN** the user clicks an objective node beside its title and then clicks empty graph space
- **THEN** the first screenshot shows its action bar, its lines emphasised and a link bar on every tab node, and the second shows none of them

#### Scenario: Selecting a done objective
- **WHEN** the user opens the Done group and clicks a done objective's node on its second line
- **THEN** it is drawn selected, its lines show, and every tab node has a link bar

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
"＋ New objective" in the header SHALL ask for a title, create the objective with no links, at the starting priority and place set in Configure (P3 and the top by default), and select it.

#### Scenario: Create and select
- **WHEN** the user clicks "＋ New objective" and enters "Write slides"
- **THEN** "Write slides" appears selected with a P3 badge, and every tab node shows a "＋ Link" bar

### Requirement: Live refresh
While the graph is shown, it SHALL redraw by itself within one second of any of these:
- a tab or pane opening, closing or moving;
- a title change;
- the current session changing;
- an agent's state changing;
- a pane's unseen alert appearing or clearing;
- a command finishing.

#### Scenario: New tab appears
- **WHEN** a new tab is opened while the graph is shown
- **THEN** the tab appears in the right column without the graph being reopened

### Requirement: Light and dark themes
Lines, badges, chips, the unlinked-tab fill and the two attention rings SHALL stay distinguishable in both Tern's light and dark appearances.

#### Scenario: Both appearances
- **WHEN** the graph is captured in the light appearance and in the dark appearance
- **THEN** both captures show every line, every badge colour, unlinked tabs filled differently from linked ones, and a "needs you" ring in a different colour from a "replied" ring

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
The grip, the done box and the trash icon SHALL each take clicks over at least 22 px of width and the full 18 px height of their line in objective nodes. Action bar buttons SHALL be at least 22 px tall. A pane row's jump button SHALL take clicks over at least 28 px of width and the row's full 22 px height. The Hard, Good and Easy buttons SHALL each be at least 22 px tall. Unselected objective nodes with a one-line title SHALL stay 48 px tall outside review mode, and pane rows 22 px.

#### Scenario: Measured hit areas
- **WHEN** a screenshot's layout data is read outside review mode with one objective selected
- **THEN** every grip, done box and trash icon is at least 22 × 18 px, every action bar button at least 22 px tall, every jump button at least 28 × 22 px, unselected objective nodes with one-line titles are 48 px tall, and pane rows are 22 px tall

#### Scenario: Review nodes
- **WHEN** a screenshot's layout data is read in review mode
- **THEN** every Hard, Good and Easy button is at least 22 px tall, and every listed node with a one-line title has the same height

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

### Requirement: Rename key
"Objectives: Rename selected objective", default key ⌥R, SHALL open the one-line Rename field for the selected objective, filled with its title, while the graph is shown over the current tab. The field SHALL behave as from a click on the title, and the selection SHALL stay. With no objective selected, or no graph shown over the tab, it SHALL show an info toast saying to select an objective in the graph, and change nothing.

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

Clicking a done objective's box SHALL ask whether to reopen it ("Reopening a done objective").

#### Scenario: Marking done
- **WHEN** the user clicks the done box of a linked open objective that is not selected
- **THEN** it moves into the Done group, the count goes up by one, and its lines are gone

#### Scenario: Box of a done objective
- **WHEN** the user opens the Done group and clicks a done objective's box
- **THEN** it stays in the Done group, the count is unchanged, the kv dump shows it still done, and its action bar asks whether to reopen it

### Requirement: Closing a done objective's tabs
"Close n tabs" in a done objective's action bar SHALL ask in the bar, naming how many tabs it will close and how many linked tabs stay open because an open objective links them. On Close it SHALL save the omp chats in those tabs as it does at a turn, then close every pane of each of them, and change no links. A graph sitting in one of them SHALL close first and show again after. If the chats can't be saved, it SHALL close nothing and say so. Cancel SHALL change nothing.

#### Scenario: Close two, keep one
- **WHEN** done objective X links open tabs A, B and C, open objective Y also links C, and the user selects X and clicks "Close 2 tabs" in its bar
- **THEN** the bar asks to close 2 tabs and says 1 stays open; after Close, the window holds C but not A or B, and the kv dump shows X still linked to A, B and C

#### Scenario: Chat ready to resume
- **WHEN** tab A held an omp chat that had replied, A was closed this way, and the user selects X
- **THEN** A shows under "Closed tabs" with "Resume", and its row starts with "omp"

#### Scenario: Cancelled
- **WHEN** the user clicks "Close 2 tabs" in X's bar and then Cancel
- **THEN** A, B and C are all still open, the bar shows its buttons again, and `kv.json` is unchanged

#### Scenario: The graph's own tab
- **WHEN** done objective X links only tab D, the graph was opened over D, and the user clicks "Close 1 tab" in X's bar and then Close
- **THEN** D is gone, no tab is left holding only the graph, and the graph is shown again

### Requirement: Closing tabs from the done notice
When an objective is marked done in the graph and has tabs "Close n tabs" would close, its "Marked done" notice SHALL also offer "Close <n> tabs" after Undo. Clicking it SHALL turn the notice into the same question, with Close and Cancel. Close SHALL close the tabs and end the notice; Cancel SHALL bring back the notice and its Undo as they were. Marking done SHALL NOT close any tab by itself.

#### Scenario: Offered after marking done
- **WHEN** open objective X links two open tabs that no other open objective links, and the user clicks X's done box
- **THEN** the header reads "Marked done “X” · Undo · Close 2 tabs", and both tabs are still open

#### Scenario: Cancel keeps Undo
- **WHEN** the user clicks "Close 2 tabs" and then Cancel, then clicks Undo within 10 seconds of marking done
- **THEN** both tabs are still open, and X is open again

#### Scenario: Confirmed from the notice
- **WHEN** the user clicks "Close 2 tabs" and then Close
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
Each objective node SHALL show its creation time after the title's last line, dimmed, as `MM-DD HH:MM` in local time, so objectives with the same title can be told apart. A line too long for the graph's width SHALL be cut with "…" before the time is. The time SHALL come from when the objective was created and SHALL NOT be part of its title: renaming SHALL NOT change it, and objectives created before this version SHALL show it too.

#### Scenario: Two with one title
- **WHEN** the user creates "Write slides" with "＋ New objective", and again a minute or more later
- **THEN** both nodes read "Write slides", each followed by its own creation time from the kv dump's `created`, as `MM-DD HH:MM`, and both kv titles are exactly "Write slides"

#### Scenario: Long title
- **WHEN** an objective's title is 120 characters long and the graph is 1400 pixels wide
- **THEN** its title takes three lines, the third ends in "…", and the creation time after it is shown whole

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

### Requirement: Controls and titles don't select text
Dragging across an objective's title, a tag chip, a due chip, a P0–P3 badge, the header's "All" and "This session" buttons, "＋ New objective", or a pane row's type, name or jump button SHALL NOT select its text. Neither dragging across nor double-clicking a group or session heading SHALL select its text: "Done (n)", "Closed tabs", "Other windows", a session heading, the `Linked to` heading or the `Other tabs` divider.

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

#### Scenario: Drag across a title
- **WHEN** the user presses on an objective's side note, drags up across its title and releases beside the title
- **THEN** the screenshot shows no text highlight on the title, and no Rename field is open

### Requirement: Title lines
An objective's title SHALL break at spaces into lines of at most 36 characters, onto at most three lines; only a word longer than a line SHALL be split. A title that needs more SHALL end its third line in "…". The breaks SHALL be the same at every graph width. Each line past the first SHALL make the node 18 px taller, and its link lines SHALL still meet it at its vertical centre.

#### Scenario: Short title
- **WHEN** an objective is titled "Fix login bug"
- **THEN** its title takes one line and its node is 48 px tall

#### Scenario: Two lines
- **WHEN** an open objective linked to a tab is titled "Write the onboarding guide for new contributors to the API"
- **THEN** its title reads "Write the onboarding guide for new" over "contributors to the API", its node is 66 px tall, and its link line meets the node's vertical centre

#### Scenario: More than three lines
- **WHEN** an objective's title is 120 characters long
- **THEN** its title takes three lines, the third ends in "…", its node is 84 px tall, and the node's tooltip holds the whole title

#### Scenario: Same breaks at any width
- **WHEN** the graph shows the two-line title of "Two lines" at 1400 and at 900 pixels wide
- **THEN** both shots break it after "new"

### Requirement: Rename by clicking the title
A click on an objective's title SHALL open the one-line Rename field, filled with the title, as ⌥R does, on open, done and review nodes. Only the title's own text SHALL take this click; the rest of the node SHALL select as before. The click SHALL NOT change the selection.

#### Scenario: Rename by click
- **WHEN** the user clicks the title "Fix login bug" and enters "Fix login timeout"
- **THEN** the field opened holding "Fix login bug", and the node and the kv dump then hold "Fix login timeout"

#### Scenario: Selection unchanged
- **WHEN** "Write slides" is selected and the user clicks the title of "Fix login bug", then dismisses the field
- **THEN** "Write slides" is still selected and "Fix login bug" is not

#### Scenario: Beside a short title
- **WHEN** the user clicks an objective node to the right of its one-line title
- **THEN** the objective is selected and no field opens

#### Scenario: Second line of a title
- **WHEN** the user clicks the second line of a two-line title
- **THEN** the Rename field opens holding the whole title

### Requirement: Attention marks
An objective node SHALL show the first mark that applies to the omp chats in the live tabs of this window that it links:
- **needs you:** one waits for the user's input. An amber ring, and a "needs you" chip first on its second line.
- **replied:** one finished a reply the user hasn't seen yet. A green ring and a "replied" chip.
- **working:** one is working. An accent-coloured "working" chip, and no ring.

Other agents SHALL NOT mark it. The chip's tooltip SHALL name the tabs.

#### Scenario: Question waiting
- **WHEN** "Fix login bug" links tab "Server", and the omp chat there asks the user a question while the user is in another tab
- **THEN** the graph shows "Fix login bug" with an amber ring and a "needs you" chip whose tooltip names "Server"

#### Scenario: Reply unseen
- **WHEN** "Fix login bug" links tab "Server", and the omp chat there finishes a reply while the user is in another tab
- **THEN** the graph shows "Fix login bug" with a green ring and a "replied" chip

#### Scenario: Chat working
- **WHEN** "Fix login bug" links tab "Server", and the omp chat there is working on a turn
- **THEN** the graph shows "Fix login bug" with an accent-coloured "working" chip first on its second line, whose tooltip names "Server", and no ring

#### Scenario: Working turns into replied
- **WHEN** "Fix login bug" shows "working" for tab "Server", and the omp chat there finishes its reply while the user is in another tab
- **THEN** the "working" chip goes, and "Fix login bug" shows a green ring and a "replied" chip

#### Scenario: Needs you wins
- **WHEN** an objective links one tab whose omp chat waits for input and another whose omp chat has an unseen reply
- **THEN** its node shows the amber ring and the "needs you" chip only

#### Scenario: Needs you wins over working
- **WHEN** an objective links tab "Server", whose omp chat waits for input, and tab "Docs", whose omp chat is working
- **THEN** its node shows the amber ring and the "needs you" chip only, naming "Server"

#### Scenario: Replied wins over working
- **WHEN** an objective links tab "Server", whose omp chat has an unseen reply, and tab "Docs", whose omp chat is working
- **THEN** its node shows the green ring and the "replied" chip only, naming "Server"

#### Scenario: Two chats in one tab
- **WHEN** tab "Split", linked to "Fix login bug", holds two omp chats side by side, one waiting for input and the other with a reply the user hasn't seen
- **THEN** "Fix login bug" shows the amber ring and the "needs you" chip only, naming "Split" once

#### Scenario: Not linked
- **WHEN** the omp chat in tab "Server" waits for input, and "Write slides" doesn't link "Server"
- **THEN** "Write slides" has no ring and no chip of any kind

### Requirement: Attention marks clear
A "replied" mark SHALL go once the user has focused the omp pane that replied, as Tern's own unseen-reply marker does. Looking at its tab while another pane there has focus SHALL NOT clear it. A "needs you" mark SHALL stay until the chat stops waiting for input, even after the user has focused it. Marks SHALL show on open, done and review nodes. A selected node SHALL show its selection ring and its mark together.

#### Scenario: Focusing the pane clears a reply
- **WHEN** "Fix login bug" shows "replied" for tab "Server", and the user focuses the omp pane there and opens the graph again
- **THEN** "Fix login bug" has no ring and no chip of either kind

#### Scenario: Another pane of the tab focused
- **WHEN** tab "Split", linked to "Fix login bug", holds two omp chats side by side, the right one finished a reply the user hasn't seen, and the user focuses the left one and opens the graph again
- **THEN** "Fix login bug" still shows "replied"

#### Scenario: Focusing keeps a question
- **WHEN** "Fix login bug" shows "needs you" for tab "Server", and the user focuses the omp pane there without answering and opens the graph again
- **THEN** "Fix login bug" still shows "needs you"

#### Scenario: Selected and marked
- **WHEN** "Fix login bug" shows "needs you" and the user selects it
- **THEN** the screenshot shows the accent selection ring and the amber ring together, and the "needs you" chip

### Requirement: Custom order
Open objectives SHALL be listed in the order the user sets, which is kept with the objectives and shared by every window. Priority, due date and badge clicks SHALL NOT change it. A new objective SHALL take the place set in Configure, top by default. The first open after updating to this version SHALL list the open objectives as before: by priority, P0 first, then by due date, earliest first and none last, then by created time, oldest first.

#### Scenario: Order kept from before
- **WHEN** `kv.json` written by 0.16.0 holds P2 due tomorrow, P2 with no due date, P0 with no due date, and P2 due today, and the graph opens
- **THEN** the order is P0, P2 due today, P2 due tomorrow, P2 with no date

#### Scenario: Badge clicks don't move a node
- **WHEN** the graph lists the P3 objectives "Fix login bug", "Review pull requests" and "Write slides" in that order, the user clicks the badge of "Write slides" three times and then clicks empty graph space
- **THEN** "Write slides" is third after every click, its badge reads P0, and the kv dump holds priority 0 for it

#### Scenario: Due date doesn't move a node
- **WHEN** the user gives "Write slides", third in the list, a due date of today
- **THEN** "Write slides" is still third

#### Scenario: New objective on top
- **WHEN** the list holds "Fix login bug" and "Review pull requests" and the user creates "Write slides" with "＋ New objective"
- **THEN** the list reads "Write slides", "Fix login bug", "Review pull requests"

#### Scenario: Same order in link choices
- **WHEN** the user has moved "Write slides" to the top and runs "Objectives: Link this tab…", then right-clicks a tab node
- **THEN** both the picker and the tab menu list the open objectives in the left column's order, "Write slides" first

### Requirement: Moving objectives
Each open objective node SHALL show a grip ⠿ at its left, outside review mode. A click on the grip SHALL lift the node: it is drawn lifted, and the header shows `Moving “<title>”` with Cancel. While a node is lifted, pointing at another shown open objective's upper or lower half SHALL show an insertion line at that node's top or bottom edge, and a click there SHALL move the lifted objective to that line. Cancel, the grip again, or any other click SHALL end the move with the order unchanged.

#### Scenario: Move to the top
- **WHEN** the list reads "Fix login bug", "Review pull requests", "Write slides", and the user clicks the grip of "Write slides" and then the upper half of "Fix login bug"
- **THEN** the list reads "Write slides", "Fix login bug", "Review pull requests", nothing is lifted, and the kv dump holds the objectives in that order

#### Scenario: Move below
- **WHEN** the user then clicks the grip of "Write slides" and the lower half of "Review pull requests"
- **THEN** the list reads "Fix login bug", "Review pull requests", "Write slides"

#### Scenario: Insertion line
- **WHEN** "Write slides" is lifted and the pointer rests on the lower half of "Fix login bug"
- **THEN** a screenshot shows "Write slides" drawn lifted, the header reading `Moving “Write slides”` with Cancel, and an accent insertion line along the bottom edge of "Fix login bug" only

#### Scenario: Cancelled move
- **WHEN** "Write slides" is lifted and the user clicks empty graph space
- **THEN** nothing is lifted, the header shows no `Moving` notice, and the order and the kv dump are unchanged

#### Scenario: Moving under a tag filter
- **WHEN** "Review pull requests" lacks the tag "api" that the other two hold, the "#api" filter is on, and the user moves "Write slides" above "Fix login bug"
- **THEN** with the filter cleared the list reads "Write slides", "Fix login bug", "Review pull requests"

#### Scenario: No grip on done objectives
- **WHEN** the user opens the Done group
- **THEN** no done node has a grip, and the Done group is still ordered most recently done first

### Requirement: Action bar
The selected objective SHALL show a row of buttons under its lines, below the rating buttons in review mode. An open objective's row SHALL hold Note, Due, Tags and Delete. A done objective's row SHALL hold Note and Tags, and "Close n tabs" while at least one of its linked tabs is open in this window and no open objective links it, n being the number of those tabs. Note, Due and Tags SHALL open the Side note field, Due date picker and Tags picker directly. No node SHALL have a ⋯ button.

#### Scenario: Open objective's bar
- **WHEN** the user selects open objective "Fix login bug"
- **THEN** a row with Note, Due, Tags and Delete shows under its lines, no other node shows one, and no node has a ⋯ button

#### Scenario: Note directly
- **WHEN** the user selects "Fix login bug", clicks Note and enters "check the session cookie"
- **THEN** no picker opened before the field, and the node's side note reads "check the session cookie"

#### Scenario: Dismissed field
- **WHEN** the user clicks Note in the bar and dismisses the field
- **THEN** the objective is unchanged

#### Scenario: Done objective with tabs to close
- **WHEN** done objective X links two open tabs that no open objective links, and the user selects X
- **THEN** X's row holds Note, Tags and "Close 2 tabs", and selecting an open objective shows no "Close" button

#### Scenario: Nothing to close
- **WHEN** done objective X's only open tab is also linked to an open objective, and the user selects X
- **THEN** X's row holds Note and Tags only

### Requirement: Inline confirmation
An action that asks before acting SHALL ask in place, never in a picker: "Close n tabs" in the action bar or the done notice, "Close n done tabs" in the header, and a done objective's box in its action bar. The control or bar SHALL turn into the question with its answers: Close and Cancel, or Keep review, Reset review and Cancel. In an action bar, the question SHALL take its own row above its answers. Cancel, or any other click in the graph, SHALL end the question and change nothing.

#### Scenario: Asked in the bar
- **WHEN** done objective X links two open tabs that no open objective links, and the user clicks "Close 2 tabs" in X's bar
- **THEN** no picker opens, and the bar reads "Close 2 tabs?" with Close and Cancel

#### Scenario: Another click cancels
- **WHEN** the bar asks "Close 2 tabs?" and the user clicks empty graph space
- **THEN** both tabs are still open, and selecting X again shows its row with "Close 2 tabs"

#### Scenario: Another click ends the reopen question
- **WHEN** a done objective's bar asks whether to reopen it, and the user clicks empty graph space
- **THEN** nothing is selected, the objective is still in the Done group, and the kv dump shows it still done

#### Scenario: Questions in a narrow graph
- **WHEN** the window is 460 px wide, and a done objective's bar asks to close its tabs or to reopen it
- **THEN** the question's row starts with "Close 2 tabs?" or "Reopen", and every answer, with its icon, sits inside the objective's node

### Requirement: New objective key
"Objectives: New objective", default key ⌥N, SHALL ask for a title and create an objective as "＋ New objective" does, selected in the graph. It SHALL first end review mode. With the graph shown over the current tab, it SHALL act there, the settings page switching back to the graph. Anywhere else it SHALL first show the graph over the current tab. Like any plugin key, ⌥N SHALL run in every pane, whichever Option key is held.

#### Scenario: In the graph
- **WHEN** the graph is shown and the user presses ⌥N and enters "Write slides"
- **THEN** "Write slides" appears selected at the top of the list, and the kv dump holds it

#### Scenario: From a shell
- **WHEN** no graph is shown, focus is in a shell, and the user presses ⌥N and enters "Write slides"
- **THEN** the graph is shown over the current tab with "Write slides" selected, and the shell's prompt is unchanged

#### Scenario: Letters still reach the panes
- **WHEN** focus is in a shell prompt and the user types "n" and "N"
- **THEN** the prompt shows "nN", and no field or toast appears

#### Scenario: From review mode
- **WHEN** review mode lists two objectives and the user presses ⌥N and enters "Write slides"
- **THEN** the left column shows the open objectives with "Write slides" selected at the top, and the Done group, and "Review (2)" is not active

#### Scenario: From a shell after review mode
- **WHEN** the graph was closed in review mode listing two objectives, focus is in a shell, and the user presses ⌥N and enters "Write slides"
- **THEN** the graph is shown over the current tab with the open objectives, "Write slides" selected at the top, and "Review (2)" not active

### Requirement: Closing tabs of done objectives
The header SHALL show "Close n done tabs" while n of the live tabs the graph shows are linked only to done objectives: at least one done objective links each, and no open objective does. Clicking it SHALL ask in place. On Close it SHALL save the omp chats in those tabs, then close every pane of each, as "Close n tabs" does for one objective, and change no links. If the chats can't be saved, it SHALL close nothing and say so.

#### Scenario: Button shows
- **WHEN** done objective X links tab A, done objective Z and open objective Y both link tab B, and tab C is linked to nothing
- **THEN** the header shows "Close 1 done tab"

#### Scenario: Closed after asking
- **WHEN** the user clicks "Close 1 done tab" and then Close
- **THEN** the window holds B and C but not A, the kv dump shows X still linked to A, and the header shows no "done tab" button

#### Scenario: Cancelled
- **WHEN** the user clicks "Close 1 done tab" and then Cancel
- **THEN** A, B and C are all still open, and the header shows "Close 1 done tab" again

#### Scenario: Only the tabs the graph shows
- **WHEN** scope "This session" is on, and the only tab linked only to done objectives is in another session
- **THEN** the header shows no "done tab" button

#### Scenario: The graph's own tab
- **WHEN** the graph was opened over tab D, which only a done objective links, and the user clicks "Close 1 done tab" and then Close
- **THEN** D is gone, no tab is left holding only the graph, and the graph is shown again

### Requirement: Direct controls don't select text
Dragging across a grip, an action bar's buttons, an inline confirmation's buttons, the `Moving` notice, the header's "Close n done tabs", or the settings page's buttons SHALL NOT select their text.

#### Scenario: Drag across the action bar
- **WHEN** the user presses on the selected objective's side note, drags across its Note, Due and Tags buttons and releases beside the bar
- **THEN** the screenshot shows no text highlight on the buttons, and no field or picker opens

### Requirement: Reopening a done objective
Clicking a done objective's box, in the Done group or in review mode, SHALL select it and turn its action bar into the question "Reopen “<title>”?" above Keep review, Reset review and Cancel. Keep review and Reset review SHALL both reopen it: it leaves the Done group, or review mode's list, and shows last among the open objectives, still selected. Cancel SHALL end the question and leave it done and selected. Reopening SHALL offer no Undo.

#### Scenario: Asking to reopen
- **WHEN** "Fix login bug" and "Review pull requests" are open, and the user opens the Done group and clicks the box of done objective "Write slides"
- **THEN** no picker opens, "Write slides" is selected, its bar asks "Reopen “Write slides”?" above Keep review, Reset review and Cancel, and the kv dump shows it still done

#### Scenario: Keep review
- **WHEN** "Write slides" links a live tab, and the user then clicks Keep review
- **THEN** the list reads "Fix login bug", "Review pull requests", "Write slides", with "Write slides" selected and its bar showing Note, Due, Tags and Delete; a line joins it to its tab, the Done count is one less, and the header shows no Undo notice

#### Scenario: Cancelled
- **WHEN** the user clicks the box of done objective "Write slides" and then Cancel
- **THEN** "Write slides" is still in the Done group and selected, its bar shows its usual buttons again, and `kv.json` is unchanged

#### Scenario: From review mode
- **WHEN** review mode lists two objectives, and the user clicks the box of one of them and then Reset review
- **THEN** review mode lists only the other one, the header shows "Review (1)" active, and the kv dump shows the reopened objective open with no schedule

#### Scenario: Last one in review mode
- **WHEN** review mode lists one objective, and the user clicks its box and then Keep review
- **THEN** the left column shows the open objectives, the reopened one last and selected, and the header shows no Review button
