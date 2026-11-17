## ADDED Requirements

### Requirement: Sort method
The page's "Order" section, after "New objectives", SHALL offer "Sort by": Your order, Priority or Newest first, the same method as the graph's sort button. It SHALL be Priority by default, also for objectives stored before this version, except that a store with "Sort by priority" turned off SHALL read as Your order. The choice SHALL be stored with the objectives in the plugin's `kv.json`, and SHALL hold in every window and after a reload. No method SHALL change the user's own order.

#### Scenario: Priority by default
- **WHEN** `kv.json` was written by 0.23.0, and the user opens the settings page
- **THEN** the "Order" section shows "Sort by" with Priority selected, and the graph's sort button reads "Priority"

#### Scenario: Turned off before this version
- **WHEN** `kv.json` was written by 0.26.0 with "Sort by priority" off, and the user opens the settings page
- **THEN** "Sort by" has Your order selected, and the graph's sort button reads "Your order"

#### Scenario: Picked and saved
- **WHEN** the user picks Newest first for "Sort by"
- **THEN** Newest first is selected, the graph's sort button reads "Newest", and the kv dump's settings hold the newest-first method next to the starting priority and place, with no "Sort by priority" field

#### Scenario: Survives a reload
- **WHEN** the user picks Your order and the plugin is reloaded
- **THEN** the settings page still shows Your order selected, and the graph lists the open objectives in the stored order

## MODIFIED Requirements

### Requirement: New objective defaults
The page SHALL let the user choose the priority new objectives start at, P0 to P3, P3 by default, and where they go in the custom order, top or bottom, top by default. Sorted by priority, that is the top or bottom of their priority; newest first, it comes first. Both SHALL apply to "＋ New objective", "Objectives: New objective" and "Objectives: New objective for this tab…", SHALL be stored with the objectives in the plugin's `kv.json`, and SHALL hold in every window and after a reload.

#### Scenario: Start at P1, at the bottom
- **WHEN** sorted in Your order, the user picks P1 and Bottom on the settings page, goes back to the graph and creates "Write slides" with "＋ New objective"
- **THEN** "Write slides" has a P1 badge and is the last open objective, and the kv dump holds priority 1 for it and the two settings

#### Scenario: Bottom of its priority
- **WHEN** sorted by priority, the list reads "Release" (P1) and "Fix login bug" (P3), and the user picks P1 and Bottom and creates "Write slides" with "＋ New objective"
- **THEN** the list reads "Release", "Write slides", "Fix login bug"

#### Scenario: First when sorted newest first
- **WHEN** sorted newest first, the list reads "Release" and "Fix login bug", and the user picks Bottom and creates "Write slides" with "＋ New objective"
- **THEN** the list reads "Write slides", "Release", "Fix login bug", and the kv dump holds "Write slides" last

#### Scenario: Defaults survive a reload
- **WHEN** the user picks P1 and Bottom and the plugin is reloaded
- **THEN** the settings page still shows P1 and Bottom selected

## REMOVED Requirements

### Requirement: Sort setting
**Reason**: The On/Off "Sort by priority" choice becomes a three-way "Sort by" choice, shared with the graph's sort button.
**Migration**: "Sort method" holds the choice; a store with "Sort by priority" off reads as Your order.
