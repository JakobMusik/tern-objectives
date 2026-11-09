## MODIFIED Requirements

### Requirement: Jump to a tab
Clicking a live tab node's header SHALL:
- switch to that tab's session if it isn't shown;
- show the tab;
- focus the pane that was last focused in it.

Its trash icon, and the header while it asks "Close tab?", SHALL NOT jump.

#### Scenario: Tab in another session
- **WHEN** session "misc" is shown and the user clicks the header of tab 2 of session "web"
- **THEN** session "web" is shown, tab 2 is the visible tab, and its last focused pane has focus

#### Scenario: Trash icon doesn't jump
- **WHEN** session "misc" is shown and the user clicks the trash icon on tab 2 of session "web"
- **THEN** session "misc" is still shown, focus is unchanged, and tab 2's header asks "Close tab?"
