# objective-store Specification

## Purpose
Holds the user's objectives as one flat, global list that every session and window of this machine shares, together with their review schedules, the tab snapshots and saved omp chats the graph needs, and the view settings, in the plugin's own private storage.

## Requirements

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

### Requirement: One global list
Objectives SHALL NOT belong to a session, tab or window. Every window of the machine SHALL read and change the same list.

#### Scenario: Visible from another session
- **WHEN** the user creates an objective while session "alpha" is shown, switches to session "beta" and opens the graph with scope All
- **THEN** the objective is listed

### Requirement: Private storage
The plugin SHALL keep all of its state, its settings included, as one JSON value under one key of its own `kv.json` in Tern's plugin data folder. Shortcuts changed in Configure SHALL be saved by Tern in its own keybinds, through Tern's settings API, and nowhere else. It SHALL write no file into any pane's working folder, the home folder or its package folder.

#### Scenario: Where data lands
- **WHEN** the user creates, edits and links objectives
- **THEN** `plugin-data/objectives/kv.json` holds the objectives and no new file appears in the panes' working folders or in the plugin's package folder

### Requirement: Read before write
Every change SHALL re-read the stored state immediately before applying itself, so that changes saved earlier by another window are kept.

#### Scenario: Another window's objective survives
- **WHEN** an objective is added to `kv.json` from outside this window, and the user then renames a different objective in this window's graph
- **THEN** `kv.json` contains both the outside objective and the renamed one

### Requirement: Side note
A side note SHALL be a single line of at most 200 characters. Line breaks that reach the plugin SHALL become spaces, and longer input SHALL be cut to 200 characters. Saving an empty note SHALL remove it. (Tern's one-line field itself joins pasted lines, without a space, before the plugin sees them.)

#### Scenario: Multi-line paste
- **WHEN** the user pastes text with a line break into the Side note field and saves it
- **THEN** the stored note is one line

#### Scenario: Clearing the note
- **WHEN** the user saves an empty side note
- **THEN** the objective has no side note

### Requirement: Due date
A due date SHALL be a calendar date with no time of day, stored as `YYYY-MM-DD` in the machine's local calendar. Input that is not a real calendar date SHALL be rejected with an error toast, leaving the objective unchanged.

#### Scenario: Valid date
- **WHEN** the user enters "2026-11-20" as the due date
- **THEN** the objective's stored due date is "2026-11-20"

#### Scenario: Invalid date
- **WHEN** the user enters "2026-02-30"
- **THEN** an error toast appears and the objective's due date is unchanged

### Requirement: Tags
A tag SHALL be stored in lowercase, trimmed, with runs of spaces replaced by one hyphen. An objective SHALL hold each tag at most once. A tag SHALL exist only while at least one objective holds it.

#### Scenario: Normalised tag
- **WHEN** the user creates the tag "  Web Work "
- **THEN** the objective's tags contain "web-work"

#### Scenario: Unused tag disappears
- **WHEN** the only objective holding tag "api" has it removed
- **THEN** "api" no longer appears in the tag picker or the tag filter

### Requirement: Tab snapshots
For every linked tab the window currently holds, the store SHALL keep a snapshot so the tab can still be shown after it closes. The snapshot SHALL hold:
- the tab's label;
- its session's id and name;
- its position;
- its pane rows;
- the key of the window that holds it.

The snapshot SHALL be refreshed whenever the graph sees the tab.

#### Scenario: Snapshot written on link
- **WHEN** the user links an objective to tab 2 of session "web"
- **THEN** `kv.json` holds a snapshot of that tab with its label, session "web", position 2, its pane rows and the window key

### Requirement: Remembered view settings
The store SHALL keep the scope filter, the tag filter, whether the Done group is open, and which pane rows are open. These settings SHALL be restored when the graph is reopened and after a plugin reload.

#### Scenario: Settings survive reload
- **WHEN** the user picks scope "This session", filters by tag "api", opens a pane row's details, and the plugin is reloaded
- **THEN** reopening the graph shows scope "This session", the "api" filter, that row open and every other live row folded

#### Scenario: Rows opened under 0.1.x
- **WHEN** `kv.json` holds view settings written by version 0.1.x, listing expanded rows, and the graph is opened
- **THEN** the listed rows that are live are open and every other live pane row is folded

#### Scenario: Rows folded under 0.4.0
- **WHEN** `kv.json` holds view settings written by version 0.4.0, listing folded rows, and the graph is opened
- **THEN** every live pane row is folded, and after the next change to a view setting `kv.json` no longer holds the folded rows

### Requirement: Durable across restarts
Objectives, links and snapshots SHALL survive a plugin reload, a Tern restart and a full daemon restart.

#### Scenario: Plugin reload
- **WHEN** the plugin is reloaded after objectives and links were made
- **THEN** the graph shows the same objectives with the same links

### Requirement: Missing priority
A stored objective without a priority SHALL read as P3, whatever starting priority Configure sets for new objectives.

#### Scenario: Record without a priority
- **WHEN** `kv.json` holds an open objective with no priority field and the graph is opened
- **THEN** its badge reads P3

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

### Requirement: Done and reopening
Marking an objective done SHALL record the done time and start or carry on its review schedule. A done objective SHALL become open again only through Undo right after it was marked done, or when the user reopens it. Reopening SHALL clear the done time, keep or drop the schedule as the user chose, and put the objective after every other objective in the stored order. Marking done, Undo and reopening SHALL NOT change its links.

#### Scenario: Done until reopened
- **WHEN** the user marks a linked objective done, waits for the Undo notice to go, then clicks its done box and Cancel
- **THEN** the record is still done with the same done time, and its tab links are identical throughout

#### Scenario: Reopened keeping its review
- **WHEN** done objective "Write slides", linked to two tabs and reviewed twice, is reopened with "Keep review" while "Fix login bug" and "Review pull requests" are open
- **THEN** the kv dump shows "Write slides" open, with no done time, the same schedule and the same two links, as the last record of the list

#### Scenario: Reopened resetting its review
- **WHEN** done objective "Write slides", linked to two tabs, is reopened with "Reset review"
- **THEN** the kv dump shows "Write slides" open, with no done time, no schedule and the same two links
