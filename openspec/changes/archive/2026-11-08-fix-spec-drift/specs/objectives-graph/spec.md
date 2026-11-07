## MODIFIED Requirements

### Requirement: Empty state
With no objectives, the left column SHALL show a hint pointing at "＋ New objective". When objectives exist but the filters leave none to list, it SHALL show "No objectives match this filter." instead.

#### Scenario: First open
- **WHEN** the graph opens with an empty store
- **THEN** the left column shows the hint, and the right column still lists the window's tabs

#### Scenario: Nothing matches
- **WHEN** the store holds objectives, none of them linked to a tab in the current session, and the user clicks "This session"
- **THEN** the left column shows only "No objectives match this filter."

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

### Requirement: Tag filter
The header SHALL show a chip for each existing tag. Clicking a chip SHALL show only objectives holding that tag; clicking it again SHALL clear the filter. At most one tag filter SHALL be active at a time. When no objective holds the filtered tag any more, the filter SHALL be dropped and every objective shown again.

#### Scenario: Filter by tag
- **WHEN** the user clicks the "#api" chip
- **THEN** only objectives tagged "api" are listed, and the chip is drawn active

#### Scenario: Filtered tag removed
- **WHEN** the "#api" filter is active and the user removes the tag "api" from the last objective holding it
- **THEN** the "#api" chip is gone, every objective is listed again, and the kv dump's view settings hold no tag filter

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

## ADDED Requirements

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
