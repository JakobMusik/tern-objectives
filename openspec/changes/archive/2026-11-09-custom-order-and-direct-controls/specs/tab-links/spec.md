# Spec Delta

## ADDED Requirements

### Requirement: Links of done objectives
A done objective's links SHALL change the same way as an open objective's: through the link bars while it is selected, in the Done group or in review mode. Nothing else SHALL change them: marking done, Undo, rating and closing its tabs SHALL leave them as they are, and the only exception SHALL be Resume, which hands a closed tab's links to the tab it opens ("Resuming a closed tab").

#### Scenario: Unlink from a done objective
- **WHEN** done objective X links tabs A and B, and the user opens the Done group, selects X and clicks "× Unlink" on A
- **THEN** the kv dump shows X linked to B only, X is still done and selected, and A shows below the "Other tabs" divider with "＋ Link"

#### Scenario: Link a done objective
- **WHEN** the user then clicks "＋ Link" on tab C
- **THEN** the kv dump shows X linked to B and C, and a green line joins X to C

#### Scenario: Resume moves a done objective's link
- **WHEN** done objective X is linked to closed tab A, which held an omp chat that had replied, and the user selects X and clicks A's "Resume"
- **THEN** the kv dump shows X linked to the new tab instead of A, and X is still done

## MODIFIED Requirements

### Requirement: Linking from the graph
While an objective is selected, open or done, every tab node SHALL show a full-width link bar at its foot: "＋ Link" when the tab is not linked to the selected objective, "× Unlink" when it is. Clicking the bar SHALL add or remove that one link, SHALL keep the selection, and SHALL NOT jump to the tab. The bar's text SHALL NOT be selectable, so a press that drifts a little before release still counts as a click.

#### Scenario: Add then remove a link
- **WHEN** the user selects an objective, clicks "＋ Link" on a tab node, then clicks "× Unlink" on the same node
- **THEN** `kv.json` shows the link after the first click and not after the second, and the graph stays shown with the objective still selected

#### Scenario: Press that drifts across the bar
- **WHEN** the user presses on "＋ Link", moves the pointer 40 px along the bar and releases
- **THEN** no text is selected and `kv.json` shows the link

### Requirement: New objective for this tab command
"Objectives: New objective for this tab…" SHALL ask for a title, then create an objective already linked to the focused pane's tab, at the starting priority and place set in Configure (P3 and the top by default).

#### Scenario: Create linked
- **WHEN** the user runs the command in tab "API Learning" and enters "Add caching layer"
- **THEN** a new P3 objective "Add caching layer" exists, linked to that tab, first among the open objectives

## REMOVED Requirements

### Requirement: Done objectives' links are fixed
**Reason**: The user wants to link and unlink done objectives' tabs too; they get the same link bars as open objectives (Links of done objectives).
**Migration**: None needed. Select a done objective and use the bars on the tab nodes. The tab menu and "Link this tab…" still list open objectives only.
