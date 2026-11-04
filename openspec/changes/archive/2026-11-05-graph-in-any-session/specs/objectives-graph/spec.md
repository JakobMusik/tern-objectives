# Spec Delta

## ADDED Requirements

### Requirement: Graph in any session
"Objectives: Open graph" SHALL show the graph as a canvas, Tern's built-in block filled from window Lua, in every session the window shows, on this machine or another. Nothing SHALL need installing on another machine, and the plugin SHALL define no block of its own. If a session's machine can't show a canvas, an error toast SHALL say so and nothing SHALL open.

#### Scenario: Canvas over the tab
- **WHEN** the user presses ⌃⌘O
- **THEN** the current tab shows a canvas owned by `objectives` with keyboard focus, and the plugin's data folder holds only `kv.json`

#### Scenario: Clicks in the canvas
- **WHEN** the graph is shown and the user selects an objective and clicks "＋ Link" on a tab node
- **THEN** the objective is selected and `kv.json` shows the new link

#### Scenario: Graph left by 0.3.0
- **WHEN** a 0.3.0 graph block is open while the plugin reloads as this version, and the user then presses ⌃⌘O
- **THEN** the block is gone and the canvas is shown

## REMOVED Requirements

### Requirement: Closing with Esc
**Reason**: The graph is a canvas in every session (user decision after 0.3.0), so there is one surface to build and check. A canvas takes no keys, and a plugin can't bind Esc, so Esc pressed inside the graph can't close it.
**Migration**: Press ⌃⌘O again, click outside the graph, or use its ×. Tern's own Esc closes the popup while its title bar has focus.
