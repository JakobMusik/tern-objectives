## ADDED Requirements

### Requirement: New objective listed first
An objective created with "＋ New objective" or ⌥N SHALL be listed first among the open objectives while it stays selected, whatever the sort method and Configure's place, and a tag filter SHALL NOT hide it. The tab menu and the "Link this tab…" picker SHALL list it first too. Its title's last line SHALL end in a "New" chip. Selecting another objective, clearing the selection, lifting a grip, marking it done, removing it and a fresh open SHALL end this; it then takes its sorted place.

#### Scenario: First when sorted by priority
- **WHEN** sorted by priority, with new objectives starting at P3 on top, the list reads "Release" (P1) and "Fix login bug" (P3), and the user clicks "＋ New objective" and enters "Write slides"
- **THEN** the list reads "Write slides", "Release", "Fix login bug", "Write slides" is selected with a "New" chip after its creation time, and the kv dump lists it first among the objectives

#### Scenario: Its own controls keep it first
- **WHEN** "Write slides" is listed first as above, and the user clicks its badge, then "＋ Link" on the Guides tab node, then the Guides tab's header
- **THEN** after each click "Write slides" is first, selected, with its "New" chip; its badge reads P2, and the kv dump links it to Guides

#### Scenario: Deselected, it takes its place
- **WHEN** "Write slides" is listed first as in "First when sorted by priority", and the user clicks empty graph space
- **THEN** the list reads "Release", "Write slides", "Fix login bug", and no node shows a "New" chip

#### Scenario: Another objective selected
- **WHEN** "Write slides" is listed first as in "First when sorted by priority", and the user clicks the node of "Fix login bug" beside its title
- **THEN** the list reads "Release", "Write slides", "Fix login bug", "Fix login bug" is selected, and no node shows a "New" chip

#### Scenario: A second new objective
- **WHEN** "Write slides" is listed first as in "First when sorted by priority", and the user presses ⌥N and enters "Write notes"
- **THEN** the list reads "Write notes", "Release", "Write slides", "Fix login bug", and only "Write notes" shows a "New" chip

#### Scenario: Bottom of Your order
- **WHEN** sorted in Your order, with new objectives placed at the bottom, the list reads "Release", "Fix login bug", and the user clicks "＋ New objective" and enters "Write slides"
- **THEN** the list reads "Write slides", "Release", "Fix login bug"; after a click on empty graph space, it reads "Release", "Fix login bug", "Write slides"

#### Scenario: Lifting a grip ends it
- **WHEN** "Write slides" is listed first as in "First when sorted by priority", and the user clicks its grip
- **THEN** "Write slides" is drawn lifted in second place, after "Release", with no "New" chip

#### Scenario: Marking it done ends it
- **WHEN** "Write slides" is listed first as in "First when sorted by priority", and the user clicks its done box and then Undo in the notice
- **THEN** the list reads "Release", "Write slides", "Fix login bug", and no node shows a "New" chip

#### Scenario: Under a tag filter
- **WHEN** "Fix login bug" holds the tag "api", the "#api" filter is on, and the user clicks "＋ New objective" and enters "Write slides"
- **THEN** the list reads "Write slides", "Fix login bug", with the "New" chip on "Write slides"; after a click on empty graph space, only "Fix login bug" is listed

#### Scenario: Link choices list it first
- **WHEN** "Write slides" is listed first as in "First when sorted by priority", and the user right-clicks the Guides tab node, then runs "Objectives: Link this tab…"
- **THEN** both the tab menu and the picker list "Write slides", "Release", "Fix login bug"

#### Scenario: Fresh open ends it
- **WHEN** "Write slides" is listed first as in "First when sorted by priority", and the user presses ⌃⌘O twice
- **THEN** the reopened graph lists "Release", "Write slides", "Fix login bug", with nothing selected and no "New" chip

#### Scenario: Not for a tab's new objective
- **WHEN** sorted by priority, the list reads "Release" (P1) and "Fix login bug" (P3), and the user runs "Objectives: New objective for this tab…", enters "Write slides" and opens the graph
- **THEN** the graph lists "Release", "Write slides", "Fix login bug", with nothing selected and no "New" chip

## MODIFIED Requirements

### Requirement: New objective button
"＋ New objective" in the header SHALL first end review mode, as ⌥N does, then ask for a title, create the objective with no links, at the starting priority and place set in Configure (P3 and the top by default), and select it, listed first while it stays selected (see "New objective listed first").

#### Scenario: Create and select
- **WHEN** the user clicks "＋ New objective" and enters "Write slides"
- **THEN** "Write slides" appears selected with a P3 badge, and every tab node shows a "＋ Link" bar

#### Scenario: From review mode
- **WHEN** review mode lists two objectives and the user clicks "＋ New objective" and enters "Write slides"
- **THEN** the left column shows the open objectives with "Write slides" selected at the top, and the Done group, and "Review (2)" is not active

### Requirement: Tag filter
The header SHALL show a chip for each existing tag. Clicking a chip SHALL show only objectives holding that tag, and a new objective while it is listed first (see "New objective listed first"); clicking it again SHALL clear the filter. At most one tag filter SHALL be active at a time. When no objective holds the filtered tag any more, the filter SHALL be dropped and every objective shown again.

#### Scenario: Filter by tag
- **WHEN** the user clicks the "#api" chip
- **THEN** only objectives tagged "api" are listed, and the chip is drawn active

#### Scenario: Filtered tag removed
- **WHEN** the "#api" filter is active and the user removes the tag "api" from the last objective holding it
- **THEN** the "#api" chip is gone, every objective is listed again, and the kv dump's view settings hold no tag filter
