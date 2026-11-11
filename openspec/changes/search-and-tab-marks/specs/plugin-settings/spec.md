## MODIFIED Requirements

### Requirement: Shortcut rows
The page SHALL list the plugin's seven commands: Open graph, Rename selected objective, New objective, Search, Link this tab, New objective for this tab, and Configure. Each row SHALL show the keys in effect for the command, as symbols such as ⌃⌘O, or "none", and offer Change and Remove. A row whose keys differ from the plugin's default SHALL also offer Reset.

#### Scenario: Defaults
- **WHEN** no shortcut was changed and the user opens the settings page
- **THEN** Open graph shows ⌃⌘O, Rename selected objective ⌥⇧R, New objective ⌥N, Search ⌃⌥F, the other three "none", and no row offers Reset

#### Scenario: Rename moved to ⌥⇧R before this version
- **WHEN** the user's keybinds hold `alt+shift+r` for "Objectives: Rename selected objective" and an empty entry on `alt+r`, as a change in an earlier version's Configure left them, and the user opens the settings page
- **THEN** Rename selected objective shows ⌥⇧R alone and offers no Reset, and ⌥⇧R with an objective selected opens its Rename field

#### Scenario: Search key changed
- **WHEN** the user clicks Change on Search and enters `ctrl+alt+s`
- **THEN** the row shows ⌃⌥S and offers Reset, ⌃⌥S in a shell opens the search field, and ⌃⌥F no longer does
