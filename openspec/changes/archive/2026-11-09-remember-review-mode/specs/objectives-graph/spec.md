## MODIFIED Requirements

### Requirement: New objective key
"Objectives: New objective", default key ⌥N, SHALL ask for a title and create an objective as "＋ New objective" does, selected in the graph. It SHALL first end review mode. With the graph shown over the current tab, it SHALL act there, the settings page switching back to the graph. Anywhere else it SHALL first show the graph over the current tab. Like any plugin key, ⌥N SHALL run in every pane, whichever Option key is held.

#### Scenario: In the graph
- **WHEN** the graph is shown and the user presses ⌥N and enters "Write slides"
- **THEN** "Write slides" appears selected at the top of the list, and the kv dump holds it

#### Scenario: From a shell
- **WHEN** no graph is shown, focus is in a shell, and the user presses ⌥N and enters "Write slides"
- **THEN** the graph is shown over the current tab with "Write slides" selected, and the shell's prompt is unchanged

#### Scenario: Letters still reach the panes
- **WHEN** focus is in a shell prompt and the user types "n" and "N"
- **THEN** the prompt shows "nN", and no field or toast appears

#### Scenario: From review mode
- **WHEN** review mode lists two objectives and the user presses ⌥N and enters "Write slides"
- **THEN** the left column shows the open objectives with "Write slides" selected at the top, and the Done group, and "Review (2)" is not active

#### Scenario: From a shell after review mode
- **WHEN** the graph was closed in review mode listing two objectives, focus is in a shell, and the user presses ⌥N and enters "Write slides"
- **THEN** the graph is shown over the current tab with the open objectives, "Write slides" selected at the top, and "Review (2)" not active
