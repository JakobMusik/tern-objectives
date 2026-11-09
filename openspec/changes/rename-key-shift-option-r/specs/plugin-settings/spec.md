## MODIFIED Requirements

### Requirement: Shortcut rows
The page SHALL list the plugin's six commands: Open graph, Rename selected objective, New objective, Link this tab, New objective for this tab, and Configure. Each row SHALL show the keys in effect for the command, as symbols such as ⌃⌘O, or "none", and offer Change and Remove. A row whose keys differ from the plugin's default SHALL also offer Reset.

#### Scenario: Defaults
- **WHEN** no shortcut was changed and the user opens the settings page
- **THEN** Open graph shows ⌃⌘O, Rename selected objective ⌥⇧R, New objective ⌥N, the other three "none", and no row offers Reset

#### Scenario: Rename moved to ⌥⇧R before this version
- **WHEN** the user's keybinds hold `alt+shift+r` for "Objectives: Rename selected objective" and an empty entry on `alt+r`, as a change in an earlier version's Configure left them, and the user opens the settings page
- **THEN** Rename selected objective shows ⌥⇧R alone and offers no Reset, and ⌥⇧R with an objective selected opens its Rename field

### Requirement: Removing and resetting a shortcut
Remove SHALL leave the command with no keys, and its keys SHALL go back to what they did without it. Reset SHALL give the command back exactly the plugin's default keys, or none for a command without a default. Both SHALL be saved in Tern's keybinds and take effect at once.

#### Scenario: Remove the rename key
- **WHEN** the user clicks Remove on Rename selected objective
- **THEN** the row shows "none" and offers Reset, and ⌥⇧R in a shell shows no toast

#### Scenario: Reset after a change
- **WHEN** New objective was changed to ⌃⌥N and the user clicks Reset on its row
- **THEN** the row shows ⌥N without Reset, Option+N in a shell opens the New objective field, and ⌃⌥N no longer does
