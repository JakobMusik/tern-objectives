# Spec Delta

## MODIFIED Requirements

### Requirement: Linking from the graph
While an objective is selected, every tab node SHALL show a full-width link bar at its foot: "＋ Link" when the tab is not linked to the selected objective, "× Unlink" when it is. Clicking the bar SHALL add or remove that one link, SHALL keep the selection, and SHALL NOT jump to the tab.

#### Scenario: Add then remove a link
- **WHEN** the user selects an objective, clicks "＋ Link" on a tab node, then clicks "× Unlink" on the same node
- **THEN** `kv.json` shows the link after the first click and not after the second, and the graph stays shown with the objective still selected

## ADDED Requirements

### Requirement: Link menu on tab nodes
Right-clicking a tab node SHALL open a menu with one row per open objective, in graph order, checked when that objective is linked to the tab. Choosing a row SHALL add or remove that one link, whether or not an objective is selected. With no open objectives, the menu SHALL show a single disabled row saying so.

#### Scenario: Link without selecting
- **WHEN** no objective is selected and the user right-clicks a tab node and chooses an unchecked objective
- **THEN** `kv.json` shows that objective linked to the tab, and a line joins the two nodes

#### Scenario: Unlink from the menu
- **WHEN** the user right-clicks a tab node linked to an objective and chooses that objective's checked row
- **THEN** `kv.json` no longer shows that link

#### Scenario: No objectives yet
- **WHEN** the store holds no open objectives and the user right-clicks a tab node
- **THEN** the menu shows one disabled row saying there are no objectives yet, and `kv.json` is unchanged
