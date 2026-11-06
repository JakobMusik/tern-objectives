## ADDED Requirements

### Requirement: Double-click to edit
Double-clicking an objective's title SHALL open the one-line Rename field, filled with the title. Double-clicking anywhere on its second line, where the side note, due chip and tags sit, SHALL open the side-note field, filled with the note. Both fields SHALL behave as from ⋯ › Rename and ⋯ › Side note. A double-click SHALL leave the selection as it was before it.

#### Scenario: Rename by double-click
- **WHEN** the user double-clicks the title of "Fix login bug" and enters "Fix login timeout"
- **THEN** the node shows "Fix login timeout", and the kv dump holds that title

#### Scenario: Side note by double-click
- **WHEN** the user double-clicks the second line of an objective that has no side note and enters "waiting on CI"
- **THEN** the node's second line shows "waiting on CI", and the kv dump holds that note

#### Scenario: Selection kept
- **WHEN** objective A is selected and the user double-clicks objective B's title, then presses Enter without changing the title
- **THEN** A is still selected with its link bars and top section, and B's title is unchanged

### Requirement: Linked tabs first
While an objective is selected, the right column SHALL start with a section headed `Linked to “<title>”`: the shown tabs that were linked to it when it was selected. A divider "Other tabs" and every other shown tab SHALL follow, each part ordered as "Tab column" says. Linking or unlinking while it stays selected SHALL NOT move a tab. Deselecting SHALL restore the normal order. With no such tab, neither heading nor divider SHALL show.

#### Scenario: Linked tabs on top
- **WHEN** the window holds sessions "web" (tabs "App build" and "Components") and "api" (tabs "Server" and "Benchmarks"), objective X is linked to "Components" and "Benchmarks", the graph was opened from "Server", and the user selects X
- **THEN** the column reads: `Linked to “X”`, "api" with "Benchmarks", "web" with "Components", the "Other tabs" divider, "api" with "Server", then "web" with "App build"

#### Scenario: Linked closed tab
- **WHEN** X is also linked to a closed tab and the user selects X
- **THEN** that tab shows under a "Closed tabs" heading inside the top section, after the live tabs, and not again below the divider

#### Scenario: Order kept while linking
- **WHEN** X is selected and the user clicks "＋ Link" on a tab below the divider, then "× Unlink" on a tab in the top section
- **THEN** both tabs stay where they were, their bars now read "× Unlink" and "＋ Link", and the kv dump holds both changes

#### Scenario: Deselect and select again
- **WHEN** the user then clicks X to deselect it, and clicks it again
- **THEN** after the first click there is no heading or divider and the column is in its normal order; after the second, the newly linked tab is in the top section and the unlinked one below the divider

#### Scenario: Nothing linked
- **WHEN** the user creates "Write slides" with "＋ New objective", which selects it
- **THEN** the column shows no `Linked to` heading and no divider

#### Scenario: This session
- **WHEN** the scope is "This session", X is linked to tabs in the current session and in another, and the user selects X
- **THEN** the top section holds only the current session's linked tabs

## MODIFIED Requirements

### Requirement: Controls don't select text
Dragging across a tag chip, a due chip, a P0–P3 badge, an objective's title or side note, the header's "All" and "This session" buttons, "Prune closed tabs", "＋ New objective", or a pane row's type, name or jump button SHALL NOT select its text.

#### Scenario: Drag across the header
- **WHEN** the user presses in the header's empty space, drags across "＋ New objective", the tag filter chips and "All" / "This session", and releases in empty space
- **THEN** the screenshot shows no text highlight on any of them

#### Scenario: Drag across a node's badge and chips
- **WHEN** the user drags from an objective's side note across its due chip and tag chip, and from its title across its P0–P3 badge
- **THEN** the screenshot shows no text highlight on the note, the title, the badge or the chips, and the objective's priority is unchanged

#### Scenario: Drag along a pane row
- **WHEN** the user drags from a tab's header across a pane row's type and name
- **THEN** the screenshot shows no text highlight on the row
