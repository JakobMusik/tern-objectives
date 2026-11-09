# Spec Delta

## ADDED Requirements

### Requirement: Saved chats follow their tabs
A saved omp chat SHALL be removed once its pane is neither live in the window nor a row of a stored tab snapshot, for example after the user unlinks the last objective from the closed tab that held it, which drops the tab's snapshot.

#### Scenario: Unlinked with its tab
- **WHEN** a tab holding an omp chat with a saved chat file, linked only to open objective Y, is closed, and the user selects Y and clicks "× Unlink" on the closed tab
- **THEN** once the graph has redrawn, the kv dump holds neither the tab's snapshot nor the pane's saved chat

## REMOVED Requirements

### Requirement: Saved sessions follow their tabs
**Reason**: Its example and scenario relied on "Prune closed tabs", which this change removes; the same rule continues as "Saved chats follow their tabs".
**Migration**: None needed; unlinking a closed tab's last link removes its snapshot and saved chats as pruning did.
