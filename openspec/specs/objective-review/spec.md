# objective-review Specification

## Purpose
Lets the user look back over done objectives on a spaced-repetition schedule, as the obsidian-spaced-repetition plugin schedules notes: done objectives keep review metadata, the graph's review mode lists the due ones, and Hard, Good and Easy update their schedules. It also covers removing done objectives in one click and undoing a mistaken done or removal.

## Requirements

### Requirement: Review schedule starts at done
Marking an objective done SHALL give it a review schedule: next review on the next calendar day, interval 1 day, ease 250% and review count 0. A done objective stored without a schedule SHALL be read as if it had been marked done on its done date, so its next review is the day after it.

#### Scenario: Marked done
- **WHEN** the user marks an open objective done on 2026-11-07
- **THEN** the kv dump shows its schedule: next review 2026-11-08, interval 1, ease 250, review count 0

#### Scenario: Done before this version
- **WHEN** `kv.json` holds an objective marked done on 2026-11-04 with no schedule, and the graph opens on 2026-11-07
- **THEN** the header shows "Review (1)", and the objective's node shows a "review due" chip

### Requirement: Rating arithmetic
Rating SHALL set ease and interval as obsidian-spaced-repetition's SM-2-OSR with default settings, where d is the whole days since the next review was due:
- Easy: ease + 20; interval (interval + d) × ease ÷ 100 × 1.3, with the new ease;
- Good: ease kept; interval (interval + d ÷ 2) × ease ÷ 100;
- Hard: ease − 20, at least 130; interval (interval + d ÷ 4) × 0.5, at least 1.

The interval SHALL be rounded to one decimal.

#### Scenario: First review, Good
- **WHEN** an objective with interval 1, ease 250, due today, is rated Good
- **THEN** its interval is 2.5 and its ease 250

#### Scenario: First review, Easy
- **WHEN** an objective with interval 1, ease 250, due today, is rated Easy
- **THEN** its interval is 3.5 and its ease 270

#### Scenario: First review, Hard
- **WHEN** an objective with interval 1, ease 250, due today, is rated Hard
- **THEN** its interval is 1 and its ease 230

#### Scenario: Overdue, Good
- **WHEN** an objective with interval 4, ease 250, due three days ago, is rated Good
- **THEN** its interval is 13.8 and its ease 250

### Requirement: Next review after a rating
After a rating, the next review SHALL fall the interval, rounded to whole days, after today. The review count SHALL go up by one, and the objective SHALL leave the review list.

#### Scenario: Good on 2026-11-07
- **WHEN** on 2026-11-07 the user clicks Good on an objective with interval 1 and ease 250
- **THEN** the kv dump shows next review 2026-11-10 and review count 1, and the objective is no longer listed

### Requirement: Review button
The header SHALL show "Review (n)" while n is above zero: the done objectives that pass the scope and tag filters and whose next review is today or earlier. Otherwise it SHALL NOT show.

#### Scenario: One due
- **WHEN** one done objective's next review is today and the filters show it
- **THEN** the header shows "Review (1)"

#### Scenario: Nothing due
- **WHEN** every done objective's next review is after today
- **THEN** the header shows no Review button

### Requirement: Review mode
Clicking "Review (n)" SHALL draw the button active and list in the left column only those due objectives, earliest next review first, then the most recently done. Each SHALL carry Hard, Good and Easy buttons showing the whole days each would give, as "Good · 3d". Open objectives and the Done group SHALL be hidden; the right column SHALL also show the listed objectives' closed tabs, which are otherwise kept out of it.

#### Scenario: Two due
- **WHEN** two done objectives are due, one of them done yesterday with a fresh schedule, three objectives are open, and the user clicks "Review (2)"
- **THEN** the left column lists only the two due objectives, the fresh one's buttons read "Hard · 1d", "Good · 3d" and "Easy · 4d", and there is no Done group

#### Scenario: Closed tab in review
- **WHEN** a due objective's only linked tab was closed with "Close linked tabs", it held an omp chat that had replied, the user clicks "Review (1)" and then selects the objective
- **THEN** after "Review (1)", that tab shows under "Closed tabs" with "Resume" and no line; after selecting, a dashed green line joins it to the objective, and no tab node has a link bar

### Requirement: Leaving review mode
Review mode SHALL end when its list becomes empty, when the active "Review (n)" button is clicked, or when the graph closes. It SHALL NOT be remembered across opens of the graph.

#### Scenario: Last one rated
- **WHEN** review mode lists one objective and the user clicks Easy
- **THEN** the left column shows the open objectives and the Done group again, and the header shows no Review button

#### Scenario: Button clicked again
- **WHEN** review mode lists two objectives and the user clicks the active "Review (2)"
- **THEN** the left column shows the open objectives and the Done group, and the header still shows "Review (2)"

### Requirement: One-click remove
A done objective's node SHALL show a trash icon. Clicking it SHALL remove the objective and its links at once, without asking, and offer Undo.

#### Scenario: Trash icon
- **WHEN** the user opens the Done group and clicks a done objective's trash icon
- **THEN** the objective and its links are gone from the kv dump, and the header shows "Removed “<title>” · Undo"

### Requirement: Undo after done or remove
After an objective is marked done or removed in the graph, the header SHALL show "Marked done “<title>” · Undo" or "Removed “<title>” · Undo". The notice SHALL stay until the next click elsewhere in the graph, the graph closing, or 10 seconds. Clicking Undo SHALL restore the objective as it was before: its fields, links, place in the list, and the tab snapshots removed with it.

#### Scenario: Undo marking done
- **WHEN** the user marks a linked objective done and clicks Undo
- **THEN** the kv dump holds its record exactly as before the first click, with no done time and no schedule, and it is back in the open list with its lines

#### Scenario: Undo removing
- **WHEN** the user removes a done objective that was the only one linked to a closed tab, and clicks Undo
- **THEN** the kv dump holds the objective at its former place in the list, with its links, and the closed tab's snapshot is back

#### Scenario: Notice expires
- **WHEN** the user marks an objective done and 10 seconds pass without a click
- **THEN** the header no longer shows the notice, and the objective stays done

#### Scenario: Notice dropped by another click
- **WHEN** the user marks an objective done and then clicks another objective's title
- **THEN** the header no longer shows the notice

### Requirement: Review controls don't select text
Dragging across the Review button, the Hard, Good and Easy buttons, the trash icon or the Undo notice SHALL NOT select their text.

#### Scenario: Drag across review buttons
- **WHEN** the user drags across a listed objective's Hard, Good and Easy buttons and releases in empty space
- **THEN** the screenshot shows no text highlight, and the objective's schedule is unchanged
