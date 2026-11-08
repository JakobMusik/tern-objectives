# Spec Delta

## ADDED Requirements

### Requirement: Stored order
The store SHALL keep the open objectives' custom order, so every window shows the same order and it survives reloads and restarts. Moving an objective SHALL re-read the store first, like every change, and SHALL change no other field of any objective. A state written before this version SHALL be read in the old automatic order, which the next write stores.

#### Scenario: Move saved
- **WHEN** the user moves "Write slides" above "Fix login bug"
- **THEN** the kv dump lists "Write slides" before "Fix login bug", and both records are otherwise unchanged

#### Scenario: Order survives a reload
- **WHEN** the user moves "Write slides" to the top and the plugin is reloaded
- **THEN** the reopened graph lists "Write slides" first

#### Scenario: Another window's objective kept
- **WHEN** an objective is added to `kv.json` from outside this window, and the user then moves "Write slides" in this window's graph
- **THEN** `kv.json` holds the outside objective and the new order

### Requirement: Removing an objective
Delete in an open objective's action bar, and a done objective's trash icon, SHALL remove the objective and its links at once, without asking, and offer Undo.

#### Scenario: Delete from the bar
- **WHEN** the user selects open objective "Write slides" and clicks Delete in its bar
- **THEN** no confirmation appears, "Write slides" and its links are gone from `kv.json`, and the header shows "Removed “Write slides” · Undo"

#### Scenario: Trash icon on a done objective
- **WHEN** the user clicks a done objective's trash icon
- **THEN** no confirmation appears, and the objective and its links are gone from `kv.json`

## MODIFIED Requirements

### Requirement: Objective record
Each objective SHALL have:
- a title: trimmed, non-empty, at most 120 characters;
- a done flag;
- a priority from P0 (most urgent) to P3;
- a created time and a done time;
- an optional side note, due date and tag list;
- once done, a review schedule: its next review date, interval in days, ease in percent and review count.

A new objective SHALL start not done, at the priority set in Configure, created now, with no note, due date, tags or review schedule, and no links unless made for a tab.

#### Scenario: Creating an objective
- **WHEN** the user creates an objective titled "  Fix login bug  "
- **THEN** the stored record has title "Fix login bug", done false, priority P3, a created time, and no note, due date, tags, links or review schedule

#### Scenario: Blank title
- **WHEN** the user submits a title that is empty or only spaces
- **THEN** no objective is created and the stored list is unchanged

#### Scenario: Over-long title
- **WHEN** the user submits a title longer than 120 characters
- **THEN** the stored title is cut to its first 120 characters

#### Scenario: Made for a tab
- **WHEN** the user runs "Objectives: New objective for this tab…" in tab A and enters a title
- **THEN** the stored record is linked to A and to no other tab

### Requirement: Private storage
The plugin SHALL keep all of its state, its settings included, as one JSON value under one key of its own `kv.json` in Tern's plugin data folder. Shortcuts changed in Configure SHALL be saved by Tern in its own keybinds, through Tern's settings API, and nowhere else. It SHALL write no file into any pane's working folder, the home folder or its package folder.

#### Scenario: Where data lands
- **WHEN** the user creates, edits and links objectives
- **THEN** `plugin-data/objectives/kv.json` holds the objectives and no new file appears in the panes' working folders or in the plugin's package folder

### Requirement: Missing priority
A stored objective without a priority SHALL read as P3, whatever starting priority Configure sets for new objectives.

#### Scenario: Record without a priority
- **WHEN** `kv.json` holds an open objective with no priority field and the graph is opened
- **THEN** its badge reads P3

## REMOVED Requirements

### Requirement: Deleting an objective
**Reason**: Delete no longer asks; it removes at once with Undo, as the done trash icon already did (Removing an objective).
**Migration**: Use Undo in the header notice within 10 seconds to bring a deleted objective back.

### Requirement: Pruning closed tabs
**Reason**: Links change only when the user clicks a link bar, or when Resume hands them to a new tab; a bulk removal of closed tabs' links goes against that.
**Migration**: A closed tab linked to an open objective stays under "Closed tabs" until the user resumes it or clicks "× Unlink" on it with the objective selected. Unlinking the last link drops its snapshot, as before.
