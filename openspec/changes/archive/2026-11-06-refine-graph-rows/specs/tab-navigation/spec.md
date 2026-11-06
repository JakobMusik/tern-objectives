# Spec Delta

## MODIFIED Requirements

### Requirement: Jump to a pane
Each pane row in a live tab SHALL end in a jump button, an arrow icon at the row's right end. Clicking it SHALL switch to that pane's session and tab and focus that exact pane. Clicking the rest of the row SHALL NOT jump.

#### Scenario: Second pane of a split
- **WHEN** the user clicks the jump button on the row of the right-hand pane of a split tab in another session
- **THEN** that session and tab are shown, and the right-hand pane has focus

#### Scenario: Row name doesn't jump
- **WHEN** the user clicks a pane row's name in a tab of another session
- **THEN** the shown session, the shown tab and the focus are unchanged
