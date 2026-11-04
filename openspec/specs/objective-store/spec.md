# objective-store Specification

## Purpose
Holds the user's objectives as one flat, global list that every session and window of this machine shares, together with the tab snapshots and view settings the graph needs, in the plugin's own private storage.

## Requirements

### Requirement: Objective record
Each objective SHALL have:
- a title: trimmed, non-empty, at most 120 characters;
- a done flag;
- a priority from P0 (most urgent) to P3;
- a created time and a done time;
- an optional side note, due date and tag list.

A new objective SHALL start not done, at P2, with the current time as its created time, and with no note, due date, tags or links.

#### Scenario: Creating an objective
- **WHEN** the user creates an objective titled "  Fix login bug  "
- **THEN** the stored record has title "Fix login bug", done false, priority P2, a created time, and no note, due date, tags or links

#### Scenario: Blank title
- **WHEN** the user submits a title that is empty or only spaces
- **THEN** no objective is created and the stored list is unchanged

#### Scenario: Over-long title
- **WHEN** the user submits a title longer than 120 characters
- **THEN** the stored title is cut to its first 120 characters

### Requirement: One global list
Objectives SHALL NOT belong to a session, tab or window. Every window of the machine SHALL read and change the same list.

#### Scenario: Visible from another session
- **WHEN** the user creates an objective while session "alpha" is shown, switches to session "beta" and opens the graph with scope All
- **THEN** the objective is listed

### Requirement: Private storage
The plugin SHALL keep all of its state as one JSON value under one key of its own `kv.json` in Tern's plugin data folder. It SHALL write no file into any pane's working folder, the home folder or its package folder.

#### Scenario: Where data lands
- **WHEN** the user creates, edits and links objectives
- **THEN** `plugin-data/objectives/kv.json` holds the objectives and no new file appears in the panes' working folders or in the plugin's package folder

### Requirement: Read before write
Every change SHALL re-read the stored state immediately before applying itself, so that changes saved earlier by another window are kept.

#### Scenario: Another window's objective survives
- **WHEN** an objective is added to `kv.json` from outside this window, and the user then renames a different objective in this window's graph
- **THEN** `kv.json` contains both the outside objective and the renamed one

### Requirement: Done state
Marking an objective done SHALL record the done time. Reopening it SHALL clear the done time. Neither SHALL change its links.

#### Scenario: Done then reopened
- **WHEN** the user marks a linked objective done and then reopens it
- **THEN** the record's done time is set after the first step and cleared after the second, and its tab links are identical throughout

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

### Requirement: Deleting an objective
Deleting SHALL ask for confirmation. On confirmation it SHALL remove the objective and its links. On cancel it SHALL change nothing.

#### Scenario: Confirmed delete
- **WHEN** the user chooses Delete for an objective and confirms
- **THEN** the objective and its links are gone from `kv.json`

#### Scenario: Cancelled delete
- **WHEN** the user chooses Delete and then cancels
- **THEN** `kv.json` is unchanged

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

### Requirement: Pruning closed tabs
"Prune closed tabs" SHALL ask for confirmation, naming how many closed tabs it will remove. On confirmation it SHALL remove every closed tab's links and snapshot. Tabs that are live, or held by another window, SHALL be untouched.

#### Scenario: Prune after closing a tab
- **WHEN** a linked tab is closed and the user confirms "Prune closed tabs"
- **THEN** no objective links that tab, its snapshot is gone, and links to live tabs remain

### Requirement: Remembered view settings
The store SHALL keep the scope filter, the tag filter, whether the Done group is open, and which pane rows are folded. These settings SHALL be restored when the graph is reopened and after a plugin reload.

#### Scenario: Settings survive reload
- **WHEN** the user picks scope "This session", filters by tag "api", folds a pane row, and the plugin is reloaded
- **THEN** reopening the graph shows scope "This session", the "api" filter, that row folded and every other live row open

#### Scenario: Rows opened under 0.1.x
- **WHEN** `kv.json` holds view settings written by version 0.1.x, listing expanded rows, and the graph is opened
- **THEN** every live pane row is open, and after the next change to a view setting `kv.json` no longer holds the old expanded rows

### Requirement: Durable across restarts
Objectives, links and snapshots SHALL survive a plugin reload, a Tern restart and a full daemon restart.

#### Scenario: Plugin reload
- **WHEN** the plugin is reloaded after objectives and links were made
- **THEN** the graph shows the same objectives with the same links
