## MODIFIED Requirements

### Requirement: Linking from the graph
While an open objective is selected, every tab node SHALL show a full-width link bar at its foot: "＋ Link" when the tab is not linked to the selected objective, "× Unlink" when it is. Clicking the bar SHALL add or remove that one link, SHALL keep the selection, and SHALL NOT jump to the tab. The bar's text SHALL NOT be selectable, so a press that drifts a little before release still counts as a click.

#### Scenario: Add then remove a link
- **WHEN** the user selects an objective, clicks "＋ Link" on a tab node, then clicks "× Unlink" on the same node
- **THEN** `kv.json` shows the link after the first click and not after the second, and the graph stays shown with the objective still selected

#### Scenario: Press that drifts across the bar
- **WHEN** the user presses on "＋ Link", moves the pointer 40 px along the bar and releases
- **THEN** no text is selected and `kv.json` shows the link

## ADDED Requirements

### Requirement: Done objectives' links are fixed
A done objective's links SHALL NOT change. Selecting it SHALL show no link bar on any tab node, and the plugin SHALL refuse a link change to it from any path, such as a click on a link bar drawn before it was marked done in another window.

#### Scenario: Done objective selected
- **WHEN** the user opens the Done group, selects a done objective and clicks where a tab node's link bar would be
- **THEN** no tab node shows a link bar, and the done objective's links in `kv.json` are unchanged
