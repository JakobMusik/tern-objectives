## ADDED Requirements

### Requirement: Done group sort button
While the Done group is open, its "Done (n)" row SHALL end in a sort button holding a sort icon and the Done group's method: "Recently done", "Priority", "Newest" or "Next review". A click SHALL switch to the next method in that order, then Recently done again, re-sort the Done group at once, keep it open and keep the selection, and store the method as the settings page's "Sort Done by" does. Its tooltip SHALL name the current method and the next. A closed group's row SHALL show no button.

#### Scenario: Shown while open
- **WHEN** `kv.json` was written by 0.28.2 sorted by priority, the graph opens with the Done group closed, and the user clicks "Done (3)"
- **THEN** before the click the row shows no sort button; after it, the row ends in the button reading "Priority", with the tooltip "Sorted by priority · click to sort newest first"

#### Scenario: Each click moves on
- **WHEN** the button reads "Recently done", the done objectives are as in "Done group sorted recently done", and the user clicks the button four times
- **THEN** after the first click it reads "Priority" and the group lists "Set up CI", "Read docs", "Tidy the backlog"; after the second, "Newest" and "Tidy the backlog", "Set up CI", "Read docs"; after the third, "Next review" and "Read docs", "Set up CI", "Tidy the backlog"; after the fourth, "Recently done" and "Read docs", "Tidy the backlog", "Set up CI"

#### Scenario: Tooltips
- **WHEN** the user clicks the button four times, starting from "Recently done"
- **THEN** its tooltip reads "Most recently done first · click to sort by priority", then "Sorted by priority · click to sort newest first", then "Sorted newest first · click to sort by next review", then "Soonest review first · click for the most recently done first", then the first again

#### Scenario: Open objectives keep their order
- **WHEN** the header's sort button reads "Your order" and the user clicks the Done group's sort button
- **THEN** the open objectives keep their order, and the header's button still reads "Your order"

#### Scenario: Selection kept
- **WHEN** "Read docs" is selected in the open Done group and the user clicks the group's sort button
- **THEN** "Read docs" is still selected, with its action bar, and the group is still open

#### Scenario: Same method on the settings page
- **WHEN** the user clicks the Done group's button until it reads "Next review", then clicks ⚙
- **THEN** the settings page's "Sort Done by" row has Next review selected, "Sort by" is unchanged, and the kv dump's settings hold both methods

### Requirement: Done group sorting
The Done group SHALL be sorted by its own method, apart from the open objectives' method. Recently done SHALL list the most recently done first. Priority SHALL list P0 first and P3 last, the most recently done first within one priority. Newest SHALL list the most recently created first. Next review SHALL list the soonest next review first, so reviews already due come first, and the most recently done first on the same day. Review mode SHALL keep its own order.

#### Scenario: Done group sorted recently done
- **WHEN** the Done group is sorted Recently done, and the done objectives are "Set up CI" (P0, created 11-02, done 11-10, next review 11-20), "Read docs" (P3, created 11-01, done 11-12, next review 11-16) and "Tidy the backlog" (P3, created 11-03, done 11-11, next review 11-25), and the user opens the Done group
- **THEN** it lists "Read docs", "Tidy the backlog", "Set up CI"

#### Scenario: Done group sorted by priority
- **WHEN** the done objectives are as in "Done group sorted recently done", and the Done group is sorted by priority
- **THEN** it lists "Set up CI", "Read docs", "Tidy the backlog"

#### Scenario: Done group sorted newest first
- **WHEN** the done objectives are as in "Done group sorted recently done", and the Done group is sorted newest first
- **THEN** it lists "Tidy the backlog", "Set up CI", "Read docs"

#### Scenario: Done group sorted by next review
- **WHEN** the done objectives are as in "Done group sorted recently done", today is 11-18, and the Done group is sorted by next review
- **THEN** it lists "Read docs", whose review is due, then "Set up CI", then "Tidy the backlog"

