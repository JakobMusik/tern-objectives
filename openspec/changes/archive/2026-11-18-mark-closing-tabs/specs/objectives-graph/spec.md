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

### Requirement: Closing tabs listed first
While a close question is showing, from a done objective's bar or notice or from "Close n done tabs", the tab nodes the graph shows that Close would close SHALL come first in the right column, under a "Closes" heading and their session headings. The other tabs SHALL follow as they would without them, after the `Linked to` heading or else the "Other tabs" divider. When the question ends, every tab SHALL go back. A tab's own "Close tab?" SHALL move nothing.

#### Scenario: Header question lists them first
- **WHEN** session docs holds tabs A, B and C and session ops holds tab D, the graph was opened from A, done objective X links C, open objective Y links A, and the user clicks "Close 1 done tab"
- **THEN** the column reads: "Closes", "docs" with C, the "Other tabs" divider, "docs" with A and B, then "ops" with D

#### Scenario: Back in place
- **WHEN** the header asks as in "Header question lists them first", and the user clicks Cancel
- **THEN** the column reads "docs" with A, B and C, then "ops" with D, with no "Closes" heading and no divider

#### Scenario: Above the linked tabs
- **WHEN** done objective X links A, B and C, open objective Y links A, and the user selects X and clicks "Close 2 tabs" in its bar
- **THEN** the column reads: "Closes", "docs" with B and C, `Linked to “X”`, "docs" with A, the "Other tabs" divider, then "ops" with D

#### Scenario: Lines follow
- **WHEN** the bar asks as in "Above the linked tabs"
- **THEN** a screenshot shows X's lines ending on B, C and A where they now are, each within 2 pixels of the vertical centre of its tab header

#### Scenario: Notice question across sessions
- **WHEN** open objective X links C and D, no other open objective links them, and the user clicks X's done box and then "Close 2 tabs" in the notice
- **THEN** the column reads: "Closes", "docs" with C, "ops" with D, the "Other tabs" divider, then "docs" with A and B

#### Scenario: Every shown tab closes
- **WHEN** done objective X links A, B, C and D, no open objective links any of them, and the user clicks "Close 4 done tabs"
- **THEN** the column reads: "Closes", "docs" with A, B and C, then "ops" with D, with no divider

#### Scenario: A tab's own question moves nothing
- **WHEN** the user clicks C's trash icon
- **THEN** C's header asks "Close tab?", and the column keeps its order

## MODIFIED Requirements

### Requirement: Linked tabs section
While an objective is selected, the right column SHALL start, after any "Closes" section, with a section headed `Linked to “<title>”`: the other shown tabs linked to it. When other tabs are shown, the "Other tabs" divider and those tabs SHALL follow, each part ordered as "Tab column" says. Linking or unlinking a tab SHALL move it across the divider at once. Deselecting SHALL restore the normal order. With no linked tab there, no heading SHALL show, nor a divider unless after "Closes".

#### Scenario: Linked tabs on top
- **WHEN** the window holds sessions "web" (tabs "App build" and "Components") and "api" (tabs "Server" and "Benchmarks"), objective X is linked to "Components" and "Benchmarks", the graph was opened from "Server", and the user selects X
- **THEN** the column reads: `Linked to “X”`, "api" with "Benchmarks", "web" with "Components", the "Other tabs" divider, "api" with "Server", then "web" with "App build"

#### Scenario: Linked closed tab
- **WHEN** X is also linked to a closed tab and the user selects X
- **THEN** that tab shows under a "Closed tabs" heading inside the top section, after the live tabs, and not again below the divider

#### Scenario: Linking moves a tab up
- **WHEN** X is selected and the user clicks "＋ Link" on "App build", below the divider
- **THEN** "App build" shows at once in the top section, under "web" before "Components", its bar reading "× Unlink", and the kv dump holds the link

#### Scenario: Unlinking moves a tab down
- **WHEN** the user then clicks "× Unlink" on "Benchmarks"
- **THEN** "Benchmarks" shows at once below the divider, under "api" with the "Server" tab, its bar reading "＋ Link", and the kv dump no longer holds that link

#### Scenario: Last link removed
- **WHEN** X is selected, linked to one shown tab, and the user clicks that tab's "× Unlink"
- **THEN** the heading and the divider are gone, the column is in its normal order, and every bar reads "＋ Link"

#### Scenario: Deselect and select again
- **WHEN** the user clicks X to deselect it, and clicks it again
- **THEN** after the first click there is no heading or divider and the column is in its normal order; after the second, the top section holds the same tabs as before

#### Scenario: Nothing linked
- **WHEN** the user creates "Write slides" with "＋ New objective", which selects it
- **THEN** the column shows no `Linked to` heading and no divider

#### Scenario: First link
- **WHEN** "Write slides" is selected with nothing linked and the user clicks "＋ Link" on a tab
- **THEN** the column starts with `Linked to “Write slides”` and that tab, followed by the divider and every other tab

#### Scenario: This session
- **WHEN** the scope is "This session", X is linked to tabs in the current session and in another, and the user selects X
- **THEN** the top section holds only the current session's linked tabs

#### Scenario: Every shown tab linked
- **WHEN** the scope is "This session", every tab of the current session is linked to X, and the user selects X
- **THEN** the column shows the `Linked to` heading and those tabs, and no divider
