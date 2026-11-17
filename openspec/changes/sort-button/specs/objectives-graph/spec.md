## ADDED Requirements

### Requirement: Sort button
The graph's header SHALL show a sort button after the search control, holding a sort icon and the current method's name: "Your order", "Priority" or "Newest". A click SHALL switch to the next method, Your order, Priority, Newest, then Your order again, and sort the left column at once. Its tooltip SHALL name the current method and the next. The click SHALL keep the selection and store the method as the settings page's "Sort by" does. Dragging across it SHALL NOT select its text.

#### Scenario: Shown with the current method
- **WHEN** `kv.json` was written by 0.26.0 with "Sort by priority" on, and the graph opens
- **THEN** the header shows the sort button right after the Search button, reading "Priority", with the tooltip "Sorted by priority · click to sort newest first"

#### Scenario: Each click moves on
- **WHEN** the button reads "Priority", the open objectives are stored as "Fix login bug" (P3, created 09:00), "Review pull requests" (P1, created 10:00) and "Write slides" (P3, created 11:00), and the user clicks the button three times
- **THEN** after the first click it reads "Newest" and the left column reads "Write slides", "Review pull requests", "Fix login bug"; after the second, "Your order" and "Fix login bug", "Review pull requests", "Write slides"; after the third, "Priority" and "Review pull requests", "Fix login bug", "Write slides"

#### Scenario: Selection kept
- **WHEN** "Write slides" is selected and the user clicks the sort button
- **THEN** "Write slides" is still selected, with its action bar and its lines

#### Scenario: Same method on the settings page
- **WHEN** the user clicks the button until it reads "Newest", then clicks ⚙
- **THEN** the settings page's "Sort by" row has Newest first selected, and the kv dump's settings hold the newest-first method

#### Scenario: Drag across the sort button
- **WHEN** the user presses in the header's empty space, drags across the sort button and releases in empty space
- **THEN** the screenshot shows no text highlight on the button

### Requirement: Sorting newest first
Sorted newest first, open objectives SHALL be listed by creation time, the newest first, and objectives created in the same second in the user's own order. The left column, the "Link this tab…" picker and the tab menu SHALL all show this order. Sorting SHALL NOT change the stored order. Open objective nodes SHALL show no grip.

#### Scenario: Newest on top
- **WHEN** sorted newest first, the kv dump lists the open objectives "Fix login bug" (created 09:00), "Review pull requests" (created 11:00) and "Write slides" (created 10:00) in that order, and the graph opens
- **THEN** the left column reads "Review pull requests", "Write slides", "Fix login bug", and the kv dump still lists them in their old order

#### Scenario: Created in the same second
- **WHEN** sorted newest first, "Fix login bug" and "Write slides" were created in the same second and are stored in that order
- **THEN** the left column lists "Fix login bug" right before "Write slides"

#### Scenario: Link choices newest first too
- **WHEN** the objectives are as in "Newest on top", and the user runs "Objectives: Link this tab…", then right-clicks a tab node
- **THEN** both the picker and the tab menu list "Review pull requests", "Write slides", "Fix login bug"

#### Scenario: No grips
- **WHEN** sorted newest first, the graph shows open objectives
- **THEN** no objective node has a grip

### Requirement: Done group order
The Done group SHALL follow the sort method. In Your order, the most recently done objective SHALL come first. Sorted by priority, P0 SHALL come first and P3 last, the most recently done first within one priority. Sorted newest first, the most recently created SHALL come first. Review mode SHALL keep its own order.

#### Scenario: Done group in your order
- **WHEN** sorted in Your order, the done objectives are "Set up CI" (P0, created 11-02, done 11-10), "Read docs" (P3, created 11-01, done 11-12) and "Tidy the backlog" (P3, created 11-03, done 11-11), and the user opens the Done group
- **THEN** it lists "Read docs", "Tidy the backlog", "Set up CI"

#### Scenario: Done group by priority
- **WHEN** the done objectives are as in "Done group in your order", sorted by priority
- **THEN** the Done group lists "Set up CI", "Read docs", "Tidy the backlog"

#### Scenario: Done group newest first
- **WHEN** the done objectives are as in "Done group in your order", sorted newest first
- **THEN** the Done group lists "Tidy the backlog", "Set up CI", "Read docs"

### Requirement: Sorted by priority
Sorted by priority, open objectives SHALL be listed P0 first and P3 last, in the user's own order within one priority. The left column, the "Link this tab…" picker and the tab menu SHALL all show this order. Sorting SHALL NOT change the stored order. Review mode SHALL keep its own order.

#### Scenario: Sorted list
- **WHEN** sorted by priority, the kv dump lists the open objectives "Fix login bug" (P3), "Review pull requests" (P1), "Write slides" (P3) and "Update dependencies" (P0) in that order, and the graph opens
- **THEN** the left column reads "Update dependencies", "Review pull requests", "Fix login bug", "Write slides", and the kv dump still lists them in their old order

#### Scenario: Link choices sorted too
- **WHEN** the objectives are as in "Sorted list", and the user runs "Objectives: Link this tab…", then right-clicks a tab node
- **THEN** both the picker and the tab menu list "Update dependencies", "Review pull requests", "Fix login bug", "Write slides"

#### Scenario: Your order chosen
- **WHEN** the objectives are as in "Sorted list", and the user picks Your order on the settings page and goes back to the graph
- **THEN** the left column reads "Fix login bug", "Review pull requests", "Write slides", "Update dependencies"

## MODIFIED Requirements

