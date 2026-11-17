# plugin-settings Specification

## Purpose
Lets users configure the plugin from inside the graph: the keyboard shortcuts of its commands, saved through Tern's own keybinds, and the defaults new objectives start with.

## Requirements

### Requirement: Settings page
"Objectives: Configure" and a ⚙ button in the graph's header SHALL show a settings page in the graph, over the current tab, in place of the columns. It SHALL list the shortcuts, the new-objective defaults and the order setting, and offer "Back to graph", which shows the graph again. ⌃⌘O SHALL close it like the graph, and the next open SHALL show the graph. Fields opened from the page SHALL bring the page back when they close.

#### Scenario: From the header
- **WHEN** the graph is shown and the user clicks ⚙
- **THEN** the graph shows the settings page with a "Shortcuts" section, a "New objectives" section and an "Order" section, and no objective or tab nodes

#### Scenario: From the palette
- **WHEN** no graph is shown and the user runs "Objectives: Configure"
- **THEN** the settings page is shown over the current tab

#### Scenario: Back to graph
- **WHEN** the settings page is shown and the user clicks "Back to graph"
- **THEN** the graph's columns are shown again with the same selection as before

#### Scenario: Next open shows the graph
- **WHEN** the settings page is shown and the user presses ⌃⌘O twice
- **THEN** the first press closes it, and the second shows the graph's columns

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

### Requirement: Changing a shortcut
Change SHALL open a one-line field, filled with the command's current keys spelled as in Tern's keybinds, such as `alt+n`. A shortcut entered there SHALL become the command's only keys: its earlier keys, the plugin's default among them, SHALL stop running it and go back to what they did without it. The change SHALL be saved in Tern's keybinds, take effect at once, and be shown on the page and in the palette. Dismissing the field SHALL change nothing.

#### Scenario: New key for New objective
- **WHEN** the user clicks Change on New objective and enters `ctrl+alt+n`
- **THEN** the row shows ⌃⌥N, the palette lists "Objectives: New objective" with ⌃⌥N, ⌃⌥N in a shell opens the New objective field, and Option+N no longer does

#### Scenario: Key for a command without one
- **WHEN** the user clicks Change on Link this tab and enters `ctrl+alt+l`
- **THEN** the row shows ⌃⌥L, and ⌃⌥L in a shell opens the "Link this tab" picker

#### Scenario: Field dismissed
- **WHEN** the user clicks Change on Open graph and dismisses the field
- **THEN** the row still shows ⌃⌘O, and ⌃⌘O still closes and opens the graph

### Requirement: Refused shortcuts
A shortcut SHALL be refused with an error toast, changing nothing, when it doesn't parse as a Tern chord, when it lacks ⌃, ⌥ or ⌘ (function keys excepted), or when something other than that command already runs on those keys. The toast SHALL name what already uses them.

#### Scenario: Taken by Tern
- **WHEN** the user enters `cmd+t` as Open graph's shortcut
- **THEN** an error toast says ⌘T is already in use, the row still shows ⌃⌘O, and ⌘T still opens a new tab

#### Scenario: No modifier
- **WHEN** the user enters `n` as New objective's shortcut
- **THEN** an error toast says a shortcut needs ⌃, ⌥ or ⌘, and the row still shows ⌥N

#### Scenario: Not a chord
- **WHEN** the user enters `alt+` as New objective's shortcut
- **THEN** an error toast says it isn't a shortcut, and the row still shows ⌥N

### Requirement: Removing and resetting a shortcut
Remove SHALL leave the command with no keys, and its keys SHALL go back to what they did without it. Reset SHALL give the command back exactly the plugin's default keys, or none for a command without a default. Both SHALL be saved in Tern's keybinds and take effect at once.

#### Scenario: Remove the rename key
- **WHEN** the user clicks Remove on Rename selected objective
- **THEN** the row shows "none" and offers Reset, and ⌥⇧R in a shell shows no toast

#### Scenario: Reset after a change
- **WHEN** New objective was changed to ⌃⌥N and the user clicks Reset on its row
- **THEN** the row shows ⌥N without Reset, Option+N in a shell opens the New objective field, and ⌃⌥N no longer does

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
