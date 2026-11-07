## MODIFIED Requirements

### Requirement: Link status
Each linked tab the graph shows SHALL be shown in one of three states, worked out from the current window every time the graph draws and never stored:
- **live:** the window holds the tab;
- **closed:** the window does not hold it, and its snapshot came from this window;
- **elsewhere:** its snapshot came from another window.

#### Scenario: Reload is not a close
- **WHEN** the plugin is reloaded, as happens on every Tern restart, and the graph is reopened
- **THEN** every linked tab the window still holds is shown live, with its links intact

#### Scenario: Closing a tab
- **WHEN** the user closes a tab linked to an open objective
- **THEN** it is shown as closed, and its links are kept

#### Scenario: Tab from another window
- **WHEN** a linked tab's snapshot names a window key other than this window's
- **THEN** it is shown as elsewhere
