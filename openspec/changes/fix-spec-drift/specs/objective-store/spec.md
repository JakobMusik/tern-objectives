## MODIFIED Requirements

### Requirement: Objective record
Each objective SHALL have:
- a title: trimmed, non-empty, at most 120 characters;
- a done flag;
- a priority from P0 (most urgent) to P3;
- a created time and a done time;
- an optional side note, due date and tag list;
- once done, a review schedule: its next review date, interval in days, ease in percent and review count.

A new objective SHALL start not done, at P2, with the current time as its created time, with no note, due date, tags or review schedule, and no links unless made for a tab.

#### Scenario: Creating an objective
- **WHEN** the user creates an objective titled "  Fix login bug  "
- **THEN** the stored record has title "Fix login bug", done false, priority P2, a created time, and no note, due date, tags, links or review schedule

#### Scenario: Blank title
- **WHEN** the user submits a title that is empty or only spaces
- **THEN** no objective is created and the stored list is unchanged

#### Scenario: Over-long title
- **WHEN** the user submits a title longer than 120 characters
- **THEN** the stored title is cut to its first 120 characters

#### Scenario: Made for a tab
- **WHEN** the user runs "Objectives: New objective for this tab…" in tab A and enters a title
- **THEN** the stored record is linked to A and to no other tab

### Requirement: Final done state
Marking an objective done SHALL record the done time and start its review schedule. Done SHALL be final: nothing SHALL make a done objective open again, except Undo right after it was marked done. Neither marking done nor that Undo SHALL change its links.

#### Scenario: Done stays done
- **WHEN** the user marks a linked objective done, waits for the Undo notice to go, then clicks its done box in the Done group
- **THEN** the record is still done with the same done time, and its tab links are identical throughout
