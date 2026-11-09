## MODIFIED Requirements

### Requirement: Done objectives group
Clicking an open objective's done box SHALL mark it done. Done objectives SHALL leave the open list and gather in a "Done (n)" group at the bottom of the left column:
- the group is collapsed by default and opens or closes on click;
- inside it, the most recently done objective comes first;
- a done objective draws lines only while it is selected.

Clicking a done objective's box SHALL ask whether to reopen it ("Reopening a done objective").

#### Scenario: Marking done
- **WHEN** the user clicks the done box of a linked open objective that is not selected
- **THEN** it moves into the Done group, the count goes up by one, and its lines are gone

#### Scenario: Box of a done objective
- **WHEN** the user opens the Done group and clicks a done objective's box
- **THEN** it stays in the Done group, the count is unchanged, the kv dump shows it still done, and its action bar asks "Reopen?"

### Requirement: Inline confirmation
An action that asks before acting SHALL ask in place, never in a picker: "Close n tabs" in the action bar or the done notice, "Close n done tabs" in the header, and a done objective's box in that objective's action bar. The control or bar SHALL turn into the question with its answers: Close and Cancel, or Keep review, Reset review and Cancel. Cancel, or any other click in the graph, SHALL end the question and change nothing.

#### Scenario: Asked in the bar
- **WHEN** done objective X links two open tabs that no open objective links, and the user clicks "Close 2 tabs" in X's bar
- **THEN** no picker opens, and the bar reads "Close 2 tabs?" with Close and Cancel

#### Scenario: Another click cancels
- **WHEN** the bar asks "Close 2 tabs?" and the user clicks empty graph space
- **THEN** both tabs are still open, and selecting X again shows its row with "Close 2 tabs"

#### Scenario: Another click ends the reopen question
- **WHEN** a done objective's bar asks "Reopen?" and the user clicks empty graph space
- **THEN** nothing is selected, the objective is still in the Done group, and the kv dump shows it still done

## ADDED Requirements

### Requirement: Reopening a done objective
Clicking a done objective's box, in the Done group or in review mode, SHALL select it and turn its action bar into "Reopen?" with Keep review, Reset review and Cancel. Keep review and Reset review SHALL both reopen it: it leaves the Done group, or review mode's list, and shows last among the open objectives, still selected. Cancel SHALL end the question and leave it done and selected. Reopening SHALL offer no Undo.

#### Scenario: Asking to reopen
- **WHEN** "Fix login bug" and "Review pull requests" are open, and the user opens the Done group and clicks the box of done objective "Write slides"
- **THEN** no picker opens, "Write slides" is selected, its bar reads "Reopen?" with Keep review, Reset review and Cancel, and the kv dump shows it still done

#### Scenario: Keep review
- **WHEN** "Write slides" links a live tab, and the user then clicks Keep review
- **THEN** the list reads "Fix login bug", "Review pull requests", "Write slides", with "Write slides" selected and its bar showing Note, Due, Tags and Delete; a line joins it to its tab, the Done count is one less, and the header shows no Undo notice

#### Scenario: Cancelled
- **WHEN** the user clicks the box of done objective "Write slides" and then Cancel
- **THEN** "Write slides" is still in the Done group and selected, its bar shows its usual buttons again, and `kv.json` is unchanged

#### Scenario: From review mode
- **WHEN** review mode lists two objectives, and the user clicks the box of one of them and then Reset review
- **THEN** review mode lists only the other one, the header shows "Review (1)" active, and the kv dump shows the reopened objective open with no schedule

#### Scenario: Last one in review mode
- **WHEN** review mode lists one objective, and the user clicks its box and then Keep review
- **THEN** the left column shows the open objectives, the reopened one last and selected, and the header shows no Review button
