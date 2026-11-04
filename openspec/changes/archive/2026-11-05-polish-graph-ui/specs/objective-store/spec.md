# Spec Delta

## MODIFIED Requirements

### Requirement: Remembered view settings
The store SHALL keep the scope filter, the tag filter, whether the Done group is open, and which pane rows are folded. These settings SHALL be restored when the graph is reopened and after a plugin reload.

#### Scenario: Settings survive reload
- **WHEN** the user picks scope "This session", filters by tag "api", folds a pane row, and the plugin is reloaded
- **THEN** reopening the graph shows scope "This session", the "api" filter, that row folded and every other live row open

#### Scenario: Rows opened under 0.1.x
- **WHEN** `kv.json` holds view settings written by version 0.1.x, listing expanded rows, and the graph is opened
- **THEN** every live pane row is open, and after the next change to a view setting `kv.json` no longer holds the old expanded rows
