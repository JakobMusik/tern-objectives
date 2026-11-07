## MODIFIED Requirements

### Requirement: Focused pane without a tab
When the focused pane belongs to no tab, both tab commands SHALL show an error toast and change nothing.

#### Scenario: Parked focus
- **WHEN** a tab command runs in a session whose only pane is parked, so no pane in a tab has focus
- **THEN** an error toast explains that the focused pane is not in a tab, and `kv.json` is unchanged

### Requirement: Link menu on tab nodes
Right-clicking a tab node SHALL open a menu headed "Link to", with one row per open objective, in graph order, checked when that objective is linked to the tab. Choosing a row SHALL add or remove that one link, whether or not an objective is selected. With no open objectives, the menu's only row of its own SHALL be a disabled one saying so; Tern's own Copy row, which every menu gets, may follow it.

#### Scenario: Link without selecting
- **WHEN** no objective is selected and the user right-clicks a tab node and chooses an unchecked objective
- **THEN** `kv.json` shows that objective linked to the tab, and a line joins the two nodes

#### Scenario: Unlink from the menu
- **WHEN** the user right-clicks a tab node linked to an objective and chooses that objective's checked row
- **THEN** `kv.json` no longer shows that link

#### Scenario: No objectives yet
- **WHEN** the store holds no open objectives and the user right-clicks a tab node
- **THEN** the menu's only row of its own is a disabled one saying there are no objectives yet, choosing it does nothing, and `kv.json` is unchanged

#### Scenario: Menu heading
- **WHEN** the store holds two open objectives and the user right-clicks a tab node
- **THEN** the menu starts with the heading "Link to", followed by the two objectives' rows

### Requirement: Done objectives' links are fixed
A done objective's links SHALL NOT change. Selecting it SHALL show no link bar on any tab node, and the plugin SHALL refuse a link change to it from any path, such as a click on a link bar drawn before it was marked done in another window. The one exception SHALL be Resume, which hands a closed tab's links, a done objective's included, to the tab it opens ("Resuming a closed tab").

#### Scenario: Done objective selected
- **WHEN** the user opens the Done group, selects a done objective and clicks where a tab node's link bar would be
- **THEN** no tab node shows a link bar, and the done objective's links in `kv.json` are unchanged

#### Scenario: Resume moves a done objective's link
- **WHEN** done objective X is linked to closed tab A, which held an omp chat that had replied, and the user selects X and clicks A's "Resume"
- **THEN** the kv dump shows X linked to the new tab instead of A, and X is still done