#### Scenario: Next reviews on the same day
- **WHEN** the Done group is sorted by next review, and "Set up CI" (done 11-10) and "Tidy the backlog" (done 11-11) both have their next review on 11-20
- **THEN** "Tidy the backlog" comes right before "Set up CI"

#### Scenario: Apart from the open objectives
- **WHEN** the open objectives are sorted newest first and the Done group by priority
- **THEN** the open objectives are listed newest first, and the Done group P0 first

#### Scenario: Review mode keeps its order
- **WHEN** the Done group is sorted newest first, "Set up CI" (created 11-02, review due 11-17) and "Read docs" (created 11-01, review due 11-16) are due, and the user clicks "Review (2)"
- **THEN** review mode lists "Read docs", then "Set up CI"

## MODIFIED Requirements

### Requirement: Done objectives group
Clicking an open objective's done box SHALL mark it done. Done objectives SHALL leave the open list and gather in a "Done (n)" group at the bottom of the left column:
- the group is collapsed by default and opens or closes on click;
- inside it, objectives are ordered as "Done group sorting" says;
- a done objective draws lines only while it is selected.

Clicking a done objective's box SHALL ask whether to reopen it ("Reopening a done objective").

#### Scenario: Marking done
- **WHEN** the user clicks the done box of a linked open objective that is not selected
- **THEN** it moves into the Done group, the count goes up by one, and its lines are gone

#### Scenario: Box of a done objective
- **WHEN** the user opens the Done group and clicks a done objective's box
- **THEN** it stays in the Done group, the count is unchanged, the kv dump shows it still done, and its action bar asks whether to reopen it

### Requirement: Sort button
The graph's header SHALL show a sort button after the search control, holding a sort icon and the current method's name: "Your order", "Priority" or "Newest". A click SHALL switch to the next method, Your order, Priority, Newest, then Your order again, and sort the open objectives at once. Its tooltip SHALL name the current method and the next. The click SHALL keep the selection and store the method as the settings page's "Sort by" does. Dragging across it SHALL NOT select its text.

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

#### Scenario: Done group keeps its order
- **WHEN** the Done group is open and sorted Recently done, and the user clicks the header's sort button
- **THEN** the open objectives are sorted by the next method, and the Done group's order and its button stay as they were

### Requirement: Sorting waits for another click
While the open objectives or the Done group are sorted by priority, a click on a priority badge, of an open or a done objective, SHALL change the badge at once and move no node. The left column SHALL keep that order while the user clicks priority badges, on any objective, and through redraws such as live refreshes. The next other click in the graph, or the next fresh open of the graph, SHALL sort it.

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
- **WHEN** the Done group is sorted by priority and open, it lists "Set up CI" (P0) and then "Read docs" (P3), which was done later, and the user clicks the badge of "Read docs" three times
- **THEN** "Read docs" stays second after each click and reads P0 after the third; after a click on empty graph space, the Done group lists "Read docs" first

#### Scenario: Refresh keeps the order
- **WHEN** "Write slides" was raised to P1 as above, and a new tab opens in the window, so the graph redraws
- **THEN** "Write slides" is still third

#### Scenario: Fresh open sorts
- **WHEN** "Write slides" was raised to P1 as above, and the user presses ⌃⌘O twice
- **THEN** the reopened graph lists "Write slides" second

#### Scenario: Only the Done group by priority
- **WHEN** the open objectives are sorted newest first, the Done group by priority, and it lists "Set up CI" (P0) and then "Read docs" (P3), which was done later, and the user clicks the badge of "Read docs" three times
- **THEN** "Read docs" stays second after each click and reads P0 after the third; after a click on empty graph space, the Done group lists "Read docs" first

## REMOVED Requirements

### Requirement: Done group order
**Reason**: The Done group gets its own method and button. This requirement tied it to the open objectives' method and named its first method "Your order", so its scenarios can't carry over.
**Migration**: See "Done group sorting" and "Done group sort button". A store from before keeps the Done group's order: its method is read from the open objectives' method, Your order as Recently done.