### Requirement: Done objectives group
Clicking an open objective's done box SHALL mark it done. Done objectives SHALL leave the open list and gather in a "Done (n)" group at the bottom of the left column:
- the group is collapsed by default and opens or closes on click;
- inside it, objectives are ordered as "Done group order" says;
- a done objective draws lines only while it is selected.

Clicking a done objective's box SHALL ask whether to reopen it ("Reopening a done objective").

#### Scenario: Marking done
- **WHEN** the user clicks the done box of a linked open objective that is not selected
- **THEN** it moves into the Done group, the count goes up by one, and its lines are gone

#### Scenario: Box of a done objective
- **WHEN** the user opens the Done group and clicks a done objective's box
- **THEN** it stays in the Done group, the count is unchanged, the kv dump shows it still done, and its action bar asks whether to reopen it

### Requirement: Custom order
Open objectives SHALL be listed in the order the user sets, which is kept with the objectives and shared by every window; sorted by priority, it applies within each priority. Priority, due date and badge clicks SHALL NOT change it. A new objective SHALL take the place set in Configure, top by default. The first open after updating to this version SHALL list the open objectives as before: by priority, P0 first, then by due date, earliest first and none last, then by created time, oldest first.

#### Scenario: Order kept from before
- **WHEN** `kv.json` written by 0.16.0 holds P2 due tomorrow, P2 with no due date, P0 with no due date, and P2 due today, and the graph opens
- **THEN** the order is P0, P2 due today, P2 due tomorrow, P2 with no date

#### Scenario: Badge clicks don't move a node
- **WHEN** sorted in Your order, the graph lists the P3 objectives "Fix login bug", "Review pull requests" and "Write slides" in that order, the user clicks the badge of "Write slides" three times and then clicks empty graph space
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
Each open objective node SHALL show a grip ⠿ at its left, outside review mode and newest-first sorting. A click on it SHALL lift the node: it is drawn lifted, and the header shows `Moving “<title>”` with Cancel. While a node is lifted, pointing at another shown open objective's upper or lower half SHALL show an insertion line at that node's top or bottom edge, and a click there SHALL move the lifted objective to that line. Cancel, the grip again, or any other click SHALL cancel the move.

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
- **THEN** no done node has a grip

#### Scenario: Switching the sort ends a move
- **WHEN** "Write slides" is lifted and the user clicks the sort button until it reads "Newest"
- **THEN** after the first click nothing is lifted, the header shows no `Moving` notice, and the order in the kv dump is unchanged

### Requirement: Sorting waits for another click
Sorted by priority, a click on a priority badge, of an open or a done objective, SHALL change the badge at once and move no node. The left column SHALL keep that order while the user clicks priority badges, on any objective, and through redraws such as live refreshes. The next other click in the graph, or the next fresh open of the graph, SHALL sort it.

#### Scenario: Badge clicks hold the order
- **WHEN** sorted by priority, the list reads "Fix login bug" (P0), "Review pull requests" (P2), "Write slides" (P3), and the user clicks the badge of "Write slides" twice
- **THEN** "Write slides" is third after each click, its badge reads P2 and then P1, and the kv dump holds priority 1 for it

#### Scenario: Another click sorts
- **WHEN** "Write slides" was raised to P1 as above, and the user then clicks empty graph space
- **THEN** the list reads "Fix login bug", "Write slides", "Review pull requests"

#### Scenario: Other badges hold it too
- **WHEN** "Write slides" was raised to P1 as above, the stored order is "Fix login bug", "Review pull requests", "Write slides", and the user clicks the badge of "Review pull requests"
- **THEN** no node moves and its badge reads P1; after a click on empty graph space, the list reads "Fix login bug", "Review pull requests", "Write slides"

#### Scenario: Done badges hold it too
- **WHEN** sorted by priority, the open Done group lists "Set up CI" (P0) and then "Read docs" (P3), which was done later, and the user clicks the badge of "Read docs" three times
- **THEN** "Read docs" stays second after each click and reads P0 after the third; after a click on empty graph space, the Done group lists "Read docs" first

#### Scenario: Refresh keeps the order
- **WHEN** "Write slides" was raised to P1 as above, and a new tab opens in the window, so the graph redraws
- **THEN** "Write slides" is still third

#### Scenario: Fresh open sorts
- **WHEN** "Write slides" was raised to P1 as above, and the user presses ⌃⌘O twice
- **THEN** the reopened graph lists "Write slides" second

### Requirement: Moving while sorted
Sorted by priority, a lifted objective SHALL take a drop only on shown open objectives of its own priority. Pointing at an objective of another priority SHALL show no insertion line, and a click on it SHALL end the move with the order unchanged.

#### Scenario: Move within a priority
- **WHEN** sorted by priority, the list reads "Release" (P1), "Fix login bug", "Review pull requests" and "Write slides" (all P3), and the user clicks the grip of "Write slides" and then the upper half of "Fix login bug"
- **THEN** the list reads "Release", "Write slides", "Fix login bug", "Review pull requests", and the kv dump holds "Write slides" before "Fix login bug"

#### Scenario: Another priority takes no drop
- **WHEN** "Write slides" is lifted as above and the pointer rests on the lower half of "Release"
- **THEN** a screenshot shows no insertion line, and a click there ends the move with the list and the kv dump unchanged

## REMOVED Requirements

### Requirement: Sorting by priority
**Reason**: Sorting by priority is now one of three sort methods, and the Done group follows it instead of keeping its own order.
**Migration**: "Sorted by priority" holds the open objectives' order, and "Done group order" the Done group's.
