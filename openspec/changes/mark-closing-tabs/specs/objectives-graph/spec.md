## ADDED Requirements

### Requirement: Tabs marked while a close asks
While a question to close tabs is showing, from a done objective's "Close n tabs" in its action bar or done notice or from "Close n done tabs" in the header, each tab node the graph shows that Close would close SHALL carry a red ring and a "Closes" chip first on its second line, and no other tab node SHALL. The question's tooltip SHALL start by naming every tab Close would close. The marks SHALL go when the question ends.

#### Scenario: Header question
- **WHEN** done objective X links tab A, done objective Z and open objective Y both link tab B, tab C is linked to nothing, and the user clicks "Close 1 done tab"
- **THEN** A's node shows a "Closes" chip and a red ring, B and C show neither, and the question's tooltip starts with "Close “A”?"

#### Scenario: Bar question with a tab that stays
- **WHEN** done objective X links open tabs A, B and C, open objective Y also links C, and the user selects X and clicks "Close 2 tabs" in its bar
- **THEN** A and B show a "Closes" chip and a red ring, C shows neither, and the question's tooltip starts with "Close “A” and “B”?"

#### Scenario: Notice question
- **WHEN** open objective X links open tabs A and B that no other open objective links, and the user clicks X's done box and then "Close 2 tabs" in the notice
- **THEN** A and B show a "Closes" chip, and the question's tooltip starts with "Close “A” and “B”?"; after Cancel, neither shows it, and the header reads "Marked done “X” · Undo · Close 2 tabs" again

#### Scenario: Another click ends the marks
- **WHEN** the header asks "Close 1 done tab?" as in "Header question", and the user clicks empty graph space
- **THEN** no tab node shows a "Closes" chip or a red ring, and A is still open

#### Scenario: The notice expires
- **WHEN** the notice asks "Close 2 tabs of “X”?" as in "Notice question", and 10 seconds pass after X was marked done
- **THEN** the notice is gone, no tab node shows a "Closes" chip, and A and B are still open

#### Scenario: A tab the graph doesn't show
- **WHEN** scope "This session" is on, done objective X links live tab A in the current session and live tab D in another session of this window, and the user selects X and clicks "Close 2 tabs" in its bar
- **THEN** A shows a "Closes" chip, D's node isn't shown, and the question's tooltip starts with "Close “A” and “D”?"

#### Scenario: Three or more names
- **WHEN** done objective X links open tabs A, B and C that no open objective links, and the user selects X and clicks "Close 3 tabs"
- **THEN** A, B and C show a "Closes" chip, and the question's tooltip starts with "Close “A”, “B” and “C”?"
